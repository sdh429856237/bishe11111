// input buffer, ref: shifter_buffer
//10kb
module binary_map_buffer#(dimen = 1024, width = 16)(
    output reg  [15 : 0]    Q,
    input  wire             CLK,
    input  wire             CEN,
    input  wire             WEN,
    input  wire [width : 0] A,
    input  wire             RESET,
    input  wire [15 : 0]    D,
    input  wire             RETN
    );
    
integer i;
integer j;
localparam num = dimen * dimen / 16;
reg [15:0] mem [2 * num - 1 : 0];
always @(posedge CLK)
begin
    if(~RESET)begin
        for (i = 0; i < num; i = i + 1)
				mem[i] <= 16'b0;
	    Q <= 16'b0;
	end
    else if(~WEN & RETN) begin
        Q <= 16'b0;
        mem[A] <= D;
        //Q <= 1024'd0;
        //mem[A % 1024] <= {1'b0, D << ((A / 1024) * 16)} | mem[A % 1024];
        //for (i = 0;i < 16;i = i + 1)begin
        //    for(j = 32 * i;j < 32 * i + 32;j = j + 1)begin
        //        mem[i + A][j] <= D[j];
        //    end
        //end
    end else if(~CEN & RETN) begin
        Q <= mem[A];
    end else begin
        Q <= 16'd0;
    end
end

endmodule