module SPI_top_module (mosi, ss_n, clk, rst_n, miso);

//Input ports
input clk, rst_n, ss_n;	//Control signals
input mosi;				//Master_out_slave_in input

//Output ports
output miso;			//Master_in_slave_out output

//Internal signals
wire[9:0] rx_data;			//The parallel data sent to RAM
wire rx_valid, tx_valid;	//Control signals for the read and write 
wire[7:0] tx_data;			//The parallel data sent from the RAM to SPI

//SPI module
SPI_Slave dut0 (mosi, ss_n, clk,rst_n, tx_valid, tx_data, miso, rx_valid, rx_data);

//RAM module
RAM dut1 (.clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), .tx_valid(tx_valid), .din(rx_data), .dout(tx_data));
endmodule