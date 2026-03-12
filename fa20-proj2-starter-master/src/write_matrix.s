.globl write_matrix

.data
mode_wb: .string "wb"

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:
    addi sp, sp, -32
    sw   ra, 28(sp)
    sw   s0, 24(sp)
    sw   s1, 20(sp)
    sw   s2, 16(sp)
    sw   s3, 12(sp)

    mv   s0, a1               # s0 = 矩阵起始地址指针
    mv   s1, a2               # s1 = 矩阵行数
    mv   s2, a3               # s2 = 矩阵列数

    la   a1, mode_wb          # 加载二进制写入模式字符串 "wb" 的地址
    jal  ra, fopen
    beqz a0, err_fopen        # 如果返回 NULL 跳转到错误处理 93
    mv   s3, a0               # s3 = (FILE *stream)

    addi a0, sp, 0            # a0 = 使用栈空间临时存储行数数据的地址
    sw   s1, 0(a0)            # 将行数 (s1) 存入栈临时位置
    li   a1, 4                # a1 = 每个元素大小 (4 字节)
    li   a2, 1                # a2 = 元素个数 (1 个整数)
    mv   a3, s3               # a3 = 文件指针
    jal  ra, fwrite
    li   t0, 1                # 期望写入 1 个元素
    bne  a0, t0, err_fwrite   # 如果实际写入数量 != 1，跳转到错误处理 94

    addi a0, sp, 0            # a0 = 复用栈空间临时存储列数数据的地址
    sw   s2, 0(a0)            # 将列数 (s2) 存入栈临时位置
    li   a1, 4                # a1 = 每个元素大小 (4 字节)
    li   a2, 1                # a2 = 元素个数 (1 个整数)
    mv   a3, s3               # a3 = 文件指针
    jal  ra, fwrite
    li   t0, 1                # 期望写入 1 个元素
    bne  a0, t0, err_fwrite   # 如果实际写入数量 != 1，跳转到错误处理 94

    mv   a0, s0               # a0 = 矩阵数据起始指针
    li   a1, 4                # a1 = 每个整数 4 字节
    mul  a2, s1, s2           # a2 = 总元素个数 = 行数 * 列数
    mv   a3, s3               # a3 = 文件指针
    jal  ra, fwrite           # 调用 fwrite
    bne  a0, a2, err_fwrite   # 如果返回的写入数量 != 总元素数，跳转到错误处理 94

    mv   a0, s3               # a0 = 文件指针
    jal  ra, fclose
    bnez a0, err_fclose       # 如果返回值非 0 ，跳转到错误处理 95

    lw   ra, 28(sp)           # 恢复返回地址
    lw   s0, 24(sp)           # 恢复 s0
    lw   s1, 20(sp)           # 恢复 s1
    lw   s2, 16(sp)           # 恢复 s2
    lw   s3, 12(sp)           # 恢复 s3
    addi sp, sp, 32           # 释放栈空间
    ret                       # 返回调用者

err_fopen:
    li   a0, 93               # 错误代码 93: fopen 失败
    jal  ra, exit             # 调用 exit 终止程序 (exit 不会返回)

err_fwrite:
    li   a0, 94               # 错误代码 94: fwrite 失败
    jal  ra, exit             # 调用 exit 终止程序

err_fclose:
    li   a0, 95               # 错误代码 95: fclose 失败
    jal  ra, exit             # 调用 exit 终止程序