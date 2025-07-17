/*
 * PicoRV32 GPIO驱动头文件
 * 提供GPIO控制功能
 */

#ifndef GPIO_H
#define GPIO_H

#include "system.h"

// ============================================================================
// GPIO配置
// ============================================================================

// GPIO方向
typedef enum {
    GPIO_DIR_INPUT = 0,
    GPIO_DIR_OUTPUT = 1
} gpio_dir_t;

// GPIO上拉/下拉
typedef enum {
    GPIO_PULL_NONE = 0,
    GPIO_PULL_UP = 1,
    GPIO_PULL_DOWN = 2
} gpio_pull_t;

// GPIO中断触发
typedef enum {
    GPIO_IRQ_NONE = 0,
    GPIO_IRQ_RISING = 1,
    GPIO_IRQ_FALLING = 2,
    GPIO_IRQ_BOTH = 3
} gpio_irq_t;

// GPIO状态
typedef enum {
    GPIO_OK = 0,
    GPIO_ERROR_INVALID_PIN,
    GPIO_ERROR_INVALID_PARAM,
    GPIO_ERROR_NOT_SUPPORTED
} gpio_status_t;

// GPIO配置结构
typedef struct {
    gpio_dir_t direction;
    gpio_pull_t pull;
    gpio_irq_t irq_trigger;
    bool irq_enable;
} gpio_config_t;

// 默认配置
#define GPIO_CONFIG_DEFAULT { \
    .direction = GPIO_DIR_INPUT, \
    .pull = GPIO_PULL_NONE, \
    .irq_trigger = GPIO_IRQ_NONE, \
    .irq_enable = false \
}

// ============================================================================
// GPIO引脚定义
// ============================================================================

// 最大GPIO数量
#define GPIO_MAX_PINS 32

// 常用引脚定义
#define GPIO_LED0    0
#define GPIO_LED1    1
#define GPIO_LED2    2
#define GPIO_LED3    3
#define GPIO_LED4    4
#define GPIO_LED5    5
#define GPIO_LED6    6
#define GPIO_LED7    7

#define GPIO_BTN0    8
#define GPIO_BTN1    9
#define GPIO_BTN2    10
#define GPIO_BTN3    11

#define GPIO_SPI_SCK 12
#define GPIO_SPI_MOSI 13
#define GPIO_SPI_MISO 14
#define GPIO_SPI_CS  15

// ============================================================================
// GPIO函数声明
// ============================================================================

// 初始化GPIO系统
gpio_status_t gpio_init(void);

// 配置GPIO引脚
gpio_status_t gpio_config(uint8_t pin, const gpio_config_t* config);

// 设置GPIO方向
gpio_status_t gpio_set_direction(uint8_t pin, gpio_dir_t direction);

// 设置GPIO上拉/下拉
gpio_status_t gpio_set_pull(uint8_t pin, gpio_pull_t pull);

// 读取GPIO值
gpio_status_t gpio_read(uint8_t pin, bool* value);

// 写入GPIO值
gpio_status_t gpio_write(uint8_t pin, bool value);

// 切换GPIO值
gpio_status_t gpio_toggle(uint8_t pin);

// 读取所有GPIO
uint32_t gpio_read_all(void);

// 写入所有GPIO
gpio_status_t gpio_write_all(uint32_t value);

// 设置GPIO掩码
gpio_status_t gpio_set_mask(uint32_t mask);

// 清除GPIO掩码
gpio_status_t gpio_clear_mask(uint32_t mask);

// 配置GPIO中断
gpio_status_t gpio_set_irq(uint8_t pin, gpio_irq_t trigger);

// 启用GPIO中断
gpio_status_t gpio_enable_irq(uint8_t pin);

// 禁用GPIO中断
gpio_status_t gpio_disable_irq(uint8_t pin);

// 清除GPIO中断
gpio_status_t gpio_clear_irq(uint8_t pin);

// 获取GPIO中断状态
uint32_t gpio_get_irq_status(void);

// 获取GPIO状态
uint32_t gpio_get_status(void);

// ============================================================================
// LED控制函数
// ============================================================================

// 设置LED
gpio_status_t gpio_set_led(uint8_t led, bool state);

// 切换LED
gpio_status_t gpio_toggle_led(uint8_t led);

// 设置所有LED
gpio_status_t gpio_set_leds(uint8_t pattern);

// 读取按钮
gpio_status_t gpio_read_button(uint8_t button, bool* pressed);

// ============================================================================
// 内联函数
// ============================================================================

// 快速读取GPIO (不检查参数)
static inline bool gpio_read_fast(uint8_t pin) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    return (data & (1 << pin)) != 0;
}

// 快速写入GPIO (不检查参数)
static inline void gpio_write_fast(uint8_t pin, bool value) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    if (value) {
        data |= (1 << pin);
    } else {
        data &= ~(1 << pin);
    }
    write_reg(GPIO_DATA_REG, data);
}

// 快速切换GPIO (不检查参数)
static inline void gpio_toggle_fast(uint8_t pin) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    data ^= (1 << pin);
    write_reg(GPIO_DATA_REG, data);
}

// 检查GPIO是否为输出
static inline bool gpio_is_output(uint8_t pin) {
    uint32_t ctrl = read_reg(GPIO_CTRL_REG);
    return (ctrl & (GPIO_CTRL_DIR_OUT << (pin * 4))) != 0;
}

// 检查GPIO是否为输入
static inline bool gpio_is_input(uint8_t pin) {
    uint32_t ctrl = read_reg(GPIO_CTRL_REG);
    return (ctrl & (GPIO_CTRL_DIR_IN << (pin * 4))) != 0;
}

// ============================================================================
// 宏定义
// ============================================================================

// LED控制宏
#define LED_ON(led)     gpio_write_fast(led, true)
#define LED_OFF(led)    gpio_write_fast(led, false)
#define LED_TOGGLE(led) gpio_toggle_fast(led)

// 按钮读取宏
#define BUTTON_PRESSED(btn) gpio_read_fast(btn)

// GPIO操作宏
#define GPIO_SET(pin)   gpio_write_fast(pin, true)
#define GPIO_CLEAR(pin) gpio_write_fast(pin, false)
#define GPIO_READ(pin)  gpio_read_fast(pin)

#endif // GPIO_H 