//***************************************************************************
//功能：将串口接收到的数据，发送至PC机上
//	串口助手设置:波特率9600 无奇偶校验位，8位数据位，一个起始位,一个停止位
//
//作者:Ray
//时间:2021-4-24
//***************************************************************************
module uart_tx(
 input            clk,
 input            rst_n,
 output   reg     uart_tx,
 input    [7:0]   data,
 input            tx_start			//串口发送标志位
 );
 
 
parameter   CLK_FREQ = 50000000;	      //系统50M频率           
parameter   UART_BPS = 115200;     		//波特率                
localparam  PERIOD   = CLK_FREQ/UART_BPS;  
 
reg [7:0] tx_data;        //发送的数据
reg start_tx_flag;        //发送数据标志位
 
//记算一位数据需要多长时间PERIOD
reg   [15:0]   cnt0;
wire           add_cnt0;
wire           end_cnt0;
 
//发送几个数据
reg   [3:0]    cnt1;
wire           add_cnt1;
wire           end_cnt1;
 
 
 //发送标志位
 always  @(posedge clk or negedge rst_n)begin
    if(rst_n==1'b0)begin
        start_tx_flag<=0;
		  tx_data<=0;
    end
    else if(tx_start) begin
        start_tx_flag<=1;    
		  tx_data<=data;      //把发送的数据存到这里来
		  
    end
    else if(end_cnt1) begin
        start_tx_flag<=0;
    end
end
 
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt0 <= 0;
    end
	 else if(end_cnt1) begin
	     cnt0 <= 0;
	 end
	 else if(end_cnt0) begin
	     cnt0 <= 0;
	 end
    else if(add_cnt0)begin
        cnt0 <= cnt0 + 1;
    end
end
assign add_cnt0 = start_tx_flag;       
assign end_cnt0 = add_cnt0 && cnt0==PERIOD-1;   //一位时间
 
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt1 <= 0;
    end
	 else if(end_cnt1) begin
	     cnt1 <= 0;
	 end
    else if(add_cnt1)begin
        cnt1 <= cnt1 + 1;
    end
end
 
assign add_cnt1 = end_cnt0 ;    
assign end_cnt1 = (cnt0==((PERIOD-1)/2))&& (cnt1==10-1);   //发送10位，包括停止位，空闲位
 
always  @(posedge clk or negedge rst_n)begin
      if(rst_n==1'b0)begin
         uart_tx<=1;               //空闲状态
      end
      else if(start_tx_flag) begin
		  if(cnt0==0)begin
           case(cnt1)
            4'd0:uart_tx<=0;         //起始位      
            4'd1:uart_tx<=tx_data[0]; 
				4'd2:uart_tx<=tx_data[1]; 
            4'd3:uart_tx<=tx_data[2];
            4'd4:uart_tx<=tx_data[3];
            4'd5:uart_tx<=tx_data[4];
            4'd6:uart_tx<=tx_data[5];
            4'd7:uart_tx<=tx_data[6];
            4'd8:uart_tx<=tx_data[7];
            4'd9:uart_tx<=1;       //停止位  
				default:;   
          endcase
        end  
      end 
end
endmodule
 