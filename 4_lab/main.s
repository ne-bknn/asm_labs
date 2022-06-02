/*

    Function:
      A^2-B^2-(A+B)*(A-B)
    Input: n
           <n lines 1 matrix>
           <n lines 2 matrix>
    Output: Resulting matrix
*/

    .arch   armv8-a 
    .data

matrix_A:
    .skip 6400
matrix_B:
    .skip 6400
matrix_1:
    .skip 6400
matrix_2:
    .skip 6400
n:
    .skip 4

fmt_double:
    .asciz "%lf "

fmt_newline:
    .asciz "\n"

fmt_read_double:
    .asciz " %lf "

fmt_read_int:
    .asciz " %d "

read_mode:
    .asciz "r"

fmt_asciz:
    .asciz "%s\n"


error_filename:
		.asciz		"Something wrong with the filename\n"
		
error_argc_label:
		.asciz		"Usage: ./3_lab.out <filename>\n"

fmt_open_file_err:
        .asciz		"Error opening file\n"



		.text
		.align 2
    .global main 
    .global matrix_mul
    .global matrix_sub_output
    .global matrix_read
    
argc_err:
		adr 		x1, error_argc_label
		bl          output
		mov 		w0, #1
        bl          _exit

my_exit:
        mov 		x0, #0
        bl          _exit

// void matrix_multiply(double * matrix_1, double *matrix_2, double *matrix_out, unsigned n) {
matrix_multiply:
        cbz     w3, matrix_multiply_end
        mov     x8, xzr
        mov     w9, wzr // w9 - i
        mov     w10, w3 // w10 - n
  loop_1_mul:
        mul     w11, w9, w3  // w11 = i * n
        mov     x12, xzr     // x12 - j
  loop_2_mul:
        add     w13, w11, w12          // w13 = i * n + j
        mov     x14, xzr               // x14 - k
        mov     w15, w12               // w15 - j
        ldr     d0, [x2, w13, uxtw #3] // d0 = matrix_2[i * n + j]
  loop_3_mul:
        add     w16, w8, w14            // w16 = i * n + k - n here is not original n, it is o*n, where o is the num of iterations
        ldr     d2, [x1, w15, uxtw #3]  // d2 = matrix_1[i * n + k]
        add     x14, x14, #1            // x14 = k + 1
        add     w15, w15, w3            // w15 = j + n
        ldr     d1, [x0, w16, uxtw #3]  // d1 = matrix_1[i * n + k]
        fmadd   d0, d1, d2, d0          // d0 = d0 + d1 * d2
        cmp     x10, x14                // n, k
        bne     loop_3_mul                  // if n != k loop again
        add     x12, x12, #1            // x12 = j + 1
        str     d0, [x2, x13, lsl #3]   // matrix_out[i * n + j] = d0
        cmp     x12, x10                // j, n
        bne     loop_2_mul                  // if j != n loop again
        add     w9, w9, #1              // i++
        add     x8, x8, x10             // n = n + n - we use another and +n it to skip multiplications
        cmp     w9, w10                 // w9, original n
        bne     loop_1_mul
  matrix_multiply_end:
        ret
        .size  matrix_multiply, .-matrix_multiply


// void matrix_sub_output(double * m1, double *m2, unsigned n)
matrix_sub_output:
    // callee saved registers used:
    // x23, x19, x20, x21, x22, x24
    stp    x29, x30, [sp, #-16]!
    stp    x19, x20, [sp, #-16]!
    stp    x21, x22, [sp, #-16]!
    stp    x23, x24, [sp, #-16]!
    cmp    w2, #1
    ble    matrix_sub_output_end
    mul    w23, w2, w2 // w23 = n * n
    mov    x19, x0 // x19 - matrix_1
    mov    x20, x1 // x20 - matrix_2
    mov    w21, wzr // w21 - i
    mov    w22, wzr // w22 - counter, should we display newline?
    mov    w24, w2
    b      loop_1_check
  loop_1:
    add    w21, w21, #1
    add    w22, w22, #1 // w22 = counter + 1
    ldr    d0, [x19], #8 // d0 = matrix_1[0]; matrix_1 = matrix_1 + 8
    ldr    d1, [x20], #8 // d1 = matrix_2[0]; matrix_2 = matrix_2 + 8
    adr    x0, fmt_double
    fsub   d0, d0, d1
    bl printf
    cmp    w22, w24
    bne loop_1_check
    adr    x0, fmt_newline
    bl printf
    mov    w22, wzr
  loop_1_check:
    cmp    w21, w23
    bge    matrix_sub_output_end
    b      loop_1
  matrix_sub_output_end:
    ldp   x23, x24, [sp], #16
    ldp   x21, x22, [sp], #16
    ldp   x19, x20, [sp], #16
    ldp   x29, x30, [sp], #16
    ret
    .size  matrix_sub_output, .-matrix_sub_output


// double * x0, int w1, FILE * x2
matrix_read:
        stp     x29, x30, [sp, #-16]!
        stp     x22, x21, [sp, #-16]!
        stp     x20, x19, [sp, #-16]!
        mov     x29, sp
        mul     w22, w1, w1
        cbz     w22, matrix_read_end
        mov     x19, x2
        mov     x20, x0
        adr     x21, fmt_read_double
  matrix_read_body:
        // FILE*, fmt, double *
        mov     x0, x19
        mov     x1, x21
        mov     x2, x20
        bl      fscanf
        add     x20, x20, #8 // matrix_1 = matrix_1 + 8
        subs    x22, x22, #1 // n--
        bne     matrix_read_body
  matrix_read_end:
        ldp     x20, x19, [sp], #16
        ldp     x22, x21, [sp], #16
        ldp     x29, x30, [sp], #16
        ret

        .global _start
        .type  _start, %function
_start:
        ldr     w0, [sp] // w0 - argc
  _validate_argc:
        cmp     w0, #2
        bne    argc_err
        ldr     x0, [sp, #8] // x0 - argv[0]
  _open_file:
        adr     x1, read_mode
        bl      fopen
        mov     x20, x0 // x20 - FILE*
        cbz     x0, open_err
  _read_matrices:
        // read n
        adr     x2, n
        adr     x1, fmt_read_int
        bl      fscanf
        adr     x2, n
        ldr     w1, [x2]
        mov     w21, w1 // w21 - n

        adr     x0, matrix_A
        mov     x2, x20
        bl      matrix_read

        adr     x0, matrix_B
        mov     x2, x20
        mov     w1, w21
        bl      matrix_read

        adr     x0, matrix_A 
        adr     x1, matrix_B
        adr     x2, matrix_1
        mov     w3, w21
        bl      matrix_multiply

        adr     x0, matrix_B
        adr     x1, matrix_A
        adr     x2, matrix_2
        mov     w3, w21
        bl      matrix_multiply

        adr     x0, matrix_1
        adr     x1, matrix_2
        mov     w2, w21
        bl      matrix_sub_output
        b       my_exit
        .size   _start, .-_start

output:
        adr     x0, fmt_asciz
        bl      printf
        ret



open_err:
        adr    x1, fmt_open_file_err
        bl     output
        mov    x0, #1
        bl     _exit
