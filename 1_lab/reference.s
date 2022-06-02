	.arch armv8-a
	.file	"reference.c"
	.text
	.align	2
	.global	_start
	.type	_start, %function
_start:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	adrp	x0, a.4
	add	x0, x0, :lo12:a.4
	ldrh	w0, [x0]
	mov	w1, w0
	adrp	x0, e.3
	add	x0, x0, :lo12:e.3
	ldr	w0, [x0]
	mul	w1, w1, w0
	adrp	x0, b.2
	add	x0, x0, :lo12:b.2
	ldrh	w0, [x0]
	mov	w2, w0
	adrp	x0, c.1
	add	x0, x0, :lo12:c.1
	ldr	w0, [x0]
	mul	w0, w2, w0
	sub	w0, w1, w0
	adrp	x1, d.0
	add	x1, x1, :lo12:d.0
	ldrh	w2, [x1]
	adrp	x1, b.2
	add	x1, x1, :lo12:b.2
	ldrh	w1, [x1]
	udiv	w1, w2, w1
	and	w1, w1, 65535
	add	w1, w0, w1
	adrp	x0, b.2
	add	x0, x0, :lo12:b.2
	ldrh	w0, [x0]
	mov	w2, w0
	adrp	x0, c.1
	add	x0, x0, :lo12:c.1
	ldr	w0, [x0]
	add	w0, w2, w0
	adrp	x2, a.4
	add	x2, x2, :lo12:a.4
	ldrh	w2, [x2]
	mul	w0, w0, w2
	udiv	w0, w1, w0
	str	w0, [sp, 12]
	nop
	add	sp, sp, 16
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.data
	.align	1
	.type	a.4, %object
	.size	a.4, 2
a.4:
	.hword	10
	.align	2
	.type	e.3, %object
	.size	e.3, 4
e.3:
	.word	70
	.align	1
	.type	b.2, %object
	.size	b.2, 2
b.2:
	.hword	20
	.align	2
	.type	c.1, %object
	.size	c.1, 4
c.1:
	.word	30
	.align	1
	.type	d.0, %object
	.size	d.0, 2
d.0:
	.hword	50
	.ident	"GCC: (GNU) 11.2.0"
	.section	.note.GNU-stack,"",@progbits
