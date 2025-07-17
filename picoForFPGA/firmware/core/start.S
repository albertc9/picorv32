/*
 * PicoRV32 启动代码
 * 系统复位后的初始化序列
 */

.section .text.startup
.global _start
.global reset_vector

reset_vector:
_start:
    // 禁用所有中断
    csrci mstatus, 8
    li t0, 0xFF
    csrc mie, t0
    
    // 设置栈指针 (使用SRAM顶部)
    li sp, 0x00010000  // 64KB SRAM的顶部
    
    // 清零所有通用寄存器
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0
    li x16, 0
    li x17, 0
    li x18, 0
    li x19, 0
    li x20, 0
    li x21, 0
    li x22, 0
    li x23, 0
    li x24, 0
    li x25, 0
    li x26, 0
    li x27, 0
    li x28, 0
    li x29, 0
    li x30, 0
    li x31, 0
    
    // 重新设置栈指针
    li sp, 0x00010000
    
    // 清零SRAM
    li a0, 0x00000000
    li a1, 0x00010000  // SRAM大小
clear_sram_loop:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, a1, clear_sram_loop
    
    // 复制数据段到RAM
    la a0, _sidata    // 源地址 (Flash中的.data段)
    la a1, _sdata     // 目标地址 (RAM中的.data段)
    la a2, _edata     // 数据段结束地址
    bge a1, a2, skip_data_copy
copy_data_loop:
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    blt a1, a2, copy_data_loop
skip_data_copy:
    
    // 清零BSS段
    la a0, _sbss      // BSS段开始地址
    la a1, _ebss      // BSS段结束地址
    bge a0, a1, skip_bss_clear
clear_bss_loop:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, a1, clear_bss_loop
skip_bss_clear:
    
    // 设置全局指针 (如果使用)
    // la gp, _gp
    
    // 调用系统初始化
    call system_init
    
    // 调用main函数
    call main
    
    // main函数返回后的处理
    j _start  // 重新启动

// 中断向量表
.section .text.vectors
.align 4

// 软件中断
software_interrupt:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw a0, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)
    sw a3, 24(sp)
    sw a4, 28(sp)
    
    // 处理软件中断
    csrr t0, mcause
    csrr t1, mepc
    
    // 调用中断处理函数
    call software_interrupt_handler
    
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw a0, 12(sp)
    lw a1, 16(sp)
    lw a2, 20(sp)
    lw a3, 24(sp)
    lw a4, 28(sp)
    addi sp, sp, 32
    mret

// 定时器中断
timer_interrupt:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw a0, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)
    sw a3, 24(sp)
    sw a4, 28(sp)
    
    // 处理定时器中断
    call timer_interrupt_handler
    
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw a0, 12(sp)
    lw a1, 16(sp)
    lw a2, 20(sp)
    lw a3, 24(sp)
    lw a4, 28(sp)
    addi sp, sp, 32
    mret

// 外部中断
external_interrupt:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw a0, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)
    sw a3, 24(sp)
    sw a4, 28(sp)
    
    // 处理外部中断
    call external_interrupt_handler
    
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw a0, 12(sp)
    lw a1, 16(sp)
    lw a2, 20(sp)
    lw a3, 24(sp)
    lw a4, 28(sp)
    addi sp, sp, 32
    mret

// 异常处理
exception_handler:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw a0, 12(sp)
    sw a1, 16(sp)
    sw a2, 20(sp)
    sw a3, 24(sp)
    sw a4, 28(sp)
    
    // 获取异常信息
    csrr t0, mcause
    csrr t1, mepc
    csrr t2, mtval
    
    // 调用异常处理函数
    mv a0, t0  // 异常原因
    mv a1, t1  // 异常PC
    mv a2, t2  // 异常值
    call exception_handler_func
    
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw a0, 12(sp)
    lw a1, 16(sp)
    lw a2, 20(sp)
    lw a3, 24(sp)
    lw a4, 28(sp)
    addi sp, sp, 32
    mret

// 中断处理函数声明
.extern software_interrupt_handler
.extern timer_interrupt_handler
.extern external_interrupt_handler
.extern exception_handler_func

// 符号定义
.global _sidata
.global _sdata
.global _edata
.global _sbss
.global _ebss 