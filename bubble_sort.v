`timescale 1ns / 1ps

module bubble_sort #(
    parameter length = 32, 
    parameter width = 16, 
    parameter num = 1024,
    parameter num_log = 1023)
    (
    input wire                  clk,
    input wire                  rst,
    input wire [length - 1 : 0] datain,
    input wire                  en,
    output reg [length - 1 : 0] dataout,
    output reg [width - 1 : 0]  index,
    output reg                  over,
    output reg                  read_finish
    );

reg [length - 1 : 0] mem [0 : num_log];
reg [width - 1 : 0] pos [0 : num_log];  
reg [width - 1 : 0] index1, index2, cnt_i, cnt_j;
reg [2 : 0] state;
//wire comp_res;
localparam idle = 3'b000;
localparam read = 3'b001;
localparam sort = 3'b010;
localparam write = 3'b011;

integer k;

always@(posedge clk or negedge rst) begin
    if(!rst) begin
        //i = 0;
        //j = 0;
        cnt_i <= 0;
        cnt_j <= 0;
        index1 <= 0;
        index2 <= 0;
        read_finish <= 0;
        state <= idle;
        dataout <= 0;
        index <= 0;
        over <= 0;
        for(k = 0; k < num; k = k + 1) begin
            mem[k] <= 0;
            pos[k] <= k + 1;
        end
    end
    else if(en == 1) begin
        if(state == idle) begin
            over <= 0;
            state <= read;
            mem[index1] <= datain;
            index1 <= index1 + 1;
        end
        else if(state == read) begin
            if(index1 == num) begin
                read_finish <= 1;
                state <= sort;
            end
            else begin
                mem[index1] <= datain;
                index1 <= index1 + 1;
            end
        end
        else if(state == sort) begin
            read_finish <= 0;
            if(mem[cnt_j] < mem[cnt_j + 1])begin
            //if(comp_res == 1)begin
                mem[cnt_j] <= mem[cnt_j + 1];
                mem[cnt_j + 1] <= mem[cnt_j];
                pos[cnt_j] <= pos[cnt_j + 1];
                pos[cnt_j + 1] <= pos[cnt_j];
            end
            if(cnt_j == num - cnt_i - 2) begin
                cnt_j <= 0;
                    //cnt_i <= cnt_i + 1;
                if(cnt_i == num - 2) begin
                    state <= write;
                    over <= 1;
                end
                else begin
                    cnt_i <= cnt_i + 1;
                end
            end
            else begin
                cnt_j <= cnt_j + 1;
            end
            //end
        end
        else if(state == write) begin
            if(index2 == num) begin
                index1 <= 0;
                index2 <= 0;
                state <= idle;
                //over <= 1;
            end
            else begin
                dataout <= mem[index2];
                index <= pos[index2];
                index2 <= index2 + 1;
            end
        end
    end  
end

//comp comp0(.in_operanda(mem[cnt_j]), .in_operandb(mem[cnt_j + 1]), .out_operand(comp_res));

endmodule