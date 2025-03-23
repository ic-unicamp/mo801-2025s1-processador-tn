.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Tests jal */
	addi x1, x0, 8
    sw x1, 512(x0)
    jal x1, PULA_LOAD_1
    lw x2, 512(x0)
PULA_LOAD_1:
	jal x1, PULA_LOAD_2
   	lw x2, 512(x0)
PULA_LOAD_2:
	lw x3, 512(x0)
.data
variable:
	.word 0xdeadbeef
                    