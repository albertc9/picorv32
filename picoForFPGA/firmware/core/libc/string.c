/*
 * PicoRV32 简化字符串处理库
 * 提供基本的字符串操作函数
 */

#include <stdint.h>
#include <stddef.h>

// 字符串长度
size_t strlen(const char* str) {
    size_t len = 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

// 字符串复制
char* strcpy(char* dest, const char* src) {
    char* d = dest;
    while (*src) {
        *d++ = *src++;
    }
    *d = '\0';
    return dest;
}

// 字符串复制 (带长度限制)
char* strncpy(char* dest, const char* src, size_t n) {
    char* d = dest;
    size_t i = 0;
    while (i < n && *src) {
        *d++ = *src++;
        i++;
    }
    while (i < n) {
        *d++ = '\0';
        i++;
    }
    return dest;
}

// 字符串比较
int strcmp(const char* s1, const char* s2) {
    while (*s1 && *s2 && *s1 == *s2) {
        s1++;
        s2++;
    }
    return (int)(*s1 - *s2);
}

// 字符串比较 (带长度限制)
int strncmp(const char* s1, const char* s2, size_t n) {
    size_t i = 0;
    while (i < n && *s1 && *s2 && *s1 == *s2) {
        s1++;
        s2++;
        i++;
    }
    if (i == n) return 0;
    return (int)(*s1 - *s2);
}

// 字符串连接
char* strcat(char* dest, const char* src) {
    char* d = dest;
    while (*d) {
        d++;
    }
    while (*src) {
        *d++ = *src++;
    }
    *d = '\0';
    return dest;
}

// 字符串连接 (带长度限制)
char* strncat(char* dest, const char* src, size_t n) {
    char* d = dest;
    while (*d) {
        d++;
    }
    size_t i = 0;
    while (i < n && *src) {
        *d++ = *src++;
        i++;
    }
    *d = '\0';
    return dest;
}

// 查找字符
char* strchr(const char* str, int c) {
    while (*str) {
        if (*str == (char)c) {
            return (char*)str;
        }
        str++;
    }
    if (c == '\0') {
        return (char*)str;
    }
    return NULL;
}

// 查找字符 (从末尾)
char* strrchr(const char* str, int c) {
    char* last = NULL;
    while (*str) {
        if (*str == (char)c) {
            last = (char*)str;
        }
        str++;
    }
    if (c == '\0') {
        return (char*)str;
    }
    return last;
}

// 内存设置
void* memset(void* ptr, int value, size_t num) {
    unsigned char* p = (unsigned char*)ptr;
    for (size_t i = 0; i < num; i++) {
        p[i] = (unsigned char)value;
    }
    return ptr;
}

// 内存复制
void* memcpy(void* dest, const void* src, size_t num) {
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    for (size_t i = 0; i < num; i++) {
        d[i] = s[i];
    }
    return dest;
}

// 内存移动
void* memmove(void* dest, const void* src, size_t num) {
    unsigned char* d = (unsigned char*)dest;
    const unsigned char* s = (const unsigned char*)src;
    
    if (d < s) {
        // 正向复制
        for (size_t i = 0; i < num; i++) {
            d[i] = s[i];
        }
    } else if (d > s) {
        // 反向复制
        for (size_t i = num; i > 0; i--) {
            d[i-1] = s[i-1];
        }
    }
    return dest;
}

// 内存比较
int memcmp(const void* ptr1, const void* ptr2, size_t num) {
    const unsigned char* p1 = (const unsigned char*)ptr1;
    const unsigned char* p2 = (const unsigned char*)ptr2;
    
    for (size_t i = 0; i < num; i++) {
        if (p1[i] != p2[i]) {
            return (int)(p1[i] - p2[i]);
        }
    }
    return 0;
}

// 查找内存中的字节
void* memchr(const void* ptr, int value, size_t num) {
    const unsigned char* p = (const unsigned char*)ptr;
    for (size_t i = 0; i < num; i++) {
        if (p[i] == (unsigned char)value) {
            return (void*)(p + i);
        }
    }
    return NULL;
} 