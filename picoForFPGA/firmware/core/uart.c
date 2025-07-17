/*
 * PicoRV32 UART驱动实现
 * 提供简单的UART通信功能
 */

#include "uart.h"
#include "system.h"
#include <stdint.h>
#include <stdarg.h>
#include <stddef.h>

// ============================================================================
// 内部变量
// ============================================================================

static uint32_t uart_baudrate = UART_BAUDRATE_DEF;
static bool uart_initialized = false;

// ============================================================================
// UART初始化函数
// ============================================================================

uart_status_t uart_init(uint32_t baudrate) {
    if (baudrate == 0) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    // 计算时钟分频器
    uint32_t clkdiv = SYSTEM_CLOCK_HZ / baudrate;
    if (clkdiv == 0) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    // 配置UART控制寄存器
    uint32_t ctrl = UART_CTRL_ENABLE;
    write_reg(UART_CTRL_REG, ctrl);
    
    // 设置时钟分频器
    write_reg(UART_CTRL_REG, ctrl | (clkdiv << 8));
    
    uart_baudrate = baudrate;
    uart_initialized = true;
    
    return UART_OK;
}

uart_status_t uart_init_config(const uart_config_t* config) {
    if (config == NULL) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    return uart_init(config->baudrate);
}

// ============================================================================
// UART发送函数
// ============================================================================

uart_status_t uart_putc(char c) {
    if (!uart_initialized) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    // 等待发送就绪
    uint32_t timeout = 10000; // 超时计数
    while (!uart_tx_ready() && timeout > 0) {
        timeout--;
        delay_cycles(10);
    }
    
    if (timeout == 0) {
        return UART_ERROR_TIMEOUT;
    }
    
    // 发送字符
    write_reg(UART_DATA_REG, c);
    
    // 处理换行符
    if (c == '\n') {
        uart_putc('\r');
    }
    
    return UART_OK;
}

uart_status_t uart_puts(const char* str) {
    if (str == NULL) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    while (*str) {
        uart_status_t status = uart_putc(*str++);
        if (status != UART_OK) {
            return status;
        }
    }
    
    return UART_OK;
}

uart_status_t uart_write(const uint8_t* data, uint32_t length) {
    if (data == NULL || length == 0) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    for (uint32_t i = 0; i < length; i++) {
        uart_status_t status = uart_putc(data[i]);
        if (status != UART_OK) {
            return status;
        }
    }
    
    return UART_OK;
}

// ============================================================================
// UART接收函数
// ============================================================================

uart_status_t uart_getc(char* c) {
    if (c == NULL || !uart_initialized) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    // 等待接收就绪
    uint32_t timeout = 10000; // 超时计数
    while (!uart_rx_ready() && timeout > 0) {
        timeout--;
        delay_cycles(10);
    }
    
    if (timeout == 0) {
        return UART_ERROR_TIMEOUT;
    }
    
    // 读取字符
    *c = (char)read_reg(UART_DATA_REG);
    
    return UART_OK;
}

uart_status_t uart_read(uint8_t* data, uint32_t length) {
    if (data == NULL || length == 0) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    for (uint32_t i = 0; i < length; i++) {
        char c;
        uart_status_t status = uart_getc(&c);
        if (status != UART_OK) {
            return status;
        }
        data[i] = c;
    }
    
    return UART_OK;
}

bool uart_available(void) {
    return uart_rx_ready();
}

// ============================================================================
// UART控制函数
// ============================================================================

uart_status_t uart_flush(void) {
    if (!uart_initialized) {
        return UART_ERROR_INVALID_PARAM;
    }
    
    // 等待发送完成
    while (uart_tx_busy()) {
        delay_cycles(10);
    }
    
    return UART_OK;
}

uart_status_t uart_set_baudrate(uint32_t baudrate) {
    return uart_init(baudrate);
}

uint32_t uart_get_status(void) {
    return read_reg(UART_CTRL_REG);
}

void uart_enable(void) {
    uint32_t ctrl = read_reg(UART_CTRL_REG);
    ctrl |= UART_CTRL_ENABLE;
    write_reg(UART_CTRL_REG, ctrl);
}

void uart_disable(void) {
    uint32_t ctrl = read_reg(UART_CTRL_REG);
    ctrl &= ~UART_CTRL_ENABLE;
    write_reg(UART_CTRL_REG, ctrl);
}

// ============================================================================
// 格式化输出函数
// ============================================================================

// 简单的字符串长度计算
static uint32_t strlen(const char* str) {
    uint32_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// 简单的数字转字符串
static void itoa(uint32_t value, char* buffer, uint8_t base) {
    char digits[] = "0123456789ABCDEF";
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        buffer[0] = '0';
        buffer[1] = '\0';
        return;
    }
    
    while (value > 0) {
        temp[i++] = digits[value % base];
        value /= base;
    }
    
    int j = 0;
    while (i > 0) {
        buffer[j++] = temp[--i];
    }
    buffer[j] = '\0';
}

int uart_printf(const char* format, ...) {
    char buffer[256];
    char* ptr = buffer;
    va_list args;
    
    va_start(args, format);
    
    while (*format) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 'd':
                case 'i': {
                    int value = va_arg(args, int);
                    if (value < 0) {
                        *ptr++ = '-';
                        value = -value;
                    }
                    itoa(value, ptr, 10);
                    ptr += strlen(ptr);
                    break;
                }
                case 'u': {
                    uint32_t value = va_arg(args, uint32_t);
                    itoa(value, ptr, 10);
                    ptr += strlen(ptr);
                    break;
                }
                case 'x':
                case 'X': {
                    uint32_t value = va_arg(args, uint32_t);
                    itoa(value, ptr, 16);
                    ptr += strlen(ptr);
                    break;
                }
                case 's': {
                    char* str = va_arg(args, char*);
                    while (*str) {
                        *ptr++ = *str++;
                    }
                    break;
                }
                case 'c': {
                    char c = va_arg(args, int);
                    *ptr++ = c;
                    break;
                }
                default:
                    *ptr++ = '%';
                    *ptr++ = *format;
                    break;
            }
        } else {
            *ptr++ = *format;
        }
        format++;
    }
    
    *ptr = '\0';
    va_end(args);
    
    uart_puts(buffer);
    return ptr - buffer;
}

void uart_print_hex(const uint8_t* data, uint32_t length) {
    for (uint32_t i = 0; i < length; i++) {
        uart_printf("%02X ", data[i]);
        if ((i + 1) % 16 == 0) {
            uart_puts("\n");
        }
    }
    if (length % 16 != 0) {
        uart_puts("\n");
    }
}

void uart_print_hex32(uint32_t value) {
    uart_printf("0x%08X", value);
}

void uart_print_dec(uint32_t value) {
    uart_printf("%u", value);
}

void uart_print_bin(uint32_t value, uint8_t bits) {
    for (int i = bits - 1; i >= 0; i--) {
        uart_putc((value & (1 << i)) ? '1' : '0');
    }
} 