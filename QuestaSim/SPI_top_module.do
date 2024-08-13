vlib work
vlog RAM.v SPI_Slave.v SPI_top_module.v SPI_top_module_tb.v
vsim -voptargs=+acc work.SPI_top_module_tb
add wave *
add wave -position insertpoint  \
sim:/SPI_top_module_tb/dut/rx_data \
sim:/SPI_top_module_tb/dut/rx_valid \
sim:/SPI_top_module_tb/dut/tx_valid \
sim:/SPI_top_module_tb/dut/tx_data
add wave -position insertpoint  \
sim:/SPI_top_module_tb/dut/dut1/mem \
sim:/SPI_top_module_tb/dut/dut1/w_addr \
sim:/SPI_top_module_tb/dut/dut1/r_addr
run -all
#quit -sim