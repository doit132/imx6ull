EXTRA_CFLAGS  :=
CFLAGS_file.o :=

# 提取当前目录下的所有 .c 文件的文件名（不带后缀）
C_FILES := $(basename $(wildcard *.c))

# 添加 .o 后缀
O_FILES := $(addsuffix .o,$(C_FILES))

obj-y += portable/MemMang/
obj-y += portable/low_power_tickless/
obj-y += portable/GCC/ARM_CA9/
obj-y += $(O_FILES)
