module SPI_Slave (mosi, ss_n, clk, rst_n, tx_valid, tx_data, miso, rx_valid, rx_data);

//State parameters
parameter IDLE=0;
parameter CHK_CMD=1;
parameter WRITE=2;
parameter READ_ADD=3;
parameter READ_DATA=4;

//Input ports
input mosi;							//Master_out_slave_in input
input ss_n, clk, rst_n, tx_valid;	//Control input signals
input[7:0] tx_data;					//The parallel data sent from the RAM to SPI

//Output ports
output reg miso;					//Master_in_slave_out output
output reg rx_valid; 				//Control signal
output reg[9:0] rx_data;			//The parallel data sent to RAM

//Internal signals
reg[3:0] counter,counter_rd_data;	//Counter for serial / parallel tranformations 
reg[2:0] cs,ns;						//State rergisters
reg end_counter_rd_data;			//Internal control signals

//Current state SQ logic
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) 
		cs<=IDLE;
	else
		cs<=ns;
end

//Next state combinational logic
always @(*) begin
	case (cs)
		IDLE: begin
			if (ss_n == 0)
				ns = CHK_CMD;
			else
				ns = IDLE;
		end
		CHK_CMD: begin
			if ((ss_n == 0) && rx_valid && (rx_data[9] == 0))
				ns = WRITE;
			else if ((ss_n == 0) && rx_valid && (rx_data[9:8] == 2'b10))
				ns = READ_ADD;
			else if ((ss_n == 0) && rx_valid && (rx_data[9:8] == 2'b11))
				ns = READ_DATA;
			else if(rx_valid == 0)
				ns = CHK_CMD;
			else
				ns = IDLE;
		end
		WRITE: begin
			if (ss_n == 1)
				ns = IDLE;
			else
				ns = WRITE;
		end
		READ_ADD: begin
			if (ss_n == 1)
				ns = IDLE;
			else
				ns = READ_ADD;
		end
		READ_DATA: begin
			if (ss_n == 1)
				ns = IDLE;
			else
				ns = READ_DATA;
		end
		default: ns = IDLE;
	endcase
end

//Serial mosi to parallel rx_data (from SPI to RAM)
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rx_data <= 0;
		counter <= 0;
		rx_valid <= 0;
	end
	else if (counter >= 10) begin
		counter <= 0;
		rx_valid <= 1;
	end
	else if((cs == CHK_CMD) && !rx_valid) begin
		rx_data[9-counter] <= mosi;
		counter <= counter + 1;
	end
	else if (cs == IDLE)
		rx_valid <= 0;
end

//Parallel tx_data to serial miso (read data from RAM to SPI)
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		miso <= 0;
		counter_rd_data <= 0;
		end_counter_rd_data <= 0;
	end
	else if (counter_rd_data >= 8) begin
		counter_rd_data <= 0;
		end_counter_rd_data <= 1;
	end
	else if ((cs == READ_DATA) && tx_valid && !end_counter_rd_data) begin
		miso <= tx_data[7-counter_rd_data];
		counter_rd_data <= counter_rd_data+1;
	end
	else if (cs == IDLE) begin
		end_counter_rd_data <= 0;
	end
end
endmodule