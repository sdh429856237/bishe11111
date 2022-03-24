// output buffer, ref: shared_buffer
// input buffer, ref: shared_buffer\
//10kb
module output_buffer(
    output reg  [511:0]  Q,
    input  wire          CLK,
    input  wire          CEN,
    input  wire          WEN,
    input  wire [5:0]   A,

    input  wire [511:0] D,
    input  wire          RETN
    );
integer i;
integer j;
//reg [12:0] count;
reg [511:0] mem [63:0];
always @(posedge CLK)
begin
    if(~WEN & RETN) begin
        Q <= 512'd0;
        //mem[A] <= D;
        for (i=0;i < 16;i = i + 1)begin
            for(j = 32 * i;j < 32 * i + 32;j = j + 1)begin
                if(A - i >= ((A / 16) * 16)) begin
                    mem[A - i][j] <= D[j];
                end
            end
        end
    end else if(~CEN & RETN) begin
        Q <= mem[A];
    end else begin
        Q <= 512'd0;
    end
end

endmodule