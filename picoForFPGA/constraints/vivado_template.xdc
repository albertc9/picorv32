# PicoSoC Vivado约束文件模板
# ================================

# 时钟约束
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# 复位信号
set_property PACKAGE_PIN P16 [get_ports resetn]
set_property IOSTANDARD LVCMOS33 [get_ports resetn]

# UART接口
set_property PACKAGE_PIN B18 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
set_property PACKAGE_PIN B17 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]

# SPI Flash接口
set_property PACKAGE_PIN D18 [get_ports flash_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports flash_cs_n]
set_property PACKAGE_PIN D19 [get_ports flash_clk]
set_property IOSTANDARD LVCMOS33 [get_ports flash_clk]
set_property PACKAGE_PIN D20 [get_ports flash_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports flash_mosi]
set_property PACKAGE_PIN D21 [get_ports flash_miso]
set_property IOSTANDARD LVCMOS33 [get_ports flash_miso]

# GPIO接口 (LED)
set_property PACKAGE_PIN H17 [get_ports {gpio[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN H16 [get_ports {gpio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN H15 [get_ports {gpio[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[2]}]
set_property PACKAGE_PIN H14 [get_ports {gpio[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[3]}]

# 时序约束
set_false_path -from [get_ports resetn]
set_false_path -to [get_ports {gpio[*]}]
set_false_path -from [get_ports {buttons[*]}]
set_false_path -from [get_ports {switches[*]}]

# 配置约束
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design] 