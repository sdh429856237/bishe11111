module PE_row #(parameter  num = 16)
	(
	// interface to system
    input wire CLK,                         
    input wire RESET,                       
    input wire EN,                          
	input wire W_EN,
	input wire SELECTOR,
	input wire OPSEL,
	
	input wire [31:0] active_left,
	input wire [num * 32 - 1:0] in_weight_above,
	output wire [num * 32 - 1:0]out_weight_below,

	input wire [num * 32 - 1:0] in_sum,
	output wire [num * 32 - 1:0] out_sum
	);

wire [num * 32 - 1:0] active_right;
//Éú³ÉPE
genvar gi;
generate
    for(gi = 0; gi < num; gi = gi + 1)   
    begin:label
		if(gi == 0)begin
			PE PE_unit(
    		.CLK(CLK),
    		.RESET(RESET),
    		.EN(EN),
			.SELECTOR(SELECTOR),
			.OPSEL(OPSEL),
			.W_EN(W_EN),
			.active_left(active_left),
			.active_right(active_right[31:0]),
			.in_sum(in_sum[31:0]),
			.out_sum(out_sum[31:0]),
			.in_weight_above(in_weight_above[31:0]),
			.out_weight_below(out_weight_below[31:0])
    		);
		end
		else begin
			PE PE_unit(
    		.CLK(CLK),
    		.RESET(RESET),
    		.EN(EN),
			.SELECTOR(SELECTOR),
			.OPSEL(OPSEL),
			.W_EN(W_EN),
			.active_left(active_right[gi * 32 - 1:(gi - 1) * 32]),
			.active_right(active_right[(gi + 1) * 32 - 1:gi * 32]),
			.in_sum(in_sum[(gi + 1) * 32 - 1:gi * 32]),
			.out_sum(out_sum[(gi + 1) * 32 - 1:gi * 32]),
			.in_weight_above(in_weight_above[(gi + 1) * 32 - 1:gi * 32]),
			.out_weight_below(out_weight_below[(gi + 1) * 32 - 1:gi * 32])
    		);
		end
	end
endgenerate

endmodule