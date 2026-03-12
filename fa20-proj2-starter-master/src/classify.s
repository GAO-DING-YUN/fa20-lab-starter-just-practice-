.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    addi sp, sp, -52
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)
    sw s9, 36(sp)
    sw s10, 40(sp)
    sw s11, 44(sp)
    sw ra, 48(sp)

    li t0, 5
    bne a0, t0, incorrect_args_count # argc != 5


	# =====================================
    # LOAD MATRICES
    # =====================================

    lw s0, 4(a1)              # s0 = argv[1] = M0_PATH
    lw s1, 8(a1)              # s1 = argv[2] = M1_PATH
    lw s2, 12(a1)             # s2 = argv[3] = INPUT_PATH
    lw s3, 16(a1)             # s3 = argv[4] = OUTPUT_PATH
    mv s11, a2                # s11 = print_classification
    li a0, 24
    jal malloc
    beqz a0, malloc_fail
    mv s4, a0

    # Load pretrained m0
    mv a0, s0                 # a0 = 文件名路径
    addi a1, s4, 0            # a1 = 指向存储 m0_row 的内存地址
    addi a2, s4, 4            # a2 = 指向存储 m0_col 的内存地址
    jal read_matrix           # 读取矩阵，返回数据指针
    mv s5, a0                 # s5 = 保存 M0 数据在内存中的指针

    # Load pretrained m1
    mv a0, s1                 # a0 = 文件名路径
    addi a1, s4, 8            # a1 = 指向存储 m1_row 的内存地址
    addi a2, s4, 12           # a2 = 指向存储 m1_col 的内存地址
    jal read_matrix
    mv s6, a0                 # s6 = 保存 M1 数据在内存中的指针

    # Load input matrix
    mv a0, s2
    addi a1, s4, 16
    addi a2, s4, 20
    jal read_matrix
    mv s7, a0

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # -------------------------------------
    # 3.1 第一层线性变换：Result1 = M0 * Input
    # -------------------------------------
    # 计算结果矩阵的大小：M0_rows * Input_cols
    lw t0, 0(s4)              # t0 = M0 行数 (m0_row)
    lw t1, 20(s4)             # t1 = Input 列数 (in_col)
    mul a0, t0, t1            # 元素个数 = 行 * 列
    slli a0, a0, 2            # 字节数 = 元素个数 * 4 (每个 int 4 字节)
    jal malloc                # 分配结果内存
    beqz a0, malloc_fail      # 检查 malloc 是否成功
    mv s8, a0                 # s8 = 保存第一层结果指针 (int*)

    # 调用矩阵乘法函数 matmul
    # 参数约定：a0=M, a1=M_row, a2=M_col, a3=N, a4=N_row, a5=N_col, a6=Out
    mv a0, s5                 # a0 = M0 数据指针
    lw a1, 0(s4)              # a1 = M0 行数
    lw a2, 4(s4)              # a2 = M0 列数
    mv a3, s7                 # a3 = Input 数据指针
    lw a4, 16(s4)             # a4 = Input 行数
    lw a5, 20(s4)             # a5 = Input 列数
    mv a6, s8                 # a6 = 输出缓冲区指针
    jal matmul                # 执行矩阵乘法

    # -------------------------------------
    # 3.2 非线性激活层：Result1 = ReLU(Result1)
    # -------------------------------------
    mv a0, s8                 # a0 = 数据指针
    lw t0, 0(s4)              # t0 = M0 行数 (结果矩阵行数)
    lw t1, 20(s4)             # t1 = Input 列数 (结果矩阵列数)
    mul a1, t0, t1            # a1 = 元素总数
    jal relu                  # 执行 ReLU 激活函数 (原地修改)

    # -------------------------------------
    # 3.3 第二层线性变换：Result2 = M1 * Result1
    # -------------------------------------
    # 计算结果矩阵的大小：M1_rows * Result1_cols (即 Input_cols)
    lw t0, 8(s4)              # t0 = M1 行数 (m1_row)
    lw t1, 20(s4)             # t1 = Result1 列数 (in_col)
    mul a0, t0, t1            # 元素个数
    slli a0, a0, 2            # 字节数
    jal malloc
    beqz a0, malloc_fail
    mv s9, a0                 # s9 = 保存第二层结果指针 (int*)

    # 调用矩阵乘法函数 matmul
    mv a0, s6                 # a0 = M1 数据指针
    lw a1, 8(s4)              # a1 = M1 行数
    lw a2, 12(s4)             # a2 = M1 列数
    mv a3, s8                 # a3 = Result1 数据指针 (ReLU 后的结果)
    lw a4, 0(s4)              # a4 = Result1 行数 (等于 M0 行数)
    lw a5, 20(s4)             # a5 = Result1 列数 (等于 Input 列数)
    mv a6, s9                 # a6 = 输出缓冲区指针
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    mv a0, s3                 # a0 = 输出文件路径 (OUTPUT_PATH)
    mv a1, s9                 # a1 = 最终结果矩阵数据指针
    lw a2, 8(s4)              # a2 = 结果矩阵行数 (M1 行数)
    lw a3, 20(s4)             # a3 = 结果矩阵列数 (Input 列数)
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

    # 调用 argmax 找出最大值的索引作为分类结果
    mv a0, s9                 # a0 = 结果矩阵数据指针
    lw t0, 8(s4)              # t0 = 行数
    lw t1, 20(s4)             # t1 = 列数
    mul a1, t0, t1            # a1 = 元素总数
    jal argmax
    mv s10, a0                # s10 = 保存分类结果

    # -------------------------------------
    # 5.1 打印结果
    # -------------------------------------
    mv a1, s10                # a1 = 分类结果整数
    jal print_int             # 打印整数

    li a1, 10                 # 换行符 ASCII 码
    jal print_char            # 打印换行

done:
    # =====================================
    # 6. Free heap (释放堆内存)
    # =====================================
    mv a0, s4                 # 释放维度数组
    jal free
    mv a0, s5                 # 释放 M0 数据
    jal free
    mv a0, s6                 # 释放 M1 数据
    jal free
    mv a0, s7                 # 释放 Input 数据
    jal free
    mv a0, s8                 # 释放第一层结果
    jal free
    mv a0, s9                 # 释放第二层结果
    jal free

    mv a0, s10                # a0 = 分类结果

    # ==========================
    # Epilogue (函数尾声)
    # ==========================
    lw ra, 48(sp)             # 恢复返回地址
    lw s11, 44(sp)            # 恢复 s11-s0 (顺序与保存时相反)
    lw s10, 40(sp)
    lw s9, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 52           # 释放栈帧空间
    ret                       # 返回调用者

malloc_fail:
    li a1, 88                 # 错误码 88: 内存分配失败
    jal exit2                 # 终止程序 (注意：此处使用 exit2，通常为 exit)

incorrect_args_count:
    li a1, 89                 # 错误码 89: 命令行参数个数错误
    jal exit2                 # 终止程序