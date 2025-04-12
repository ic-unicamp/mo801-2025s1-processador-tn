.global _boot
.text

_boot: 
	addi a1, x0, 1
	slli a1, a1, 11
	addi x1, x0, 1
   	j ALO
	sw x0, 0(a1)
ALO:
	sw x1, 0(a1)

	ebreak

.data
variable:
	.word 0xdeadbeef
                    