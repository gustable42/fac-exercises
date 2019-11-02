.data
    newline: .asciiz "\n"

    # 	Variáveis Syscall
    sys_print_int:		.word 1
    sys_print_binary:   .word 35
    sys_print_string:   .word 4
    sys_read_int:		.word 5
    sys_exit:			.word 10

.text

main:
    #inicializando o acumulador e o q0
	li $s0, 0 # q0 = 0
	li $s1, 0 # acc = 0
    li $s4, 0 # n = 0
	
	#setando o syscall para leitura do multiplicando e multiplicador
	li $v0, 5
	syscall
	move $s2, $v0 # Multiplicando = input
	
	li $v0, 5
	syscall
	move $s3, $v0 # Multiplicador = input

    #setando em n o tamanho do inteiro com maior número de bits
    bne $s2, $zero, getn
    bne $s3, $zero, getn
    j END

multfac:
    #get lsd from Q
    #$t0 = lsd - q0
    #if $t0 == 0 case_default
    #if $t0 < 0 case_01
    #if $t0 > 0 case_10

getn:
    addi $s4, $s4, 1
    srl $t0, $s2, 1
    srl $t1, $s3, 1
    
    bne $t0, $zero, getn
    bne $t1, $zero, getn

    j multfac

case_01:
    add $s1, $s1, $s2
    j case_default

case_10:
    sub $s1, $s1, $s2
    j case_default

case_default:
    # fazer o shift AQq0
    addi $s4, $s4, -1
    beq $s4, $zero, END
    j multfac

END:
    #colocar A em hi, Q em lo
    #printar o registrador de hi lo