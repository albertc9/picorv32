#!/usr/bin/env tclsh
#
# Xilinx Vivado下载脚本
# 用于将固件下载到A7系列FPGA
#

# 获取命令行参数
set bitstream_file [lindex $argv 0]
set firmware_file [lindex $argv 1]

# 检查参数
if {$bitstream_file == ""} {
    puts "错误: 请指定bitstream文件"
    puts "用法: vivado -mode batch -source xilinx_flash.tcl -tclargs <bitstream.bit> [firmware.bin]"
    exit 1
}

# 检查bitstream文件是否存在
if {![file exists $bitstream_file]} {
    puts "错误: bitstream文件不存在: $bitstream_file"
    exit 1
}

puts "开始下载到Xilinx A7 FPGA..."
puts "Bitstream文件: $bitstream_file"

# 打开硬件管理器
open_hw_manager

# 连接到硬件
connect_hw_server

# 获取硬件目标
set hw_targets [get_hw_targets]
if {[llength $hw_targets] == 0} {
    puts "错误: 未找到硬件目标"
    puts "请检查FPGA连接和驱动安装"
    exit 1
}

# 使用第一个可用的目标
set hw_target [lindex $hw_targets 0]
puts "使用硬件目标: $hw_target"

# 打开目标
open_hw_target $hw_target

# 获取设备
set hw_devices [get_hw_devices]
if {[llength $hw_devices] == 0} {
    puts "错误: 未找到硬件设备"
    exit 1
}

# 使用第一个设备
set hw_device [lindex $hw_devices 0]
puts "使用硬件设备: $hw_device"

# 设置当前设备
current_hw_device $hw_device

# 刷新硬件设备
refresh_hw_device -update_hw_probes false $hw_device

# 下载bitstream
puts "下载bitstream..."
set_property PROGRAM.FILE $bitstream_file $hw_device
program_hw_devices $hw_device

puts "Bitstream下载完成"

# 如果有固件文件，尝试下载到Flash
if {$firmware_file != "" && [file exists $firmware_file]} {
    puts "下载固件到Flash: $firmware_file"
    
    # 这里需要根据具体的Flash控制器来实现
    # 目前只是显示信息
    puts "注意: 固件下载功能需要根据具体的Flash控制器实现"
    puts "请手动将固件文件复制到Flash的适当位置"
}

# 关闭硬件管理器
close_hw_manager

puts "下载完成" 