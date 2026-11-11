/* Nuclei ISA 16.5.21/22: conditional stack exchange, not a stored CSR. */
.section .text
.global _start
.macro check_swap csr, cause, level, expected_sp, expected_scratch
    li t0, \cause
    csrw mcause, t0
    li t0, \level
    csrw 0x346, t0
    li sp, 0x20001000
    li t0, 0x20002000
    csrw mscratch, t0
    csrrw sp, \csr, sp
    li t0, \expected_sp
    bne sp, t0, fail
    csrr t1, mscratch
    li t0, \expected_scratch
    bne t0, t1, fail
    /* The matching exit restores both original values. */
    csrrw sp, \csr, sp
    li t0, 0x20001000
    bne sp, t0, fail
    csrr t1, mscratch
    li t0, 0x20002000
    bne t0, t1, fail
.endm
_start:
    la t0, fail
    ori t0, t0, 3
    csrw mtvec, t0
    check_swap 0x349, 0x30000000, 0, 0x20001000, 0x20002000
    check_swap 0x349, 0x30000000, 0x40000000, 0x20002000, 0x20001000
    check_swap 0x349, 0x30400000, 0, 0x20002000, 0x20001000
    check_swap 0x349, 0x30400000, 0x80000000, 0x20001000, 0x20002000
    check_swap 0x348, 0x30000000, 0, 0x20001000, 0x20002000
    check_swap 0x348, 0x00000000, 0, 0x20002000, 0x20001000
    check_swap 0x348, 0x10000000, 0, 0x20002000, 0x20001000
    li a0, 0x600d
    ebreak
.balign 64
fail:
    li a0, 0xbad
    ebreak
