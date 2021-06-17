//注意:
//串口助手设置:波特率9600 无奇偶校验位，8位数据位，一个停止位
module uart_top(
    input  clk,
    input  rst_n  ,
	input  uart_rx  ,
	output  uart_tx  ,
   output wire [7:0] seg_sel,
   output wire [7:0] segment
	
);
 
wire [7:0] data; 
wire uart_rx_done;
				
/*				
//数码管				
seg_num seg_disp_uut(
    .clk       (clk),
    .rst_n     (rst_n),
    .seg_sel   (seg_sel),
    .segment   (segment),
	 .data      (data)
 );
 */
 
//FPGA接收串口助手发来的数据 
uart_rx uart_rx_uut(
     .clk    (clk),
    .rst_n   (rst_n),
    .uart_rx (uart_rx),
    .uart_rx_done(uart_rx_done),
	 .data    (data)
);
	 
//FPGA把接收的数据发送到串口助手上	 	 
uart_tx uart_tx_uut(
   .clk     (clk),
   .rst_n   (rst_n),
   .uart_tx (uart_tx),
   .data    (data),
   .tx_start(uart_rx_done)
 );
	 
endmodule