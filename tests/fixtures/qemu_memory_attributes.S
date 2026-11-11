/* Nuclei memory attribute CSRs: independent region state and RMW access. */
.section .text
.global _start
.macro check_region base, mask, address, size_mask
    csrr t0, \base
    bnez t0, fail
    csrr t0, \mask
    bnez t0, fail
    li t0, \size_mask
    csrw \mask, t0
    li t1, \address
    csrw \base, t1
.endm
.macro verify_region base, mask, address, size_mask
    csrr t0, \mask
    li t1, \size_mask
    bne t0, t1, fail
    csrr t0, \base
    li t1, \address
    bne t0, t1, fail
    csrci \base, 1
    csrr t0, \base
    andi t1, t1, -2
    bne t0, t1, fail
    csrw \base, zero
    csrr t0, \base
    bnez t0, fail
    csrr t0, \mask
    li t1, \size_mask
    bne t0, t1, fail
.endm
_start:
    check_region 0x7f3, 0x7f4, 0x38000005, 0xfffff000
    check_region 0x7f5, 0x7f6, 0x38002005, 0xffffe000
    check_region 0x7f9, 0x7fa, 0x38004005, 0xffffc000
    check_region 0x7fb, 0x7fc, 0x38008005, 0xffff8000
    check_region 0x7fd, 0x7fe, 0x38010005, 0xffff0000
    check_region 0xbe0, 0xbe1, 0x38020005, 0xfffe0000
    check_region 0xbe2, 0xbe3, 0x38040005, 0xfffc0000
    check_region 0xbe4, 0xbe5, 0x38080005, 0xfff80000
    verify_region 0x7f3, 0x7f4, 0x38000005, 0xfffff000
    verify_region 0x7f5, 0x7f6, 0x38002005, 0xffffe000
    verify_region 0x7f9, 0x7fa, 0x38004005, 0xffffc000
    verify_region 0x7fb, 0x7fc, 0x38008005, 0xffff8000
    verify_region 0x7fd, 0x7fe, 0x38010005, 0xffff0000
    verify_region 0xbe0, 0xbe1, 0x38020005, 0xfffe0000
    verify_region 0xbe2, 0xbe3, 0x38040005, 0xfffc0000
    verify_region 0xbe4, 0xbe5, 0x38080005, 0xfff80000
    li a0, 0x600d
    ebreak
fail:
    li a0, 0xbad
    ebreak
