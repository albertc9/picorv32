# PicoSoC for FPGA - Vivado项目创建脚本
# ======================================

# 设置项目参数
set project_name "picosoc_fpga"
set project_dir "./vivado_project"
set device_part "xc7a35tcpg236-1"  # 可根据需要修改

# 创建项目
create_project $project_name $project_dir -part $device_part -force

# 设置项目属性
set_property board_part digilentinc:arty-a7-35:part0:1.0 [current_project]
set_property target_language Verilog [current_project]

# 添加RTL文件 (按依赖顺序)
add_files -norecurse [list \
    "rtl/core/picorv32.v" \
    "rtl/peripheral/simpleuart.v" \
    "rtl/peripheral/spiflash.v" \
    "rtl/peripheral/spimemio.v" \
    "rtl/memory/ice40up5k_spram.v" \
    "rtl/soc/picorv32_soc.v" \
    "rtl/soc/picosoc.v" \
]

# 设置顶层模块
set_property top picosoc [current_fileset]
set_property top_file "rtl/soc/picosoc.v" [current_fileset]

# 添加约束文件
add_files -fileset constrs_1 -norecurse "constraints/vivado_template.xdc"

# 添加仿真文件
add_files -fileset sim_1 -norecurse [list \
    "testbench/simple_tb.v" \
    "testbench/picosoc_tb.v" \
]

# 设置仿真顶层
set_property top simple_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# 更新编译顺序
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Vivado项目创建完成！"
puts "项目名称: $project_name"
puts "项目路径: $project_dir"
puts "顶层模块: picosoc"
puts ""
puts "下一步操作:"
puts "1. 在Vivado中打开项目"
puts "2. 修改约束文件中的引脚分配"
puts "3. 运行综合和实现"
puts "4. 生成比特流文件" 