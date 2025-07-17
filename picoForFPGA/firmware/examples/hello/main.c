/*
 * PicoRV32 Hello World示例
 * 演示基本的UART输出和LED控制
 */

#include "system.h"
#include "uart.h"
#include "gpio.h"

int main() {
    // 初始化系统
    system_init();
    
    // 初始化UART
    uart_init(UART_BAUDRATE_DEF);
    
    // 初始化GPIO
    gpio_init();
    
    // 配置LED为输出
    gpio_config_t led_config = {
        .direction = GPIO_DIR_OUTPUT,
        .pull = GPIO_PULL_NONE,
        .irq_trigger = GPIO_IRQ_NONE,
        .irq_enable = false
    };
    
    for (int i = 0; i < 8; i++) {
        gpio_config(i, &led_config);
    }
    
    // 打印欢迎信息
    uart_puts("\n");
    uart_puts("========================================\n");
    uart_puts("  PicoRV32 Hello World Demo\n");
    uart_puts("========================================\n");
    uart_puts("\n");
    
    // 显示系统信息
    uart_printf("System Clock: %u Hz\n", SYSTEM_CLOCK_HZ);
    uart_printf("UART Baudrate: %u\n", UART_BAUDRATE_DEF);
    uart_printf("SRAM Size: %u bytes\n", SRAM_SIZE);
    uart_printf("Flash Size: %u bytes\n", FLASH_SIZE);
    uart_puts("\n");
    
    // LED跑马灯演示
    uart_puts("Starting LED demo...\n");
    
    uint8_t led_pattern = 0x01;
    int direction = 1;  // 1 = 左移, 0 = 右移
    
    while (1) {
        // 设置LED模式
        gpio_set_leds(led_pattern);
        
        // 打印当前LED状态
        uart_printf("LED Pattern: 0x%02X ", led_pattern);
        for (int i = 7; i >= 0; i--) {
            uart_putc((led_pattern & (1 << i)) ? '1' : '0');
        }
        uart_puts("\n");
        
        // 更新LED模式
        if (direction) {
            led_pattern <<= 1;
            if (led_pattern == 0) {
                led_pattern = 0x80;
                direction = 0;
            }
        } else {
            led_pattern >>= 1;
            if (led_pattern == 0) {
                led_pattern = 0x01;
                direction = 1;
            }
        }
        
        // 延时
        delay_ms(500);
    }
    
    return 0;
}

