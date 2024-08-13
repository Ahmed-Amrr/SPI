module RAM (clk, rst_n, din, rx_valid, dout, tx_valid);

//Parameters
parameter MEM_DEPTH = 256;  //Size of the memory
parameter ADDR_SIZE = 8;    //Size of the word

//Input ports
input [ADDR_SIZE + 1 : 0] din;  //the MSB 2-bits are control bits, the LSB 8-bits are input data to RAM
input clk, rst_n, rx_valid;     //Control input signals

//Output ports
output reg [ADDR_SIZE - 1 : 0]dout; //8-bits Output data from the RAM
output reg tx_valid;                //Control output signal

reg [ADDR_SIZE - 1 : 0] mem [MEM_DEPTH - 1 : 0];    //Memory
reg [ADDR_SIZE - 1 : 0] w_addr,r_addr;              //Internal registers to store the read and write addresses
reg [ADDR_SIZE - 1 : 0] data;                       //Internal reg to save the data of the LSB 8-bits
reg [1:0] opcode;             //Internal reg to save the opcode of the MSB 2-bits
//RAM sequential logic
always @(posedge clk or negedge rst_n) begin
    //Active low async reset
    if(~rst_n)  begin
        dout <= 0;
        tx_valid <= 0;
        w_addr <= 0;
        r_addr <=0;
        data <= 0;
        opcode <= 0;
    end
    //rx_valid refers to that there is data on din ready to be read
    else if (rx_valid) begin
        //The LSB 8-bits are the data to be stored
        data <= din[ADDR_SIZE-1 : 0];
        //The MSB 2-bits are the opcode
        opcode <= din[ADDR_SIZE + 1 : ADDR_SIZE];
        //The MSB 2-bits are control signals
        case (opcode)
            2'b00: w_addr <= data;      //Store the Write addres
            2'b01: mem[w_addr] <= data; //Write the data in the stored write address
            2'b10: r_addr <= data;      //Store the Read address
            2'b11: begin                //Read the data stored in memory at read address
                dout <= mem[r_addr];
                tx_valid <= 1;
            end
        endcase
    end
end
endmodule