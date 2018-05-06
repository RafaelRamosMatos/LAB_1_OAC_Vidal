######################################################################################
# Autor: Rafael Rmos de Matos:150145683 
#################################################################################
.data
##################################################################################
FileName:                  .space 64   # arquivo compactado
fileout:		   .asciiz "descompactado.txt" # arquivo descompactado
mensagem_inicial:          .asciiz "COMPACTAR (C) OU DESCOMPACTAR (D):\n"
nome_arquivo:		   .asciiz "\nDIGITE O NOME DO ARQUIVO E APERTE ENTER\n"
arquivo_erro:		   .asciiz "\nARQUIVO NAO ENCONTRADO"
mensagem_erro:             .asciiz "\nENTRADA INCORRETA DIGITE NOVAMENTE:\n"
comando_execucao:          .asciiz " "
fpilha:		           .asciiz ""  #string: celula do arquivo compactado 
####################################################################################
#FileName:	.asciiz	"x.txt"
FileCompactadoName:	.asciiz	"compactado.lzw"
BufferIn:	.space	1
StringFinal:	.space	1000
StringAux:	.space	1000
StringAux2:	.space	1000
StringAux3:	.space	1000
Caracter:	.space	2
Dicionario:	.asciiz	
.text
#######################################################################################
#MOSTRA A MENSAGEM INICIA NA I/O 
mensagem:
    li $v0, 4       
    la $a0, mensagem_inicial    
    syscall         
    
##########################################################################################
#PEDE PARA O USUARIO O QUE ELE DESEJA FAZER: COMPACTAR OU DESCOMPÁCTAR
    li $v0, 12          
    syscall      
    
    beq $v0, 'D', file_name
    beq $v0, 'd', file_name
    beq $v0, 'C', file_name
    beq $v0, 'c', file_name
    
    li $v0, 4       
    la $a0, mensagem_erro   
    syscall         
    
    j mensagem
            
##########################################################################################			
file_name: # entrada com o nome do arquivo 
	 move $t2, $v0
	 li $v0, 4     
  	 la $a0, nome_arquivo    
   	 syscall     
   	 li $v0, 8
   	 la $a0, FileName 
   	 li $a1, 64
    	 syscall
    loop_fim_nome:
		lb $t1, FileName($t0)
    	 	beq $t1 , '\n', pula_2
    	 	addi $t0, $t0, 1
    	 	j  loop_fim_nome
    	 	
    	 	pula_2:
    	 		li $t1, '\0'
    	 		sb $t1, FileName($t0)
    	 		li $t0, 0
    	 		li $t1, 0
   	
########################################################################################
		
 ########################################################################################
 #VERIFICA SE O ARQUIVO EXISTE
  	bne $v0, -1, main
  	li $v0, 4       
    	la $a0, arquivo_erro   
    	syscall 
    	
    	j file_name
############################################################################################  
main: 
	 beq $t2, 'D', rafael
   	 beq $t2, 'd', rafael
    	 beq $t2, 'C', tomas
    	 beq $t2, 'c', tomas
    	 
########################################################################################
rafael:	#System call para abrir o arquivo de leitura 
		        li $v0,13 
			la $a0,FileName
			li $a1,0       
			li $a2,0
			syscall
			move $t6,$v0 
         #System call para abrir o arquivo de escrita
			
		       li   $v0, 13        
                       la   $a0, fileout    
                       li   $a1, 1       
                       li   $a2, 0        
                       syscall           
                       move $t7, $v0  
########################################################################################

############################################################################################
 la $t2, 0 #contador de endereço
 loop_copia: # nesta parte ele atualiza onde a leitura foi interompida 
			li $v0,14 #System call para ler ficheiro
			move $a0,$t6
			la $a1, fpilha($t2)
			li $a2, 10	# quantidade de char que sao lidos 
			syscall
			addi $t2, $t2, 9
			lb $t4, fpilha($t2)
			beq $t4, 0, copiado
			addi $t2, $t2, 1	
			j loop_copia
			copiado:
###########################################################################################
la $s7, 0 # ponteiro da fpilha (ponteiro do arquivo já na memoria .data)
la $t8, 1
leitura_do_arquivo:
# esta funcao ler de ( ate ) entao e feita a leitura (n,char)
		loopleitura:
			addi $t8, $t8, 1 
			addi $s7, $s7, 1 
			lb $t4, fpilha($s7)
			beq $t4, 0, exit	  
			beq $t4, ',', fim_celula # checa se chegou no fim da celula 
			j loopleitura			
			fim_celula: # fim da celula 
			addi $s7, $s7, 2 
			move $s5, $s7
			li $s6, 0
			
##########################################################################################
# o $s7 vai ser o ponteiro que guarda o endereço de posicao de leitura 
#FUNCAO PARA TRANSFOMAR CARACTERE EM INTERIO 	
converte_char_int:
li $t0,0	
procura_virgula: # nesta funcao e iniciada um busca pela virgula na celula
	lb $a1, fpilha($t5)
 	beq $a1, ',', fim_virgula # a virgula é a condicao de parada 
 	addi, $t5, $t5, 1
 	j procura_virgula
fim_virgula:
move $s0, $t5	
####################################################################################		
procura_numero:	# nesta parte acontece a convercao
	addi, $t5, $t5, -1 # a numero é lido da direita para esquerda para identificar a orden de grandeza  
 	lb $a1, fpilha($t5) # $a1 recebe o unumero em fomato de caractere 
 	beq $a1, '(', fim_soma
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
zero: #op = operacao de soma
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
op: # atribuicao de ordem de grandeza 
	beq $t0, 1, dez
	beq $t0, 2, cem
	beq $t0, 3, mil
	beq $t0, 4, dez_mil
	beq $t0, 5, cem_mil
	beq $t0, 6, milhao
	soma: #soma de acordo com a ordem de grandeza 
	add $t3, $t3, $t1
	addi $t0, $t0, 1
	j procura_numero
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
milhao:	
	mulou $t1,$t1,1000000
	j soma	
fim_soma:	
	la $t0, 0

	move $v1, $t3  # retorna $v1 como o numero em inteiro 	
	
##########################################################################################
#VERIFICA SE O NUMERO LIDO E ZERO PARA ESCREVER O CARACTER DA CELULA NO ARQUIVO
	move $t3, $v1
	beqz $t3, procura_caractere
	j empilha # caso não seja zero sera empilhado 
#######################################################################################
empilha_celula:  #funcao que empilha que não tem zero 
			#preparando o formato da pilha  
			bnez $s6 pula_1
			move $s6, $s7  
			pula_1:   
			addi $sp, $sp, -8 # pilha com 8 bytes 
		       	sw   $ra, 4($sp) # primeiro elemento da pilha é o endereco com 4 bytes 
       
	empilha_char: # inicio da empilhagem  dos caracteres 
		
		addi $sp, $sp, 1
		addi $s6, $s6, -1
		lb $a3, fpilha($s6)
		sb $a3, 0($sp)
		 
		
	fim_pilha: # fim da empilhagem
		addi $sp, $sp, -1 # atuali o $sp na pilha para manter sempre um espaco de 8 bytes 
		j leitura_arquivo_busca	
####################################################################################
procura_caractere: # preparando para escrever no arquivo de saida  
	move $s5, $s0
	addi $s5, $s5, 1
	
####################################################################################
						
escreve: #ecreve no arquivo de saida 
            		
            loop_escrita:
 			li   $v0, 15       # system call para escrever no arquivo 
                        move $a0, $t7  
                        la $a1, fpilha($s5)   # file descriptor 			  # address of buffer from which to write
                        li   $a2,1    
                        syscall 
                 move $t5, $s7
                 j desempilha
###################################################################################						
			
###################################################################################
leitura_arquivo_busca:
		beq $t3, 1, caso_unico
		li $t2, 1
		li $t0, 0
		addi $t3, $t3, -1
		loop_busca: 
			lb $t4, fpilha($t0)
			beq $t4, ')', soma_1
			addi $t0, $t0, 1
			j loop_busca
			soma_1:
			
			beq $t2, $t3, fim_celula_1 
			addi $t2, $t2, 1
			addi $t0, $t0, 1
			j loop_busca
			fim_celula_1:	 # fim da celula  
			move $t5, $t0
			
			loop_celula:
				addi $t0, $t0, 1 # t0 fica com o fim da celula a ser empilhada 
				lb $t4, fpilha($t0)
			  	beq $t4, ')', encon
				j loop_celula
			encon:
			move $s6, $t0
			li $t3, 0
			
			j converte_char_int
			caso_unico:
			li $t5, 0
			li $t3, 0
			j converte_char_int
############################################################################################
empilha:
	jal empilha_celula
	# neste linha  fica o  endereço do primeiro  $ra
desempilha:
	beq $sp, 2147479548, loopleitura # pilha vazia é reprezendado pelo valor de $sp igual a 2147479548 
	addi $sp, $sp, 1	
pega_letra: 
	li   $v0, 15       # system call para escrever no arquivo 
        move $a0, $t7  
        la $a1, ($sp) 
        li   $a2, 1    
        syscall 
        
        addi $sp, $sp, -1
	lw $ra, 4($sp)	
	addi $sp, $sp, 8			
	jr $ra	
####################################################################################

exit: # fim, fechando os dois aruivos:  entrada e saida 
			li $v0,16 #System call para fechar ficheiro     
			move $a0,$t6 
			syscall
			li $v0,16 #System call para fechar ficheiro     
			move $a0,$t7 
			syscall
			#termina o progrma
			li $v0, 10
			syscall
############################################################################################
#############################################################################################
tomas:
jal	populaDicionario
jal	compacta

li	$v0,10
syscall

compacta:
	li	$t0,0
	LoopGrandeCompacta:
		la	$s0,StringAux
		la	$s1,Caracter
		li	$s7,0
		addi	$sp,$sp,-16
		sw	$s0,12($sp)
		sw	$s1,8($sp)
		sw	$t0,4($sp)
		sw	$ra,($sp)
		move	$a0,$t0
		jal	get
		lw	$ra,($sp)
		lw	$t0,4($sp)
		lw	$s1,8($sp)
		lw	$s0,12($sp)
		addi	$sp,$sp,16
		move	$t1,$v0
		LoopPequenoCompacta:
			lb	$t2,($t1)
			lb	$t3,1($t1)
			addi	$s7,$s7,1
			beq	$t2,'\0',fimArquivoCompacta
			beq	$t3,'\0',fimStringCompacta
			sb	$t2,($s0)
			addi	$s0,$s0,1
			addi	$t1,$t1,1
			j	LoopPequenoCompacta
			fimStringCompacta:
				bgt 	$s7,1, StringMaiorQueUm
				sb	$t2,($s1)
				li	$t2,'\0'
				sb	$t2,1($s1)
				li	$v0,0
				j	EscreveCompacta
				StringMaiorQueUm:
				sb	$t2,($s1)
				li	$t2,'\0'
				sb	$t2,($s0)
				sb	$t2,1($s1)
				la	$s0,StringAux
				addi	$sp,$sp,-16
				sw	$s0,12($sp)
				sw	$s1,8($sp)
				sw	$t0,4($sp)
				sw	$ra,($sp)
				move	$a0,$s0
				jal	getIndex
				lw	$ra,($sp)
				lw	$t0,4($sp)
				lw	$s1,8($sp)
				lw	$s0,12($sp)
				addi	$sp,$sp,16
				addi	$v0,$v0,1
				EscreveCompacta:
				move	$a0,$v0
				la	$a1,Caracter
				sw	$s0,12($sp)
				sw	$s1,8($sp)
				sw	$t0,4($sp)
				sw	$ra,($sp)
				jal	escreveArquivo
				lw	$ra,($sp)
				lw	$t0,4($sp)
				lw	$s1,8($sp)
				lw	$s0,12($sp)
				addi	$t0,$t0,1
				j	LoopGrandeCompacta
				fimArquivoCompacta:
					jr	$ra	
				
escreveArquivo:	#recebe em $a0 o index INTEIRO do dicionario e em a1 o caracter
	move	$a0,$a0
	move	$s1,$a1
	addi	$sp,$sp,-8
	sw	$ra,4($sp)
	sw	$s1,($sp)
	jal	intToString
	lw	$s1,($sp)
	lw	$ra,4($sp)
	addi	$sp,$sp,8
	la	$s0,StringAux3	#aqui fica o retorno da funcai intToString
	la	$t0,StringFinal
	li	$t7,0
	li	$t1,'('
	sb	$t1,($t0)
	add	$t7,$t7,1
	addi	$t0,$t0,1
	LoopEscreveNumero:
		lb	$t1,($s0)
		beq	$t1,'\0',fimNumeroEscreve
		sb	$t1,($t0)
		addi	$t7,$t7,1
		addi	$t0,$t0,1
		addi	$s0,$s0,1
		j	LoopEscreveNumero
	fimNumeroEscreve:
		li	$t1,','
		sb	$t1,($t0)
		addi	$t7,$t7,1
		addi	$t0,$t0,1
		addi	$s0,$s0,1
		lb	$t1,($s1)
		sb	$t1,($t0)
		addi	$t7,$t7,1
		addi	$t0,$t0,1
		li	$t1,')'
		sb	$t1,($t0)
		add	$t7,$t7,1
	escreveArquivoFinal:
		li	$v0,13
		la	$a0,FileCompactadoName
		li	$a1, 9          
		li 	$a2, 0
		syscall
		move	$a0,$v0
		la	$a1,StringFinal
		move	$a2,$t7
		li	$v0,15
		syscall
		li	$v0,16
		syscall
		
		
		jr	$ra
	
		
##############################################################################################################################
intToString:	#a0 recebe o valor int 
la	$t1,StringAux3
move	$t0,$a0
li	$t3,0
li	$t4,0
loopIntToString:
div 	$t2, $t0, 10
mfhi 	$t2 #resto
addi	$t2,$t2,48
addi	$sp,$sp,-1
sb 	$t2,($sp)
div 	$t0, $t0, 10
addi	$t3,$t3,1
beqz	$t0,fimLoopIntToString		
j	loopIntToString
fimLoopIntToString:
lb	$t2,($sp)
addi	$sp,$sp,1
sb	$t2,($t1)
addi	$t1,$t1,1
addi	$t4,$t4,1
beq	$t3,$t4,fimFim
j	fimLoopIntToString
fimFim:
li	$t2,'\0'
sb	$t2,($t1)
jr	$ra
##############################################################################################################################




getIndex:	# $a0 tem o valor da string
	move	$s0,$a0
	la	$s1,Dicionario
	addi	$s1,$s1,1
	la	$s2,StringAux2
	li	$t1,0
LoopIndex:	
	lb	$t0,($s1)
	sb	$t0,($s2)
	beq	$t0,'\0', fimStringIndex
	addi	$s1,$s1,1
	addi	$s2,$s2,1
	j	LoopIndex
	fimStringIndex:
		la	$s2,StringAux2
		addi	$sp,$sp,-20
		sw	$ra,16($sp)
		sw	$s0,12($sp)
		sw	$s1,8($sp)
		sw	$s2,4($sp)
		sw	$t1,($sp)
		move	$a0,$s2
		move	$a1,$s0
		jal	comparaString
		lw	$t1,($sp)
		lw	$s2,4($sp)
		lw	$s1,8($sp)
		lw	$s0,12($sp)
		lw	$ra,16($sp)
		addi	$sp,$sp,20
		beq	$v0,1,IguaisIndex
		lb	$t0,1($s1)
		beq	$t0,'\0',fimDicionarioIndex
		addi	$s1,$s1,1
		addi	$t1,$t1,1
		la	$s2,StringAux2
		j	LoopIndex
		IguaisIndex:
			move	$v0,$t1
			jr	$ra
		fimDicionarioIndex:
			li	$v0,-1
			jr	$ra

populaDicionario:
	la	$s0,Dicionario
	la	$s1,StringAux	
	la	$s2,BufferIn
	la	$a0,FileName
	li	$a1,0
	li	$a2,0
	li	$v0,13
	syscall
	move	$s3,$v0
	LoopPopula:
		move	$a0,$s3
		move	$a1,$s2
		li	$a2,1
		li	$v0,14
		syscall
		move	$t0,$v0
		beq	$t0,0,fimArquivo
		lb	$t1,($s2)
		li	$t2,'\0'
		sb	$t1,($s1)
		sb	$t2,1($s1)
		addi	$sp,$sp,-20
		sw	$ra,16($sp)
		sw	$s0,12($sp)
		sw	$s1,8($sp)
		sw	$s2,4($sp)
		sw	$s3,($sp)
		la	$a0,StringAux
		jal	adiciona
		lw	$s3,($sp)
		lw	$s2,4($sp)
		lw	$s1,8($sp)
		lw	$s0,12($sp)
		lw	$ra,16($sp)
		addi	$sp,$sp,20
		move	$t0,$v0
		beq	$t0,-1,jaExistia
		la	$s1,StringAux
		j	LoopPopula
		jaExistia:
			addi	$s1,$s1,1
			j	LoopPopula
		fimArquivo:
			move	$a0,$s3
			li	$v0,16
			syscall
			jr	$ra		
		
		
adiciona:	# recebe string em $a0
	move	$t0,$a0
	li	$t1,0
	Loop1:
		move	$a0,$t1
		addi	$sp,$sp,-12
		sw	$ra,8($sp)
		sw	$t0,4($sp)
		sw	$t1,($sp)
		jal	get
		lw	$t1,($sp)
		lw	$t0,4($sp)
		lw	$ra,8($sp)
		addi	$sp,$sp,12	
		addi	$sp,$sp,-16
		move	$t2,$v0
		sw	$ra,12($sp)
		sw	$t2,8($sp)
		sw	$t0,4($sp)
		sw	$t1,($sp)
		move	$a0,$t2
		move	$a1,$t0
		jal	comparaString
		lw	$t1,($sp)
		lw	$t0,4($sp)
		lw	$t2,8($sp)
		lw	$ra,12($sp)
		addi	$sp,$sp,16
		move	$t3,$v0
		beq	$t3,1,Existe
		lb	$t2,($t2)
		beq	$t2,'\0',naoExiste
		addi	$t1,$t1,1
		j	Loop1
		Existe:
			li	$v0,-1
			jr	$ra
		naoExiste:
			la	$t1,Dicionario
		Loop2:
			lb	$t2,($t1)
			lb	$t3,1($t1)
			beq	$t2,'\0',fim1
			addi	$t1,$t1,1
			j	Loop2
			fim1:
				beq	$t3,'\0',fim2
				addi	$t1,$t1,1
				j	Loop2
			fim2:			
				addi	$t1,$t1,1
				lb	$t4,($t0)
				sb	$t4,($t1)
				addi	$t0,$t0,1
				beq	$t4,'\0',fim
				j	fim2
			fim:
				li	$v0,1
				jr	$ra
		
		
	

comparaString:	#coloca em $v0 1 se forem iguais e -1 se forem diferentes
	lb	$t0,($a0)	#carrega da memoria um byte string1
	lb	$t1,($a1)	#carrega da memoria um byte string2	
	bne	$t0,$t1, notEqual
	beq	$t0,$t1, equal		
notEqual:	
	li	$v0,-1
	jr	$ra
equal:	
	beq	$t0,$zero,fimCompara
	addi	$a0,$a0,1
	addi	$a1,$a1,1
	j	comparaString
fimCompara:
	li	$v0,1
	jr	$ra	
	

get:	# recebe int em $a0
	
	move	$t0,$a0
	la	$t1,Dicionario
	li	$t2,0
	addi	$t1,$t1,1
	Loop:
		beq	$t2,$t0,chegouString
		lb	$t3,($t1)
		beq	$t3,'\0',fimString
		addi	$t1,$t1,1
		j	Loop
		fimString:
			addi	$t2,$t2,1
			addi	$t1,$t1,1
			j	Loop
		chegouString:
			move	$v0,$t1
			jr	$ra
