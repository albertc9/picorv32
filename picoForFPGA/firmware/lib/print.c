// 打印函数实现
// 用于picoSoC的UART输出

#include "firmware.h"

// UART寄存器地址
#define UART_DATA 0x02000008
#define UART_CLKDIV 0x02000004

// 写入UART数据寄存器
static void uart_putchar(char c) {
    *(volatile uint32_t*)UART_DATA = c;
}

// 打印单个字符
void print_chr(char ch) {
    uart_putchar(ch);
}

// 打印字符串
void print_str(const char *p) {
    while (*p) {
        uart_putchar(*p++);
    }
}

// 打印十进制数字
void print_dec(unsigned int val) {
    char buffer[16];
    int i = 0;
    
    // 处理0的特殊情况
    if (val == 0) {
        uart_putchar('0');
        return;
    }
    
    // 转换为字符串
    while (val > 0) {
        buffer[i++] = '0' + (val % 10);
        val /= 10;
    }
    
    // 反向打印
    while (i > 0) {
        uart_putchar(buffer[--i]);
    }
}

// 打印十六进制数字
void print_hex(unsigned int val, int digits) {
    for (int i = digits - 1; i >= 0; i--) {
        int digit = (val >> (i * 4)) & 0xF;
        if (digit < 10) {
            uart_putchar('0' + digit);
        } else {
            uart_putchar('a' + digit - 10);
        }
    }
} 