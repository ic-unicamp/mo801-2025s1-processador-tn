.global _boot
.text

_boot: 
    addi x30, x0, 511
    slli  x30, x30, 3
	addi x1, x0, 511
    addi x2, x0, 255
    
    and x3, x1, x2
    or  x4, x1, x2
    xor x5, x1, x2
    
    sw x3, 0(x30)
    sw x4, 0(x30)
    sw x5, 0(x30)

    andi x6, x1, 255
    ori  x7, x1, 255
    xori x8, x1, 255

    sw x6, 0(x30)
    sw x7, 0(x30)
    sw x8, 0(x30)

    ebreak

.data
variable:
	.word 0xdeadbeef
                    