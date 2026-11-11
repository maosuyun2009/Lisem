/* Cache geometry advertised to cache-maintenance firmware. */
.section .text
.global _start
_start:
    csrr t0, 0xfc0
    andi t0, t0, 1023
    li t1, 0x195
    bne t0, t1, fail
    csrr t0, 0xfc1
    andi t0, t0, 1023
    li t1, 0x194
    bne t0, t1, fail
    /* Coherent guest memory still permits the Nuclei cache commands. */
    li t0, 0x20000000
    csrw 0x7cb, t0
    li t0, 6
    csrw 0x7cc, t0
    /* FlushPipeCCM: coherent accesses have no pending cache pipeline. */
    csrwi 0x4cf, 1
    csrr t0, 0x4cf
    bnez t0, fail
    li a0, 0x600d
    ebreak
fail:
    li a0, 0xbad
    ebreak
