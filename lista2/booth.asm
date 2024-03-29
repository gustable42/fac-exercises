############### Desenvolvido por ###############
## Gustavo Veloso - 17/0065251
## Leonardo Barreiros - 15/0135521
################################################


################################################ Descrição da lógica ###################################################

 # --> srl
 # 0000 0001 [0] <-- bit de sinal 
 
 # O ultimo bit da cadeia é a representação do bit de sinal e portanto devemos armazena-lo para que 
 # não seja perdido quando deslocado para direita toda vez que o bit de sinal muda é acrescentado 
 # no bit mais significativo o valor do bit de sinal, portanto:

 # 0000 0001 [0]
 # srl
 # 1000 0000 [1]
 
 # representação em assembly da memória
 # ------------------------------------------------------------------
 #       mais significativo   menos significativo
 # 0 x [xxxx xxxx xxxx xxxx] [xxxx xxxx xxxx xxxx] 
 # ------------------------------------------------------------------
 
 # Para identificar o bit menos siginificativo iremos usar uma especie de mascara para sempre pegar o menor bit
 # E atualizando o multiplicador para que seja pego o menor valor em relação ao ultimo digito

 # exemplo:
 # 7 AND mask
 # 7 -> 0 x 0000 0000 0000 0000 0000 0000 0000 0111
 # mask ->  0000 0000 0000 0000 0000 0000 0000 0001

 # Quando o bit for igual retorna 1 se o bit for diferente retorna 0 srl no multiplicador original para 
 # ser uma especie de pop(). Este bit deve ser acrescentado ao final do valor do multiplicando.
 # Para isso ser feito podemos fazer um sll no bit e fazer um add  com o multiplicando original,
 # ou inves de sll podemos usar mul e repetir o restante do processo.

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


########################### quantidade de iterações necessárias ###########################
 # Deve-se ter um iterador por fora desta operação para que seja contado a quantidade 
 # de iterações para que tenha um ponto de parada. A quantidade de iterações irá se 
 # dar pela quantidade de bits que o multiplicando ou multiplicador, escolhendo sempre o maior.
 # Exemplo:

 # 0010 0001 x 0000 0011 -> para na 8ª interação
 # A quantidade de inteções é limitada pela quantidade de #### iterações necessárias ou menor que 32 #####


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
    
########################################################################################################################

.data
    newline: .asciiz "\n"

    hi: .asciiz "Registrador da porção mais significativa [a]:\n"
    lo: .asciiz "Registrador da porção menos significativa [b]:\n"
    produto: .asciiz "Multiplicação de a por b:\n"
.text

main:
    #inicializando o acumulador e o q0
	li $s0, 0 # q0 = 0
	li $s1, 0 # acc = 0
    li $s4, 0 # n = 0
	
	#setando o syscall para leitura do multiplicando e multiplicador
	li $v0, 5
	syscall
	move $s2, $v0 # Multiplicando = input (M)
	
	li $v0, 5
	syscall
	move $s3, $v0 # Multiplicador = input (Q)

    #setando em n o tamanho do inteiro com maior número de bits

    jal getn
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
    addi $a1, $a1, 1 # quantidade de iterações 
    srl $a0, $a0, 1
    
    bne $t0, $zero, getn

    move $v0, $a1
    jr $ra

case_01:
    add $s1, $s1, $s2
    j case_default

case_10:
    sub $s1, $s1, $s2
    j case_default

case_default:
    # fazer o shift AQq0
    #get LSD from A and pop off the value from it
    li $t0, 1
	and $t0, $s1, $t0
    srl $s1, $s1, 1

    #get LSD from Q, sum LSD from A to Q and pop off from it
    li $t1, 1
    and $t1, $s3, $t1
    srl $s3, $s3, 1
    move $s0, $t1

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

    la $a0, produto

    li $v0, 4 # string do produto
    syscall

    li $v0, 5
    move $a0, $s7 # valor do produto
    syscall

    la $a0, newline

    li $v0, 4
    syscall  # printa quebra de linha

    li $v0, 10
    syscall