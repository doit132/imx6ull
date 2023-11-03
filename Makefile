PHONY := clean

# 路径
objtree		:= .

# 交叉编译工具链设置
ARCH  ?= arm
CROSS_COMPILE ?= arm-linux-

ifeq ($(ARCH),x86)
	CC := gcc
else
	CC := $(CROSS_COMPILE)gcc
endif

AS  	= $(CROSS_COMPILE)as
LD  	= $(CROSS_COMPILE)ld
CC      = $(CROSS_COMPILE)gcc
CPP     = $(CC) -E
AR      = $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

export AS LD CC CPP AR NM
export STRIP OBJCOPY OBJDUMP

# 编译选项
CFLAGS := -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu89
CFLAGS += -fexec-charset=gbk
CFLAGS += -I $(shell pwd)/include

# 链接选项
LDFLAGS := -T./project/imx6ull.ld

export CFLAGS LDFLAGS

TOPDIR := $(shell pwd)
export TOPDIR

# 被编译的当前目录下的文件
obj-y +=

# 被编译的子目录
obj-y += imx6ull/
obj-y += project/
obj-y += bsp/

# 编译目标文件的名称
TARGET := test.bin

FreeRTOSINCLUDE    :=


all : start_recursive_build $(TARGET)
	@echo $(TARGET) has been built!

start_recursive_build:
	make -C ./ -f $(TOPDIR)/Makefile.build

$(TARGET) : built-in.o
	$(CC) -o $(TARGET) built-in.o $(LDFLAGS)

#定义清理伪目标
clean:
# make -C drivers clean
# make -C freertos clean
# rm -f *.o *.elf *.bin
	rm -f $(shell find -name "*.o")
	rm -f $(shell find -name "*.elf")
	rm -f $(shell find -name "*.bin")
	rm -f $(TARGET)

PHONY += distclean

distclean:
	rm -f $(shell find -name "*.o")
	rm -f $(shell find -name "*.o.d")
	rm -f $(TARGET)

.PHONY : $(PHONY)
