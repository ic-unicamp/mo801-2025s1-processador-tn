.global _boot
.text
/* Testa instruções de memória */
_boot:                    
    /* x0  = 0    0x000 */
    /*sw x0, 10(x0)*/
    addi x1 , x0,   1000  /* x1  = 1000 0x3E8 */
    addi x0, x1, 1000
    addi x2, x0, 53
    
    /* 
        x1 = 1000
        x2 = 53
    */

    add x1, x1, x1
    sub x3, x1, x2
    
    /* 
        x1 = 2000
        x2 = 53
        x3 = 1947
    */

    sw x1, 512(x0)  /* store posição 512 => 2000 */
    lw x2, 512(x0)  /* load x2 2000 */
 
.data
variable:
	.word 0xdeadbeef
                    