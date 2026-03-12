.globl read_matrix

.data
mode_r: .asciiz "r"

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:
    # ========== Prologue ==========
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)              # s0 = filename
    sw s1, 8(sp)              # s1 = rows 指针
    sw s2, 12(sp)             # s2 = cols 指针
    sw s3, 16(sp)             # s3 = file pointer
    sw s4, 20(sp)             # s4 = matrix pointer
    sw s5, 24(sp)             # s5 = rows 值
    sw s6, 28(sp)             # s6 = cols 值
    sw s7, 32(sp)             # s7 = 临时变量
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)

    mv s0, a0                 # filename
    mv s1, a1                 # rows 指针
    mv s2, a2                 # cols 指针

    mv a0, s0                 # filename
    la a1, mode_r             # "r" 模式
    jal fopen
    mv s3, a0                 # 保存文件指针

    beq a0, zero, error_fopen # 如果返回 NULL，错误 90

    mv a0, s1                 # 缓冲区 = rows 指针
    li a1, 4                  # 元素大小 = 4 字节
    li a2, 1                  # 读取 1 个元素
    mv a3, s3                 # 文件指针
    jal fread

    li t0, 1
    bne a0, t0, error_fread   # 如果返回值 != 1，错误 91

    mv a0, s2                 # 缓冲区 = cols 指针
    li a1, 4                  # 元素大小 = 4 字节
    li a2, 1                  # 读取 1 个元素
    mv a3, s3                 # 文件指针
    jal fread

    li t0, 1
    bne a0, t0, error_fread   # 如果返回值 != 1，错误 91

    lw s5, 0(s1)              # s5 = rows
    lw s6, 0(s2)              # s6 = cols

    mul t0, s5, s6            # t0 = rows * cols (元素个数)
    slli t0, t0, 2            # t0 = rows * cols * 4 (字节数)
    mv a0, t0                 # malloc 参数 = 字节数
    jal malloc
    mv s4, a0                 # 保存矩阵指针

    # 检查 malloc 错误
    beq a0, zero, error_malloc # 如果返回 NULL，错误 88

    mv a0, s4                 # 缓冲区 = 矩阵指针
    li a1, 4                  # 元素大小 = 4 字节
    mv a2, t0                 # 元素个数 = rows * cols (注意：t0 现在是字节数，需要除以 4)
    srli a2, t0, 2            # a2 = 字节数 / 4 = 元素个数
    mv a3, s3                 # 文件指针
    jal fread

    bne a0, a2, error_fread   # 如果返回值 != 元素个数，错误 91

    mv a0, s3                 # 文件指针
    jal fclose

    bne a0, zero, error_fclose # 如果返回值 != 0，错误 92

    mv a0, s4

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    ret

error_malloc:
    li a0, 88
    li a7, 93
    ecall

error_fopen:
    li a0, 90
    li a7, 93
    ecall

error_fread:
    li a0, 91
    li a7, 93
    ecall

error_fclose:
    li a0, 92
    li a7, 93
    ecall


