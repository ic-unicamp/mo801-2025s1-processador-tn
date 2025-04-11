.global _boot
.text

_boot:
    addi x5, x0, 1
    slli x5, x5, 11

   	addi x1, x0, 32
    addi x2, x0, 2
    sub  x3, x0, x1
    
    sra x4, x3, x2
    sw x4, 0(x5)
    srai x4, x3, 2
    sw x4, 0(x5)
    
	ebreak;
.data
variable:
	.word 0xdeadbeef
                    