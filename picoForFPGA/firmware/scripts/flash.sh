#!/bin/bash
#
# PicoRV32 通用下载脚本
# 支持多种FPGA平台的固件下载
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "PicoRV32 通用下载脚本"
    echo ""
    echo "用法: $0 <平台> <板卡> <固件文件>"
    echo ""
    echo "参数:"
    echo "  平台     - ice40, xilinx, generic"
    echo "  板卡     - icebreaker, hx8k, arty, basys3, etc."
    echo "  固件文件 - 要下载的.bin文件路径"
    echo ""
    echo "示例:"
    echo "  $0 ice40 icebreaker build/hello/hello.bin"
    echo "  $0 xilinx arty build/blink/blink.bin"
    echo ""
}

# 检查依赖工具
check_dependencies() {
    local platform=$1
    
    case $platform in
        ice40)
            if ! command -v iceprog &> /dev/null; then
                print_error "iceprog 未找到，请安装 icestorm 工具链"
                exit 1
            fi
            if ! command -v yosys &> /dev/null; then
                print_warning "yosys 未找到，某些功能可能不可用"
            fi
            ;;
        xilinx)
            if ! command -v vivado &> /dev/null; then
                print_error "vivado 未找到，请安装 Xilinx Vivado"
                exit 1
            fi
            ;;
        *)
            print_warning "未知平台 $platform，跳过依赖检查"
            ;;
    esac
}

# 检查设备连接
check_device() {
    local platform=$1
    local board=$2
    
    case $platform in
        ice40)
            if ! lsusb | grep -q "1d50:6026\|0403:6010"; then
                print_error "未检测到 iCE40 设备"
                print_info "请检查USB连接和驱动安装"
                exit 1
            fi
            ;;
        xilinx)
            if ! lsusb | grep -q "03fd:0008\|03fd:0009"; then
                print_error "未检测到 Xilinx 设备"
                print_info "请检查USB连接和驱动安装"
                exit 1
            fi
            ;;
        *)
            print_warning "未知平台 $platform，跳过设备检查"
            ;;
    esac
}

# iCE40平台下载
flash_ice40() {
    local board=$1
    local firmware=$2
    
    print_info "开始下载到 iCE40 $board..."
    
    case $board in
        icebreaker)
            # 下载到iCEBreaker板
            print_info "使用 iceprog 下载到 iCEBreaker..."
            iceprog -S "$firmware"
            ;;
        hx8k)
            # 下载到HX8K板
            print_info "使用 iceprog 下载到 HX8K..."
            iceprog "$firmware"
            ;;
        up5k)
            # 下载到UP5K板
            print_info "使用 iceprog 下载到 UP5K..."
            iceprog -S "$firmware"
            ;;
        *)
            print_error "不支持的 iCE40 板卡: $board"
            exit 1
            ;;
    esac
    
    print_success "下载完成"
}

# Xilinx平台下载
flash_xilinx() {
    local board=$1
    local firmware=$2
    
    print_info "开始下载到 Xilinx $board..."
    
    case $board in
        arty)
            # 下载到Arty A7板
            print_info "使用 Vivado 下载到 Arty A7..."
            # 这里需要根据具体的bitstream文件来实现
            print_warning "Xilinx下载功能需要bitstream文件，请手动实现"
            ;;
        basys3)
            # 下载到Basys3板
            print_info "使用 Vivado 下载到 Basys3..."
            print_warning "Xilinx下载功能需要bitstream文件，请手动实现"
            ;;
        *)
            print_error "不支持的 Xilinx 板卡: $board"
            exit 1
            ;;
    esac
    
    print_success "下载完成"
}

# 通用平台下载
flash_generic() {
    local board=$1
    local firmware=$2
    
    print_info "开始下载到通用平台 $board..."
    print_warning "通用平台下载功能需要根据具体硬件实现"
    print_info "固件文件: $firmware"
    print_info "请手动下载固件到目标设备"
}

# 主函数
main() {
    # 检查参数
    if [ $# -lt 3 ]; then
        show_help
        exit 1
    fi
    
    local platform=$1
    local board=$2
    local firmware=$3
    
    # 检查固件文件
    if [ ! -f "$firmware" ]; then
        print_error "固件文件不存在: $firmware"
        exit 1
    fi
    
    print_info "平台: $platform"
    print_info "板卡: $board"
    print_info "固件: $firmware"
    print_info "固件大小: $(du -h "$firmware" | cut -f1)"
    
    # 检查依赖
    check_dependencies "$platform"
    
    # 检查设备连接
    check_device "$platform" "$board"
    
    # 根据平台执行下载
    case $platform in
        ice40)
            flash_ice40 "$board" "$firmware"
            ;;
        xilinx)
            flash_xilinx "$board" "$firmware"
            ;;
        generic)
            flash_generic "$board" "$firmware"
            ;;
        *)
            print_error "不支持的平台: $platform"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 