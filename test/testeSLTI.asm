.global _boot
.text

_boot:
	lui x1, 1048575
    addi x2, x0, 1
    slli x3, x2, 11

    sltu x4, x2, x1
    sw x4, 0(x3)

    slt x4, x2, x1
    sw x4, 0(x3)

    slt x4, x1, x2
    sw x4, 0(x3)
    
	ebreak
.data
variable:
	.word 0xdeadbeef
                    