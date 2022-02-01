/*
     Expression
                     d
     a ⋅ e - b ⋅ c + ─
                     b
     ─────────────────
       (b + c) ⋅ a

     where variable sizes are:
     a - 16,
     b - 16,
     c - 32,
     d - 16,
     e - 32.

     Variables are unsigned.

     Alignment: chaotic neutral^W^W
     first two columns 8 chars wide,
     third column is 16 wide, last - 48
*/

        .section .rodata
mesg: 	.asciz   "Hello World\n"

	.text
	.global main

main: 	stp	x29, x30, [sp, #-16]!

	// printf("Hello World!\n")
	adr	x0, mesg
	bl printf

	// return 0
	mov 	w0, #0
	ldp	x29, x30, [sp], #16
	ret
	
	.size	main,(. - main)
