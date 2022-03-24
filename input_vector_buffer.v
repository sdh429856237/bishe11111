// input buffer, ref: shifter_buffer
//10kb
module input_vector_buffer(
    output reg  [511:0] Q,
    input  wire          CLK,
    input  wire          CEN,
    input  wire          WEN,
    input  wire [12:0]   A,
    input  wire          RESET,
    input  wire [511:0] D,
    input  wire          RETN
    );
    
integer i;
integer j;
parameter num = 2048;
reg [511:0] mem [12:0];
always @(posedge CLK)
begin
    if(~RESET)begin
        for (i = 0; i < num; i = i + 1)
				mem[i] <= 512'b0;
	    Q <= 512'b0;
	end
    else if(~WEN & RETN) begin
        Q <= 512'd0;
        mem[A] <= D;
    end else if(~CEN & RETN) begin
        Q <= mem[A];
    end else begin
        Q <= 512'd0;
    end
end

endmodule