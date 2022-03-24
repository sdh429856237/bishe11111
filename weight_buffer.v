// weight buffer, ref: shared_buffer
// input buffer, ref: shared_buffer\
//10kb
module weight_buffer(
    output reg  [511:0] Q,
    input  wire         CLK,
    input  wire         CEN,
    input  wire         WEN,
    //input  wire         OPSTAGE,//weight输出选择信号，1表示正常输出，0表示输出常数1/////
    input  wire [5:0]  A,

    input  wire [511:0] D,
    input  wire         RETN
    );

integer i;
reg [511:0] mem [63:0];
always @(posedge CLK)
begin
    if(~WEN & RETN) begin
        Q <= 512'd0;
        mem[A] <= D;
    end else if(~CEN & RETN) begin
        //Q <= OPSTAGE ? mem[A] : {16{1'b0, 8'b01111111, 23'b0}};///////
        Q <= mem[A];
    end else begin
        Q <= 512'd0;
    end
end

endmodule