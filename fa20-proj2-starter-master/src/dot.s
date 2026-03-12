.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================

dot:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    li t0, 1

    blt a2, t0, error_length

    blt a3, t0, error_stride

    blt a4, t0, error_stride

    mv s0, a0                 # s0 = v0 指针
    mv s1, a1                 # s1 = v1 指针
    mv s2, a2                 # s2 = 长度
    mv s3, a3                 # s3 = v0 stride
    mv s4, a4                 # s4 = v1 stride
    li s5, 0                  # s5 = 循环索引 i = 0
    li s6, 0                  # s6 = 累加和 sum = 0

loop_start:
    bge s5, s2, loop_end

    mul t0, s5, s3            # t0 = i * stride0
    slli t0, t0, 2            # t0 = (i * stride0) * 4 (字节偏移)
    add t1, s0, t0            # t1 = v0 基地址 + 偏移
    lw t2, 0(t1)              # t2 = v0[i]

    mul t0, s5, s4            # t0 = i * stride1
    slli t0, t0, 2            # t0 = (i * stride1) * 4 (字节偏移)
    add t3, s1, t0            # t3 = v1 基地址 + 偏移
    lw t4, 0(t3)              # t4 = v1[i]

    mul t5, t2, t4            # t5 = v0[i] * v1[i]
    add s6, s6, t5            # sum += 乘积

    addi s5, s5, 1
    j loop_start

error_length:
    li a0, 75
    li a7, 93
    ecall

error_stride:
    li a0, 76
    li a7, 93
    ecall

loop_end:
    mv a0, s6
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32
    ret