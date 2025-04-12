.global _boot
.text

_boot: 
	addi a1, x0, 1
	slli a1, a1, 11
	addi x2, x0, 511
    addi x1, x0, 1
   	
    beq x0, x0, BEQJ
	sw x0, 0(a1)
BEQJ:
	sw x2, 0(a1)

    bne x0, x1, BNEJ
	sw x0, 0(a1)
BNEJ:
	sw x2, 0(a1)

    blt x0, x1, BLTJ
	sw x0, 0(a1)
BLTJ:
	sw x2, 0(a1)

    bltu x0, x1, BLTUJ
	sw x0, 0(a1)
BLTUJ:
	sw x2, 0(a1)

    bge x1, x0, BGEJ
	sw x0, 0(a1)
BGEJ:
	sw x2, 0(a1)

    bgeu x1, x0, BGEUJ
	sw x0, 0(a1)
BGEUJ:
	sw x2, 0(a1)

    ebreak

.data
variable:
	.word 0xdeadbeef
                    