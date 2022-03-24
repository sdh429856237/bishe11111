module PE(
    input wire CLK,                         
    input wire RESET,                       
    input wire EN,//PE使能信号                          
    input wire SELECTOR,//weight选择信号，1为写入weight，0为使用weight用于计算 
    input wire OPSEL,//计算模式选择信号，1为PE执行向量乘法运算，0为PE执行L1距离运算                   
    input wire W_EN,//写weight使能信号                        
    
    input wire [31:0]active_left,
    output reg [31:0]active_right,

    input wire [31:0]in_sum,
    output reg [31:0]out_sum,

    input wire [31:0]in_weight_above,
    output wire [31:0]out_weight_below
	);
	
    reg [31:0] weight_1; 
    reg [31:0] weight_2;
    
    //
    wire exception1, exception2, overflow, underflow;
    wire [31:0] weight_tmp, L1_operand, L1_tmp, L1_result, mul_tmp, mul_result;
    //wire [63:0] mul_tmp, mul_result;
    //
    
    always @(negedge RESET or posedge CLK ) begin
        if(~RESET) begin
            out_sum <= 0;
            active_right <= 0; 
            weight_1 <= 0;
            weight_2 <= 0;
        end
        else begin
            if(EN) begin
                active_right <= active_left;              
                if(SELECTOR) begin                                       
                    //out_sum <= weight_2 * active_left + in_sum;//我把浮点加法和浮点乘法的模块删掉了，以*和+表达浮点乘和浮点加的意思，便于理解
                    out_sum <= (OPSEL) ? mul_result : L1_result;////
                    if(W_EN) begin
                        weight_1 <= in_weight_above;
                    end
                end  
                else begin
                    //out_sum <= weight_1 * active_left + in_sum;
                    out_sum <= (OPSEL) ? mul_result : L1_result;/////
                    if(W_EN) begin
                        weight_2 <= in_weight_above;    
                    end
                end             
            end
        end
    end
    /////
    assign weight_tmp = (SELECTOR) ? weight_2 : weight_1;
    Multiplication mul0(
   	    .a_operand(weight_tmp),
   	    .b_operand(active_left),
   	    .Exception(exception1),
   	    .Overflow(overflow),
   	    .Underflow(underflow),
   	    .result(mul_tmp)
    );
    Addition_Subtraction add0(///////做不了64bit的加法
   	    .a_operand(mul_tmp),
   	    .b_operand(in_sum),
   	    .AddBar_Sub(1'b0),
   	    .Exception(exception2),
   	    .result(mul_result)
    );
    
    Addition_Subtraction sub0(
   	    .a_operand(active_left),
   	    .b_operand(weight_tmp),
   	    .AddBar_Sub(1'b1),
   	    .Exception(exception2),
   	    .result(L1_operand)
    );
    assign L1_tmp = {1'b0, L1_operand[30:0]};
    Addition_Subtraction add1(
   	    .a_operand(L1_tmp),
   	    .b_operand(in_sum),
   	    .AddBar_Sub(1'b0),
   	    .Exception(exception2),
   	    .result(L1_result)
    );
    /////
    assign out_weight_below = (SELECTOR) ? weight_1 : weight_2;
endmodule