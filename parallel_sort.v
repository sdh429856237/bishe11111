`timescale 1ns / 1ps

module parallel_sort #(
    parameter length = 32, 
    parameter width = 8, 
    parameter num = 16,
    parameter offset = 8
)
(
    input wire                  clk,
    input wire                  rst,
    input wire [length - 1 : 0] datain,
    input wire                  en,
    output reg [length - 1 : 0] dataout,
    // output reg [width - 1 : 0]  index,
    output reg                  over,
    output reg                  read_finish,
    output reg                  write_fin_o
    );

reg [length - 1 : 0] mem [0 : num];
// reg [width - 1 : 0] pos [0 : num];  
reg [width - 1 : 0] index1, index2, cnt_i, cnt_j;
reg [2 : 0] state;
//wire comp_res;
localparam idle = 3'b000;
localparam read = 3'b001;
localparam sort = 3'b010;
localparam write = 3'b011;

integer k;
reg selector;
reg comp_en;
//reg [length - 1 : 0] a, b;
//reg [length - 1 : 0] a [num / 2 - 1 : 0];
//reg [length - 1 : 0] b [num / 2 - 1 : 0];
wire [num / 2 - 1 : 0] c;
genvar gi;
generate
    for(gi = 0; gi < num / 2; gi = gi + 1) begin
        comp_unit #(
            .LENGTH(length),
            .OFFSET(offset)
        )comp_unit (
            .in_operanda((comp_en == 1) ? ((selector == 0) ? mem[2 * gi] : mem[2 * gi + 1]) : 0),
            .in_operandb((comp_en == 1) ? ((selector == 0) ? mem[2 * gi + 1] : mem[2 * gi + 2]) : 0),
            .out_operand(c[gi])
        );
    end
endgenerate

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
        // index <= 0;
        over <= 0;
        selector <= 0;
        comp_en <= 0;
        write_fin_o <= 0;
        for(k = 0; k <= num; k = k + 1) begin
            mem[k] <= 0;
            // pos[k] <= k + 1;
        end
    end
    else if(en == 1) begin
        if(state == idle) begin
            over <= 0;
            state <= read;
            mem[index1] <= datain;
            index1 <= index1 + 1;
            write_fin_o <= 0;
        end
        else if(state == read) begin
            write_fin_o <= 0;
            if(index1 == num) begin
                read_finish <= 1;
                state <= sort;
                cnt_i <= 0;
                selector <= 0;
                comp_en <= 1;
                write_fin_o <= 0;
            end
            else begin
                mem[index1] <= datain;
                index1 <= index1 + 1;
            end
        end
        else if(state == sort) begin
            read_finish <= 0;
            write_fin_o <= 0;
            for(k = 0; k < num / 2 - selector; k = k + 1) begin
                if(selector == 0) begin
                    mem[2 * k] <= (c[k] == 0) ? mem[2 * k] : mem[2 * k + 1];
                    mem[2 * k + 1] <= (c[k] == 0) ? mem[2 * k + 1] : mem[2 * k];
                    // pos[2 * k] <= (c[k] == 0) ? pos[2 * k] : pos[2 * k + 1];
                    // pos[2 * k + 1] <= (c[k] == 0) ? pos[2 * k + 1] : pos[2 * k];                
                end
                else begin
                    mem[2 * k + 1] <= (c[k] == 0) ? mem[2 * k + 1] : mem[2 * k + 2];
                    mem[2 * k + 2] <= (c[k] == 0) ? mem[2 * k + 2] : mem[2 * k + 1];
                    // pos[2 * k + 1] <= (c[k] == 0) ? pos[2 * k + 1] : pos[2 * k + 2];
                    // pos[2 * k + 2] <= (c[k] == 0) ? pos[2 * k + 2] : pos[2 * k + 1];                       
                end
            end
            if(cnt_i % 2 == 0) begin
                selector <= 1;
            end
            else begin
                selector <= 0;
            end
            cnt_i <= cnt_i + 1;
            if(cnt_i == num - 1) begin
                state <= write;
                comp_en <= 0;
                over <= 1;
            end
        end
        else if(state == write) begin
            over <= 0;
            if(index2 == num) begin
                index1 <= 0;
                index2 <= 0;
                state <= idle;
                //over <= 1;
                write_fin_o <= 1'b1;
            end
            else begin
                dataout <= mem[index2];
                // index <= pos[index2];
                index2 <= index2 + 1;
            end
        end
    end else begin 
        index1 <= 0;
        index2 <= 0;
    end
end

//comp comp0(.in_operanda(mem[cnt_j]), .in_operandb(mem[cnt_j + 1]), .out_operand(comp_res));

endmodule