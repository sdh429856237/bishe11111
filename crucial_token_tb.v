`timescale 1ns / 1ps

module crucial_token_tb();
    parameter dimen = 16;
    parameter binary_width = 4;
    parameter index_width = 4;
    //parameter num_log = 7;
    reg RESET;
    reg CLK;
    reg EN;
    reg [31 : 0] sort_res;
    reg [15 : 0] sort_index;
    wire read_finish;
    wire [binary_width : 0] binary_addr;
    wire binary_cen;
    wire binary_wen;
    wire binary_ren;
    reg [15 : 0] binary_row;
    wire [index_width : 0] token;
    wire valid;
    wire find_finish;        
    
    reg [binary_width : 0] baddr;
    reg bcen;
    reg bwen;
    reg bren;
    reg [15 : 0] D;
    wire [15 : 0] Q;
    
    always #50 binary_row = Q;
    
    binary_map_buffer #(.dimen(dimen), .width(binary_width)) map0(
        .Q(Q),
        .CLK(CLK),
        .CEN(((bren == 1) ? bcen : binary_cen)),
        .WEN(((bren == 1) ? bwen : binary_wen)),
        .A(((bren == 1) ? baddr : binary_addr)),
        .RESET(RESET),
        .D(D),
        .RETN(bren | binary_ren)
    );    
    
    
    
    crucial_token #(.dimen(dimen), .binary_width(binary_width), .index_width(index_width))crucial_token0(
        .CLK(CLK),
        .RESET(RESET),
        .EN(EN),
        .sort_res(sort_res),
        .sort_index(sort_index),
        .read_finish(read_finish),
        .binary_addr(binary_addr),
        .binary_cen(binary_cen),
        .binary_wen(binary_wen),
        .binary_ren(binary_ren),
        .binary_row(binary_row),
        //.W_EN(W_EN),
        // .....
        //.in_sum(in_sum),
        .token(token),
        .valid(valid),
        .find_finish(find_finish)
    );
    initial begin
        RESET = 0;
        CLK = 1;
        EN = 0;
        #100 RESET = 1;
        bren = 1;
        bwen = 0;
        bcen = 1;
        baddr = 0;
        D = 16'b0010010000000010;
        #100
        baddr = 1;
        D = 16'b0000011000100000;
        //datain = 8;
        #100
        baddr = 2;
        D = 16'b0000000100000000;
        //datain = 148;
        #100
        baddr = 3;
        D = 16'b0001110000010110;
        //datain = 981;
        #100
        baddr = 4;
        D = 16'b0000000000000000;
        #100
        baddr = 5;
        D = 16'b0000010000110000;
        //datain = 64;
        #100
        baddr = 6;
        D = 16'b0000000000000100;
        //datain = 1024;
        #100
        baddr = 7;
        D = 16'b0000001000000010;
        #100
        baddr = 8;
        D = 16'b0000000100000000;
        #100
        baddr = 9;
        D = 16'b0000000000010000;
        #100
        baddr = 10;
        D = 16'b0010000000100100;
        #100
        baddr = 11;
        D = 16'b0000010000000000;
        #100
        baddr = 12;
        D = 16'b0000100000000100;
        #100
        baddr = 13;
        D = 16'b0010000000110000;
        #100
        baddr = 14;
        D = 16'b0000010000001010;
        #100
        baddr = 15;
        D = 16'b0000000100001000;
        #100
        bren = 0;
        bwen = 1;
        bcen = 1;
        EN = 1;
        sort_res = 6;
        sort_index = 4;
        //datain = 8;
        #100
        sort_res = 3;
        sort_index = 1;
        #100
        sort_res = 3;
        sort_index = 2;
        #100
        sort_res = 3;
        sort_index = 6;
        #100
        sort_res = 3;
        sort_index = 11;
        #100
        sort_res = 3;
        sort_index = 14;
        #100
        sort_res = 3;
        sort_index = 15;
        #100
        sort_res = 2;
        sort_index = 8;
        #100
        sort_res = 2;
        sort_index = 13;
        #100
        sort_res = 2;
        sort_index = 16;
        #100
        sort_res = 1;
        sort_index = 3;
        #100
        sort_res = 1;
        sort_index = 7;
        #100
        sort_res = 1;
        sort_index = 9;
        #100
        sort_res = 1;
        sort_index = 10;
        #100
        sort_res = 1;
        sort_index = 12;
        #100
        sort_res = 0;
        sort_index = 5;
        //datain = 77;
        /*
        SELECTOR = 1;
        W_EN = 1;
        in_sum = 0;
        #100 RESET = 0;
        //权重初始化
        #50 
        in_weight_above[7:0]<=3;
        in_weight_above[15:8]<=4;
        // in_weight_above[23:16]<=5;
        // in_weight_above[31:24]<=6;
        #100
        in_weight_above[7:0]<=1;
        in_weight_above[15:8]<=2;
        #100
        SELECTOR=0;
        in_weight_above[7:0]<=5;
        in_weight_above[15:8]<=6;
        // in_sum[15:0]<=1;
        // in_sum[31:16]<=2;
        // in_sum[47:32]<=3;
        // in_sum[63:48]<=4;
        active_left[7:0]<=1;
        #100
        active_left[7:0]<=2;
        active_left[15:8]<=3;
        in_weight_above[7:0]<=7;
        in_weight_above[15:8]<=8;
        #100
        W_EN = 0;
        active_left[7:0]<=0;
        active_left[15:8]<=4;
        #100
        active_left[15:8]<=0;
        // active_left[23:16]<=5;
        // active_left[31:24]<=6;
        // #100
        // active_left[7:0]<=4;
        // active_left[15:8]<=5;
        // active_left[23:16]<=6;
        // active_left[31:24]<=7;
        // #100
        // active_left[7:0]<=5;
        // active_left[15:8]<=6;
        // active_left[23:16]<=7;
        // active_left[31:24]<=8;
        // #100
        // active_left[7:0]<=6;
        // active_left[15:8]<=7;
        // active_left[23:16]<=8;
        // active_left[31:24]<=9;
        */
    end

    always #50 CLK = ~CLK;
endmodule