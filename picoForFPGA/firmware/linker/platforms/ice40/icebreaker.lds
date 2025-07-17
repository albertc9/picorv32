/*
 * PicoRV32 iCEBreaker板链接脚本
 * 针对iCEBreaker板的特定内存布局
 */

/* 内存定义 */
MEMORY {
    /* 内部SRAM - iCEBreaker有128KB SRAM */
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 128K
    
    /* 程序Flash - 1MB SPI Flash */
    FLASH (rx) : ORIGIN = 0x00100000, LENGTH = 1M
}

/* 入口点 */
ENTRY(_start)

/* 段定义 */
SECTIONS {
    /* 代码段 - 放在Flash中 */
    .text : {
        . = ALIGN(4);
        KEEP(*(.text.startup))  /* 启动代码 */
        *(.text)                /* 代码 */
        *(.text*)               /* 代码 */
        . = ALIGN(4);
        _etext = .;             /* 代码段结束 */
    } >FLASH
    
    /* 只读数据段 - 放在Flash中 */
    .rodata : {
        . = ALIGN(4);
        *(.rodata)              /* 只读数据 */
        *(.rodata*)             /* 只读数据 */
        . = ALIGN(4);
    } >FLASH
    
    /* 数据段 - 在Flash中存储，运行时复制到RAM */
    .data : AT(_etext) {
        . = ALIGN(4);
        _sdata = .;             /* 数据段开始 */
        *(.data)                /* 数据 */
        *(.data*)               /* 数据 */
        . = ALIGN(4);
        _edata = .;             /* 数据段结束 */
    } >RAM
    
    /* BSS段 - 清零的未初始化数据 */
    .bss : {
        . = ALIGN(4);
        _sbss = .;              /* BSS段开始 */
        *(.bss)                 /* BSS */
        *(.bss*)                /* BSS */
        *(COMMON)               /* 公共符号 */
        . = ALIGN(4);
        _ebss = .;              /* BSS段结束 */
    } >RAM
    
    /* 堆栈段 - 使用SRAM顶部 */
    .stack : {
        . = ALIGN(16);
        . = . + 8K;             /* 8KB栈空间 */
        . = ALIGN(16);
        _estack = .;            /* 栈顶 */
    } >RAM
    
    /* 堆段 */
    .heap : {
        . = ALIGN(4);
        _heap_start = .;        /* 堆开始 */
        . = . + 16K;            /* 16KB堆空间 */
        . = ALIGN(4);
        _heap_end = .;          /* 堆结束 */
    } >RAM
    
    /* 调试信息 */
    .debug_info : {
        *(.debug_info)
        *(.debug_info.*)
    } >FLASH
    
    .debug_abbrev : {
        *(.debug_abbrev)
        *(.debug_abbrev.*)
    } >FLASH
    
    .debug_line : {
        *(.debug_line)
        *(.debug_line.*)
    } >FLASH
    
    .debug_frame : {
        *(.debug_frame)
        *(.debug_frame.*)
    } >FLASH
    
    .debug_str : {
        *(.debug_str)
        *(.debug_str.*)
    } >FLASH
    
    /* 丢弃不需要的段 */
    /DISCARD/ : {
        *(.comment)
        *(.gnu*)
        *(.note*)
        *(.eh_frame*)
    }
} 