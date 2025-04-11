.global _boot
.text

_boot:
	addi a1, zero, 1
	slli a1, a1, 11

	lui x1, 1048575
    addi x2, x0, 1
    addi x3, x0, 10
    
    blt x2, x1, BLTJ
	sw x0, 0(a1)
BLTJ:
	sw x3, 0(a1)

    bltu x2, x1, BLTUJ
	sw x0, 0(a1)
BLTUJ:
	sw x3, 0(a1)

    bge x1, x2, BGEJ
	sw x0, 0(a1)
BGEJ:
	sw x3, 0(a1)

    bgeu x1, x2, BGEUJ
	sw x0, 0(a1)
BGEUJ:
	sw x3, 0(a1)
    
	ebreak
.data
variable:
	.word 0xdeadbeef
                    