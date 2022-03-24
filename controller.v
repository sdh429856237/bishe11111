module controller(
    input wire CLK,                         
    input wire RESET,                      
    input wire EN,                          

    output reg [5:0] STATE,               
    
    output reg W_EN,
    output reg SELECTOR,

    input wire [5:0] IADDR,                
    input wire [5:0] WADDR,                
    input wire [5:0] OADDR,                
    //share buffer
    output reg share_wen,
    output reg share_ren,
    output reg share_cen,
    output reg [5:0] share_addr,
    // weight buffer
    output reg weight_wen,
    output reg weight_ren,
    output reg weight_cen,
    output reg [5:0] weight_addr,
    // activate buffer
    output reg activate_wen,
    output reg activate_ren,
    output reg activate_cen,
    output reg [5:0] activate_addr,
    // output buffer
    output reg output_wen,
    output reg output_ren,
    output reg output_cen,
    output reg [5:0] output_addr,
    
    //output reg inputa_finish,
    //output reg inputw_finish,
    output reg run_finish
    );
parameter IDLE = 6'd0;      
parameter INPUTA = 6'd1;    // activation从shared buffer写入input buffer
parameter INPUTW = 6'd2;    // weight从shared buffer写入weight buffer
parameter INPUTSW = 6'd3;
parameter INPUTSA = 6'd4;
parameter CALCULATE = 6'd5;
parameter OUTPUT = 6'd6;
parameter RETURN = 6'd7;

always @(posedge CLK or negedge RESET) begin
    if(~RESET) begin
        STATE <= IDLE;
        W_EN <= 0;
        SELECTOR <=0;

        share_wen <= 1;
        share_ren <= 0;
        share_cen <= 1;
        share_addr <= 0;
        // weight buffer
        weight_wen <= 1;
        weight_ren <= 0;
        weight_cen <= 1;
        weight_addr <= 0;
        // activate buffer
        activate_wen <= 1;
        activate_ren <= 0;
        activate_cen <= 1;
        activate_addr <= 0;
        // output buffer
        output_wen <= 1;
        output_ren <= 0;
        output_cen <= 1;
        output_addr <= 0;
        
        //inputa_finish <= 0;
        //inputw_finish <= 0;
        run_finish <= 0;
    end else if (EN) begin
        if (STATE == IDLE) begin
            STATE <= INPUTSW;
            share_wen <= 0;
            share_ren <= 1;
            share_cen <= 1;
            weight_addr <= 0;
            share_addr <= WADDR;
        end
        else if(STATE == INPUTSW)begin
            //把weight写入share buffer
            share_addr <= share_addr + 1;
            if(share_addr >= 15 + WADDR)begin
                STATE <= INPUTSA;
                share_addr <= IADDR;
                //inputw_finish <= 1;
            end
        end
        else if(STATE == INPUTSA)begin
            //把activate写入share buffer
            //inputw_finish <= 0;
            share_addr <= share_addr + 1;
            if(share_addr == 15 + IADDR)begin
                STATE <= INPUTW;
                //读share buffer
                share_wen <= 1;
                share_ren <= 1;
                share_cen <= 0;
                share_addr <= WADDR;
                weight_addr <= -1;
                //inputa_finish <= 1;
            end
        end
        else if (STATE == INPUTW)begin
            //inputa_finish <= 1;
            //把weight从share buffer写入weight buffer
            weight_wen <= 0;
            weight_ren <= 1;
            weight_cen <= 1;
            share_addr <= share_addr + 1;
            weight_addr <= weight_addr + 1;
            if(share_addr == 16 + WADDR)begin
                STATE <= INPUTA;
                share_addr <= IADDR;
                //读weight buffer
                weight_wen <= 1;
                weight_ren <= 1;
                weight_cen <= 0;
                weight_addr <= -1;
                activate_addr <= -1;
                //打开PE，weight开始进入PE
                SELECTOR = 1;
                W_EN = 1;
            end
        end
        else if (STATE == INPUTA)begin
            //把activate从share buffer写入activate buffer
            activate_wen <= 0;
            activate_ren <= 1;
            activate_cen <= 1;
            share_addr <= share_addr + 1;
            activate_addr <= activate_addr + 1;
            weight_addr <= weight_addr + 1;//weight流动
            if(share_addr == 16 + IADDR)begin
                STATE <= CALCULATE;
                //关闭share buffer
                share_wen <= 1;
                share_ren <= 0;
                share_cen <= 1;
                //读activate buffer
                activate_wen <= 1;
                activate_ren <= 1;
                activate_cen <= 0;
                activate_addr <= -1;
                
            end
        end
        else if (STATE == CALCULATE)begin
            //weight加载结束
            W_EN = 0;
            SELECTOR = 0;

            activate_addr <= activate_addr + 1;
            if(activate_addr == 16)begin
                STATE <= OUTPUT;
                //关闭activate buffer
                //activate_wen <= 1;
                //activate_ren <= 0;
                //activate_cen <= 1;
                //准备写入output buffer
                output_addr <= OADDR;
                output_wen <= 0;
                output_ren <= 1;
                output_cen <= 1;
            end
        end
        else if (STATE == OUTPUT)begin
            output_addr <= output_addr + 1;
            if(output_addr == 13 + OADDR) begin
                //关闭activate buffer
                activate_wen <= 1;
                activate_ren <= 0;
                activate_cen <= 1;
            end
            else if(output_addr == 29 + OADDR)begin
                STATE <= RETURN;
                run_finish <= 1;
            end
        end
        else if (STATE == RETURN)begin
            run_finish <= 0;
            STATE <= IDLE;
        end
    end

end

endmodule