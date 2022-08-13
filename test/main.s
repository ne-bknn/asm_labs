    .arch armv8-a

    .p2align 2

    .text
    .global main
    .type main, %function

main:
    mov x0, #6
    mov x1, #-1
    mov x2, #-100
    mov x3, #-15
    mov x4, #-16
    mov x5, #-20
    mov x6, #-150
    fmov s1, #0.5

    cbz x0, exit

    // x0 - max, x4 - counter 
    mov x4, x0
    mov x0, x1

exit:
output:
    mov x1, x0
    adrp x0, .L.str
    add  x0, x0, :lo12:.L.str
    bl printf
    mov x8, #93
    mov x0, #0
    svc #0
    .size main, .-main

    .data

.L.str:
    .asciz  "%d\n"
