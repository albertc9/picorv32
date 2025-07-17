/*
 * PicoRV32 系统初始化实现
 */

#include "system.h"
#include "uart.h"
#include "gpio.h"

// 系统状态
static uint32_t system_status = 0;

// 系统初始化
void system_init(void) {
    // 初始化GPIO
    gpio_init();
    
    // 初始化UART
    uart_init(UART_BAUDRATE_DEF);
    
    // 设置系统状态
    system_status = 0x01;  // 系统已初始化
    
    // 打印启动信息
    uart_puts("PicoRV32 System Initialized\n");
}

// 系统重置
void system_reset(void) {
    // 禁用所有中断
    disable_global_irq();
    
    // 清零系统状态
    system_status = 0;
    
    // 跳转到启动代码
    __asm__ volatile("j _start");
}

// 获取系统状态
uint32_t system_get_status(void) {
    return system_status;
}

// 系统错误处理
void system_error(error_t error, const char* message) {
    uart_puts("System Error: ");
    uart_puts(message);
    uart_puts("\n");
    
    // 根据错误类型处理
    switch (error) {
        case ERROR_INVALID_PARAM:
            uart_puts("Invalid parameter\n");
            break;
        case ERROR_TIMEOUT:
            uart_puts("Operation timeout\n");
            break;
        case ERROR_HARDWARE:
            uart_puts("Hardware error\n");
            break;
        case ERROR_NOT_SUPPORTED:
            uart_puts("Operation not supported\n");
            break;
        default:
            uart_puts("Unknown error\n");
            break;
    }
} 