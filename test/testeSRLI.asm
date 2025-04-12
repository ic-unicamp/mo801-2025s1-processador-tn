.global _boot
.text

_boot:  
    addi x1, x0, 1
    slli x1, x1, 11

   	addi x4, x0, 1
    slli x4, x4, 15
    srli x4, x4, 11
    sw x4, 0(x1)

	ebreak;
.data
variable:
	.word 0xdeadbeef
                    