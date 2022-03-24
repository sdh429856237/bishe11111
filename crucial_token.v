`timescale 1ns / 1ps

module crucial_token#(dimen = 1024, binary_width = 16, index_width = 10)(
    input  wire         CLK,                         
    input  wire         RESET,                      
    input  wire         EN,
    
    input  wire [31 : 0] sort_res,
    input  wire [15 : 0] sort_index,
    output reg           read_finish,
    
    output reg  [binary_width : 0] binary_addr,
    output reg           binary_cen,
    output reg           binary_wen,
    output reg           binary_ren,
    input  wire [15 : 0] binary_row,//T1, T1放在下标最小的位置
    
    output reg  [index_width : 0] token,
    output reg          valid,
    output reg          find_finish
    );
    
    reg [dimen * 32 - 1 : 0] result_buffer;
    reg [dimen * 16 - 1 : 0] index_buffer;
    reg [(dimen / 2) * 16 - 1 : 0] non_crucial_buffer;
    reg [10 : 0] cnt1, cnt2, cnt3, index;
    reg [dimen - 1 : 0] binary_map_row;
    reg [index_width : 0] i, j, r;
    
    reg [3 : 0] state;
    localparam IDLE = 6'd0;      
    localparam INPUTSR = 6'd1;    
    localparam INPUTBR1 = 6'd2;
    localparam INPUTBR2 = 6'd3;
    localparam CALCULATE = 6'd4;
    localparam UPDATE = 6'd5;
    //parameter OUTPUT = 6'd6;
    localparam RETURN = 6'd6;
    localparam tmp = 6'd7;///////////////////////
    
    integer k;
    always @(posedge CLK or negedge RESET) begin
        if(~RESET) begin
            state <= IDLE;
            //sort_ren <= 0;
            //sort_wen <= 1;
            //sort_cen <= 1;
            //sort_addr <= 0;
            binary_ren <= 0;
            binary_wen <= 1;
            binary_cen <= 1;
            binary_addr <= 0;
            result_buffer <= 0;
            index_buffer <= 0;
            non_crucial_buffer <= 0;
            cnt1 <= 0;
            cnt2 <= 0;
            cnt3 <= 0;
            index <= 0;
            //pos <= 0;
            token <= 0;
            valid <= 0;
            binary_map_row <= 0;
            read_finish <= 0;
            find_finish <= 0;
            i <= 0;
            j <= 0;
            k = 0;
            r <= 0;
        end
        else if(EN) begin
            if(state == IDLE) begin
                state <= INPUTSR;
                //sort_wen <= 1;
                //sort_cen <= 0;
                //sort_ren <= 1;
                //sort_addr <= 0;
                result_buffer <= result_buffer | ({1'b0, sort_res} << 32 * cnt1);
                index_buffer <= index_buffer | ({1'b0, 1'b1, sort_index[14:0]} << 16 * cnt1);
                cnt1 <= cnt1 + 1;
                //i <= 0;
            end
            else if(state == INPUTSR) begin
                //sort_addr <= sort_addr + 1;
                //i = i + 1;
                if(cnt1 == dimen) begin
                    state <= CALCULATE;
                    read_finish <= 1;
                    cnt1 <= 0;
                end
                else begin
                    result_buffer <= result_buffer | ({1'b0, sort_res} << 32 * cnt1);
                    index_buffer <= index_buffer | ({1'b0, 1'b1, sort_index[14:0]} << 16 * cnt1);
                    cnt1 <= cnt1 + 1;
                end
            end
            else if(state == CALCULATE) begin
                read_finish <= 0;
                if(cnt2 == dimen) begin
                    find_finish <= 1;
                    state <= RETURN;
                    cnt2 <= 0;
                end
                //for(i = cnt2; i < dimen; i = i + 1) begin
                    else if(index_buffer[cnt2 * 16 + 15] == 1'b1) begin
                    //if(index_buffer[dimen * 16 - 1 - i * 16] == 1'b1) begin
                        //state <= INPUTBR1;//////////////////////////////
                        state <= tmp; 
                        binary_wen <= 1;
                        binary_cen <= 0;
                        binary_ren <= 1;
                        binary_addr <= {1'b0, index_buffer[cnt2 * 16 + 14], index_buffer[cnt2 * 16 + 13], index_buffer[cnt2 * 16 + 12], index_buffer[cnt2 * 16 + 11], index_buffer[cnt2 * 16 + 10], index_buffer[cnt2 * 16 + 9], index_buffer[cnt2 * 16 + 8], index_buffer[cnt2 * 16 + 7], index_buffer[cnt2 * 16 + 6], index_buffer[cnt2 * 16 + 5], index_buffer[cnt2 * 16 + 4], index_buffer[cnt2 * 16 + 3], index_buffer[cnt2 * 16 + 2], index_buffer[cnt2 * 16 + 1], index_buffer[cnt2 * 16]} - 1;
                        cnt2 <= cnt2 + 1;
                        token <= {1'b0, index_buffer[cnt2 * 16 + 14], index_buffer[cnt2 * 16 + 13], index_buffer[cnt2 * 16 + 12], index_buffer[cnt2 * 16 + 11], index_buffer[cnt2 * 16 + 10], index_buffer[cnt2 * 16 + 9], index_buffer[cnt2 * 16 + 8], index_buffer[cnt2 * 16 + 7], index_buffer[cnt2 * 16 + 6], index_buffer[cnt2 * 16 + 5], index_buffer[cnt2 * 16 + 4], index_buffer[cnt2 * 16 + 3], index_buffer[cnt2 * 16 + 2], index_buffer[cnt2 * 16 + 1], index_buffer[cnt2 * 16]};
                        valid <= 1;
                        //cnt3 <= cnt3 + 1;
                    end
                    else begin
                        cnt2 <= cnt2 + 1;
                    end
                //end
                //if(cnt2 == dimen) begin
                //    find_finish <= 1;
                //    state <= RETURN;
                //end
            end
            else if(state == tmp) begin
                state <= INPUTBR1;
            end
            else if(state == INPUTBR1) begin
                valid <= 0;
                if(cnt3 == (dimen / 16)) begin
                    state <= INPUTBR2;
                    binary_wen <= 1;
                    binary_cen <= 1;
                    binary_ren <= 0;
                    cnt3 <= 0;
                end
                else begin
                    binary_map_row <= binary_map_row | ({1'b0, binary_row} << (cnt3 * 16));
                    cnt3 <= cnt3 + 1;
                    binary_addr <= binary_addr + dimen;
                end
                //binary_map_row <= binary_map_row | ({1'b0, binary_row} << (cnt3 * 16));
                //cnt3 <= cnt3 + 1;
                //state <= INPUTBR2;
            end
            else if(state == INPUTBR2) begin
                //valid <= 0; 
                //binary_map_row <= binary_row;
                //for(j = 0, r = 0; j < dimen; j = j + 1) begin
                if(j == dimen) begin
                    state <= UPDATE;
                    j <= 0;
                end
                else begin
                    if(binary_map_row[j] == 1) begin
                        {non_crucial_buffer[16*r+15], non_crucial_buffer[16*r+14], non_crucial_buffer[16*r+13], non_crucial_buffer[16*r+12], non_crucial_buffer[16*r+11], non_crucial_buffer[16*r+10], non_crucial_buffer[16*r+9], non_crucial_buffer[16*r+8], non_crucial_buffer[16*r+7], non_crucial_buffer[16*r+6], non_crucial_buffer[16*r+5], non_crucial_buffer[16*r+4], non_crucial_buffer[16*r+3], non_crucial_buffer[16*r+2], non_crucial_buffer[16*r+1], non_crucial_buffer[16*r]} <= j + 1;
                        r <= r + 1;
                    end
                    j <= j + 1;
                end
                //end
                //state <= UPDATE;
                //binary_wen <= 1;
                //binary_cen <= 1;
                //binary_ren <= 0;             
            end
            else if(state == UPDATE) begin
                //for(j = 0; j < dimen; j = j + 1) begin
                //    for(i = 0; i < r; i = i + 1) begin
                //        if({non_crucial_buffer[16*i+15], non_crucial_buffer[16*i+14], non_crucial_buffer[16*i+13], non_crucial_buffer[16*i+12], non_crucial_buffer[16*i+11], non_crucial_buffer[16*i+10], non_crucial_buffer[16*i+9], non_crucial_buffer[16*i+8], non_crucial_buffer[16*i+7], non_crucial_buffer[16*i+6], non_crucial_buffer[16*i+5], non_crucial_buffer[16*i+4], non_crucial_buffer[16*i+3], non_crucial_buffer[16*i+2], non_crucial_buffer[16*i+1], non_crucial_buffer[16*i]} == {1'b0, index_buffer[j * 16 + 14], index_buffer[j * 16 + 13], index_buffer[j * 16 + 12], index_buffer[j * 16 + 11], index_buffer[j * 16 + 10], index_buffer[j * 16 + 9], index_buffer[j * 16 + 8], index_buffer[j * 16 + 7], index_buffer[j * 16 + 6], index_buffer[j * 16 + 5], index_buffer[j * 16 + 4], index_buffer[j * 16 + 3], index_buffer[j * 16 + 2], index_buffer[j * 16 + 1], index_buffer[j * 16]}) begin
                //            index_buffer[j * 16 + 15] <= 0; 
                //        end
                //    end
                //end
                if(j < dimen) begin
                    if(i < r) begin
                        if({non_crucial_buffer[16*i+15], non_crucial_buffer[16*i+14], non_crucial_buffer[16*i+13], non_crucial_buffer[16*i+12], non_crucial_buffer[16*i+11], non_crucial_buffer[16*i+10], non_crucial_buffer[16*i+9], non_crucial_buffer[16*i+8], non_crucial_buffer[16*i+7], non_crucial_buffer[16*i+6], non_crucial_buffer[16*i+5], non_crucial_buffer[16*i+4], non_crucial_buffer[16*i+3], non_crucial_buffer[16*i+2], non_crucial_buffer[16*i+1], non_crucial_buffer[16*i]} == {1'b0, index_buffer[j * 16 + 14], index_buffer[j * 16 + 13], index_buffer[j * 16 + 12], index_buffer[j * 16 + 11], index_buffer[j * 16 + 10], index_buffer[j * 16 + 9], index_buffer[j * 16 + 8], index_buffer[j * 16 + 7], index_buffer[j * 16 + 6], index_buffer[j * 16 + 5], index_buffer[j * 16 + 4], index_buffer[j * 16 + 3], index_buffer[j * 16 + 2], index_buffer[j * 16 + 1], index_buffer[j * 16]}) begin
                            index_buffer[j * 16 + 15] <= 0; 
                        end
                        i <= i + 1;
                    end
                    else begin
                        i <= 0;
                        j <= j + 1;
                    end
                end
                else begin
                    i <= 0;
                    j <= 0;
                    r <= 0;
                    state <= CALCULATE;
                end
                //state <= CALCULATE;
            end
            else if(state == RETURN) begin
                state <= IDLE;
                find_finish <= 0;
            end
            else begin
                state <= IDLE;
            end
        end
    end
    
endmodule
