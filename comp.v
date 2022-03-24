module comp(
    //parameter BIN = 32'b0_01111101_00000000000000000000110
    input  wire [31:0] in_operanda,
    input  wire [31:0] in_operandb,
    output wire out_operand 
);
//a - b < 0, out = 1; a - b >= 0, out = 0;

    wire [31:0] tmp;
    wire        exception;

    Addition_Subtraction sub0(//////ºŸ…Ë «in_operandºıBIN
   	    .a_operand(in_operanda),
   	    .b_operand(in_operandb),
   	    .AddBar_Sub(1'b1),
   	    .Exception(exception),
   	    .result(tmp)
    );
    assign out_operand = tmp[31] ? 1'b1 : 1'b0;
    
endmodule