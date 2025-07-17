#!/bin/bash
#
# PicoRV32 串口监视器脚本
# 提供串口通信和调试功能
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
DEFAULT_BAUDRATE=115200
DEFAULT_DEVICE="/dev/ttyUSB0"

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

print_data() {
    echo -e "${CYAN}$1${NC}"
}

# 显示帮助信息
show_help() {
    echo "PicoRV32 串口监视器"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -d, --device <设备>     串口设备 (默认: $DEFAULT_DEVICE)"
    echo "  -b, --baudrate <波特率>  波特率 (默认: $DEFAULT_BAUDRATE)"
    echo "  -p, --platform <平台>   目标平台 (ice40, xilinx, generic)"
    echo "  -h, --help             显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -d /dev/ttyUSB1 -b 115200"
    echo "  $0 --platform ice40 --device /dev/ttyACM0"
    echo ""
}

# 检查串口设备
check_device() {
    local device=$1
    
    if [ ! -e "$device" ]; then
        print_error "串口设备不存在: $device"
        print_info "可用的串口设备:"
        ls /dev/tty* 2>/dev/null | grep -E "(USB|ACM)" || print_warning "未找到USB串口设备"
        exit 1
    fi
    
    if [ ! -r "$device" ] || [ ! -w "$device" ]; then
        print_error "没有串口设备的读写权限: $device"
        print_info "请检查用户权限或使用sudo"
        exit 1
    fi
}

# 检测串口设备
detect_device() {
    local platform=$1
    
    # 常见的串口设备
    local devices=(
        "/dev/ttyUSB0"
        "/dev/ttyUSB1"
        "/dev/ttyACM0"
        "/dev/ttyACM1"
        "/dev/ttyS0"
        "/dev/ttyS1"
    )
    
    for device in "${devices[@]}"; do
        if [ -e "$device" ] && [ -r "$device" ] && [ -w "$device" ]; then
            print_info "检测到可用串口设备: $device"
            echo "$device"
            return 0
        fi
    done
    
    print_error "未找到可用的串口设备"
    return 1
}

# 设置串口参数
setup_serial() {
    local device=$1
    local baudrate=$2
    
    # 设置串口参数
    stty -F "$device" \
        $baudrate \
        raw \
        -echo \
        -echoe \
        -echok \
        -echonl \
        -icanon \
        -iexten \
        -isig \
        -ixon \
        -ixoff \
        -opost \
        -onlcr \
        -onocr \
        -onlret \
        -ofill \
        -ofdel \
        crtscts \
        clocal \
        hupcl \
        cread \
        -hupcl \
        -clocal \
        -crtscts \
        -cread \
        -ignbrk \
        -brkint \
        -ignpar \
        -parmrk \
        -inpck \
        -istrip \
        -inlcr \
        -igncr \
        -icrnl \
        -iuclc \
        -ixon \
        -ixany \
        -ixoff \
        -imaxbel \
        -iutf8 \
        -opost \
        -olcuc \
        -ocrnl \
        -onlcr \
        -onocr \
        -onlret \
        -ofill \
        -ofdel \
        -echoe \
        -echok \
        -echonl \
        -noflsh \
        -xcase \
        -tostop \
        -echoprt \
        -echoctl \
        -echoke
}

# 启动串口监视器
start_monitor() {
    local device=$1
    local baudrate=$2
    
    print_info "启动串口监视器..."
    print_info "设备: $device"
    print_info "波特率: $baudrate"
    print_info "按 Ctrl+C 退出"
    echo ""
    
    # 设置串口参数
    setup_serial "$device" "$baudrate"
    
    # 启动cat命令读取串口数据
    cat "$device" &
    local cat_pid=$!
    
    # 等待用户输入并发送到串口
    while true; do
        if read -r line; then
            echo "$line" > "$device"
        fi
    done &
    local input_pid=$!
    
    # 等待任意子进程结束
    wait -n
    
    # 清理子进程
    kill $cat_pid $input_pid 2>/dev/null || true
}

# 使用screen启动串口监视器
start_screen() {
    local device=$1
    local baudrate=$2
    
    print_info "使用screen启动串口监视器..."
    print_info "设备: $device"
    print_info "波特率: $baudrate"
    print_info "退出screen: Ctrl+A, K"
    echo ""
    
    screen "$device" "$baudrate"
}

# 使用minicom启动串口监视器
start_minicom() {
    local device=$1
    local baudrate=$2
    
    print_info "使用minicom启动串口监视器..."
    print_info "设备: $device"
    print_info "波特率: $baudrate"
    print_info "退出minicom: Ctrl+A, X"
    echo ""
    
    minicom -D "$device" -b "$baudrate"
}

# 主函数
main() {
    local device=""
    local baudrate=$DEFAULT_BAUDRATE
    local platform=""
    local use_screen=false
    local use_minicom=false
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--device)
                device="$2"
                shift 2
                ;;
            -b|--baudrate)
                baudrate="$2"
                shift 2
                ;;
            -p|--platform)
                platform="$2"
                shift 2
                ;;
            --screen)
                use_screen=true
                shift
                ;;
            --minicom)
                use_minicom=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定设备，尝试自动检测
    if [ -z "$device" ]; then
        device=$(detect_device "$platform")
        if [ $? -ne 0 ]; then
            exit 1
        fi
    fi
    
    # 检查设备
    check_device "$device"
    
    # 根据可用的工具选择串口监视器
    if [ "$use_screen" = true ] && command -v screen &> /dev/null; then
        start_screen "$device" "$baudrate"
    elif [ "$use_minicom" = true ] && command -v minicom &> /dev/null; then
        start_minicom "$device" "$baudrate"
    elif command -v screen &> /dev/null; then
        print_info "使用screen作为串口监视器"
        start_screen "$device" "$baudrate"
    elif command -v minicom &> /dev/null; then
        print_info "使用minicom作为串口监视器"
        start_minicom "$device" "$baudrate"
    else
        print_warning "未找到screen或minicom，使用基本的cat命令"
        start_monitor "$device" "$baudrate"
    fi
}

# 执行主函数
main "$@" 