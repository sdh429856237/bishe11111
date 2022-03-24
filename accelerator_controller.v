module accelerator_controller(
    input wire CLK,                         
    input wire RESET,                      
    input wire EN,                          
              
    input wire [12 : 0] WVADDR,         
    
    //input wire inputw_finish,
    //input wire inputa_finish,
    input  wire         run_finish,       
                   
    //input vector buffer
    output reg          input_vector_wen,
    output reg          input_vector_ren,
    output reg          input_vector_cen,
    output reg [12 : 0] input_vector_addr,
    
    output reg EN_ARRAY,
    output reg OPSEL,
    output reg [12 : 0] array_iaddr,
    output reg [12 : 0] array_waddr,
    output reg [12 : 0] array_oaddr,
    
    output reg          output_vector_wen,
    output reg          output_vector_ren,
    output reg          output_vector_cen,
    output reg [12 : 0] output_vector_addr,
    
    output reg          binary_map_wen,
    output reg          binary_map_ren,
    output reg          binary_map_cen,
    output reg [12 : 0] binary_map_addr,
    
    output reg          addition_result_wen,
    output reg          addition_result_ren,
    output reg          addition_result_cen,
    output reg [3 : 0]  addition_result_addr,
    
    output reg          sort_result_wen,
    output reg          sort_result_ren,
    output reg          sort_result_cen,
    output reg [3 : 0]  sort_result_addr,
    
    output reg EN_SORT,
    input  wire sort_over,
    
    input wire input_sort_finish,
    
    output reg EN_CRUCIAL,
    
    input wire input_sort_result_finish,
    input wire find_over
    );
    
reg [12 : 0] weight_addr, act_addr;
reg [1 : 0] exchange;
reg [6 : 0] cnt, cnt_update_weightaddr;
reg [5 : 0] STATE;
    
parameter IDLE       = 6'd0;      
parameter INPUTV     = 6'd1;    // ������д��input buffer
parameter RUN_ARRAY1 = 6'd2;    // ��һ������systolic array
parameter OUTPUTBM   = 6'd3;    // ����������binary map buffer
parameter RUN_ARRAY2 = 6'd4;    // �ڶ�������systolic array
parameter OUTPUTAR   = 6'd5;    // ����������addition result buffer
parameter SORT       = 6'd6;    // ����ð������
parameter OUTPUTSR   = 6'd7;    // �������������sort result buffer
parameter FIND_TOKEN = 6'd8;    // ����crucial token
parameter RETURN     = 6'd9;

always @(posedge CLK or negedge RESET) begin
    if(~RESET) begin
        weight_addr <= 0;
        act_addr <= 0;
        exchange <= 0;
        cnt <= 0;
        cnt_update_weightaddr <= 0;
        //input_addr <= 0;
        
        STATE <= IDLE;
        input_vector_wen <= 1;
        input_vector_ren <= 0;
        input_vector_cen <= 1;
        input_vector_addr <= 0;
        
        EN_ARRAY <= 0;
        OPSEL <= 0;
        array_iaddr <= 0;
        array_waddr <= 0;
        array_oaddr <= 0;
        
        output_vector_wen <= 1;
        output_vector_ren <= 0;
        output_vector_cen <= 1;
        output_vector_addr <= 0;     
        
        binary_map_wen <= 1;
        binary_map_ren <= 0;
        binary_map_cen <= 1;
        binary_map_addr <= 0;  
        
        addition_result_wen <= 1;
        addition_result_ren <= 0;
        addition_result_cen <= 1;
        addition_result_addr <= 0;     
        
        sort_result_wen <= 1;
        sort_result_ren <= 0;
        sort_result_cen <= 1;
        sort_result_addr <= 0;           
        
        EN_SORT <= 0;
        EN_CRUCIAL <= 0;
        
    end else if (EN) begin
        if (STATE == IDLE) begin
            STATE <= INPUTV;
            input_vector_wen <= 0;
            input_vector_ren <= 1;
            input_vector_cen <= 1;
            input_vector_addr <= WVADDR;
        end
        else if(STATE == INPUTV)begin
            input_vector_addr <= input_vector_addr + 1;
            if(input_vector_addr >= 2047 + WVADDR)begin
                STATE <= RUN_ARRAY1;
                input_vector_wen <= 1;
                input_vector_ren <= 1;
                input_vector_cen <= 0;
                input_vector_addr <= WVADDR;
                weight_addr <= WVADDR;
                act_addr <= WVADDR;
                EN_ARRAY <= 1;
                OPSEL <= 0;
                array_waddr <= 0;
                array_iaddr <= 13'b0000000100000;
                array_oaddr <= 0;
                exchange <= 0;
            end
        end
        else if(STATE == RUN_ARRAY1)begin//û�м�����1024*1024����������
            input_vector_addr <= input_vector_addr + 1;
            if((input_vector_addr == 15 + weight_addr) && (exchange == 0)) begin
                input_vector_addr <= act_addr;
                exchange <= 1;
                //input_vector_wen <= 1;
                //input_vector_ren <= 0;
                //input_vector_cen <= 1;
                //weight_addr <= input_vector_addr + 1;
            end
            else if((input_vector_addr == 15 + act_addr) && (exchange == 1)) begin
                exchange <= 2;
                input_vector_wen <= 1;
                input_vector_ren <= 0;
                input_vector_cen <= 1;
                //act_addr <= input_vector_addr + 1;
            end
            else if(run_finish == 1) begin//��ǰ�벿���������ɵ���벿������������׼��ַ����α仯��
                cnt <= cnt + 1;
                input_vector_wen <= 1;
                input_vector_ren <= 1;
                input_vector_cen <= 0;
                exchange <= 0;
                if(cnt == 8191) begin
                    input_vector_wen <= 1;
                    input_vector_ren <= 0;
                    input_vector_cen <= 1;
                    STATE <= OUTPUTBM;
                    EN_ARRAY <= 0;
                    exchange <= 0;
                    output_vector_wen <= 1;
                    output_vector_ren <= 1;
                    output_vector_cen <= 0;
                    output_vector_addr <= 0;
                
                    binary_map_wen <= 0;
                    binary_map_ren <= 1;
                    binary_map_cen <= 1;
                    binary_map_addr <= -1;
                end
                else if(cnt == 4095) begin
                    array_oaddr <= 0;
                    weight_addr <= weight_addr + 16;
                    act_addr <= act_addr + 16;
                    input_vector_addr <= weight_addr + 16;
                end
                //else begin
                //    array_oaddr <= array_oaddr + 16;
                //end
                else if(cnt % 64 == 63) begin
                    array_oaddr <= array_oaddr + 16;
                    act_addr <= WVADDR;
                    weight_addr <= weight_addr + 16;
                    input_vector_addr <= weight_addr + 16;
                end
                else begin
                    act_addr <= act_addr + 16;
                    array_oaddr <= array_oaddr + 16;
                    input_vector_addr <= weight_addr;
                end
            end
        end
        else if (STATE == OUTPUTBM)begin
            cnt <= 0;
            output_vector_addr <= output_vector_addr + 1;
            binary_map_addr <= binary_map_addr + 1;
            if(binary_map_addr == (1024 * 64 - 1))begin
                STATE <= RUN_ARRAY2;
                binary_map_wen <= 1;
                binary_map_ren <= 0;
                binary_map_cen <= 1;
                binary_map_addr <= 0;
                weight_addr <= 0;
                act_addr <= 0;
                output_vector_wen <= 1;
                output_vector_ren <= 0;
                output_vector_cen <= 1;
                EN_ARRAY <= 1;
                OPSEL <= 1;
                array_waddr <= 0;
                array_iaddr <= 13'b0000000100000;
                array_oaddr <= 0;
                exchange <= 0;
            end
        end//////////////////////RUN_ARRAY2״̬�Ŀ����߼���û�и���
        else if(STATE == RUN_ARRAY2)begin//û�м�����1024*1024����������
            binary_map_addr <= binary_map_addr + 1;
            if((binary_map_addr == 15 + weight_addr) && (exchange == 0)) begin
                binary_map_wen <= 1;
                binary_map_ren <= 1;
                binary_map_cen <= 0;
                binary_map_addr <= act_addr;
                exchange <= 1;
                //input_vector_wen <= 1;
                //input_vector_ren <= 0;
                //input_vector_cen <= 1;
                //weight_addr <= input_vector_addr + 1;
            end
            else if((binary_map_addr == 15 + act_addr) && (exchange == 1)) begin
                exchange <= 2;
                binary_map_wen <= 1;
                binary_map_ren <= 0;
                binary_map_cen <= 1;
                //act_addr <= input_vector_addr + 1;
            end
            else if(run_finish == 1) begin//��ǰ�벿���������ɵ���벿������������׼��ַ����α仯��
                cnt <= cnt + 1;
                //binary_map_wen <= 1;
                //binary_map_ren <= 1;
                //binary_map_cen <= 0;
                exchange <= 0;
                if(cnt == 4095) begin
                    binary_map_wen <= 1;
                    binary_map_ren <= 0;
                    binary_map_cen <= 1;
                    STATE <= OUTPUTAR;
                    EN_ARRAY <= 0;
                    exchange <= 0;
                    output_vector_wen <= 1;
                    output_vector_ren <= 1;
                    output_vector_cen <= 0;
                    output_vector_addr <= 0;
                
                    addition_result_wen <= 0;
                    addition_result_ren <= 1;
                    addition_result_cen <= 1;
                    addition_result_addr <= -1;
                end
                //else if(cnt == 4095) begin
                //    array_oaddr <= 0;
                //    weight_addr <= weight_addr + 16;
                //    act_addr <= act_addr + 16;
                //    input_vector_addr <= weight_addr + 16;
                //end
                //else begin
                //    array_oaddr <= array_oaddr + 16;
                //end
                else if(cnt % 64 == 63) begin
                    array_oaddr <= 0;
                    act_addr <= act_addr + 16;
                    //weight_addr <= weight_addr + 16;
                    binary_map_addr <= weight_addr;
                end
                else begin
                    act_addr <= act_addr + 16;
                    array_oaddr <= array_oaddr + 16;
                    binary_map_addr <= weight_addr;
                end
            end
        end
        /*
        else if(STATE == RUN_ARRAY2)begin//û�м�����1024*1024����������,����share buffer
            binary_map_addr <= binary_map_addr + 1;
            if((binary_map_addr == 15 + weight_addr) && (exchange == 0)) begin
                binary_map_addr <= weight_addr;
                exchange <= 1;
                //input_vector_wen <= 1;
                //input_vector_ren <= 0;
                //input_vector_cen <= 1;
                //weight_addr <= input_vector_addr + 1;
            end
            else if((binary_map_addr == 15 + weight_addr) && (exchange == 1)) begin
                exchange <= 2;
                binary_map_wen <= 1;
                binary_map_ren <= 0;
                binary_map_cen <= 1;
                weight_addr <= binary_map_addr + 1;
            end
            else if(run_finish == 1) begin
                cnt <= cnt + 1;
                if(cnt == 127) begin////////�޸�systolic array�е�output buffer�˿�
                    STATE <= OUTPUTAR;
                    EN_ARRAY <= 0;
                    exchange <= 0;
                    output_vector_wen <= 1;
                    output_vector_ren <= 1;
                    output_vector_cen <= 0;
                    output_vector_addr <= 0;
                
                    binary_map_wen <= 0;
                    binary_map_ren <= 1;
                    binary_map_cen <= 1;
                    binary_map_addr <= -1;
                end
                else begin
                    if(cnt == 63) begin
                        array_oaddr <= 0;
                    end
                    else begin
                        array_oaddr <= array_oaddr + 16;
                    end
                    //array_oaddr <= array_oaddr + 16;
                    exchange <= 0;
                    input_vector_wen <= 1;
                    input_vector_ren <= 1;
                    input_vector_cen <= 0;
                    binary_map_addr <= weight_addr;
                    array_iaddr <= array_iaddr + 16;
                    array_waddr <= array_waddr + 16;
                end
            end
        end
        */
        else if (STATE == OUTPUTAR)begin
            addition_result_addr <= addition_result_addr + 1;
            output_vector_addr <= output_vector_addr + 1;
            if(addition_result_addr == 1023)begin
                STATE <= SORT;
                output_vector_wen <= 1;
                output_vector_ren <= 0;
                output_vector_cen <= 1;
                
                addition_result_wen <= 1;
                addition_result_ren <= 1;
                addition_result_cen <= 0;
                addition_result_addr <= 0;
            end
        end
        else if (STATE == SORT)begin
            EN_SORT <= 1;
            
            addition_result_addr <= addition_result_addr + 1;
            if(input_sort_finish == 1) begin
                addition_result_wen <= 1;
                addition_result_ren <= 0;
                addition_result_cen <= 1;
            end 
            if(sort_over == 1)begin
                STATE <= OUTPUTSR;
                sort_result_addr <= 0;
                sort_result_wen <= 0;
                sort_result_ren <= 1;
                sort_result_cen <= 1;
            end
        end
        else if (STATE == OUTPUTSR)begin
            sort_result_addr <= sort_result_addr + 1;
            if(sort_result_addr == 1023) begin
                EN_SORT <= 0;
                sort_result_wen <= 1;
                sort_result_ren <= 1;
                sort_result_cen <= 0;
                sort_result_addr <= 0;
                STATE <= FIND_TOKEN;
                EN_CRUCIAL <= 1;
            end
        end
        else if (STATE == FIND_TOKEN)begin
            sort_result_addr <= sort_result_addr + 1;
            if(input_sort_result_finish == 1) begin
                sort_result_wen <= 1;
                sort_result_ren <= 0;
                sort_result_cen <= 1;
            end
            else if(find_over == 1) begin
                STATE <= RETURN;
            end
        end
        else if(STATE == RETURN) begin
            STATE <= IDLE;
        end
    end

end

endmodule