`timescale 1ns / 1ps

module huffman #(
    parameter DATA_WIDTH = 8,
    parameter FREQ_WIDTH = 8
)(
    input                                           clk,
    input                                           rst,
    input                                           input_start_i,
    input                                           input_end_i,
    input [FREQ_WIDTH - 1: 0]                       data_in,
    output reg                                      ack,
    output [SORT_WIDTH + $clog2(NODE_SIZE) - 1: 0]   symbol_o,
    output wire                                     output_start_o,
    output wire                                     output_end_o
);
    // 状态机状态
    localparam IDLE = 0;
    localparam INPUT = 1;
    localparam SORT_INPUT = 2;
    localparam SORT_SORT = 3;
    localparam SORT_OUTPUT = 4;
    localparam BUILD = 5;
    localparam TRAVERSE = 6;
    localparam OUTPUT = 7;


    localparam NUM_WIDTH = DATA_WIDTH + 1;
    localparam NODE_WIDTH = FREQ_WIDTH + 2 * NUM_WIDTH + 1;
    localparam SORT_WIDTH = NUM_WIDTH + FREQ_WIDTH;
    localparam DATA_SIZE =  1 << DATA_WIDTH;
    localparam SORT_SIZE =  SORT_WIDTH * DATA_SIZE; 
    localparam NODE_SIZE = 1 << NUM_WIDTH;

    localparam ROOT_NODE = 2 * (DATA_SIZE - 1);

    // 状态机
    reg [2: 0] state;
    reg [NUM_WIDTH - 1: 0] phase;
    reg [NUM_WIDTH - 1: 0] sort_phase;
    reg [NUM_WIDTH - 1: 0] sort_out_phase;

    reg build_done;
    reg traverse_done;
    reg output_done;

    // huffman tree
    reg [NUM_WIDTH - 1: 0] huffman_tree_parent [0: NODE_SIZE - 1];

    reg [SORT_WIDTH - 1: 0] sorted_freq [0: DATA_SIZE - 1];

    reg [NUM_WIDTH - 1: 0] sort_count;

    // sort array
    /*
    ************************************
    |     number      |    frequency     |
    |  DATA_WIDTH + 1 |    FREQ_WIDTH    |
    *************************************
    */
    wire [SORT_WIDTH - 1: 0] sort_res;
    reg [SORT_SIZE - 1: 0] sort_in; 

    reg [SORT_WIDTH - 1: 0] sorted_num [0: DATA_SIZE - 1];
    // 排序后的数组, 便于调试和赋值
    wire [NUM_WIDTH - 1: 0] sort_num [0: DATA_SIZE - 1];
    wire [FREQ_WIDTH - 1: 0] sort_freq [0: DATA_SIZE - 1];

    // // 排序后对于子树节点进行合并的数组
    wire [NUM_WIDTH - 1: 0] fixed_sort_num [0: DATA_SIZE - 1];
    wire [FREQ_WIDTH - 1: 0] fixed_sort_freq [0: DATA_SIZE - 1];

    wire [NUM_WIDTH - 1: 0] merge_sort_num;
    wire [FREQ_WIDTH - 1: 0] merge_sort_freq;


    genvar a;
    genvar b;
    generate 
        for(a = 0; a < DATA_SIZE; a = a + 1) begin 
            assign sort_num[a] = (rst == 1'b1) ? sorted_num[a][FREQ_WIDTH +: NUM_WIDTH]: 0;
            assign sort_freq[a] = (rst == 1'b1) ? sorted_num[a][0 +: FREQ_WIDTH]: 0;
        end
    endgenerate

    assign merge_sort_num = (rst == 1'b1) ? parent_number: 0;
    assign merge_sort_freq = (rst == 1'b1) ? sort_freq[0] + sort_freq[1]: 0;

    assign fixed_sort_num[0] = (rst == 1'b1) ? merge_sort_num: 0;
    assign fixed_sort_freq[0] = (rst == 1'b1) ? merge_sort_freq: 0;
    assign fixed_sort_num[DATA_SIZE - 1] = (rst == 1'b1) ? (1 << NUM_WIDTH) - 1: 0;
    assign fixed_sort_freq[DATA_SIZE - 1] = (rst == 1'b1) ? (1 << FREQ_WIDTH) - 1: 0;

    generate 
        for(a = 1; a < DATA_SIZE - 1; a = a + 1) begin 
            assign fixed_sort_num[a] = (rst == 1'b1) ? sorted_num[a + 1][FREQ_WIDTH +: NUM_WIDTH]: 0;
            assign fixed_sort_freq[a] = (rst == 1'b1) ? sorted_num[a + 1][0 +: FREQ_WIDTH]: 0;
        end
    endgenerate

    always@(posedge clk) begin 
        if(~rst)begin 
            for(i = 0; i < DATA_SIZE; i = i + 1)begin 
                sorted_freq[i] = 0;
            end
        end else if(state == SORT_OUTPUT)begin 
            if(sort_count == 1 && !write_fin)begin 
                sorted_freq[sort_out_phase[DATA_WIDTH - 1: 0]] <= sort_res;
            end
        end else if(output_done)begin 
            for(i = 0; i < DATA_SIZE; i = i + 1)begin 
                sorted_freq[i] = 0;
            end
        end
    end


    always@(posedge clk) begin 
        if(~rst) begin 
            ack <= 1'b0;
        end else if(input_start_i) begin 
            ack <= 1'b1;
        end else begin 
            ack <= 1'b0;
        end
    end

    // 状态机, 时序逻辑
    always@(posedge clk) begin
        if(~rst) begin 
            state <= IDLE;
            sort_count <= 0;
        end else begin 
            case(state)
                IDLE:
                    if(input_start_i) begin
                        state <= INPUT;
                        phase <= 0;
                    end
                    else begin 
                        state <= IDLE;
                        phase <= 0;
                    end
                INPUT:
                    if(input_end_i) begin 
                        // state <= BUILD;
                        state <= SORT_INPUT;
                        phase <= 0;
                        sort_count <= sort_count + 1;
                    end else begin 
                        state <= INPUT;
                        phase <= phase + 1;
                        sort_phase <= 0;
                    end
                 SORT_INPUT:
                    if(read_fin) begin 
                        state <= SORT_SORT;
                        sort_phase <= 0;
                    end else begin 
                        state <= SORT_INPUT;
                        sort_phase <= sort_phase + 1;
                    end
                SORT_SORT:
                    if(sort_fin)begin 
                        state <= SORT_OUTPUT;
                        sort_phase <= 0;
                    end else begin 
                        state <= SORT_SORT;
                        sort_phase <= 0;
                    end
                SORT_OUTPUT:
                    if(write_fin)begin 
                        state <= BUILD;
                        sort_phase <= 0;
                    end else begin 
                        state <= SORT_OUTPUT;
                        sort_phase <= 0;
                    end
                BUILD:
                    if(build_done) begin 
                        phase <= 0;
                        state <= TRAVERSE;
                    end else begin 
                        phase <= phase + 1;
                        sort_phase <= 0;
                        state <= SORT_INPUT;
                        sort_count <= sort_count + 1;
                    end
                TRAVERSE: begin 
                    if(traverse_done)begin 
                        phase <= 0;
                        state <= OUTPUT;
                    end else begin 
                        phase <= phase + 1;
                        state <= TRAVERSE;
                    end
                end
                OUTPUT: begin 
                    if(output_done)begin 
                        phase <= 0;
                        state <= IDLE;
                        sort_count <= 0;
                    end else begin
                        phase <= phase + 1;
                        state <= OUTPUT;
                    end
                end
            endcase
        end
    end

    integer i;
    integer j;


    always@(*) begin
        if(~rst) begin 
            sort_in = 'b0;
            build_done = 1'b0;
        end else if(state == INPUT)begin 
            if(phase <= DATA_SIZE - 1 && !input_end_i)begin 
                sort_in[phase * SORT_WIDTH +: SORT_WIDTH] = {phase, data_in};
            end else begin 
            end
        end else if(state == BUILD) begin 
            if(phase <= DATA_SIZE - 1) begin 
                for(i = 0; i < DATA_SIZE; i = i + 1)begin
                    sort_in[i * SORT_WIDTH +: SORT_WIDTH] = {fixed_sort_num[i], fixed_sort_freq[i]};
                end
                build_done = 1'b0;
            end else begin 
                build_done = 1'b1;
            end
        end else begin 
            build_done = 1'b0;
        end
    end

    wire [NUM_WIDTH - 1: 0] parent_number;
    assign parent_number = phase + DATA_SIZE;

    // 建树过程
    always @(posedge clk) begin
        if(~rst)begin 
            for(i = 0; i < NODE_SIZE; i = i + 1) begin 
                huffman_tree_parent[i] = 0;
            end
        end else if(state == BUILD) begin 
            huffman_tree_parent[sort_num[0]] <= parent_number;
            huffman_tree_parent[sort_num[1]] <= parent_number;
        end
    end

    always@(posedge clk)begin 
        if(~rst)begin 
            for(i = 0; i < DATA_SIZE; i = i + 1)begin 
                sorted_num[i] = 0;
            end 
            sort_out_phase <= 0;
        end else if(state == SORT_OUTPUT)begin
            sort_out_phase <= sort_out_phase + 1;
            if(sort_out_phase <= DATA_SIZE - 1)begin 
                sorted_num[sort_out_phase[DATA_WIDTH - 1: 0]] <= sort_res; 
            end
        end else begin 
            sort_out_phase <= 0;
        end
    end

    // 编码过程
    reg [$clog2(NODE_SIZE) - 1: 0] encode_len [0: DATA_SIZE - 1];
    reg [NUM_WIDTH - 1: 0]  parent_nodes [0: DATA_SIZE - 1];
    always@(posedge clk) begin 
        if(~rst) begin 
            for(i = 0; i < DATA_SIZE; i = i + 1) begin 
                encode_len[i] = 0;
                parent_nodes[i] = i[NUM_WIDTH - 1: 0];
            end
            traverse_done <= 1'b0;
        end else if(state == TRAVERSE) begin 
            if(phase <= DATA_SIZE - 1)begin 
                for(i = 0; i < DATA_SIZE; i = i + 1)begin 
                    if(parent_nodes[i] != ROOT_NODE) begin 
                        encode_len[i] = encode_len[i] + 1;
                        // 更新下一个节点
                        parent_nodes[i] = huffman_tree_parent[parent_nodes[i]];
                    end
                end
                traverse_done <= 1'b0;
            end else begin 
                traverse_done <= 1'b1;
            end
        end else begin 
            traverse_done <= 1'b0;
        end
    end
    

    wire en;
    wire read_fin;
    wire write_fin;
    wire sort_fin;

    assign en = (state == SORT_INPUT | state == SORT_SORT | state == SORT_OUTPUT) ? 1'b1: 1'b0;
    parallel_sort #( 
        .length(NUM_WIDTH + FREQ_WIDTH),
        .width(NUM_WIDTH),
        .num(DATA_SIZE),
        .offset(FREQ_WIDTH)
    ) parallel_sort( 
        .clk(clk),
        .rst(rst),
        .datain(sort_in[sort_phase * SORT_WIDTH +: SORT_WIDTH]),
        .en(en),
        .dataout(sort_res),
        .over(sort_fin),
        .read_finish(read_fin),
        .write_fin_o(write_fin)
    );

    always@(*)begin 
        if(~rst)begin 
            output_done = 0;
        end else if(state == OUTPUT)begin 
            if(phase == DATA_SIZE - 1) output_done = 1'b1;
            else begin 
            end
        end else begin 
            output_done = 1'b0;
        end
    end

    // assign encode_len_o = (state == OUTPUT) ? encode_len[phase[DATA_WIDTH - 1: 0]]: 0;
    // assign encode_len_o = (state == OUTPUT) ? {sorted_freq[DATA_SIZE - phase[DATA_WIDTH - 1: 0] - 1], encode_len[sorted_freq[DATA_SIZE - phase[DATA_WIDTH - 1: 0] - 1][FREQ_WIDTH +: NUM_WIDTH]]}: 0;
    assign symbol_o = (state == OUTPUT) ? {sorted_freq[DATA_SIZE - phase[DATA_WIDTH - 1: 0] - 1], encode_len[sorted_freq[DATA_SIZE - phase[DATA_WIDTH - 1: 0] - 1][FREQ_WIDTH +: DATA_WIDTH]]}: 0;
    assign output_start_o = (state == OUTPUT && phase == 0) ? 1'b1: 1'b0;
    assign output_end_o = (state == OUTPUT && output_done) ? 1'b1: 1'b0; 


endmodule