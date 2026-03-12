.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:

    # Error checks
    li t0, 1
    blt a1, t0, error_m0        # m0_rows < 1 → 错误 72
    blt a2, t0, error_m0        # m0_cols < 1 → 错误 72
    blt a4, t0, error_m1        # m1_rows < 1 → 错误 73
    blt a5, t0, error_m1        # m1_cols < 1 → 错误 73
    bne a2, a4, error_match     # m0_cols != m1_rows → 错误 74
    # Prologue
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    mv s0, a0                   # s0 = m0 指针
    mv s1, a1                   # s1 = m0_rows
    mv s2, a2                   # s2 = m0_cols
    mv s3, a3                   # s3 = m1 指针
    mv s4, a4                   # s4 = m1_rows
    mv s5, a5                   # s5 = m1_cols
    mv s6, a6                   # s6 = d 指针
    li s7, 0                    # i

outer_loop_start:
    bge s7, s1, outer_loop_end

    li t0, 0

inner_loop_start:
    bge t0, s5, inner_loop_end

    mul a0, s7, s2
    slli a0, a0, 2
    add a0, s0, a0   #i

    slli a1, t0, 2
    add a1, s3, a1    #j

    mv a2, s2 #m0_col
    li a3, 1 #stride
    mv a4, s5 #m1_cols
    jal dot

    mul t1, s7, s5              # t1 = i * m1_cols
    add t1, t1, t0              # t1 = i * m1_cols + j
    slli t1, t1, 2              # t1 = (i * m1_cols + j) * 4
    add t1, s6, t1              # t1 = d 基地址 + 偏移
    sw a0, 0(t1)                # d[i][j] = 点积结果

    addi t0, t0, 1
    j inner_loop_start

inner_loop_end:
    addi s7, s7, 1
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 48
    ret

error_m0:
    li a0, 72
    li a7, 93
    ecall

error_m1:
    li a0, 73
    li a7, 93
    ecall

error_match:
    li a0, 74
    li a7, 93
    ecall