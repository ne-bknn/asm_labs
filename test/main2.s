    .arch armv8-a
    .p2align 2

    .data

fmt_write:
    .asciz "%c\n"

fmt_read:
    .asciz " %20[^ |\t\n] "

buf:
    .skip 20

    .text
    .global _start
    .type _start, %function



_start:
    adr x0, fmt_read
    adr x1, buf

    bl scanf

    adr x0, fmt_write
    adr x1, buf
    ldr x1, [x1]
    bl printf

    mov x8, #93
    mov x0, 0
    svc #0
