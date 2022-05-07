`timescale 1ns / 1ps

module comp_unit#(
    parameter LENGTH = 32,
    parameter OFFSET = 8
)(
   input [LENGTH - 1: 0] in_operanda,
   input [LENGTH - 1: 0] in_operandb,
   output wire out_operand
);

    assign out_operand = (in_operanda[OFFSET - 1: 0] < in_operandb[OFFSET - 1: 0]) ? 1'b1: 1'b0;

endmodule