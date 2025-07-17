/*
 * PicoRV32 系统定义头文件
 * 定义内存映射、寄存器地址和系统常量
 */

#ifndef SYSTEM_H
#define SYSTEM_H

#include <stdint.h>
#include <stdbool.h>

// ============================================================================
// 内存映射定义
// ============================================================================

// 内部SRAM
#define SRAM_BASE           0x00000000
#define SRAM_SIZE           SRAM_SIZE_CONFIG
#define SRAM_END            (SRAM_BASE + SRAM_SIZE - 1)

// 程序Flash
#define FLASH_BASE          0x00100000
#define FLASH_SIZE          FLASH_SIZE_CONFIG
#define FLASH_END           (FLASH_BASE + FLASH_SIZE - 1)

// 外设寄存器
#define PERIPH_BASE         0x02000000

// UART寄存器
#define UART_CTRL_REG       (PERIPH_BASE + 0x00)
#define UART_DATA_REG       (PERIPH_BASE + 0x04)

// GPIO寄存器
#define GPIO_CTRL_REG       (PERIPH_BASE + 0x08)
#define GPIO_DATA_REG       (PERIPH_BASE + 0x0C)

// SPI Flash控制器寄存器
#define SPI_CTRL_REG        (PERIPH_BASE + 0x10)
#define SPI_DATA_REG        (PERIPH_BASE + 0x14)

// 定时器寄存器
#define TIMER_CTRL_REG      (PERIPH_BASE + 0x18)
#define TIMER_VALUE_REG     (PERIPH_BASE + 0x1C)

// 中断控制器寄存器
#define IRQ_CTRL_REG        (PERIPH_BASE + 0x20)
#define IRQ_STATUS_REG      (PERIPH_BASE + 0x24)

// 用户外设空间
#define USER_PERIPH_BASE    0x03000000

// ============================================================================
// 寄存器定义
// ============================================================================

// UART控制寄存器位定义
#define UART_CTRL_ENABLE    0x01
#define UART_CTRL_TX_READY  0x02
#define UART_CTRL_RX_READY  0x04
#define UART_CTRL_TX_BUSY   0x08
#define UART_CTRL_RX_BUSY   0x10

// GPIO控制寄存器位定义
#define GPIO_CTRL_DIR_OUT   0x01
#define GPIO_CTRL_DIR_IN    0x02
#define GPIO_CTRL_PULLUP    0x04
#define GPIO_CTRL_PULLDOWN  0x08

// SPI控制寄存器位定义
#define SPI_CTRL_ENABLE     0x01
#define SPI_CTRL_CS_LOW     0x02
#define SPI_CTRL_CLK_POL    0x04
#define SPI_CTRL_CLK_PHA    0x08
#define SPI_CTRL_TX_READY   0x10
#define SPI_CTRL_RX_READY   0x20

// 定时器控制寄存器位定义
#define TIMER_CTRL_ENABLE   0x01
#define TIMER_CTRL_IRQ_EN   0x02
#define TIMER_CTRL_IRQ_PEND 0x04

// 中断控制寄存器位定义
#define IRQ_CTRL_ENABLE     0x01
#define IRQ_CTRL_GLOBAL_EN  0x02

// ============================================================================
// 系统常量
// ============================================================================

// 系统时钟频率 (Hz)
#define SYSTEM_CLOCK_HZ     SYSTEM_CLOCK_CONFIG

// UART波特率
#define UART_BAUDRATE_DEF   UART_BAUDRATE_CONFIG

// 默认UART时钟分频器
#define UART_CLKDIV_DEFAULT (SYSTEM_CLOCK_HZ / UART_BAUDRATE_DEF)

// 中断向量表大小
#define IRQ_VECTOR_SIZE     32

// 最大中断优先级
#define MAX_IRQ_PRIORITY    7

// ============================================================================
// 内联函数
// ============================================================================

// 内存屏障
static inline void memory_barrier(void) {
    __asm__ volatile("fence" : : : "memory");
}

// 读取寄存器
static inline uint32_t read_reg(uint32_t addr) {
    uint32_t value;
    __asm__ volatile("lw %0, 0(%1)" : "=r"(value) : "r"(addr));
    return value;
}

// 写入寄存器
static inline void write_reg(uint32_t addr, uint32_t value) {
    __asm__ volatile("sw %0, 0(%1)" : : "r"(value), "r"(addr));
}

// 读取字节
static inline uint8_t read_byte(uint32_t addr) {
    uint8_t value;
    __asm__ volatile("lb %0, 0(%1)" : "=r"(value) : "r"(addr));
    return value;
}

// 写入字节
static inline void write_byte(uint32_t addr, uint8_t value) {
    __asm__ volatile("sb %0, 0(%1)" : : "r"(value), "r"(addr));
}

// 读取半字
static inline uint16_t read_half(uint32_t addr) {
    uint16_t value;
    __asm__ volatile("lh %0, 0(%1)" : "=r"(value) : "r"(addr));
    return value;
}

// 写入半字
static inline void write_half(uint32_t addr, uint16_t value) {
    __asm__ volatile("sh %0, 0(%1)" : : "r"(value), "r"(addr));
}

// ============================================================================
// 中断控制
// ============================================================================

// 启用全局中断
static inline void enable_global_irq(void) {
    __asm__ volatile("csrsi mstatus, 8");
}

// 禁用全局中断
static inline void disable_global_irq(void) {
    __asm__ volatile("csrci mstatus, 8");
}

// 启用特定中断
static inline void enable_irq(uint32_t irq_num) {
    uint32_t mask = 1 << irq_num;
    write_reg(IRQ_CTRL_REG, read_reg(IRQ_CTRL_REG) | mask);
}

// 禁用特定中断
static inline void disable_irq(uint32_t irq_num) {
    uint32_t mask = ~(1 << irq_num);
    write_reg(IRQ_CTRL_REG, read_reg(IRQ_CTRL_REG) & mask);
}

// 清除中断挂起
static inline void clear_irq_pending(uint32_t irq_num) {
    uint32_t mask = 1 << irq_num;
    write_reg(IRQ_STATUS_REG, mask);
}

// ============================================================================
// 延时函数
// ============================================================================

// 简单延时循环
static inline void delay_cycles(uint32_t cycles) {
    for (volatile uint32_t i = 0; i < cycles; i++) {
        __asm__ volatile("nop");
    }
}

// 毫秒延时
static inline void delay_ms(uint32_t ms) {
    uint32_t cycles = (SYSTEM_CLOCK_HZ / 1000) * ms;
    delay_cycles(cycles);
}

// 微秒延时
static inline void delay_us(uint32_t us) {
    uint32_t cycles = (SYSTEM_CLOCK_HZ / 1000000) * us;
    delay_cycles(cycles);
}

// ============================================================================
// 错误处理
// ============================================================================

// 错误代码
typedef enum {
    ERROR_NONE = 0,
    ERROR_INVALID_PARAM,
    ERROR_TIMEOUT,
    ERROR_HARDWARE,
    ERROR_NOT_SUPPORTED
} error_t;

// 错误处理函数
void system_error(error_t error, const char* message);

// ============================================================================
// 系统初始化
// ============================================================================

// 系统初始化
void system_init(void);

// 系统重置
void system_reset(void);

// 获取系统状态
uint32_t system_get_status(void);

#endif // SYSTEM_H 