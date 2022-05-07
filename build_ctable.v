`timescale 1ns / 1ps

module build_ctable#(
    DATA_WIDTH = 8
)(
    input                                        clk,
    input                                        rst,
    input                                        input_start_i,
    input                                        input_end_i,
    input [3: 0]                                 encode_len_i,
    output wire [DATA_WIDTH - 1: 0]              max_num_o,
    output wire [DATA_WIDTH - 1: 0]              max_bits_o,
    output reg [DATA_WIDTH - 1: 0]               encode_o,
    output wire                                  output_start_o,
    output wire                                  output_end_o                      
);
    localparam NUM_WIDTH = DATA_WIDTH + 1;
    localparam NODE_SIZE = 1 << NUM_WIDTH;
    localparam DATA_SIZE = 1 << DATA_WIDTH;

    localparam IDLE = 0;
    localparam INPUT = 1;
    localparam FETCH = 2;
    localparam WORKING = 3;
    localparam ENCODING = 4;

    reg [3: 0] nbits [0: NODE_SIZE - 1];
    reg [DATA_WIDTH - 1: 0] vals_per_rank [0: DATA_SIZE - 1];
    reg [DATA_WIDTH - 1: 0] max_bits;
    reg [DATA_WIDTH - 1: 0] max_num;
    reg [2: 0] state;
    reg [DATA_WIDTH - 1: 0] phase;
    reg [DATA_WIDTH - 1: 0] min;

    reg working_done;
    reg encoding_done;
    reg fetch_done;
    reg input_done;
    // wire [NUM_WIDTH - 1: 0] encode_len [0: DATA_SIZE - 1];

    reg [3: 0] encode_len [0: DATA_SIZE - 1];
    integer x;

    
    // generate
    //     for(i = 0; i < DATA_SIZE; i = i + 1) begin 
    //         assign encode_len[i] = (rst) ? encode_len_i[i * NUM_WIDTH +: NUM_WIDTH]: 0;
    //     end
    // endgenerate


    always @(posedge clk) begin
        if(~rst) begin 
            state <= IDLE;
            phase <= 0;
        end else begin 
            case(state)
                IDLE:
                    if(input_start_i) begin 
                        state <= INPUT;
                        phase <= 0;
                    end else begin 
                        state <= IDLE;
                        phase <= 0;
                    end
                INPUT:
                    if(input_end_i) begin 
                        state <= FETCH;
                        phase <= 0;
                    end else begin 
                        state <= INPUT;
                        phase <= phase + 1;
                    end
                FETCH:
                    if(fetch_done)begin
                        state <= WORKING;
                        phase <= 0; 
                    end else begin 
                        state <= FETCH;
                        phase <= phase + 1;
                    end
                WORKING:
                    if(working_done) begin 
                        state <= ENCODING;
                        phase <= 0;
                    end else begin 
                        state <= WORKING;
                        phase <= phase + 1;
                    end
                ENCODING:
                    if(encoding_done) begin 
                        state <= IDLE;
                        phase <= 0;
                    end else begin 
                        state <= ENCODING;
                        phase <= phase + 1;
                    end
                // OUTPUT: begin 
                //     if(output_done) begin 
                //         state <= IDLE;
                //         phase <= 0;
                //     end else begin 
                //         state <= OUTPUT;
                //         phase <= phase + 1;
                //     end
                // end
            endcase
        end
    end

    always@(posedge clk) begin 
        if(~rst)begin 
            for(x = 0; x < DATA_SIZE; x = x + 1)begin 
                encode_len[x] = 0;
            end
            input_done <= 0;
        end else if(state == INPUT) begin 
            if(phase <= DATA_SIZE - 1 && !input_end_i) begin 
                encode_len[phase] <= encode_len_i;
                // input_done <= 0;
            end else begin 
                // input_done <= 1;
            end
        end
    end


    always@(*)begin 
        if(~rst) begin 
            max_bits = 0;
        end else if(fetch_done) begin 
            for(x = DATA_SIZE - 1; x >= 0; x = x - 1)begin 
                if(nbits[x] > 0 && max_bits == 0) begin 
                    max_bits = x[DATA_WIDTH - 1: 0];
                end else begin 
                    // max_bits = max_bits;
                end
            end
        end else begin 
            // max_bits = max_bits;
        end
    end

    always@(*)begin 
        if(~rst) begin 
            max_num = 0;
        end else if(fetch_done) begin 
            for(x = DATA_SIZE - 1; x >= 0; x = x - 1)begin 
                if(encode_len[x] > 0 && max_num == 0) begin 
                    max_num = x[DATA_WIDTH - 1: 0];
                end else begin 
                    // max_num = max_num;
                end
            end
        end else begin 
            // max_num = max_num;
        end
    end

    always@(posedge clk)begin 
        if(~rst) begin 
            fetch_done <= 1'b0;
            for(x = 0; x < NODE_SIZE; x = x + 1)begin
                nbits[x] = 0; 
            end 
        end else if(state == FETCH) begin 
            if(phase < DATA_SIZE) begin 
                nbits[encode_len[phase[DATA_WIDTH - 1: 0]]] = nbits[encode_len[phase[DATA_WIDTH - 1: 0]]] + 1;
            end else begin 
                fetch_done <= 1'b1;
            end
        end else begin 
            fetch_done <= 1'b0;
        end
    end

    wire [DATA_WIDTH - 1: 0] n;
    assign n = (state == WORKING) ? max_bits - phase[DATA_WIDTH - 1: 0]: 0;

    always@(posedge clk)begin 
        if(~rst) begin 
            working_done <= 1'b0;
            min <= 0;
            for(x = 0; x < NODE_SIZE; x = x + 1) begin 
                vals_per_rank[x] = 0;
            end
        end else if(state == WORKING) begin 
            if(phase == 0)begin 
                vals_per_rank[max_bits] <= 0;
                if(min == 0)begin 
                    min <= (min + nbits[n]) >> 1;
                end
            end else if(max_bits > phase[DATA_WIDTH - 1: 0]) begin 
                vals_per_rank[n] <= min;
                min <= (min + nbits[n]) >> 1;
            end else begin 
                working_done <= 1'b1;
            end
        end else begin 
            working_done <= 1'b0;
        end
    end

    always@(posedge clk)begin 
        if(~rst) begin 
            encode_o <= 0;
            encoding_done <= 1'b0;
        end else if(state == ENCODING) begin 
            if(phase <= max_num) begin 
                 encode_o <= vals_per_rank[encode_len[phase]];
                 vals_per_rank[encode_len[phase][DATA_WIDTH - 1: 0]] <= vals_per_rank[encode_len[phase]] + 1;
            end else begin 
                encoding_done <= 1'b1;
            end
        end else begin 
            encoding_done <= 1'b0;
        end
    end

    assign max_bits_o = (state == ENCODING) ? max_bits: 0;
    assign max_num_o = (state == ENCODING) ? max_num: 0;


    assign output_start_o = (state == ENCODING && phase == 0) ? 1'b1: 1'b0;
    assign output_end_o = (state == ENCODING && encoding_done) ? 1'b1: 1'b0; 


endmodule