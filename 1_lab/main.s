/*
    Lab 1, #33

     Expression
          (a^3 + b^3)
     ---------------------
     a^2 × c - b^2 × d + e

     where variable sizes are:
     a - 16,
     b - 16,
     c - 16,
     d - 16,
     e - 16.

     Variables are unsigned.

     Code alignment: chaotic neutral^W^W
     1 column - 8 chars wide - optional labels
     2 column - 8 chars wide - instructions/directives
     3 column - 16 chars wide - operands
     4 column - 48 chars wide - comments
     third column is 16 wide, last - 48
*/
        .arch    armv8-a
        .data
a:      .2byte   10
b:      .2byte   20
c:      .2byte   30
d:      .2byte   50
e:      .2byte   17000
      
        .p2align 3  // filling memory with nops so res is aligned to 2^3 bytes
res:
        .skip 8

	      .text
        .p2align 2
	      .global _start
        .type _start,%function

_start:
        adr   x0, a    // load address of a in x0
        adr   x1, b 
        adr   x2, c 
        adr   x3, d
        adr   x4, e
        ldrsh x0, [x0] // copy by adddres in x0 to x0 with sign in mind
        ldrsh x1, [x1]
        ldrsh x2, [x2]
        ldrsh x3, [x3]
        ldrsh w4, [x4]
        
        mul   x5, x0, x0 // a^2
        mul   x6, x1, x1 // b^2
        mul   x7, x5, x0 // a^3

        madd  x7, x1, x6, x7 // a^3+b^2*b
        bvs   exception      // check for signed overflows

        mul   x5, x5, x2  // a^2*c
        mul   x6, x6, x3  // b^2*d

        subs   x5, x5, x6  // a^2*c-b^2*d; operations with suffix s set overflow/zero flags so bvs can check it
        bvs   exception

        adds  x5, x5, w4, sxtw // (a^2*c-b^2*d)+e
        bvs   exception
        
        beq   exception        // jump if zero (eq?) flag is set

        sdiv  x5, x7, x5

        adr   x0, res  // load addr of res to x0
        str   x5, [x0] // store contents of x5 to address that is in x0
        mov   x0, #0   // exit code
        b     _exit    // jump on _exit

exception:
        mov x0, #1    // exit code
        b   _exit

_exit:
        mov x8, #93   // store syscall code in x8
        svc #0        // call syscall
        .size _start, _exit-_start
