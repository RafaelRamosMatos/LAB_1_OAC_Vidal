######################################################################################
# Autor: Rafael Rmos de Matos:150145683 
#################################################################################
.data
ficheiro:                  .space 64   # arquivo compactado
fileout:		   .asciiz "descompactardo.txt" # arquivo descompactado
mensagem_inicial:          .asciiz "COMPACTAR (C) OU DESCOMPACTAR (D):\n"
nome_arquivo:		   .asciiz "\nDIGITE O NOME DO ARQUIVO E APERTE ENTER\n"
arquivo_erro:		   .asciiz "\nARQUIVO NAO ENCONTRADO"
mensagem_erro:             .asciiz "\nENTRADA INCORRETA DIGITE NOVAMENTE:\n"
comando_execucao:          .asciiz " "
fpilha:		           .asciiz ""  #string: celula do arquivo compactado 
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
   	 la $a0, ficheiro 
   	 li $a1, 64
    	 syscall
    loop_fim_nome:
		lb $t1, ficheiro($t0)
    	 	beq $t1 , '\n', pula_2
    	 	addi $t0, $t0, 1
    	 	j  loop_fim_nome
    	 	
    	 	pula_2:
    	 		li $t1, '\0'
    	 		sb $t1, ficheiro($t0)
    	 		li $t0, 0
    	 		li $t1, 0
   	 
########################################################################################
		#System call para abrir o arquivo de leitura 
		        li $v0,13 
			la $a0,ficheiro
			li $a1,0       
			li $a2,0
			syscall
			move $t6,$v0 
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
rafael:
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
leitura_do_arquivo:
# esta funcao ler de ( ate ) entao e feita a leitura (n,char)
		loopleitura:
			addi $s7, $s7, 1 
			lb $t4, fpilha($s7)
			beq $t4, 0, exit	  
			beq $t4, ')', fim_celula # checa se chegou no fim da celula 
			j loopleitura			
			fim_celula: # fim da celula 
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
tomas:
exit: # fim, fechando os dois aruivos:  entrada e saida 
			li $v0,16 #System call para fechar ficheiro     
			move $a0,$t6 
			syscall
			li $v0,16 #System call para fechar ficheiro     
			move $a0,$t7 
			syscall

