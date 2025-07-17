/*
 * PicoRV32 GPIO驱动实现
 * 提供GPIO控制功能
 */

#include "gpio.h"
#include <stddef.h>

// ============================================================================
// 内部变量
// ============================================================================

static bool gpio_initialized = false;

// ============================================================================
// GPIO初始化函数
// ============================================================================

gpio_status_t gpio_init(void) {
    // 初始化GPIO控制寄存器
    write_reg(GPIO_CTRL_REG, 0);
    
    // 初始化GPIO数据寄存器
    write_reg(GPIO_DATA_REG, 0);
    
    gpio_initialized = true;
    
    return GPIO_OK;
}

// ============================================================================
// GPIO配置函数
// ============================================================================

gpio_status_t gpio_config(uint8_t pin, const gpio_config_t* config) {
    if (pin >= GPIO_MAX_PINS || config == NULL) {
        return GPIO_ERROR_INVALID_PARAM;
    }
    
    if (!gpio_initialized) {
        return GPIO_ERROR_INVALID_PARAM;
    }
    
    uint32_t ctrl = read_reg(GPIO_CTRL_REG);
    uint32_t mask = 0xF << (pin * 4);  // 4位配置位
    uint32_t config_val = 0;
    
    // 设置方向
    if (config->direction == GPIO_DIR_OUTPUT) {
        config_val |= GPIO_CTRL_DIR_OUT;
    } else {
        config_val |= GPIO_CTRL_DIR_IN;
    }
    
    // 设置上拉/下拉
    if (config->pull == GPIO_PULL_UP) {
        config_val |= GPIO_CTRL_PULLUP;
    } else if (config->pull == GPIO_PULL_DOWN) {
        config_val |= GPIO_CTRL_PULLDOWN;
    }
    
    // 更新控制寄存器
    ctrl = (ctrl & ~mask) | (config_val << (pin * 4));
    write_reg(GPIO_CTRL_REG, ctrl);
    
    // 配置中断 (如果支持)
    if (config->irq_enable) {
        gpio_set_irq(pin, config->irq_trigger);
        gpio_enable_irq(pin);
    }
    
    return GPIO_OK;
}

gpio_status_t gpio_set_direction(uint8_t pin, gpio_dir_t direction) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    uint32_t ctrl = read_reg(GPIO_CTRL_REG);
    uint32_t mask = GPIO_CTRL_DIR_OUT << (pin * 4);
    
    if (direction == GPIO_DIR_OUTPUT) {
        ctrl |= mask;
    } else {
        ctrl &= ~mask;
    }
    
    write_reg(GPIO_CTRL_REG, ctrl);
    
    return GPIO_OK;
}

gpio_status_t gpio_set_pull(uint8_t pin, gpio_pull_t pull) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    uint32_t ctrl = read_reg(GPIO_CTRL_REG);
    uint32_t mask = (GPIO_CTRL_PULLUP | GPIO_CTRL_PULLDOWN) << (pin * 4);
    uint32_t pull_val = 0;
    
    if (pull == GPIO_PULL_UP) {
        pull_val = GPIO_CTRL_PULLUP;
    } else if (pull == GPIO_PULL_DOWN) {
        pull_val = GPIO_CTRL_PULLDOWN;
    }
    
    ctrl = (ctrl & ~mask) | (pull_val << (pin * 4));
    write_reg(GPIO_CTRL_REG, ctrl);
    
    return GPIO_OK;
}

// ============================================================================
// GPIO读写函数
// ============================================================================

gpio_status_t gpio_read(uint8_t pin, bool* value) {
    if (pin >= GPIO_MAX_PINS || value == NULL) {
        return GPIO_ERROR_INVALID_PARAM;
    }
    
    *value = gpio_read_fast(pin);
    return GPIO_OK;
}

gpio_status_t gpio_write(uint8_t pin, bool value) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    gpio_write_fast(pin, value);
    return GPIO_OK;
}

gpio_status_t gpio_toggle(uint8_t pin) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    gpio_toggle_fast(pin);
    return GPIO_OK;
}

uint32_t gpio_read_all(void) {
    return read_reg(GPIO_DATA_REG);
}

gpio_status_t gpio_write_all(uint32_t value) {
    write_reg(GPIO_DATA_REG, value);
    return GPIO_OK;
}

gpio_status_t gpio_set_mask(uint32_t mask) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    data |= mask;
    write_reg(GPIO_DATA_REG, data);
    return GPIO_OK;
}

gpio_status_t gpio_clear_mask(uint32_t mask) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    data &= ~mask;
    write_reg(GPIO_DATA_REG, data);
    return GPIO_OK;
}

// ============================================================================
// GPIO中断函数
// ============================================================================

gpio_status_t gpio_set_irq(uint8_t pin, gpio_irq_t trigger) {
    (void)trigger;
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    // 这里需要根据具体的硬件实现来配置中断
    // 目前返回不支持错误
    return GPIO_ERROR_NOT_SUPPORTED;
}

gpio_status_t gpio_enable_irq(uint8_t pin) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    // 这里需要根据具体的硬件实现来启用中断
    return GPIO_ERROR_NOT_SUPPORTED;
}

gpio_status_t gpio_disable_irq(uint8_t pin) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    // 这里需要根据具体的硬件实现来禁用中断
    return GPIO_ERROR_NOT_SUPPORTED;
}

gpio_status_t gpio_clear_irq(uint8_t pin) {
    if (pin >= GPIO_MAX_PINS) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    // 这里需要根据具体的硬件实现来清除中断
    return GPIO_ERROR_NOT_SUPPORTED;
}

uint32_t gpio_get_irq_status(void) {
    // 这里需要根据具体的硬件实现来获取中断状态
    return 0;
}

uint32_t gpio_get_status(void) {
    return read_reg(GPIO_CTRL_REG);
}

// ============================================================================
// LED控制函数
// ============================================================================

gpio_status_t gpio_set_led(uint8_t led, bool state) {
    if (led > 7) {  // 假设最多8个LED
        return GPIO_ERROR_INVALID_PIN;
    }
    
    return gpio_write(led, state);
}

gpio_status_t gpio_toggle_led(uint8_t led) {
    if (led > 7) {
        return GPIO_ERROR_INVALID_PIN;
    }
    
    return gpio_toggle(led);
}

gpio_status_t gpio_set_leds(uint8_t pattern) {
    uint32_t data = read_reg(GPIO_DATA_REG);
    data = (data & 0xFFFFFF00) | pattern;  // 只修改低8位
    write_reg(GPIO_DATA_REG, data);
    return GPIO_OK;
}

gpio_status_t gpio_read_button(uint8_t button, bool* pressed) {
    if (button > 3 || pressed == NULL) {  // 假设最多4个按钮
        return GPIO_ERROR_INVALID_PARAM;
    }
    
    return gpio_read(button + 8, pressed);  // 按钮从引脚8开始
} 