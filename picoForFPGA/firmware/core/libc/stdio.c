/*
 * PicoRV32 简化stdio库
 * 提供基本的输入输出函数
 */

#include <stdint.h>
#include <stdarg.h>
#include <stddef.h>

// 外部UART函数声明
extern void uart_putc(char c);
extern void uart_puts(const char* str);
extern int uart_printf(const char* format, ...);

// 标准输出重定向到UART
int putchar(int c) {
    uart_putc((char)c);
    return c;
}

int puts(const char* str) {
    uart_puts(str);
    uart_putc('\n');
    return 0;
}

// 格式化输出
int printf(const char* format, ...) {
    va_list args;
    va_start(args, format);
    int result = uart_printf(format, args);
    va_end(args);
    return result;
}

// 格式化输出到字符串
int sprintf(char* str, const char* format, ...) {
    va_list args;
    va_start(args, format);
    int result = vsprintf(str, format, args);
    va_end(args);
    return result;
}

// 格式化输出到字符串 (带长度限制)
int snprintf(char* str, size_t size, const char* format, ...) {
    va_list args;
    va_start(args, format);
    int result = vsnprintf(str, size, format, args);
    va_end(args);
    return result;
}

// 可变参数格式化输出
int vprintf(const char* format, va_list args) {
    return uart_printf(format, args);
}

// 可变参数格式化输出到字符串
int vsprintf(char* str, const char* format, va_list args) {
    // 简单的实现，只支持基本格式
    char* ptr = str;
    
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
                    ptr += int_to_str(value, ptr, 10);
                    break;
                }
                case 'u': {
                    unsigned int value = va_arg(args, unsigned int);
                    ptr += uint_to_str(value, ptr, 10);
                    break;
                }
                case 'x':
                case 'X': {
                    unsigned int value = va_arg(args, unsigned int);
                    ptr += uint_to_str(value, ptr, 16);
                    break;
                }
                case 's': {
                    char* s = va_arg(args, char*);
                    while (*s) {
                        *ptr++ = *s++;
                    }
                    break;
                }
                case 'c': {
                    int c = va_arg(args, int);
                    *ptr++ = (char)c;
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
    return ptr - str;
}

// 可变参数格式化输出到字符串 (带长度限制)
int vsnprintf(char* str, size_t size, const char* format, va_list args) {
    if (size == 0) return 0;
    
    char* ptr = str;
    char* end = str + size - 1;
    
    while (*format && ptr < end) {
        if (*format == '%') {
            format++;
            switch (*format) {
                case 'd':
                case 'i': {
                    int value = va_arg(args, int);
                    if (value < 0) {
                        if (ptr < end) *ptr++ = '-';
                        value = -value;
                    }
                    ptr += int_to_str_limited(value, ptr, 10, end - ptr);
                    break;
                }
                case 'u': {
                    unsigned int value = va_arg(args, unsigned int);
                    ptr += uint_to_str_limited(value, ptr, 10, end - ptr);
                    break;
                }
                case 'x':
                case 'X': {
                    unsigned int value = va_arg(args, unsigned int);
                    ptr += uint_to_str_limited(value, ptr, 16, end - ptr);
                    break;
                }
                case 's': {
                    char* s = va_arg(args, char*);
                    while (*s && ptr < end) {
                        *ptr++ = *s++;
                    }
                    break;
                }
                case 'c': {
                    int c = va_arg(args, int);
                    if (ptr < end) *ptr++ = (char)c;
                    break;
                }
                default:
                    if (ptr < end) *ptr++ = '%';
                    if (ptr < end) *ptr++ = *format;
                    break;
            }
        } else {
            *ptr++ = *format;
        }
        format++;
    }
    
    *ptr = '\0';
    return ptr - str;
}

// 辅助函数：整数转字符串
static int int_to_str(int value, char* str, int base) {
    char digits[] = "0123456789ABCDEF";
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        str[0] = '0';
        str[1] = '\0';
        return 1;
    }
    
    while (value > 0) {
        temp[i++] = digits[value % base];
        value /= base;
    }
    
    int j = 0;
    while (i > 0) {
        str[j++] = temp[--i];
    }
    str[j] = '\0';
    return j;
}

// 辅助函数：无符号整数转字符串
static int uint_to_str(unsigned int value, char* str, int base) {
    char digits[] = "0123456789ABCDEF";
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        str[0] = '0';
        str[1] = '\0';
        return 1;
    }
    
    while (value > 0) {
        temp[i++] = digits[value % base];
        value /= base;
    }
    
    int j = 0;
    while (i > 0) {
        str[j++] = temp[--i];
    }
    str[j] = '\0';
    return j;
}

// 辅助函数：整数转字符串 (带长度限制)
static int int_to_str_limited(int value, char* str, int base, int max_len) {
    if (max_len <= 0) return 0;
    
    char digits[] = "0123456789ABCDEF";
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        if (max_len > 0) {
            str[0] = '0';
            str[1] = '\0';
            return 1;
        }
        return 0;
    }
    
    while (value > 0 && i < 31) {
        temp[i++] = digits[value % base];
        value /= base;
    }
    
    int j = 0;
    while (i > 0 && j < max_len - 1) {
        str[j++] = temp[--i];
    }
    if (j < max_len) {
        str[j] = '\0';
    }
    return j;
}

// 辅助函数：无符号整数转字符串 (带长度限制)
static int uint_to_str_limited(unsigned int value, char* str, int base, int max_len) {
    if (max_len <= 0) return 0;
    
    char digits[] = "0123456789ABCDEF";
    char temp[32];
    int i = 0;
    
    if (value == 0) {
        if (max_len > 0) {
            str[0] = '0';
            str[1] = '\0';
            return 1;
        }
        return 0;
    }
    
    while (value > 0 && i < 31) {
        temp[i++] = digits[value % base];
        value /= base;
    }
    
    int j = 0;
    while (i > 0 && j < max_len - 1) {
        str[j++] = temp[--i];
    }
    if (j < max_len) {
        str[j] = '\0';
    }
    return j;
} 