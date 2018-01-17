////////////////////////////////////////////
//	（1）模拟FIFO控制模块的外部接口信号
//	（2）单片机准备接收数据：rx_ready拉高
//	（3）FIFO检测到数据准备完毕：data_valid拉高;同时rx_ready拉高时，开始将数据载入FIFO
//	（4）装满后开始使能uart,发送数据
//	（5）单片机收满后拉低rx_ready信号，uart停止发送
////////////////////////////////////////////
`timescale	1ns/1ps

module tb_fifo_0();

//-----------------接口定义-------------------=//
reg 	sclk;				//系统时钟
reg		rd_clk;				//读数据时钟
reg		data_tvalid = 0;	//FFT数据准备完毕
reg		[13:0]	data;		//数据
reg		rx_ready;			//单片机接收准备

wire	tx_ready;			//uart发送准备
wire	data_out;

//===============产生时钟信号==================//
initial		sclk = 1;		
always	#5	sclk = ~sclk;		//系统时钟100M

initial		rd_clk = 1;			//数据读取时钟
always	begin
	#100
	rd_clk = 1;
	#10
	rd_clk = 0;
end	
	
//===============产生valid信号=================//
reg		[12:0]	cnt = 0;
always @(posedge sclk) begin	
	if(cnt == 13'd8000)	begin		//计数一个周期
		cnt <= 0;
	end
	else	begin
		cnt <= cnt + 1;
	end
end

always @(posedge sclk) begin
	if(cnt <= 13'd1023)	begin
		data_tvalid <= 1;			//fft数据准备完毕
		data <= cnt;				//产生数据
	end
	else if(cnt > 13'd1024)	begin
		data_tvalid <= 0;
		data <= data;
	end
	else	begin
		data_tvalid <= data_tvalid;
		data <= data;
	end
end

//=================接收方信号=================//
initial	begin
	rx_ready = 0;
	#75000
	rx_ready = 1;
	#180050
	rx_ready = 0;
	#44950
	rx_ready = 1;
	#180000
	rx_ready = 0;
end

//-------------------例化---------------------//
FIFO_Control_0		FIFO_Control_0_inst0(
    .clk		(sclk),            
    .wr_clk		(sclk),         
    .rd_clk		(rd_clk),	         
    .data_valid		(data_tvalid),     
    .rx_ready		(rx_ready),       
    .data_re		(data),

    .tx_ready		(tx_ready),
	.data_out	(data_out)
);

endmodule 




