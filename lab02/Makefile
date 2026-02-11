# 编译器配置
CC = gcc
CFLAGS = -ggdb -Wall -std=c99
LDFLAGS =

# 定义要生成的可执行文件（对应你的项目目标）
TARGETS = test_bit_ops test_lfsr vector-test

# --------------------------
# 默认目标：make 命令会执行这个 all 目标
all: $(TARGETS)  # 把所有可执行文件作为 all 的依赖，执行 make 时会编译这些目标

# --------------------------
# test_bit_ops 的编译规则
test_bit_ops: bit_ops.o test_bit_ops.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# test_lfsr 的编译规则
test_lfsr: lfsr.o test_lfsr.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# vector-test 的编译规则
vector-test: vector.o vector-test.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# --------------------------
# 通用规则：.c 文件编译为 .o 文件
.c.o:
	$(CC) $(CFLAGS) -c $<

# --------------------------
# 清理编译产物
clean:
	rm -f *.o $(TARGETS)