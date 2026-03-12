.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:

    # Prologue
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)

    li t0, 1
    blt a1, t0, error

    mv s0, a0                 # 数组指针
    mv s1, a1                 # 元素个数
    li s2, 0                  # i = 0
    li s3, 0                  # max_idx = 0
    lw t0, 0(s0)              # array[0]
    mv s4, t0                 # max_val = array[0]

loop_start:
    bge s2, s1, loop_end

    slli t0, s2, 2
    add t1, s0, t0            # array[i] 的地址
    lw t2, 0(t1)              # 加载 array[i]

    ble t2, s4, loop_continue
    mv s4, t2
    mv s3, s2

loop_continue:
    addi s2, s2, 1
    j loop_start


loop_end:
    mv a0, s3
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret



error:
    li a0, 77
    li a7, 93
    ecall