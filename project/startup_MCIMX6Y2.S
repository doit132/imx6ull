/* ---------------------------------------------------------------------------------------*/
/*  @file:    startup_MCIMX6Y2.S                                                          */
/*  @purpose: CMSIS Cortex-A7 Core Device Startup File                                    */
/*            MCIMX6Y2                                                                    */
/*  @version:  2.0                                                                        */
/*  @date:     2016-8-24                                                                  */
/*  @build:   b160722                                                                     */
/* ---------------------------------------------------------------------------------------*/
/*                                                                                        */
/* Copyright (c) 1997 - 2016 , Freescale Semiconductor, Inc.                              */
/* All rights reserved.                                                                   */
/*                                                                                        */
/* Redistribution and use in source and binary forms, with or without modification,       */
/* are permitted provided that the following conditions are met:                          */
/*                                                                                        */
/* o Redistributions of source code must retain the above copyright notice, this list     */
/*   of conditions and the following disclaimer.                                          */
/*                                                                                        */
/* o Redistributions in binary form must reproduce the above copyright notice, this       */
/*   list of conditions and the following disclaimer in the documentation and/or          */
/*   other materials provided with the distribution.                                      */
/*                                                                                        */
/* o Neither the name of copyright holder nor the names of its               */
/*   contributors may be used to endorse or promote products derived from this            */
/*   software without specific prior written permission.                                  */
/*                                                                                        */
/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND        */
/* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED          */
/* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE                 */
/* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR       */
/* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES         */
/* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;           */
/* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON         */
/* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT                */
/* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          */
/* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                           */
/*****************************************************************************/
/* Version: GCC for ARM Embedded Processors                                  */
/*****************************************************************************/
    .global _start  				/* 全局标号 */
    .extern put
    .extern FreeRTOS_IRQ_Handler
    .extern FreeRTOS_SWI_Handler
_start:
	ldr pc, =Reset_Handler		          /* 复位中断 					    */
	ldr pc, =Undefined_Handler	          /* 未定义中断 					*/
    ldr pc, =FreeRTOS_SWI_Handler		  /* SVC(Supervisor)中断 		   */
	ldr pc, =PrefAbort_Handler	          /* 预取终止中断 					*/
	ldr pc, =DataAbort_Handler	          /* 数据终止中断 					*/
	ldr	pc, =NotUsed_Handler	          /* 未使用中断					   */
	ldr pc, =FreeRTOS_IRQ_Handler		  /* IRQ中断 					  */
	ldr pc, =FIQ_Handler		          /* FIQ(快速中断)未定义中断 	     */

Reset_Handler:
    cpsid   i               /* Mask interrupts */

    /*
     * 关闭 I, DCache 和 MMU
     * 采取读-改-写的方式
     */
    mrc     p15, 0, r0, c1, c0, 0     /* 读取 CP15 的 C1 寄存器到 R0 中       		           */
    bic     r0,  r0, #(0x1 << 12)     /* 清除 C1 寄存器的 bit12 位(I 位)，关闭 I Cache          */
    bic     r0,  r0, #(0x1 <<  2)     /* 清除 C1 寄存器的 bit2(C 位)，关闭 D Cache    			*/
    bic     r0,  r0, #0x2             /* 清除 C1 寄存器的 bit1(A 位)，关闭对齐					 */
    bic     r0,  r0, #(0x1 << 11)     /* 清除 C1 寄存器的 bit11(Z 位)，关闭分支预测			      */
    bic     r0,  r0, #0x1             /* 清除 C1 寄存器的 bit0(M 位)，关闭 MMU				     */
    mcr     p15, 0, r0, c1, c0, 0     /* 将 r0 寄存器中的值写入到 CP15 的 C1 寄存器中	 		   */

    /* 设置各个模式下的栈指针，
	 * 注意：IMX6UL的堆栈是向下增长的！
	 * 堆栈指针地址一定要是4字节地址对齐的！！！
	 * DDR范围:0X80000000~0X9FFFFFFF
	 */
	/* 进入IRQ模式 */
    mrs r0, cpsr
	bic r0, r0, #0x1f 	/* 将r0寄存器中的低5位清零，也就是cpsr的M0~M4 	*/
	orr r0, r0, #0x12 	/* r0或上0x13,表示使用IRQ模式					 */
	msr cpsr, r0		/* 将r0 的数据写入到cpsr_c中 					 */
	ldr sp, =0x80600000	/* 设置IRQ模式下的栈首地址为0X80600000,大小为2MB   */

	/* 进入SYS模式 */
	mrs r0, cpsr
	bic r0, r0, #0x1f 	/* 将r0寄存器中的低5位清零，也就是cpsr的M0~M4 	   */
	orr r0, r0, #0x1f 	/* r0或上0x13,表示使用SYS模式					 */
	msr cpsr, r0		/* 将r0 的数据写入到cpsr_c中 					 */
	ldr sp, =0x80400000	/* 设置SYS模式下的栈首地址为0X80400000,大小为2MB   */

	/* 进入SVC模式 */
	mrs r0, cpsr
	bic r0, r0, #0x1f 	/* 将r0寄存器中的低5位清零，也就是cpsr的M0~M4 	*/
	orr r0, r0, #0x13 	/* r0或上0x13,表示使用SVC模式				  */
	msr cpsr, r0		    /* 将r0 的数据写入到cpsr_c中              */
	// cps     #0x13
	ldr sp, =0X80200000	/* 设置SVC模式下的栈首地址为0X80200000,大小为2MB */


	// cps     #0x12                /* Enter IRQ mode                */
    // ldr     sp, =0x80600000      /* Set up IRQ handler stack      */

    // cps     #0x1F                /* Enter System mode             */
    // ldr     sp, =0x80400000      /* Set up System/User Mode stack */

    // cps     #0x13                /* Enter Supervisor mode         */
    // ldr     sp, =0x80200000      /* Set up Supervisor Mode stack  */

	ldr     r0,=SystemInit
    blx     r0

	cpsie i				/* 打开全局中断 */
#if 0
	/* 使能IRQ中断 */
	mrs r0, cpsr		/* 读取cpsr寄存器值到r0中 			 */
	bic r0, r0, #0x80	/* 将r0寄存器中bit7清零，也就是CPSR中的I位清零，表示允许IRQ中断 */
	msr cpsr, r0		/* 将r0重新写入到cpsr中 			*/
#endif

	b main				/* 跳转到main函数 			 	   */


/* 未定义中断 */
.align  2
.arm
.weak Undefined_Handler
.type Undefined_Handler, %function
Undefined_Handler:
    b Undefined_Handler
    .size Undefined_Handler, . - Undefined_Handler

/* SVC 中断 */
.align 2
.arm
.weak SVC_Handler
.type SVC_Handler, %function
SVC_Handler:
    ldr   r0,=SVC_Handler
    bx    r0
    .size SVC_Handler, . - SVC_Handler

/* 预取终止中断 */
.align 2
.arm
.weak PrefAbort_Handler
.type PrefAbort_Handler, %function
PrefAbort_Handler:
    ldr   r0,=PrefAbort_Handler
    bx    r0
    .size PrefAbort_Handler, . - PrefAbort_Handler

/* 数据终止中断 */
.align 2
.arm
.weak DataAbort_Handler
.type DataAbort_Handler, %function
DataAbort_Handler:
    ldr   r0,=DataAbort_Handler
    bx    r0
    .size DataAbort_Handler, . - DataAbort_Handler

/* 未使用的中断 */
.align 2
.arm
.weak NotUsed_Handler
.type NotUsed_Handler, %function
NotUsed_Handler:
	ldr r0, =NotUsed_Handler
	bx r0

/* IRQ中断！重点！！！！！ ，进入中断后，系统必然进入IRQ模式*/
.align 2
.arm
.weak IRQ_Handler
.type IRQ_Handler, %function
IRQ_Handler:
    push    {lr}                         /* 保存 lr 地址 */
    push    {r0-r3, r12}                 /* 保存 r0-r3，r12 寄存器 */

    MRS     r0, spsr                     /* 读取 spsr 寄存器 */
    push    {r0}                         /* 保存 spsr 寄存器 */

    MRC     P15, 4, r1, C15, C0, 0       /* 从 CP15 的 C0 寄存器内的值到 R1 寄存器中
								          * 参考文档 ARM Cortex-A(armV7)编程手册 V4.0.pdf P49
								          * Cortex-A7 Technical ReferenceManua.pdf P68 P138
								          */
    ADD     r1, r1, #0x2000              /* GIC 基地址加 0X2000，也就是 GIC 的 CPU 接口端基地址 */
    LDR     r0, [r1, #0xC]               /* GIC 的 CPU 接口端基地址加 0X0C 就是 GICC_IAR 寄存器，
								          * GICC_IAR 寄存器保存这当前发生中断的中断号，我们要根据
								          * 这个中断号来绝对调用哪个中断服务函数
								          */

    push    {r0, r1}                     /* 保存 r0, r1 */

    CPS     #0x13                        /* 进入 SVC 模式，允许其他中断再次进去 */

    push    {lr}                         /* 保存 SVC 模式的 lr 寄存器 */
    LDR     r2, =SystemIrqHandler        /* 加载 C 语言中断处理函数到 r2 寄存器中，汇编传参，参数少于三个的时候，参数保存在 r0*/
    BLX     r2                           /* 运行 C 语言中断处理函数，带有一个参数，保存在 R0 寄存器中 */
    POP     {lr}             /* 执行完 C 语言中断服务函数，lr 出栈 */

    CPS     #0x12            /* 进入IRQ模式 */

    POP     {r0, r1}

    STR     r0, [r1, #0x10]  /* 中断执行完成，写 EOIR */

    POP     {r0}
    MSR     spsr_cxsf, r0    /* 恢复spsr */

    POP     {r0-r3, r12}     /* r0-r3,r12出栈 */
    POP     {lr}             /* lr出栈 */
    SUBS    pc, lr, #4       /* 将lr-4赋给pc */
    .size IRQ_Handler, . - IRQ_Handler

# FIQ 中断
.align 2
.arm
.weak FIQ_Handler
.type FIQ_Handler, %function
FIQ_Handler:
    ldr   r0,=FIQ_Handler
    bx    r0
    .size FIQ_Handler, . - FIQ_Handler
