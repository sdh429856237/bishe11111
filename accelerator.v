module Accelerator(
    // interface to system
    input wire CLK,                         // CLK = 200MHz
    input wire RESET,                       // RESET, Negedge is active
    input wire EN,                          // enable signal for the accelerator, high for active
    input wire OPSEL,

    input wire [12:0] IADDR,                // input address for shared SRAM
    input wire [12:0] WADDR,                // weight address for shared SRAM
    input wire [16:0] OADDR,                // output address for shared SRAM
    output wire [5:0] STATE,                 // output state for the tb to check the runtime...
    input wire [511:0] input_data,
    ////OPSEL?
    input wire output_buffer_wen,
    input wire output_buffer_ren,
    input wire output_buffer_cen,
    input wire [16 : 0] output_buffer_addr,
    output reg [511 : 0] output_buffer_data
    );

// always @(posedge CLK or negedge RESET) begin
//     if(~RESET) begin
//         // reset
        
//     end else if (EN) begin
//         // logic
        
//     end
// end

// controller
wire [12:0] share_addr;
//wire [5:0] STATE;
wire W_EN;
wire SELECTOR;
wire share_wen;
wire share_ren;
wire share_cen;
wire weight_ren;
wire weight_cen;
wire weight_wen;
wire [12:0] weight_addr;
wire input_ren;
wire input_cen;
wire input_wen;
wire [12:0] input_addr;
wire output_ren;
wire output_cen;
wire output_wen;
wire [16:0] output_addr;
/*
controller controller(
        .CLK(CLK),
        .RESET(RESET),
        .EN(EN),
        .STATE(STATE),
        .W_EN(W_EN),
        .SELECTOR(SELECTOR),
        .share_wen(share_wen),
        .share_ren(share_ren),
        .share_cen(share_cen),
        .share_addr(share_addr),
        .weight_wen(weight_wen),
        .weight_ren(weight_ren),
        .weight_cen(weight_cen),
        .weight_addr(weight_addr),
        .activate_wen(input_wen),
        .activate_ren(input_ren),
        .activate_cen(input_cen),
        .activate_addr(input_addr),
        .output_wen(output_wen),
        .output_ren(output_ren),
        .output_cen(output_cen),
        .output_addr(output_addr),
        .IADDR(IADDR),
        .WADDR(WADDR),
        .OADDR(OADDR)
        //OUT PUT ADDR
        //.input_data(input_data)
    );

// // shared buffer
wire [511:0] share_out;
shared_buffer share_buffer(
    .Q(share_out),
    .CLK(CLK),
    .CEN(share_cen),
    .WEN(share_wen),
    .A(share_addr),
    .D(input_data),
    .RETN(share_ren)
);
// input buffer
wire [511:0] input_out;
input_buffer input_buffer(
    .Q(input_out),
    .CLK(CLK),
    .CEN(input_cen),
    .WEN(input_wen),
    .A(input_addr),
    .D(share_out),
    .RETN(input_ren),
    .RESET(RESET)
);
// // weight buffer
wire [511:0] weight_out;
weight_buffer weight_buffer(
    .Q(weight_out),
    .CLK(CLK),
    .CEN(weight_cen),
    .WEN(weight_wen),
    .A(weight_addr),
    .D(share_out),
    .RETN(weight_ren)
);
// PE array
parameter num1 = 16;
parameter num2 = 16;
wire [num2*64-1:0]out_sum;
PE_array #(.num1(num1),.num2(num2))PE_array(
        .CLK(CLK),
        .RESET(RESET),
        .EN(EN),
        .SELECTOR(SELECTOR),
        .W_EN(W_EN),
        .OPSEL(OPSEL),
        // .....
        .active_left(input_out),
        .out_sum_final(out_sum),
        .in_weight_above(weight_out),
        .out_weight_final(out_weight_below)
    );
// output buffer
//wire [num2 * 32 - 1:0]output_out;
wire cen, ren, wen, addr;
assign ren = output_ren | output_buffer_ren;
assign cen = output_ren ? output_cen : output_buffer_cen;
assign wen = output_ren ? output_wen : output_buffer_wen;
assign addr = output_ren ? output_addr : output_buffer_addr;

*/////////////////////////////////////
/*
output_buffer output_buffer(
    .Q(output_out),
    .CLK(CLK),
    .CEN(output_cen),
    .WEN(output_wen),
    .A(output_addr),
    .D(out_sum),
    .RETN(output_ren)
    //.RESET(RESET)
);
*/
////////////////////
/*
output_buffer output_buffer(
    .Q(output_buffer_data),
    .CLK(CLK),
    .CEN(cen),
    .WEN(wen),
    .A(addr),
    .D(out_sum),
    .RETN(ren)
    //.RESET(RESET)
);
*/
endmodule
