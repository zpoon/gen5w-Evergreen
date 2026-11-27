.syntax unified
.thumb
.section .text
.global gate, fallback, resume_delta, resume_anchor
.thumb_func
gate:
    ldr.w ip, handler
    cmp.w ip, #0
    beq fallback
    bx ip
    .org 16
    .word 0x45564731
    .word 1
    .word fallback-gate
handler:
    .word 0
.thumb_func
fallback:
    push.w {r4,r5,r6,r7,r8,r9,r10,r11,lr}
    ldr.w ip, resume_delta
resume_anchor:
    add ip, pc
    bx ip
    .balign 4
resume_delta:
    .word 0
