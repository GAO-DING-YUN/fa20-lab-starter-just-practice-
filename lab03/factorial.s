.globl factorial

.data
n: .word 8

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    # YOUR CODE HERE
    beq a0, x0, base_case

    # 保存到栈（递归调用会修改 ra）
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)

    # 递归调用：factorial(n-1)
    addi a0, a0, -1
    jal ra, factorial

    # 恢复
    lw t0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8

    # 计算：n × factorial(n-1)
    mul a0, a0, t0       # a0 = factorial(n-1) × n
    jr ra

base_case:
    addi a0, x0, 1
    jr ra