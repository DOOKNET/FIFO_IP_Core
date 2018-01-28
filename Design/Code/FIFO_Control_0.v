/////////////////////////////////////////////////////
//  1.单片机发送指令，等待接收数据
//  2.检测到valid拉高，FIFO开始缓存数据
//  3.检测到存满后开始发送
//  4.当rx_ready拉低时，发送结束
/////////////////////////////////////////////////////
module FIFO_Control_0(
    input   clk,                //系统时钟
    input   wr_clk,             //写数据时钟
    input   rd_clk,             //读数据时钟
    input   data_valid,         //FFT数据准备完毕
    input   rx_ready,           //单片机准备接收数据
    input   [13:0]  data_re,    //FFT数据

    output  tx_ready,			//FIFO填装空闲状态
	output	[13:0]	data_out
);

parameter   state_0 = 3'b001;
parameter   state_1 = 3'b010;
parameter   state_2 = 3'b100;

reg     [2:0]   current_state = 3'b001;
reg     [2:0]   next_state = 3'b001;

reg     wr_en = 0;
reg     rd_en = 0;
wire    full;
wire	empty;
wire	[9:0]	rd_data_count;
wire	[9:0]	wr_data_count;

reg		uart_en = 0;		//uart使能信号

assign	tx_ready = data_valid;


//-----------------三段式状态机---------------------//
always @(posedge clk) begin
    current_state <= next_state;
end
//-------------------------------------------------//
always @(posedge clk) begin
    case (current_state)
        state_0:
            begin
                if((rx_ready == 1) && (data_valid == 1))    begin	//单片机准备接收，FIFO准备填充
                    next_state <= state_1;
                end
                else    begin
                    next_state <= state_0;
                end
            end 
        state_1:
            begin
                if((rx_ready == 1) && (full == 1))    begin			//单片机还在接收，FIFO填满
                    next_state <= state_2;
                end
				else	begin
					next_state <= state_1;
				end
            end
        state_2:
            begin
                if(rx_ready == 0)    begin							//单片机停止接收
                    next_state <= state_0;
                end
                else    begin
                    next_state <= state_2;
                end
            end 
      default: ;
    endcase
end
//------------------------------------------------//
always @(posedge clk) begin
    case (next_state)
        state_0:    
            begin   
                wr_en <= 0;
                rd_en <= 0;
                uart_en <= 0;
            end
        state_1:
            begin
                wr_en <= 1;
                rd_en <= 0;
                uart_en <= 0;
            end
        state_2:
            begin
                wr_en <= 0;
                rd_en <= 1;
                uart_en <= 1;
            end
        default: ;
    endcase
end
//-----------------------------------------------//

FIFO				FIFO_inst0(
  .wr_clk			(wr_clk),
  .rd_clk			(rd_clk),
  .din				(data_re),
  .wr_en			(wr_en),
  .rd_en			(rd_en),
  .dout				(data_out),
  .full				(full),
  .empty			(empty),
  .rd_data_count	(rd_data_count),
  .wr_data_count	(wr_data_count)
);



endmodule
