	.global asm_get_convolved_value
	.align 2
	.type asm_get_convolved_value, %function
asm_get_convolved_value:
	ldr w8, [sp]
	ldr w9, [sp, #8]
	stp x29, x30, [sp, #-16]!
	stp x16, x17, [sp, #-16]!
	stp x18, x19, [sp, #-16]!
	stp x20, x21, [sp, #-16]!
	// x0 - unsigned char* in
	// w1 - int w
	// w2 - int h
	// w3 - int n_channels
	// w4 - int x
	// w5 - int y
	// w6 - int channel
	// x7 - int* matrix
	// w8 - int matrix_size
	// w9 - int coeff
	// w10 - convolved value
	mov w10, #0

	tbz w8, #0, _wrong_matrix_size

	cmp w8, #1
	blt _zero_matrix_size
	
	// w11 - i, w12 - j
	mov w11, #0
	b _gcv_outer_loop_check
_gcv_outer_loop:
	mov w12, #0
	b _gcv_inner_loop_check
_gcv_inner_loop:
	// w13 - x+i-1
	// w14 - y+j-1
	add w13, w4, w11
	add w14, w5, w12
	sub w13, w13, #1
	sub w14, w14, #1

	cmp w13, w2
	bge _gcv_inner_loop_inc
	cmp w14, w1
	bge _gcv_inner_loop_inc

	// w15 - convolved value delta
	// w16-w21 are saved, may be used
	
	// calculate offset in convolution matrix
	mul x16, x11, x8 // i*matrix_size
	add x16, x16, x12     // i*matrix_size + j
	mov x20, #4
	mul x16, x16, x20
	// get convolution matrix value
	ldr w17, [x7, x16]
	// calculate offset in image
	mul x16, x13, x1 // (x+i-1)*w
	mul x16, x16, x3
	mul x18, x14, x3
	add x16, x16, x18
	add x16, x16, x6

	ldrb w16, [x0, x16]
	mul w16, w17, w16
	add w10, w10, w16
_gcv_inner_loop_inc:
	add w12, w12, #1
_gcv_inner_loop_check:
	cmp w12, w8
	bne _gcv_inner_loop
	
	add w11, w11, #1
_gcv_outer_loop_check:
	cmp w11, w8
	bne _gcv_outer_loop
	b _get_convolved_value_exit


_zero_matrix_size:
	mov w10, wzr
_get_convolved_value_exit:
	sdiv w0, w10, w9
	ldp x21, x20, [sp], #16
	ldp x19, x18, [sp], #16
	ldp x17, x16, [sp], #16
	ldp x29, x30, [sp], #16
	ret

_wrong_matrix_size:
	adr x0, _wrong_matrix_label
	bl puts
	mov x1, #1
	bl exit

	.data
_wrong_matrix_label:
	.asciz "Convolution matrix size should be odd\n"
