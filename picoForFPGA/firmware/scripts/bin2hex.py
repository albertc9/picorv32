#!/usr/bin/env python3
"""
二进制文件转十六进制格式脚本
用于生成Verilog内存初始化文件
"""

import sys
import os

def bin_to_hex(bin_file, hex_file, width=32):
    """
    将二进制文件转换为十六进制格式
    
    Args:
        bin_file: 输入二进制文件路径
        hex_file: 输出十六进制文件路径
        width: 数据宽度 (8, 16, 32)
    """
    
    if not os.path.exists(bin_file):
        print(f"错误: 输入文件 {bin_file} 不存在")
        return False
    
    try:
        with open(bin_file, 'rb') as f:
            data = f.read()
    except Exception as e:
        print(f"错误: 无法读取文件 {bin_file}: {e}")
        return False
    
    try:
        with open(hex_file, 'w') as f:
            # 写入文件头
            f.write("// 自动生成的十六进制文件\n")
            f.write(f"// 源文件: {bin_file}\n")
            f.write(f"// 数据宽度: {width}位\n")
            f.write(f"// 数据长度: {len(data)}字节\n\n")
            
            # 根据宽度处理数据
            if width == 8:
                # 8位数据
                for i, byte in enumerate(data):
                    f.write(f"{byte:02X}\n")
                    
            elif width == 16:
                # 16位数据 (小端序)
                for i in range(0, len(data), 2):
                    if i + 1 < len(data):
                        word = data[i] | (data[i + 1] << 8)
                    else:
                        word = data[i]
                    f.write(f"{word:04X}\n")
                    
            elif width == 32:
                # 32位数据 (小端序)
                for i in range(0, len(data), 4):
                    word = 0
                    for j in range(4):
                        if i + j < len(data):
                            word |= data[i + j] << (j * 8)
                    f.write(f"{word:08X}\n")
                    
            else:
                print(f"错误: 不支持的数据宽度 {width}")
                return False
                
    except Exception as e:
        print(f"错误: 无法写入文件 {hex_file}: {e}")
        return False
    
    print(f"成功: 转换 {len(data)} 字节到 {hex_file}")
    return True

def main():
    if len(sys.argv) < 3:
        print("用法: python3 bin2hex.py <输入文件> <输出文件> [宽度]")
        print("  宽度: 8, 16, 或 32 (默认: 32)")
        sys.exit(1)
    
    bin_file = sys.argv[1]
    hex_file = sys.argv[2]
    width = int(sys.argv[3]) if len(sys.argv) > 3 else 32
    
    if width not in [8, 16, 32]:
        print("错误: 宽度必须是 8, 16, 或 32")
        sys.exit(1)
    
    if not bin_to_hex(bin_file, hex_file, width):
        sys.exit(1)

if __name__ == "__main__":
    main() 