// shared buffer (128kB)
module shared_buffer(
    output reg  [511:0] Q,
    input  wire         CLK,
    input  wire         CEN,    
    input  wire         WEN,    
    input  wire [5:0]  A,
    input  wire [511:0] D,      
    input  wire         RETN    
    );

reg [511:0] mem [63:0];
always @(posedge CLK)
begin
    if(~WEN & RETN) begin
        Q <= 512'd0;
        mem[A] <= D;
    end else if(~CEN & RETN) begin
        Q <= mem[A];
    end else begin
        Q <= 512'd0;
    end
end

endmodule