.global _boot
.text
/* Testa instruções de memória */
_boot:                    
    /* x0  = 0    0x000 */
    /*sw x0, 10(x0)*/
    addi x1, x0, 1000  /* x1  = 1000 0x3E8 */
    addi x0, x1, 1000  /* x0  = 1000 0x3E8 -> tests */
    addi x2, x0, 53    /* x1  = 53 0x3E8 */
    sw x2, 512(x0)     /* tests addi */
    sw x0, 512(x0)     /* tests x0 + * = x0 */

    add x1, x1, x1     /* tests add */
    sw x1, 512(x0)
    sub x3, x1, x2     /* tests sub */
    sw x3, 512(x0)
 
.data
variable:
	.word 0xdeadbeef
                    