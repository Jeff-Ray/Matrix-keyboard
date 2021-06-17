# Matrix-keyboard
### 基于Verilog的矩阵键盘实现
#### 现象
采用的是4*4矩阵键盘，每按下一个键数码管会显示当前按键的值，**依次循环左移显示**。KEY——Value保存的是键值，送入到数码管动态显示模块即可，RTL图如下图所示：
![RTL图](https://img-blog.csdnimg.cn/20210617141308437.jpg#pic_center)
#### 原理
矩阵键盘的原理就是分行和列扫描，来获知按下按键的行数和列数，然后得到按下按键的键值。因为四脚的微动按键的同一排引脚是相连的，相当于是一个引脚，所以利用这个点会大大简化我们的电路，不用做太多的飞线。
矩阵键盘的扫描原理为，先让四个横行或者四个竖列输出高电平，另外四个为输入模式，若扫描到高电平，则表示该行或该列有按键按下，接着切换输入输出，扫描另外四个，得到另外的坐标，由此确定按键按下的位置，原理图如下所示：

![矩阵键盘](https://img-blog.csdnimg.cn/2021061714092242.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2ppYW5mZW5nXzUyMA==,size_16,color_FFFFFF,t_70#pic_center)
#### 软件实现
#### 键盘扫描
矩阵键盘有多种检测方式，这里主要的扫描方式采用行列扫描，采用的是状态机扫描键盘，代码如下：

```c
//***************************************************************************
//功能：矩阵键盘检测
//
//
//作者:Ray
//时间:2021-4-24
//***************************************************************************
module KeyValue(
	CLK,
	nRST,
	KEY_ROW,
	KEY_COL,
	KEY_Value,
	Value_en
);
	input CLK;
	input nRST;
	input [3:0]KEY_COL;				//列
	output reg Value_en;
	output reg [3:0]KEY_ROW;		//行
	output reg [3:0]KEY_Value;		//矩阵键盘按下的值
	
	wire [3:0]key_flag;				//按键标志位
	wire [3:0]key_state;
	
	reg [4:0]state;
	reg row_flag;						//标识已定位到行
	reg [1:0]rowIndex;				//行索引
	reg [1:0]colIndex;				//列索引
	
	localparam
		NO_KEY		=	5'b00001,
		ROW_ONE		=	5'b00010,
		ROW_TWO		=	5'b00100,
		ROW_THREE	=	5'b01000,
		ROW_FOUR	=	5'b10000;
		
	KeyPress u0(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[0]),
		.KEY_FLAG(key_flag[0]),
		.KEY_STATE(key_state[0])
	);
	
	KeyPress u1(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[1]),
		.KEY_FLAG(key_flag[1]),
		.KEY_STATE(key_state[1])
	);
	
	KeyPress u2(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[2]),
		.KEY_FLAG(key_flag[2]),
		.KEY_STATE(key_state[2])
	);
	
	KeyPress u3(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_IN(KEY_COL[3]),
		.KEY_FLAG(key_flag[3]),
		.KEY_STATE(key_state[3])
	);

	//==========通过状态机判断行===========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			begin
				state <= NO_KEY;
				row_flag <= 1'b0;
				KEY_ROW <= 4'b0000;
			end
		else
			case(state)
				NO_KEY: begin
					row_flag <= 1'b0;
					KEY_ROW <= 4'b0000;	
					if(key_flag != 4'b0000) begin
						state <= ROW_ONE;
						KEY_ROW <= 4'b1110;
					end
					else
						state <= NO_KEY;
				end
				
				ROW_ONE: begin
					//这里做判断只能用KEY_COL而不能用key_state
					//因为由于消抖模块使得key_state很稳定
					//不会因为KEY_ROW的短期变化而变化
					//而KEY_COL则会伴随KEY_ROW实时变化
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd0;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_TWO;
						KEY_ROW <= 4'b1101;
					end						
				end
				
				ROW_TWO: begin
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd1;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_THREE;
						KEY_ROW <= 4'b1011;
					end						
				end
				
				ROW_THREE: begin
					if(KEY_COL != 4'b1111) begin
						state <= NO_KEY;
						rowIndex <= 4'd2;
						row_flag <= 1'b1;
					end
					else begin
						state <= ROW_FOUR;
						KEY_ROW <= 4'b0111;
					end						
				end
				
				ROW_FOUR: begin
					if(KEY_COL != 4'b1111) begin
						rowIndex <= 4'd3;
						row_flag <= 1'b1;
					end
					state <= NO_KEY;
				end
			endcase
	
	//===========判断按键所在列=============//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			colIndex <= 2'd0;
		else if(key_state != 4'b1111)
			case(key_state)
				4'b1110: colIndex <= 2'd0;
				4'b1101: colIndex <= 2'd1;
				4'b1011: colIndex <= 2'd2;
				4'b0111: colIndex <= 2'd3;
			endcase
	
	//===========通过行列计算键值==========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			Value_en <= 1'b0;
		else if(row_flag)
			begin
				Value_en <= 1'b1;
				KEY_Value <= 4*rowIndex + colIndex;
			end
		else
			Value_en <= 1'b0;
			
endmodule

```

##### 消抖
由于微触按键按下时会产生抖动，所以需要进行消抖。消抖这里采用的是状态机消抖，代码如下：

```c
//***************************************************************************
//功能：定义状态机,方便后期用于矩阵键盘消抖
//
//
//作者:Ray
//时间:2021-4-24
//***************************************************************************
module KeyPress(
	CLK,
	nRST,
	KEY_IN,
	KEY_FLAG,
	KEY_STATE
);
	input CLK;
	input nRST;
	input KEY_IN;
	
	output reg KEY_FLAG;			//按键按下标志位 高电平为按下
	output reg KEY_STATE;
	
	reg key_a, key_b;
	reg en_cnt, cnt_full;
	reg [3:0]state;
	reg [19:0]cnt;
	wire flag_H2L, flag_L2H;
	
	//运用状态机对矩阵键盘进行检测
	//定义状态
	localparam
		Key_up			=	4'b0001,
		Filter_Up2Down	=	4'b0010,
		Key_down			=	4'b0100,
		Filter_Down2Up	=	4'b1000;
		
	//======判断按键输入信号跳变沿========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			begin
				key_a <= 1'b0;
				key_b <= 1'b0;
			end
		else
			begin
				key_a <= KEY_IN;
				key_b <= key_a;
			end
	assign flag_H2L = key_b && (!key_a);
	assign flag_L2H = (!key_b) && key_a;
	
	//============计数使能模块==========//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			cnt <= 1'b0;
		else if(en_cnt)
			cnt <= cnt + 1'b1;
		else
			cnt <= 1'b0;
			
	//=============计数模块=============//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			cnt_full <= 1'b0;
		else if(cnt == 20'd999_999)
			cnt_full <= 1'b1;
		else
			cnt_full <= 1'b0;
	
	//=============有限状态机============//
	always @(posedge CLK or negedge nRST)
		if(!nRST)
			begin
				en_cnt <= 1'b0;
				state <= Key_up;
				KEY_FLAG <= 1'b0;
				KEY_STATE <= 1'b1;
			end
		else
			case(state)
				//保持没按
				Key_up: begin 
					KEY_FLAG <= 1'b0;
					if(flag_H2L) begin
						state <= Filter_Up2Down;
						en_cnt <= 1'b1;
					end
					else
						state <= Key_up;							
				end
				//正在向下按	
				Filter_Up2Down: begin
					if(cnt_full) begin
						en_cnt <= 1'b0;
						state <= Key_down;
						KEY_STATE <= 1'b0;
						KEY_FLAG <= 1'b1;
					end
					else if(flag_L2H) begin
						en_cnt <= 1'b0;
						state <= Key_up;
					end
					else
						state <= Filter_Up2Down;
				end
				//保持按下状态
				Key_down: begin
					KEY_FLAG <= 1'b0;
					if(flag_L2H) begin
						state <= Filter_Down2Up;
						en_cnt <= 1'b1;
					end
					else 
						state <= Key_down;
				end
				//正在释放按键
				Filter_Down2Up: begin
					if(cnt_full) begin
						en_cnt <= 1'b0;
						state <= Key_up;
						KEY_FLAG <= 1'b1;
						KEY_STATE <= 1'b1;
					end
					else if(flag_H2L) begin
						en_cnt <= 1'b0;
						state <= Key_down;
					end						
					else
						state <= Filter_Down2Up;
				end
				//其他未定义状态
				default: begin
					en_cnt <= 1'b0;
					state <= Key_up;
					KEY_FLAG <= 1'b0;
					KEY_STATE <= 1'b1;
				end
			endcase	
endmodule
```
### 小结
已上板测试过，可以正常进行矩阵键盘扫描以及数码管显示，因为篇幅的原因，没有描述数码管动态显示，有需要的可以下载工程自己测试。

