module DigitalTube(
	CLK,
	nRST,
	KEY_ROW,
	KEY_COL,
	SEL,
	SEG
);
	input CLK;
	input nRST;
	input [3:0]KEY_COL;
	output [3:0]KEY_ROW;
	output [7:0]SEL; //位选
	output [7:0]SEG; //段选
	
	wire value_en;
	wire [3:0]key_value;
	
	KeyValue keyValue1(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_ROW(KEY_ROW),
		.KEY_COL(KEY_COL),
		.KEY_Value(key_value),
		.Value_en(value_en)
	);
	
	ShowControl showControl1(
		.CLK(CLK),
		.nRST(nRST),
		.KEY_Value(key_value),
		.Value_en(value_en),
		.SEL(SEL),
		.SEG(SEG)
	);
endmodule
