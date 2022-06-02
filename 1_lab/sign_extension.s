        .arch   armv8-a
        .data
a:      .2byte  10
        .text
        .global _start
        .type _start,%function
_start:
        adr x0, a
        ldrsh x0, [x0]
        b     _exit
_exit:
        mov x8, #93
        svc #0
        .size _start, _exit-_start
