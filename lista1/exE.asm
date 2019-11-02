.data
    newline: .asciiz "\n"

.text
    li $s0, 7 #$s0 = somatório fatura

main:
    li $v0, 5
    syscall
    move $s1, $v0 #$s1 = quantidade de m^3

    slti $t0, $s1, 11 # $t0 = 1 if $s1 < 11; $t0 = 0 if $s1 >= 11
    beq $t0, $zero, LOOP # ($t0 == 0) go to LOOP
    bne $t0, $zero, END # ($t0 != 0) go to END

LOOP:
    slti $t0, $s1, 101 # $t0 = 1 if $s1 < 101; $t0 = 0 if $s1 >= 101
    beq $t0, $zero, caseD
    slti $t0, $s1, 31 # $t0 = 1 if $s1 < 31; $t0 = 0 if $s1 >= 31
    beq $t0, $zero, caseC
    slti $t0, $s1, 11 # $t0 = 1 if $s1 < 11; $t0 = 0 if $s1 >= 11
    beq $t0, $zero, caseB
    j END

caseB:
    addi $s0, $s0, 1
    j LOOP

caseC:
    addi $s0, $s0, 2
    j LOOP

caseD:
    addi $s0, $s0, 5
    j LOOP


END:
    move $a0, $s0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 10
    syscall
