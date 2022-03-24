`timescale 1ns / 1ps

module bubble_sort_tb();
    parameter length = 32;
    parameter width = 16;
    parameter num = 8;
    parameter num_log = 7;
    reg RESET;
    reg CLK;
    reg [length - 1 : 0] datain;
    reg EN;            
    wire [length - 1 : 0] dataout;
    wire [width - 1 : 0] index;
    wire over;
    wire read_finish;
                  // enable signal for the accelerator; high for active
    //reg SELECTOR;                    // weight select read or use
    //reg W_EN;                         // enable weight to flow
    //reg [num1*8-1:0]active_left;
    //reg [num2*16-1:0]in_sum;
    //reg [num2*8-1:0]in_weight_above;
    //wire [num2*16-1:0]out_sum;
    //wire [7:0]active_right;
    //wire [num2*8-1:0]out_weight_below;
    bubble_sort #(.length(length), .width(width), .num(num), .num_log(num_log))bubble_sort0(
        .clk(CLK),
        .rst(RESET),
        .en(EN),
        .datain(datain),
        //.W_EN(W_EN),
        // .....
        .dataout(dataout),
        //.in_sum(in_sum),
        .index(index),
        .over(over),
        .read_finish(read_finish)
    );
    initial begin
        RESET = 0;
        CLK = 1;
        EN = 0;
        #100 RESET = 1;
        EN = 1;
        datain = 0;
        #100
        datain = 8;
        #100
        datain = 148;
        #100
        datain = 981;
        #100
        datain = 64;
        #100
        datain = 1024;
        #100
        datain = 8;
        #100
        datain = 77;
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