.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Test branch */
    add  x1, x0, x0   /* Initial value x1 = 0 */
    addi x2, x0, 300  /* Initial value x2 = 300 */
for:
    addi x1, x1, 100
    sw x1, 512(x0)
    lw x0, 512(x0) /* print mem[512] */
    bne x1, x2, for
lw x0, 512(x0) /* print mem[512] */
.data
variable:
	.word 0xdeadbeef
                    