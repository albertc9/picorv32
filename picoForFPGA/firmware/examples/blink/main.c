/*
 * PicoRV32 LED闪烁示例
 * 演示简单的LED控制和定时
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
    
    // 配置所有LED
    for (int i = 0; i < 8; i++) {
        gpio_config(i, &led_config);
    }
    
    // 打印启动信息
    uart_puts("\n");
    uart_puts("PicoRV32 LED Blink Demo\n");
    uart_puts("Press any key to change pattern\n");
    uart_puts("\n");
    
    uint8_t pattern = 0;
    uint32_t blink_count = 0;
    
    while (1) {
        // 切换LED状态
        if (pattern == 0) {
            // 所有LED同时闪烁
            gpio_set_leds(0xFF);
            uart_puts("All LEDs ON\n");
        } else if (pattern == 1) {
            // 交替闪烁
            gpio_set_leds(0xAA);
            uart_puts("Alternating pattern\n");
        } else if (pattern == 2) {
            // 奇偶交替
            gpio_set_leds(0x55);
            uart_puts("Odd/Even pattern\n");
        } else if (pattern == 3) {
            // 二进制计数
            gpio_set_leds(blink_count & 0xFF);
            uart_printf("Binary count: %u\n", blink_count & 0xFF);
        }
        
        // 延时
        delay_ms(1000);
        
        // 关闭所有LED
        gpio_set_leds(0x00);
        uart_puts("All LEDs OFF\n");
        
        delay_ms(500);
        
        // 检查是否有按键输入
        if (uart_available()) {
            char c;
            uart_getc(&c);
            pattern = (pattern + 1) % 4;
            uart_printf("Pattern changed to %u\n", pattern);
        }
        
        blink_count++;
    }
    
    return 0;
} 