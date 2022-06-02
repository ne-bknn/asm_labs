    .arch armv8-a
    .data
matrA:
    .skip 12800
matrB:
    .skip 12800
matr3:
    .skip 12800
matr4:
    .skip 12800
matr5:
    .skip 12800
res:
    .skip 12800
usage:
    .string "Usage %s file\n"
format:
    .string "Incorrect format of file\n"
size:
    .string "Dimension of matrix must be less or equal 20\n"
formint:
    .string "%d"
formfloat:
    .string "%f"
space:
    .string " "
outf:
    .string "%.1f"
newstr:
    .string "\n"
mode:
    .string "r"
    .text
    .align  2
    .global main
    .type   main, %function
    .equ    progname, 32
    .equ    filename, 40
    .equ    filestruct, 48
    .equ    n, 56
    .equ    A, 64
    .equ    B, 72
    .equ    matrix3, 80
    .equ    matrix4, 88
    .equ    matrix5, 96
    .equ    result, 104
    .equ    buf, 112
main: // usage
    mov x16, #4192
    sub sp, sp, x16
    stp x29, x30, [sp]
    stp x27, x28, [sp, #16]
    mov x29, sp
    cmp w0, #2
    beq 0f
    ldr x2, [x1]
    adr x0, stderr
    ldr x0, [x0]
    adr x1, usage
    bl fprintf
9:
    mov w0, #1
    ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    mov x16, #4192
    add sp, sp, x16
    b _exit
0://open file
    ldr x0, [x1]
    str x0, [x29, progname]
    ldr x0, [x1, #8]
    str x0, [x29, filename]
    adr x1, mode
    bl fopen
    cbnz x0, 1f
    ldr x0, [x29, filename]
    bl perror
    b 9b
1://read n
    str x0, [x29, filestruct]
    adr x1, formint
    add x2, x29, n
    bl fscanf
    cmp w0, #1
    adr x16, matrA
    str x16, [x29, A]
    adr x16, matrB
    str x16, [x29, B]
    adr x16, matr3
    str x16, [x29, matrix3]
    adr x16, matr4
    str x16, [x29, matrix4]
    adr x16, matr5
    str x16, [x29, matrix5]
    adr x16, res
    str x16, [x29, result]
    beq 2f
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, format
    bl fprintf
    b 9b
2://x28 = n * n
    mov x27, #0
    ldr w28, [x29, n]
    cmp x28, #0
    ble 3f
    cmp x28, #20
    bgt 3f
    mul x28, x28, x28
    b 4f
3:// if n < 0 or n > 20 -> error
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, size
    bl fprintf
    b 9b
4://read in matrA
    ldr x0, [x29, filestruct]
    adr x1, formfloat
    adr x13, matrA
    lsl x2, x27, #2
    add x2, x2, x13
    bl fscanf
    cmp w0, #1
    beq 5f
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, format
    bl fprintf
    b 9b
5:
    add x27, x27, #1
    cmp x27, x28
    bne 4b
6:
    mov x27, #0
    ldr w28, [x29, n]
    cmp x28, #0
    ble 7f
    cmp x28, #20
    bgt 7f
    mul x28, x28, x28
    b   8f
7:
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, size
    bl fprintf
    b 9b
8://read in matrB
    ldr x0, [x29, filestruct]
    adr x1, formfloat
    adr x13, matrB
    lsl x2, x27, #2
    add x2, x2, x13
    bl fscanf
    cmp w0, #1
    beq 10f
    ldr x0, [x29, filestruct]
    bl fclose
    adr x0, stderr
    ldr x0, [x0]
    adr x1, format
    bl fprintf
    b 9b
10: // A^2 - B^2 - (A + B) * (A - B)
    add x27, x27, #1
    cmp x27, x28
    bne 8b
    ldr x0, [x29, filestruct]
    bl fclose

    ldr x0, [x29, n]// A^2
    ldr x1, [x29, A]
    ldr x2, [x29, A]
    ldr x3, [x29, result]
    bl matrMul

    ldr x0, [x29, n]// B^2
    ldr x1, [x29, B]
    ldr x2, [x29, B]
    ldr x3, [x29, matrix3]
    bl matrMul

    ldr x0, [x29, n]// -B^2
    ldr x1, [x29, matrix3]
    bl matrNeg

    ldr x0, [x29, n]// res = A^2 - B^2
    ldr x1, [x29, result]
    ldr x2, [x29, matrix3]
    ldr x3, [x29, result]
    bl matrSum

    ldr x0, [x29, n]// (A + B)
    ldr x1, [x29, A]
    ldr x2, [x29, B]
    ldr x3, [x29, matrix4]
    bl matrSum

    ldr x0, [x29, n]// B^1
    ldr x1, [x29, B]
    ldr x2, [x29, matrix3]
    mov x3, #1
    bl square

    ldr x0, [x29, n]// -B^1
    ldr x1, [x29, matrix3]
    bl matrNeg

    ldr x0, [x29, n]// (A - B)
    ldr x1, [x29, A]
    ldr x2, [x29, matrix3]
    ldr x3, [x29, matrix3]
    bl matrSum

    ldr x0, [x29, n]// (A + B) * (A - B)
    ldr x1, [x29, matrix4]
    ldr x2, [x29, matrix3]
    ldr x3, [x29, matrix5]
    bl matrMul

    ldr x0, [x29, n]// -(A + B) * (A - B)
    ldr x1, [x29, matrix5]
    bl matrNeg

    ldr x0, [x29, n]// res = res - (A + B) * (A - B)
    ldr x1, [x29, result]
    ldr x2, [x29, matrix5]
    ldr x3, [x29, result]
    bl matrSum

    /*ldr x0, [x29, n] // A^2
    ldr x1, [x29, A]
    ldr x2, [x29, matrix3]
    mov x3, #2
    bl square

    ldr x0, [x29, n] // res = A^2
    ldr x1, [x29, matrix3]
    ldr x2, [x29, result]
    bl equating

    ldr x0, [x29, n] // B^2
    ldr x1, [x29, B]
    ldr x2, [x29, matrix3]
    mov x3, #2
    bl square

    ldr x0, [x29, n]// -B^2
    ldr x1, [x29, matrix3]
    bl matrNeg

    ldr x0, [x29, n]//res = A^2 - B^2
    ldr x1, [x29, result]
    ldr x2, [x29, matrix3]
    ldr x3, [x29, result]
    bl matrSum

    ldr x0, [x29, n]//(A + B)
    ldr x1, [x29, A]
    ldr x2, [x29, B]
    ldr x3, [x29, matrix3]
    bl matrSum

    ldr x0, [x29, n]// B^1
    ldr x1, [x29, B]
    ldr x2, [x29, matrix4]
    mov x3, #1
    bl square

    ldr x0, [x29, n]// -B^1
    ldr x1, [x29, matrix4]
    bl matrNeg

    ldr x0, [x29, n]//(A - B)
    ldr x1, [x29, A]
    ldr x2, [x29, matrix4]
    ldr x3, [x29, matrix4]
    bl matrSum

    ldr x0, [x29, n]//(A + B) * (A - B)
    ldr x1, [x29, matrix3]
    ldr x2, [x29, matrix4]
    ldr x3, [x29, matrix4]
    bl matrMul

    ldr x0, [x29, n]// -(A + B) * (A - B)
    ldr x1, [x29, matrix4]
    bl matrNeg

    ldr x0, [x29, n]// res = A^2 - B^2 - (A + B) * (A - B)
    ldr x1, [x29, result]
    ldr x2, [x29, matrix4]
    ldr x3, [x29, result]
    bl matrSum */

    ldr x0, [x29, n]
    ldr x1, [x29, result]
    bl outMatr

    ldr x0, [x29, n]
    ldr x1, [x29, result]
    mov w0, #0
    ldp x29, x30, [sp]
    ldp x27, x28, [sp, #16]
    mov x16, #4192
    add sp, sp, x16
_exit:
    ret
    .size   main, .-main
    .type   fillZero, %function
fillZero:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    mov x19, #0
    str x0, [x29, amount]
    str x1, [x29, matrA]
    ldr x2, [x29, amount]
    mov x3, x29
    add x3, x29, matrA
    mul x20, x2, x2
0:
    lsl x22, x19, #2
    fsub s0, s0, s0
    str s0, [x29, x22]
    add x19, x19, #1
    cmp x19, x20
    beq 1f
    b   0b
1:
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size   fillZero, .-fillZero
    .type   equating, %function
equating:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    str x2, [x29, matB]
    mov x10, #0
    mov x8, x0
    mul x8, x8, x8
    mov x7, #0
1:
    cmp x7, x8
    beq 2f
    ldr s1, [x1]
    str s1, [x2]
    add x1, x1, #4
    add x2, x2, #4
    add x7, x7, #1
    b 1b
2:
    ldr x1, [x29, matA]
    ldr x2, [x29, matB]
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size   equating, .-equating
    .type   matrSum, %function
    .equ    amount, 16
    .equ    matA,   24
    .equ    matB,   32
    .equ    mat3,   40
    .equ    buf,    48
matrSum:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    str x2, [x29, matB]
    str x3, [x29, mat3]
    mov x10, #0
    mov x8, x0
    mul x8, x8, x8
1:
    cmp x10, x8
    beq 2f
    ldr s1, [x1]
    ldr s2, [x2]
    fadd s3, s2, s1
    str s3, [x3]
    add x1, x1, #4
    add x2, x2, #4
    add x3, x3, #4
    add x10, x10, #1
    b 1b
2:
    ldr x1, [x29, matA]
    ldr x2, [x29, matB]
    ldr x3, [x29, mat3]
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size   matrSum, .-matrSum
    .type   matrNeg, %function
matrNeg:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    mov x10, #-1
    mul x11, x0, x0
0:
    add x10, x10, #1
    cmp x10, x11
    beq 1f
    ldr s0, [x1, x10, lsl #2]
    fneg s0, s0
    str s0, [x1, x10, lsl #2]
    b 0b
1:
    mov x0, #0
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size matrNeg, .-matrNeg
    .type matrMul, %function
matrMul:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    str x2, [x29, matB]
    str x3, [x29, mat3]

    ldr x0, [x29, matA]
    ldr x1, [x29, matB]
    ldr x2, [x29, amount]
    ldr x3, [x29, mat3]
    mov x19, #0 //k
    mov x20, #0 //j
    mov x21, #0 //i
0:
    mov x22, x21
    mul x22, x22, x2
    add x22, x22, x19
    lsl x22, x22, #2
    ldr s0, [x0, x22]
    mov x22, x19
    mul x22, x22, x2
    add x22, x20, x22
    lsl x22, x22, #2
    ldr s1, [x1, x22]
    mov x22, x21
    mul x22, x22, x2
    add x22, x22, x20
    lsl x22, x22, #2
    ldr s2, [x3, x22]
    fmul s0, s0, s1
    fadd s0, s0, s2
    str s0, [x3, x22]
1:
    add x19, x19, #1
    cmp x19, x2
    beq 2f
    b 0b
2:
    mov x19, #0
    add x20, x20, #1
    cmp x20, x2
    beq 3f
    b 0b
3:
    mov x20, #0
    add x21, x21, #1
    cmp x21, x2
    beq _ex
    b 0b
/*i:
    add x10, x10, #1
    cmp x10, x0
    beq _ex
    mov x11, #-1
j:
    add x11, x11, #1
    cmp x11, x0
    beq i
    mul x15, x10, x0
    add x15, x15, x11
    fmov s0, #-1.0
    fmov s4, #1.0
    fadd s0, s0, s5
    mov x12, #-1
k:
    add x12, x12, #1
    cmp x12, x0
    beq j
    mul x16, x10, x0
    add x16, x16, x12
    mul x17, x12, x0
    add x17, x17, x11
    ldr s1, [x1, x16, lsl #2]
    ldr s2, [x2, x17, lsl #2]
    fmadd s0, s1, s2, s0
    str s0, [x3, x15, lsl #2]
    b k*/
_ex:
    mov x0, #0
    //mov x0, x3
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size   matrMul, .-matrMul
    .type   square, %function
    .equ    temp, 48
square:
    mov x16, #12848
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    str x2, [x29, matB]
    str x3, [x29, mat3]
    mov x4, x3
    mov x20, #0
    bl equating
0:
    add x20, x20, #1
    cmp x20, x4
    beq 1f
    ldr x0, [x29, amount]
    ldr x1, [x29, matB]
    ldr x2, [x29, matA]
    add x3, x29, temp
    bl matrMul
    ldr x0, [x29, amount]
    add x1, x29, temp
    ldr x2, [x29, matB]
    bl equating
    ldr x1, [x29, matA]
    ldr x2, [x29, matB]
    ldr x3, [x29, mat3]
    b 0b
1:
    mov x0, #0
    ldp x29, x30, [sp]
    mov x16, #12848
    add sp, sp, x16
    ret
    .size   square, .-square
    .type   outMatr, %function
outMatr:
    mov x16, #4128
    sub sp, sp, x16
    stp x29, x30, [sp]
    mov x29, sp
    str x0, [x29, amount]
    str x1, [x29, matA]
    mov x17, #0 //i
    mov x18, #0 //j
    ldr x19, [x29, amount]
    ldr x20, [x29, matA]
0:
    mov x23, x17
    mul x23, x23, x19
    add x23, x18, x23
    lsl x23, x23, #2
    add x23, x23, x20
    adr x0, formfloat
    ldr s23, [x23]
    fcvt d0, s23
    bl printf
    b 1f
    /*add x17, x17, #1
    cmp x17, x0
    beq 2f
    str x17, [x29, buf]
    mov x19, buf
    add x19, x19, #8
    str x18, [x29, x19]
    adr x0, newstr
    bl printf
    ldr x0, [x29, amount]
    ldr x1, [x29, matA]
    ldr x17, [x29, buf]
    mov x18, #-1*/
1:
    add x18, x18, #1
    cmp x18, x19
    beq 3f
    adr x0, space
    bl printf
    b 0b
    /*add x18, x18, #1
    cmp x18, x0
    beq 0b
    str x17, [x29, buf]
    mov x19, buf
    add x19, x19, #8
    str x18, [x29, x19]
    mul x17, x17, x0
    lsl x18, x18, #2
    add x17, x17, x18
    adr x0, formfloat
    add x1, x29, matA
    //add x1, x1, x17
    ldr s1, [x1]
    fcvt d0, s1
    bl printf
    adr x0, space
    bl printf
    ldr x0, [x29, amount]
    ldr x1, [x29, matA]
    ldr x17, [x29, buf]
    mov x19, buf
    add x19, x19, #8
    ldr x18, [x29, x19]
    b   1b*/
3:
    adr x0, newstr
    bl printf
    mov x18, #0
    add x17, x17, #1
    cmp x17, x19
    beq 2f
    b 0b
2:
    mov x0, #0
    ldp x29, x30, [sp]
    mov x16, #4128
    add sp, sp, x16
    ret
    .size   outMatr, .-outMatr
