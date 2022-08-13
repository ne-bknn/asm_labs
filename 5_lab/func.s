  	.data

   	.text
	.global conv
	.align 2
	.type conv, %function
conv:
	mov 	w10, #-1
	mov 	w11, #8
	mul 	w0, w0, w10
	madd 	w0, w1, w10, w0
	madd 	w0, w2, w10, w0
	madd 	w0, w3, w10, w0
	madd 	w0, w4, w11, w0
	madd 	w0, w5, w10, w0
	madd 	w0, w6, w10, w0
	madd 	w0, w7, w10, w0
	madd 	w0, w8, w10, w0
	mov 	w11, #32
	sdiv 	w0, w0, w11
end1:
	b       sub_conv
	.size   conv, .-conv

    	.text
	.global  asm_process
	.align   2
	.type    asm_process, %function
asm_process:
	sub     sp, sp, #96
	stp     x22, x23, [sp]
	stp     x24, x25, [sp, #16]
	stp     x26, x27, [sp, #32]
	stp     x28, x29, [sp, #48]
	stp     x19, x20, [sp, #64]
	stp 	x21, x20, [sp, #80]

	mov 	 x12, x4    // n_channels
	mov 	 x25, x12
	mov	 x19, x1   // buf_out
	mov  	 x29, x0   // buf_in
	mov	 x20, x2    // width
	mov 	 x18, x20
	mul 	 x18, x18, x25
	sub 	 x18, x18, x12
	mov      x21, x3    //height
	mov 	 x17, x21
	mul 	 x17, x17, x25
	sub 	 x17, x17, x12
	mov	 x28, xzr	// x counter
	mov	 x27, xzr	//  y counter
asm_process_y:
asm_process_x:
	mov	 x22, x19       // buf address
	mov 	 x23, x20       // width
	mul	 x23, x20, x27  // beginning of x27's row
	add	 x23, x23, x28  // index of needed byte

	mov	 x0, x12
	mul      x24, x20, x0   // width in bytes
	add 	 x24, x23, x24  // index beginning of x27+1 row
	mul 	 x26, x20, x0   // width in bytes
	add 	 x26, x26, x24  // index beginning of x27+2 row
	add 	 x26, x26, x22  // address next in column of x27+2
	
	add 	 x16, x24, x29  // address to write
	add 	 x24, x24, x22  // next of column in x27+1

	add	 x22, x22, x23  // address of current byte to read

	mov 	 x25, x12       // read by byte, put in x0-x8, call conv
	ldrb	 w0, [x22]
    	add      x22, x22, x25
	ldrb	 w1, [x22]
    	add      x22, x22, x25
	ldrb	 w2, [x22]

	ldrb 	 w3, [x24]
    	add      x24, x24, x25
	ldrb	 w4, [x24]
	add 	 x24, x24, x25
	ldrb 	 w5, [x24]

	ldrb 	 w6, [x26]
    	add      x26, x26, x25
	ldrb	 w7, [x26]
	add 	 x26, x26, x25
	ldrb 	 w8, [x26]

	b	 conv

sub_conv:
	add 	x24, x16, x25
	strb	 w0, [x24]
	add	 x28, x28, #1 // x counter
	cmp	 x28, x18
	blt	 asm_process_x // keep iterating
	add	 x27, x27, #1
	mov	 x28, xzr      // null it
	cmp	 x27, x17
	blt	 asm_process_y // keep iterating
	mov 	 x0, x29
	mov 	 x1, x19
end:
	ldp     x22, x23, [sp]
	ldp     x24, x25, [sp, #16]
	ldp     x26, x27, [sp, #32]
	ldp     x28, x29, [sp, #48]
	ldp     x19, x20, [sp, #64]
	ldp 	x21, x20, [sp, #80]
	add     sp, sp, #96
	ret
	.size asm_process, .-asm_process
