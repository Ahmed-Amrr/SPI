module SPI_Slave_tb ();

	reg mosi,ss_n,clk,rst_n,tx_valid;
	reg[7:0] tx_data;
	wire miso,rx_valid; // rx_valid show the counter ends
	wire[9:0] rx_data;

	SPI_Slave dut0 (mosi,ss_n,clk,rst_n,tx_valid,tx_data,miso,rx_valid,rx_data);

	initial begin
		clk=0;
		forever
		#2 clk=~clk;
	end

	initial begin
//1
		rst_n=0; mosi=$random; ss_n=1; tx_valid=1; tx_data=$random;
		@(negedge clk);
//2
		rst_n=1; mosi=$random; ss_n=1; tx_valid=1; tx_data=$random;
		@(negedge clk);
//3
		ss_n=0; tx_data=$random;  tx_valid=1;
		repeat(30) begin
			mosi=$random; ss_n=0;
			@(negedge clk);
		end
		ss_n=1;
		@(negedge clk);

//4
		ss_n=0; tx_data=$random; tx_valid=1;
		repeat(30) begin
			mosi=$random; ss_n=0;
			@(negedge clk);
		end
		ss_n=1;
		@(negedge clk);

//5
		ss_n=0; tx_data=$random; tx_valid=1;
		repeat(30) begin
			mosi=$random; ss_n=0;
			@(negedge clk);
		end
		ss_n=1;
		@(negedge clk);

		$stop;
	end

	initial begin
		$monitor("rst_n=%b ,ss_n=%b ,mosi=%b ,rx_valid=%b ,rx_data=%b ,tx_valid=%b ,tx_data=%b ,miso=%b",rst_n,ss_n,mosi,rx_valid,rx_data,tx_valid,tx_data,miso);
	end

endmodule