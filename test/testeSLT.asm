    .section .text
    .globl _start

_start:
    addi a0, x0, 1
    slli a0, a0, 11
    addi x1, x0, 100  # x1 = 100
    addi x2, x0, 1    # x2 = 1

    sll x1, x1, x2    # x1 = x1 << x2 (shift left lógico)

    sw x1, 512(a0)    # Armazena x1 em mem[512]

    srl x1, x1, x2    # x1 = x1 >> x2 (shift right lógico)

    sw x1, 513(a0)    # Armazena x1 em mem[513]
    ebreak

.section .bss
    .space 1024       # Aloca 1024 bytes de memória
mem:
