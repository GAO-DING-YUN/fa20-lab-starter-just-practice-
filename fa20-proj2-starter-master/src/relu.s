.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    li t0, 1
    blt a1, t0, error
    mv s0, a0    # 数组指针
    mv s1, a1    # 元素个数
    li s2, 0     # i = 0
loop_start:
    bge s2, s1, loop_end

    slli t0, s2, 2          # i * 4 (每个 int 占 4 字节)
    add t1, s0, t0          # 计算 array[i] 的地址
    lw t2, 0(t1)            # 加载 array[i]

    blez t2, set_zero       # 如果 <= 0，设置为 0
    j store_back
set_zero:
    li t2, 0
store_back:
    sw t2, 0(t1)            # 写回内存
    addi s2, s2, 1          # i++
    j loop_start

loop_end: # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret

error:
    li a0, 78             # 错误码
    li a7, 93
    ecall