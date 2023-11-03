SECTIONS {
	. = 0X87800000;
	.text :
	{
		project/startup_MCIMX6Y2.o
		freertos/portable/GCC/ARM_CA9/portASM.o
		*(.text)
	}
	.rodata ALIGN(4) : {*(.rodata*)}
	.data ALIGN(4)   : { *(.data) }
	__bss_start = .;
	.bss ALIGN(4)  : { *(.bss)  *(COMMON) }
	__bss_end = .;
}
