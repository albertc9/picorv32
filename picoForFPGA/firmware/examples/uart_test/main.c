/*
 * PicoRV32 UART测试示例
 * 演示UART通信和回显功能
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
    
    gpio_config(0, &led_config);  // LED0用于指示活动
    
    // 打印欢迎信息
    uart_puts("\n");
    uart_puts("========================================\n");
    uart_puts("  PicoRV32 UART Test Demo\n");
    uart_puts("========================================\n");
    uart_puts("\n");
    uart_puts("Commands:\n");
    uart_puts("  'h' - Print help\n");
    uart_puts("  's' - Print system info\n");
    uart_puts("  'l' - Toggle LED\n");
    uart_puts("  'e' - Echo mode\n");
    uart_puts("  'q' - Quit echo mode\n");
    uart_puts("  't' - Test pattern\n");
    uart_puts("\n");
    
    char command;
    bool echo_mode = false;
    uint32_t char_count = 0;
    
    while (1) {
        if (uart_available()) {
            char c;
            uart_getc(&c);
            char_count++;
            
            // 在echo模式下回显所有字符
            if (echo_mode) {
                if (c == 'q') {
                    echo_mode = false;
                    uart_puts("\nEcho mode disabled\n");
                    continue;
                }
                uart_putc(c);
                continue;
            }
            
            // 处理命令
            switch (c) {
                case 'h':
                case 'H':
                    uart_puts("\nCommands:\n");
                    uart_puts("  'h' - Print help\n");
                    uart_puts("  's' - Print system info\n");
                    uart_puts("  'l' - Toggle LED\n");
                    uart_puts("  'e' - Echo mode\n");
                    uart_puts("  'q' - Quit echo mode\n");
                    uart_puts("  't' - Test pattern\n");
                    uart_puts("\n");
                    break;
                    
                case 's':
                case 'S':
                    uart_puts("\nSystem Information:\n");
                    uart_printf("  System Clock: %u Hz\n", SYSTEM_CLOCK_HZ);
                    uart_printf("  UART Baudrate: %u\n", UART_BAUDRATE_DEF);
                    uart_printf("  SRAM Size: %u bytes\n", SRAM_SIZE);
                    uart_printf("  Flash Size: %u bytes\n", FLASH_SIZE);
                    uart_printf("  Characters received: %u\n", char_count);
                    uart_puts("\n");
                    break;
                    
                case 'l':
                case 'L':
                    gpio_toggle(0);
                    uart_puts("\nLED toggled\n");
                    break;
                    
                case 'e':
                case 'E':
                    echo_mode = true;
                    uart_puts("\nEcho mode enabled. Type 'q' to quit.\n");
                    break;
                    
                case 't':
                case 'T':
                    uart_puts("\nTest pattern:\n");
                    uart_puts("0123456789ABCDEF\n");
                    uart_puts("abcdefghijklmnop\n");
                    uart_puts("!@#$%^&*()_+-=[]\n");
                    uart_puts("{}|\\:;\"'<>?,./\n");
                    uart_puts("\n");
                    break;
                    
                case '\r':
                case '\n':
                    uart_puts("\n");
                    break;
                    
                default:
                    uart_printf("\nUnknown command: '%c' (0x%02X)\n", c, c);
                    uart_puts("Type 'h' for help\n");
                    break;
            }
        }
        
        // 短暂延时
        delay_ms(10);
    }
    
    return 0;
} 