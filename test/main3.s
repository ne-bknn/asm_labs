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

    stp x9, x10, [sp, #-16]!
    stp x7, x8, [sp, #-16]!
    stp x5, x6, [sp, #-16]!
    stp x3, x4, [sp, #-16]!
    stp x1, x2, [sp, #-16]!

    // x0 - current max, x1, x2 - current elements, x4 - counter
    mov x4, x0
    mov x0, x1
    
    b loop_check
loop_body:
    ldp x1, x2, [sp], #16
    cmp x1, x0
    ble else_label_1
    mov x0, x1
else_label_1:
    cmp x2, x0
    ble else_label_2
    mov x0, x2
else_label_2:
    sub x4, x4, #2
loop_check:
    cmp x4, #2
    bge loop_body

    cmp x4, #1
    bne exit
    ldr x1, [sp]
    cmp x1, x0
    ble exit
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
