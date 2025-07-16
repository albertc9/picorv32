# Artix-7 FPGA 约束文件
# ======================

# 时钟约束
create_clock -period 10.000 -name clk100 -waveform {0.000 5.000} [get_ports clk100]

# 时钟属性
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk100]

# 复位信号
set_property PACKAGE_PIN P16 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

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
set_property PACKAGE_PIN D22 [get_ports flash_wp_n]
set_property IOSTANDARD LVCMOS33 [get_ports flash_wp_n]
set_property PACKAGE_PIN D23 [get_ports flash_hold_n]
set_property IOSTANDARD LVCMOS33 [get_ports flash_hold_n]

# LED指示灯
set_property PACKAGE_PIN H17 [get_ports {leds[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[0]}]
set_property PACKAGE_PIN H16 [get_ports {leds[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[1]}]
set_property PACKAGE_PIN H15 [get_ports {leds[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[2]}]
set_property PACKAGE_PIN H14 [get_ports {leds[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[3]}]
set_property PACKAGE_PIN G17 [get_ports {leds[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[4]}]
set_property PACKAGE_PIN G16 [get_ports {leds[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[5]}]
set_property PACKAGE_PIN G15 [get_ports {leds[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[6]}]
set_property PACKAGE_PIN G14 [get_ports {leds[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {leds[7]}]

# 按钮
set_property PACKAGE_PIN M18 [get_ports {buttons[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {buttons[0]}]
set_property PACKAGE_PIN L18 [get_ports {buttons[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {buttons[1]}]
set_property PACKAGE_PIN K18 [get_ports {buttons[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {buttons[2]}]
set_property PACKAGE_PIN J18 [get_ports {buttons[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {buttons[3]}]

# 开关
set_property PACKAGE_PIN M13 [get_ports {switches[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[0]}]
set_property PACKAGE_PIN R15 [get_ports {switches[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[1]}]
set_property PACKAGE_PIN R17 [get_ports {switches[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[2]}]
set_property PACKAGE_PIN T18 [get_ports {switches[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[3]}]
set_property PACKAGE_PIN U18 [get_ports {switches[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[4]}]
set_property PACKAGE_PIN R13 [get_ports {switches[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[5]}]
set_property PACKAGE_PIN T8 [get_ports {switches[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[6]}]
set_property PACKAGE_PIN U8 [get_ports {switches[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {switches[7]}]

# 时序约束
set_false_path -from [get_ports rst_n]
set_false_path -to [get_ports {leds[*]}]
set_false_path -from [get_ports {buttons[*]}]
set_false_path -from [get_ports {switches[*]}]

# 配置约束
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_MODE SPIx4 [current_design] 