cmake_minimum_required(VERSION 4.0)
project(fa20_lab_starter C)

set(CMAKE_C_STANDARD 11)

include_directories(fa20-proj1-starter-master)
include_directories(fa20-proj4-starter-master)
include_directories(lab01)
include_directories(lab02)
include_directories(lab07)
include_directories(lab09)
include_directories(lab10)
include_directories(lab10/libbmp)
include_directories(lab10/libhttp)

add_executable(fa20_lab_starter
        fa20-proj1-starter-master/gameoflife.c
        fa20-proj1-starter-master/imageloader.c
        fa20-proj1-starter-master/imageloader.h
        fa20-proj1-starter-master/imageloadertester.c
        fa20-proj1-starter-master/steganography.c
        fa20-proj4-starter-master/mat_test.c
        fa20-proj4-starter-master/matrix.c
        fa20-proj4-starter-master/matrix.h
        fa20-proj4-starter-master/numc.c
        fa20-proj4-starter-master/numc.h
        lab01/eccentric.c
        lab01/hello.c
        lab01/interactive_hello.c
        lab01/ll_cycle.c
        lab01/ll_cycle.h
        lab01/no_segfault_ex.c
        lab01/segfault_ex.c
        lab01/test_ll_cycle.c
        lab02/bit_ops.c
        lab02/bit_ops.h
        lab02/lfsr.c
        lab02/lfsr.h
        lab02/test_bit_ops.c
        lab02/test_lfsr.c
        lab02/vector-test.c
        lab02/vector.c
        lab02/vector.h
        lab03/ex2.c
        lab07/matrixMultiply.c
        lab07/test_transpose.c
        lab07/transpose.c
        lab07/transpose.h
        lab09/simd.c
        lab09/simd.h
        lab09/test_simd.c
        lab10/libbmp/libbmp.c
        lab10/libbmp/libbmp.h
        lab10/libhttp/libhttp.c
        lab10/libhttp/libhttp.h
        lab10/dotp.c
        lab10/hello.c
        lab10/omp_apps.c
        lab10/omp_apps.h
        lab10/server.c
        lab10/server_utils.c
        lab10/server_utils.h
        lab10/v_add.c)
