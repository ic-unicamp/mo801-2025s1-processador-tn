.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
	addi x2, x0, 511
    sw x2, 512(x0)
    
    lh  x1, 512(x0)
    lh  x1, 514(x0)
    lb  x1, 512(x0)
    lb  x1, 513(x0)
    lhu x1, 512(x0)
    lhu x1, 514(x0)
    lbu x1, 512(x0)
    lbu x1, 513(x0)

.data
variable:
	.word 0xdeadbeef
                    