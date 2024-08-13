module SPI_top_module_tb ();

//Ports
reg mosi, ss_n, clk,rst_n;
wire miso;

//The SPI module
SPI_top_module dut (mosi, ss_n, clk, rst_n, miso);

//Initiate the clock
initial begin
	clk=0;
	forever
	    #2 clk=~clk;
end

//The test bench
integer i;
initial begin

    //Test reset & intiate signals
    mosi = 0;   ss_n = 1;
    rst_n = 0;
    @(negedge clk);
    if (miso != 0) begin
        $display("there was an error");
        $stop;
    end

    rst_n = 1;  //Release the reset button

    //Test write & its address
    repeat (1000) begin
        ss_n = 0;                           //Release the ss_n to start communication
        @(negedge clk);

        //Sends the Write address
        for (i = 0; i < 10; i = i + 1) begin
            if (i < 2) begin
                mosi = 0;                   //first 2 bits are 00 to intiate write address
            end
            else
                mosi = $random;             //sends 8 bits to be stored in the write address
            @(negedge clk);
        end

        repeat(2) @(negedge clk);           //Wait for the write address to read din in 2 clocks

        ss_n = 1;                           //Set ss_n to stop the communication and start new one
        @(negedge clk);

        ss_n = 0;                           //Release the ss_n to start new task
        @(negedge clk);

        //Sends the data to be stored
        for (i = 0; i < 10; i = i + 1) begin
            if (i == 0) begin
                mosi = 0;                   //first 2 bits are 01 to intiate write data
            end
            else if (i == 1) begin
                mosi = 1;
            end
            else
                mosi = $random;             //sends 8 bits to be stored in the memory
            @(negedge clk);
        end

        repeat(2) @(negedge clk);           //Wait for the RAM to store din in 2 clocks

        ss_n = 1;                           //Set ss_n to stop the communication and start new one
        @(negedge clk);
    end
    $stop;                                  //Pause the sim after writing the memory

    //test Read & its address
    repeat (1000) begin
        ss_n = 0;                           //Release the ss_n to start communication
        @(negedge clk);

        // sends the Read address
        for (i = 0; i < 10; i = i + 1) begin
            if (i == 0) begin
                mosi = 1;                   //first 2 bits are 10 to intiate Read address
            end
            else if (i == 1) begin
                mosi = 0;
            end
            else
                mosi = $random;             //sends 8 bits to be stored in the Read address
            @(negedge clk);
        end

        repeat(2) @(negedge clk);           //Wait for the read address to store din in 2 clocks

        ss_n = 1;                           //Set ss_n to stop the communication and start new one
        @(negedge clk);

        ss_n = 0;                           //Release the ss_n to start a new task
        @(negedge clk);

        //Receives the read data
        for (i = 0; i < 10; i = i + 1) begin
            if (i < 2) begin
                mosi = 1;                   //first 2 bits are 11 to intiate read data
            end
            else
                mosi = $random;             //the rest of the 8 bits are dummy data
            @(negedge clk);
        end

        repeat(2) @(negedge clk);           //Wait for the RAM to send the data on TX_data from mem read address stored

        repeat(9) @(negedge clk);           //Wait for the SPI slave to transfer the TX_data from parallel to series on the miso

        ss_n = 1;                           //Set ss_n to stop the communication and start new one
        @(negedge clk);
    end
    $stop;                                  //End of simulation
end
endmodule