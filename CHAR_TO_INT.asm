.data 
char:   .asciiz 
file: 	.asciiz  "7864,"
.text
	#$a2 e $t2 estão com as respostas 
 	la $t5,0 # primeiro endereço de file 
 	 # contador inicio 0
 	li $t0, 0
procura_virgula:
	lb $a1, file($t5)
 	beq $a1, ',', fim_virgula
 	addi, $t5, $t5, 1
 	j procura_virgula
fim_virgula:		
Loop:	
	addi, $t5, $t5, -1
 	lb $a1, file($t5)
	beq $a1, 48, zero
	beq $a1, 49, um
	beq $a1, 50, dois
	beq $a1, 51, tres
	beq $a1, 52, quatro
	beq $a1, 53, cinco
	beq $a1, 54, seis
	beq $a1, 55, sete
	beq $a1, 56, oito
	beq $a1, 57, nove
	
zero:
	li $t1, 0
	j op
um:
	li $t1, 1
	j op
dois:
	li $t1, 2
	j op
tres:
	li $t1, 3
	j op
quatro:
	li $t1, 4
	j op
cinco:
	li $t1, 5
	j op
seis:
	li $t1, 6
	j op
sete:
	li $t1, 7
	j op
oito:
	li $t1, 8
	j op
nove:
	li $t1, 9
	j op
op:
	beq $t0, 1, dez
	beq $t0, 2, cem
	beq $t0, 3, mil
	beq $t0, 4, dez_mil
	beq $t0, 5, cem_mil
	soma:
	add $t2, $t2, $t1
	addi $t0, $t0, 1
	beq $t5, 0, fim
	j Loop
dez:	
	mulou $t1,$t1,10
	j soma
cem:	
	mulou $t1,$t1,100
	j soma
mil:	
	mulou $t1,$t1,1000
	j soma	
dez_mil:	
	mulou $t1,$t1,10000
	j soma	
cem_mil:	
	mulou $t1,$t1,100000
	j soma	
fim:	
	move $v1, $t2
