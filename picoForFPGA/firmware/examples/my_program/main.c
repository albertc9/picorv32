// 我的第一个picoSoC C程序
// 这个程序演示了如何在picoSoC上运行C代码

#include "firmware.h"

// 简单的延时函数
void delay(int count) {
    for (int i = 0; i < count; i++) {
        // 简单的循环延时
        for (int j = 0; j < 1000; j++) {
            __asm__ volatile ("nop");
        }
    }
}

// 主程序入口
void main(void) {
    // 初始化消息
    print_str("=== picoSoC C程序启动 ===\n");
    print_str("Hello from RISC-V!\n");
    
    // 计数器示例
    int counter = 0;
    while (1) {
        print_str("计数器: ");
        print_dec(counter);
        print_str("\n");
        
        counter++;
        
        // 延时一段时间
        delay(1000);
        
        // 每10次打印一个特殊消息
        if (counter % 10 == 0) {
            print_str("*** 已经运行了 ");
            print_dec(counter);
            print_str(" 次 ***\n");
        }
    }
} 