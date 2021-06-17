module cal_top(
	
	input  sys_clk,			//50MHz
   input  sys_rst_n,			//异步复位 低电平有效
	input  uart_rx,			//串口接收端口
	
	input [3:0] KEY_COL,		//矩阵 列
	
	output [3:0]KEY_ROW,		//矩阵 行
	output [7:0]SEL, 			//位选
	output [7:0]SEG, 			//段选
	
	output  uart_tx			//串口发送端口
);

	wire [7:0] data; 
	wire uart_rx_done;

	wire value_en;
	wire [3:0]key_value;		//矩阵键盘值
	
	KeyValue keyValue1(
		.CLK(sys_clk),
		.nRST(sys_rst_n),
		.KEY_ROW(KEY_ROW),
		.KEY_COL(KEY_COL),
		.KEY_Value(key_value),
		.Value_en(value_en)
	);
	
	ShowControl showControl1(
		.CLK(sys_clk),
		.nRST(sys_rst_n),
		.KEY_Value(key_value),
		.Value_en(value_en),
		.SEL(SEL),
		.SEG(SEG)
	);
	
	//接收串口助手发来的数据 
	uart_rx uart_rx_uut(
		  .clk    (sys_clk),
		 .rst_n   (sys_rst_n),
		 .uart_rx (uart_rx),
		 .uart_rx_done(uart_rx_done),
		 .data    (data)
	);
		 
	//接收的数据发送到串口助手上 	 
	uart_tx uart_tx_uut(
		.clk     (sys_clk),
		.rst_n   (sys_rst_n),
		.uart_tx (uart_tx),
		.data    (data),
		.tx_start(uart_rx_done)
	 );
	 
	 
	
endmodule