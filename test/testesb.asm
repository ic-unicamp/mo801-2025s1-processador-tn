.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Test ADDI */
    addi a0, x0, 1
    slli a0, a0, 11
    addi x1 , x0, 511   /* x1  = 1000 0x3E8 */
    
    lw x2, 512(a0)
    sb x1, 512(a0)
    sb x1, 513(a0)
    lw x2, 512(a0)
    sh x1, 516(a0)
    sh x1, 518(a0)
    lw x2, 516(a0)
    ebreak

.data
variable:
	.word 0xdeadbeef
                    