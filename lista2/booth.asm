.data
    newline: .asciiz "\n"

    hi: .asciiz "Registrador da porção mais significativa:\n"
    lo: .asciiz "Registrador da porção menos significativa:\n"
    # 	Variáveis Syscall
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
 # --> srl
 # 0000 0001 [0] <-- bit de sinal 
 
 # O ultimo bit da cadeia é a representação do bit de 
 # sinal e portanto devemos armazena-lo para que 
 # não seja perdido quando deslocado para direita
 # toda vez que o bit de sinal muda é acrescentado 
 # no bit mais significativo o valor do bit de sinal, 
 # portanto

 # 0000 0001 [0]
 # srl
 # 1000 0000 [1]
 # representação em assembly

 #       mais significativo   menos significativo
 # 0 x [xxxx xxxx xxxx xxxx] [xxxx xxxx xxxx xxxx] 

 # Para identificar o bit menos siginificativo iremos 
 # usar uma especie de mascara para sempre pegar o menor bit
 # E atualizando o multiplicador para que seja pego o menor 
 # valor em relação ao ultimo digito

 # exemplo:
 # 7 AND mask
 # 7 -> 0 x 0000 0000 0000 0000 0000 0000 0000 0111
 # mask ->  0000 0000 0000 0000 0000 0000 0000 0001

 # quando o bit for igual retorna 1 se o bit for diferente retorna 0
 # srl no multiplicador original para ser uma especie de pop()
 # este bit deve ser acrescentado ao final do valor do multiplicando
 # Para isso ser feito podemos fazer um sll no bit e fazer um add  com o multiplicando original
 # ou inves de sll podemos usar mul e repetir o restante do processo

 # 7 ->    0 x 0000 0000 0000 0000 0000 0000 0000 0011
 # mask -> 0 x 0000 0000 0000 0000 0000 0000 0000 0001
 # -------------------------------------------------------
 # result -> 0x0000 0000 0000 0000 0000 0000 0000 0001 <-- sll
 #         0 x 0000 0000 0000 0000 0000 0000 1000 0000
 # -------------------------------------------------------
 # ADD
 #         0 x 0000 0000 0000 0000 0000 0000 0000 0011
 #         0 x 0000 0000 0000 0000 0000 0000 1000 0000
 # -------------------------------------------------------
 # result -> 0x0000 0000 0000 0000 0000 0000 1000 0011


## quantidade de interações necessárias ##
 # Deve-se ter um interador por fora desta operação para que seja contado
 # a quantidade de interações para que tenha um ponto de parada
 # Portanto para termos a quantidade de interadores devemos fatorar o numero,
 # ou seja, divir por 2
 # e contar a quantidade de divisões necessárias
 # exemplo
 # faremos isso com um for e srl e a cada 1 existente teremos um contador que sera incrementado
 # até que o valor seja igual a 0
 # 7 --> 0111 -> 0 + 2^2 + 2^1 ^ 2^0 --> 0 + 4 + 2 + 1 = 7
 # contador <= 4 interações
 # o contador irá começar com 1 para tratar em caso do bit mais significativo do multiplicador seja igual a 0
 # A quantidade de inteções é limitada pela quantidade de #### interações necessárias ou menor que 32 #####


### esqueleto da função ###

# passo1:
    # mflo $s0 multiplicador
    # lw $t0, 0x000000FF # mascara para zerar a porção de bit mais significativa do multiplicador  
    # and $s0, $s0, $t0 # multiplicador and $t0
    # j passo2
# passo2:
    # se ultimo bit atual + bit de sinal for 01 faça porção mais significativa - multiplicando -> 0 + 1 = 1
    # mfhi multiplicando
    # sub resultado, significativo, multiplicando

    # se ultimo bit atual + bit de sinal for 10 faça porção mais significativa + multiplicando -> 1 + 1 = 2 -> 10
    # mfhi multiplicando
    # add resultado, significativo, multiplicando
# passo3:
    # checa se ja atingiu a quantidade de interações totais
    # beq interador == interações necessárias, exit
    # deslocamento aritmetico de produto -> srl
# passo4: 
    # beq interador < 33, exit
    
    
    #get lsd from Q
    #$t0 = lsd - q0
    #if $t0 == 0 case_default
    #if $t0 < 0 case_01
    #if $t0 > 0 case_10

getn:
    addi $s4, $s4, 1 # quantidade de interações 
    srl $t0, $s2, 1 # 
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

    mfhi $s5 # move para menor porção o resultado da operação
    mflo $s6 # move para maior porção o resultado da operação

    la $a0, hi

    li $v0, 4
    syscall # print string da maior porção

    li $v0, 1
    move $a0, $s5
    syscall # printa valor da maior porção

    la $a0, lo

    li $v0, 4
    syscall # printa string registrador na menor porção

    li $v0, 1
    move $a0, $s6
    syscall # print valor da menor porçao

    la $a0, newline

    li $v0, 4
    syscall  # printa quebra de linha

    li $v0, 10
    syscall