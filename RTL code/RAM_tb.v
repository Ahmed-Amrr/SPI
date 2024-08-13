module RAM_tb ();
	reg [9:0] din;
	reg clk,rst_n,rx_valid;
	wire [7:0] dout;
	wire tx_valid;
	RAM dut (clk,rst_n,din,rx_valid,dout,tx_valid);
	initial begin
		clk=0;
		forever begin
		#5; clk=~clk;	
		end
	end
	initial begin
	    $readmemh("mem.dat",dut.mem);
		rst_n=0; rx_valid=0; din=$random();
		@(negedge clk);
		rst_n=1; rx_valid=1;
		@(negedge clk); 
		repeat(1000) begin
			din=$random();
			@(negedge clk);
		end
		$stop;
	end	
endmodule 