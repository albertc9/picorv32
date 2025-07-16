# Xilinx Vivado 综合脚本
# ======================

# 设置项目参数
set project_name "picorv32_fpga"
set top_module "artix7_demo"
set device "xc7a35t-csg324-1"

# 创建项目
create_project $project_name . -part $device -force

# 设置项目属性
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]

# 添加源文件
add_files -norecurse {
    ../../rtl/core/picorv32.v
    ../../rtl/peripherals/picorv32_soc.v
    ../../rtl/peripherals/picosoc.v
    ../../rtl/peripherals/spimemio.v
    ../../rtl/peripherals/simpleuart.v
    ../../rtl/peripherals/spiflash.v
    ../../examples/xilinx7/artix7_demo.v
}

# 设置顶层模块
set_property top $top_module [current_fileset]

# 添加约束文件
add_files -fileset constrs_1 -norecurse {
    ../../constraints/artix7_demo.xdc
}

# 运行综合
synth_design -top $top_module -part $device

# 生成报告
report_timing_summary -file timing_summary.rpt
report_utilization -file utilization.rpt
report_power -file power.rpt

# 运行实现
opt_design
place_design
route_design

# 生成比特流
write_bitstream -file $project_name.bit

# 生成调试文件
write_debug_probes -file $project_name.ltx

puts "综合完成！"
puts "比特流文件: $project_name.bit"
puts "调试文件: $project_name.ltx" 