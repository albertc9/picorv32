/*
 * PicoRV32 UART驱动头文件
 * 提供简单的UART通信功能
 */

#ifndef UART_H
#define UART_H

#include "system.h"

// ============================================================================
// UART配置
// ============================================================================

// UART状态
typedef enum {
    UART_OK = 0,
    UART_ERROR_TIMEOUT,
    UART_ERROR_BUSY,
    UART_ERROR_INVALID_PARAM
} uart_status_t;

// UART配置结构
typedef struct {
    uint32_t baudrate;
    uint8_t data_bits;
    uint8_t stop_bits;
    uint8_t parity;
    uint8_t flow_control;
} uart_config_t;

// 默认配置
#define UART_CONFIG_DEFAULT { \
    .baudrate = UART_BAUDRATE_DEF, \
    .data_bits = 8, \
    .stop_bits = 1, \
    .parity = 0, \
    .flow_control = 0 \
}

// ============================================================================
// UART函数声明
// ============================================================================

// 初始化UART
uart_status_t uart_init(uint32_t baudrate);

// 使用配置结构初始化UART
uart_status_t uart_init_config(const uart_config_t* config);

// 发送单个字符
uart_status_t uart_putc(char c);

// 发送字符串
uart_status_t uart_puts(const char* str);

// 发送数据
uart_status_t uart_write(const uint8_t* data, uint32_t length);

// 接收单个字符
uart_status_t uart_getc(char* c);

// 接收数据
uart_status_t uart_read(uint8_t* data, uint32_t length);

// 检查是否有数据可读
bool uart_available(void);

// 等待发送完成
uart_status_t uart_flush(void);

// 设置波特率
uart_status_t uart_set_baudrate(uint32_t baudrate);

// 获取UART状态
uint32_t uart_get_status(void);

// 启用/禁用UART
void uart_enable(void);
void uart_disable(void);

// ============================================================================
// 格式化输出函数
// ============================================================================

// 打印格式化字符串
int uart_printf(const char* format, ...);

// 打印十六进制数据
void uart_print_hex(const uint8_t* data, uint32_t length);

// 打印十六进制值
void uart_print_hex32(uint32_t value);

// 打印十进制值
void uart_print_dec(uint32_t value);

// 打印二进制值
void uart_print_bin(uint32_t value, uint8_t bits);

// ============================================================================
// 内联函数
// ============================================================================

// 快速发送字符 (不检查状态)
static inline void uart_putc_fast(char c) {
    while (!(read_reg(UART_CTRL_REG) & UART_CTRL_TX_READY)) {
        // 等待发送就绪
    }
    write_reg(UART_DATA_REG, c);
}

// 快速接收字符 (不检查状态)
static inline char uart_getc_fast(void) {
    while (!(read_reg(UART_CTRL_REG) & UART_CTRL_RX_READY)) {
        // 等待接收就绪
    }
    return (char)read_reg(UART_DATA_REG);
}

// 检查发送就绪
static inline bool uart_tx_ready(void) {
    return (read_reg(UART_CTRL_REG) & UART_CTRL_TX_READY) != 0;
}

// 检查接收就绪
static inline bool uart_rx_ready(void) {
    return (read_reg(UART_CTRL_REG) & UART_CTRL_RX_READY) != 0;
}

// 检查发送忙
static inline bool uart_tx_busy(void) {
    return (read_reg(UART_CTRL_REG) & UART_CTRL_TX_BUSY) != 0;
}

// 检查接收忙
static inline bool uart_rx_busy(void) {
    return (read_reg(UART_CTRL_REG) & UART_CTRL_RX_BUSY) != 0;
}

// ============================================================================
// 宏定义
// ============================================================================

// 标准输出重定向
#define putchar(c) uart_putc_fast(c)
#define getchar() uart_getc_fast()

// 调试输出宏
#ifdef DEBUG
    #define DEBUG_PRINT(fmt, ...) uart_printf("[DEBUG] " fmt "\n", ##__VA_ARGS__)
    #define DEBUG_HEX(data, len) uart_print_hex(data, len)
    #define DEBUG_HEX32(val) uart_print_hex32(val)
#else
    #define DEBUG_PRINT(fmt, ...)
    #define DEBUG_HEX(data, len)
    #define DEBUG_HEX32(val)
#endif

// 错误输出宏
#define ERROR_PRINT(fmt, ...) uart_printf("[ERROR] " fmt "\n", ##__VA_ARGS__)
#define WARN_PRINT(fmt, ...) uart_printf("[WARN] " fmt "\n", ##__VA_ARGS__)
#define INFO_PRINT(fmt, ...) uart_printf("[INFO] " fmt "\n", ##__VA_ARGS__)

#endif // UART_H 