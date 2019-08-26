; R-TYPE

; GRUPO 76
; 86372 - Alexandre Galambas
; 86430 - Guilherme Galambas



; CONSTANTES
CURSOR				EQU		FFFCh
WRITE				EQU		FFFEh
LCD_CURSOR			EQU		FFF4h
LCD_WRITE			EQU		FFF5h
LED					EQU		FFF8h
MASK_LED			EQU		1111111111111111b
MASK_ADDR			EQU		FFFAh
MASK_MENU			EQU		0110000000000000b
MASK_GAME			EQU		1001000000011111b
MASK_PAUSE			EQU		0001000000000000b
MASK_FINAL			EQU		0100000000000000b
TIMER_VAL			EQU		FFF6h
TIMER_CTRL			EQU		FFF7h
SPEED				EQU		1
END_CONST			EQU		'^'

					ORIG	8000h
; VARIAVEIS
; Inicio
CheckStart			TAB		1
CheckRestart		TAB		1
Level				TAB		1
; Nave
NavePos				WORD	0402h
DelNave				TAB		1
CheckDown			WORD	1
CheckUp				WORD	1
CheckLeft			WORD	1
CheckRight			WORD	1
CheckLaser			WORD	1
CheckPause			WORD	1
; Laser
LaserTimer			WORD	1
LaserPos			TAB		6
; Obstaculos
ObstTimer			TAB		1
ObstRndPos			WORD	0200h
AstrdPos			TAB		23			; normal - 11, hard - 22
BHolePos			TAB		9			; nomral - 4, hard - 8
AstrdCnt			WORD	6			; normal - 6, hard - 3
BHoleCnt			WORD	24			; normal - 24, hard - 12
; Placa
Score				TAB		5
LEDTimer			WORD	0
DecConv				TAB		17

; CARACTERES
; Ecra Inicial
LOGO_1				STR		'                        ____       _______', END_CONST
LOGO_2				STR		'                       / __ \     /__  __/_  _ ____  ___', END_CONST
LOGO_3				STR		'                      / /_/ / ____  / / / / / / __ \/ _ \', END_CONST
LOGO_4				STR		'                     / ,  _/ /___/ / / / /_/ / /_/ /  __/', END_CONST
LOGO_5				STR		'                    /_/|_|        /_/  \__, / ,___/\___/', END_CONST
LOGO_6				STR		'                                       __/ / /', END_CONST
LOGO_7				STR		'                                      \___/_/', END_CONST
START_1				STR		'                                 PREPARA-TE!!', END_CONST
START_2				STR		'                             Modo Facil (Prime IE)', END_CONST
START_3				STR		'                            Modo Dificil (Prime ID)', END_CONST
; Ecra Final
GO_1				STR		'                ______                       ____', END_CONST
GO_2				STR		'               / ____/___  ____ ___  ___    / __ \_   __ __  _ ___', END_CONST
GO_3				STR		'              / / __/ __ \/ __  __ \/ _ \  / / / / | / / _ \/ ,__/', END_CONST
GO_4				STR		'             / /_/ / /_/ / / / / / /  __/ / /_/ /| |/ /  __/ /', END_CONST
GO_5				STR		'             \____/\__,_/_/ /_/ /_/\___/  \____/ |___/\___/_/', END_CONST
FINAL_1				STR		'                                 FIM DO JOGO', END_CONST
FINAL_2				STR		'                               PONTUACAO:', END_CONST
FINAL_3				STR		'                    (Prime IE para voltar ao Menu Inicial)', END_CONST
; Jogo
LCD_POS				STR		'POSICAO: (  ,  )', END_CONST
LCD_PAUSE			STR		'PRIME IC > PAUSE', END_CONST
DEL					EQU		' '
LIM					EQU		'#'
L_WING				EQU		'\'
CANNON				EQU		'>'
BODY				EQU		')'
R_WING				EQU		'/'
LASER				EQU		'-'
ASTRD				EQU		'*'
B_HOLE				EQU		'O'

; TABELA DE INTERRUPCOES

					ORIG	FE00h

I0					WORD	Down
I1					WORD	Up
I2					WORD	Left
I3					WORD	Right
I4					WORD	Shot

					ORIG	FE0Ch

IC					WORD	Pause
ID					WORD	Hard
IE					WORD	Start
I15					WORD	Timer

;============================================
;		INICIO DO PROGRAMA
;============================================

					ORIG	0000h
					ENI
					JMP		Main

;============================================
;		ROTINAS DE INTERRUPCOES
;============================================

; MOVER PARA BAIXO
Down:				MOV		M[CheckDown], R0
					RTI
					
; MOVER PARA CIMA
Up:					MOV		M[CheckUp], R0
					RTI
					
; MOVER PARA A ESQUERDA
Left:				MOV		M[CheckLeft], R0
					RTI
					
; MOVER PARA A DIREITA
Right:				MOV		M[CheckRight], R0
					RTI
					
; CRIAR TIRO
Shot:				MOV		M[CheckLaser], R0
					RTI

; COMECAR JOGO
Start:				MOV		M[CheckStart], R0
					MOV		M[CheckRestart], R0
					MOV		M[Level], R0
					RTI
					
; COMECAR JOGO - HARD
Hard:				PUSH	R1
					MOV		M[CheckStart], R0
					MOV		R1, 1
					MOV		M[Level], R1
					POP		R1
					RTI
					
; TEMPORIZADOR
Timer:				DEC		M[ObstTimer]
					DEC		M[LaserTimer]
					DEC		M[LEDTimer]
					RTI

; PAUSA
Pause:				PUSH	R1
					CMP		M[CheckPause], R0
					BR.Z	RetMask
					MOV		R1, MASK_PAUSE
					MOV		M[CheckPause], R0
					BR		RetPause
RetMask:			MOV		R1, 1
					MOV		M[CheckPause], R1
					MOV		R1, MASK_GAME
RetPause:			MOV		M[MASK_ADDR], R1
					POP		R1
					RTI

;============================================
;		ROTINAS DO PROGRAMA
;============================================

; StartScreen: Desenha o Menu Inicial do Jogo
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve o logotipo do jogo e as mensagens iniciais

StartScreen:		PUSH	R1
					PUSH	R2
					
					MOV		R1, 0300h									; Escreve R-TYPE linha a linha
					MOV		R2, LOGO_1
					CALL	ScreenAux
					MOV		R2, LOGO_2
					CALL	ScreenAux
					MOV		R2, LOGO_3
					CALL	ScreenAux
					MOV		R2, LOGO_4
					CALL	ScreenAux
					MOV		R2, LOGO_5
					CALL	ScreenAux
					MOV		R2, LOGO_6
					CALL	ScreenAux
					MOV		R2, LOGO_7
					CALL	ScreenAux
					
					ADD		R1, 0200h									; Escreve as mensagens iniciais
					MOV		R2, START_1
					CALL	ScreenAux
					ADD		R1, 0100h
					MOV		R2, START_2
					CALL	ScreenAux
					MOV		R2, START_3
					CALL	ScreenAux
					
					POP		R2
					POP		R1
					RET
					
; FinalScreen: Desenha o Menu Final do Jogo
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve GAME OVER e as mensagens finais

FinalScreen:		PUSH	R1
					PUSH	R2
					PUSH	R3
					
					MOV		R1, 0300h									; Escreve GAME OVER linha a linha
					MOV		R2, GO_1
					CALL	ScreenAux
					MOV		R2, GO_2
					CALL	ScreenAux
					MOV		R2, GO_3
					CALL	ScreenAux
					MOV		R2, GO_4
					CALL	ScreenAux
					MOV		R2, GO_5
					CALL	ScreenAux
					
					ADD		R1, 0400h									; Escreve as mensagens finais
					MOV		R2, FINAL_1
					CALL	ScreenAux
					ADD		R1, 0100h
					MOV		R2, FINAL_2
					CALL	ScreenAux
					ADD		R1, 0200h
					MOV		R2, FINAL_3
					CALL	ScreenAux
					
					MOV		R1, Score									; Obtem a pontuacao final
					MOV		R2, 0E2Dh
FinalScore:			MOV		M[CURSOR], R2
					MOV		R3, M[R1]
					ADD		R3, 0030h									; Transforma em codigo ASCII
					MOV		M[WRITE], R3
					DEC		R2
					INC		R1
					MOV		R3, END_CONST
					CMP		M[R1], R3									; Verifica se a tabela Score chegou ao fim
					BR.NZ	FinalScore
					
					POP		R3
					POP		R2
					POP		R1
					RET
					
; ScreenAux: Rotina Auxiliar para escrever as Strings dos Menus
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Ciclo que escreve os caracteres de uma string um a um

ScreenAux:			MOV		M[CURSOR], R1
					MOV		R3, M[R2]
					MOV		M[WRITE], R3
					INC		R1
					INC		R2
					MOV		R3, END_CONST
					CMP		M[R2], R3									; Verifica se a string chegou ao fim
					BR.NZ	ScreenAux
					MVBL	R1, R0
					ADD		R1, 0100h									; Faz a mudança de linha
					
					RET
					
; ClrScreen: Limpa o Ecra
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve um espaco em todas as posicoes do ecra

ClrScreen:			PUSH	R1
					PUSH	R2
					PUSH	R3
					
					MOV		R2, DEL
					MOV		R1, R0
ClrScreenAux:		MOV		M[CURSOR], R1
					MOV		M[WRITE], R2
					INC		R1
					MOV		R3, R0
					MVBL	R3, R1
					CMP		R3, 004Fh									; Verifica a chegada ao fim de cada linha
					BR.NZ	ClrScreenAux
					MVBL	R1, R0
					ADD		R1, 0100h									; Faz a mudanca de linha
					CMP		R1, 1800h									; Verifica a chegada ao fim da ultima linha
					BR.NZ	ClrScreenAux
					
					POP		R3
					POP		R2
					POP		R1
					RET
					
; DrwLim: Faz os Limites do Jogo
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve 80 vezes o caracter « # » na primeira e ultima linhas do ecra

DrwLim:				PUSH	R1
					PUSH	R2
					
					MOV		R1, R0										; Posicao inicial do limite superior
					MOV		R2, R0
					
DrwLimAux:			MOV		M[CURSOR], R1
					MOV		R2, LIM
					MOV		M[WRITE], R2
					INC		R1
					MVBL	R2, R1
					CMP		R2, 004Fh									; Verifica se o limite foi totalmente escrito
					BR.NZ	DrwLimAux
					
					MVBH	R2, R1
					MOV		R1, 1700h									; Posicao inicial do limite inferior
					CMP		R2, 174Fh									; Verifica se o segundo limite foi totalmente escrito
					BR.NZ	DrwLimAux
					
					POP		R2
					POP		R1
					RET
					
; ClrNave: Apaga a Nave
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve um espaco na posicao das diferentes partes da nave no ecra

ClrNave:			PUSH	R1
					PUSH	R2
					MOV		R1, M[DelNave]
; Asa esquerda
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
; Canhao
					ADD		R1, 0101h									; Posicao do Canhao em relacao a Asa Esquerda
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
; Corpo
					DEC		R1											; Posicao do Corpo em relacao ao Canhao
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
; Asa direita
					ADD		R1, 0100h									; Posicao da Asa Direita em relacao ao Corpo
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
					
					POP		R2
					POP		R1
					RET
					
; DrwNave: Desenha a Nave
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve os caracteres correspondentes as diferentes partes da nave no ecra

DrwNave:			PUSH	R1
					PUSH	R2
					PUSH	R3
					
					MOV		R1, M[NavePos]
					MOV		M[DelNave], R1								; Guarda a posicao anterior da nave
; Asa esquerda
					MOV		M[CURSOR], R1
					MOV		R2, L_WING
					MOV		M[WRITE], R2
; Canhao
					ADD		R1, 0101h									; Posicao do Canhao em relacao a Asa Esquerda
					MOV		M[CURSOR], R1
					MOV		R2, CANNON
					MOV		M[WRITE], R2
					MOV		R3, R1
; Corpo
					DEC		R1											; Posicao do Corpo em relacao ao Canhao
					MOV		M[CURSOR], R1
					MOV		R2, BODY
					MOV		M[WRITE], R2
; Asa direita
					ADD		R1, 0100h									; Posicao da Asa Direita em relacao ao Corpo
					MOV		M[CURSOR], R1
					MOV		R2, R_WING
					MOV		M[WRITE], R2
; Escreve no LCD
					ADD		R3, 0001h									; Regulariza a primeira coluna do ecra como 1 ao inves de 0
					MOV		R1, 00FFh
					AND 	R1, R3
					PUSH	R1											; Mete na pilha a coluna correspondente ao canhao da nave
					CALL	Converter
					POP		R1
					
					MOV		R2, 800Ah
					MOV		M[LCD_CURSOR], R2
					MOV		R2, 10
					DIV		R1, R2										; Separa o numero de dois digitos em dois de um digito
					ADD		R1, 48
					MOV		M[LCD_WRITE], R1
					MOV		R1, 800Bh
					MOV		M[LCD_CURSOR], R1
					ADD		R2, 48
					MOV		M[LCD_WRITE], R2
					
					MOV		R1, FF00h
					AND 	R1, R3
					SHR		R1, 8
					PUSH	R1											; Mete na pilha a linha correspondente ao canhao da nave
					CALL	Converter
					POP		R1
					
					MOV		R2, 800Dh
					MOV		M[LCD_CURSOR], R2
					MOV		R2, 10
					DIV		R1, R2										; Separa o numero de dois digitos em dois de um digito
					ADD		R1, 48
					MOV		M[LCD_WRITE], R1
					MOV		R1, 800Eh
					MOV		M[LCD_CURSOR], R1
					ADD		R2, 48
					MOV		M[LCD_WRITE], R2
					
					POP		R3
					POP		R2
					POP		R1
					RET
					
; Converter: Converte um Numero Hexadecimal num Decimal
; 					Entradas:	SP+5 --> Numero Hexadecimal
; 					Saidas:		SP+5 --> Numero Decimal
; 					Efeitos:	Converte usando o metodo da multiplicacao por 2^n, sendo n o indice dos bits a 1

Converter:			PUSH	R1
					PUSH	R2
					PUSH	R3
					
					MOV		R4, DecConv
					MOV		R2, R0
					MOV		R3, 0001h
					
Convert:			MOV		R1, R3
					AND		R1, M[SP+5]
					CMP		R1, R0										; Verifica se o bit e zero ou um
					BR.Z	NextBit
					ADD		R2, M[R4]
					
NextBit:			INC		R4
					SHL		R3, 1
					MOV		R1, END_CONST
					CMP		M[R4], R1									; Verifica se viu todos os bits
					BR.NZ	Convert
					MOV		M[SP+5], R2									; Valor convertido
					
					POP		R3
					POP		R2
					POP		R1
					RET
					
; TurnOff: Desliga os LED
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Muda a memoria de LED para 0

TurnOff:			MOV		M[LED], R0
					RET
					
; MoveDown: Move a Nave para Baixo
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Apaga a nave na posicao atual e desenha-a numa posicao abaixo

MoveDown:			MOV		R1, R0
					MVBH	R1, M[NavePos]
					CMP		R1, 1400h									; Verifica a colisao com o limite inferior
					JMP.Z	StopDown
					
					MOV		R1, 0100h
					ADD		M[NavePos], R1
					CALL	ClrNave
					CALL	DrwNave
StopDown:			MOV		R1, 1
					MOV		M[CheckDown], R1							; Retoma o ciclo principal

					RET
					
; MoveUp: Move a Nave para Cima
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Apaga a nave na posicao atual e desenha-a numa posicao acima

MoveUp:				MOV		R1, R0
					MVBH	R1, M[NavePos]
					CMP		R1, 0100h									; Verifica a colisao com o limite superior
					JMP.Z	StopUp
					
					MOV		R1, 0100h
					SUB		M[NavePos], R1
					CALL	ClrNave
					CALL	DrwNave
StopUp:				MOV		R1, 1
					MOV		M[CheckUp], R1								; Retoma o ciclo principal

					RET
					
; MoveLeft: Move a Nave para a Esquerda
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Apaga a nave na posicao atual e desenha-a numa posicao a esquerda

MoveLeft:			MOV		R1, R0
					MVBL	R1, M[NavePos]
					CMP		R1, 0000h									; Verifica a colisao com o limite a esquerda
					JMP.Z	StopLeft
					
					DEC		M[NavePos]
					CALL	ClrNave
					CALL	DrwNave
StopLeft:			MOV		R1, 1
					MOV		M[CheckLeft], R1							; Retoma o ciclo principal

					RET
					
; MoveRight: Move a Nave para a Direita
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Apaga a nave na posicao atual e desenha-a numa posicao a direita

MoveRight:			MOV		R1, R0
					MVBL	R1, M[NavePos]
					CMP		R1, 004Dh									; Verifica a colisao com o limite a direita
					JMP.Z	StopRight
					
					INC		M[NavePos]
					CALL	ClrNave
					CALL	DrwNave
StopRight:			MOV		R1, 1
					MOV		M[CheckRight], R1							; Retoma o ciclo principal

					RET
					
; DrwAmmo: Cria o Tiro
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Escreve o caracter « - » numa posicao a direita do canhao

DrwAmmo:			PUSH	R1
					PUSH	R2
					MOV		R1, LaserPos
					
NextAmmo:			CMP		M[R1], R0									; Verifica se o laser se encontra no ecra
					BR.Z	Shoot
					INC		R1
					MOV		R2, END_CONST
					CMP		M[R1], R2									; Verifica se ainda existem tiros por criar
					BR.NZ	NextAmmo
					BR		NoAmmo
					
Shoot:				MOV		R2, M[NavePos]								; Cria um novo laser
					ADD		R2, 0102h
					MOV		M[R1], R2
					MOV		M[CURSOR], R2
					MOV		R2, LASER
					MOV		M[WRITE], R2
					
NoAmmo:				MOV		R1, 1
					MOV		M[CheckLaser], R1							; Retoma o ciclo principal
					
					POP		R2
					POP		R1
					RET

; MoveLaser: Move os Tiros
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Apaga os tiros nas posicoes atuais e escreve-os uma posicao a direira
;								Confirma colisao com os obstaculos e com a nave

MoveLaser:			PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					PUSH	R5
					
					MOV		R3, LaserPos

NextLaser:			CMP		M[R3], R0
					JMP.Z	NoLaser
; APAGAR O LASER
					MOV		R1, M[R3]
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
; VERIFICAR COLISAO COM A NAVE
					MOV		R2, M[NavePos]
					CMP		R2, R1
					BR.Z	LaserGameOver								; Verificar colisao com a asa esquerda
					ADD		R2, 0101h
					CMP		R2, R1
					BR.Z	LaserGameOver								; Verificar colisao com o canhao
					DEC		R2
					CMP		R2, R1
					BR.Z	LaserGameOver								; Verificar colisao com o corpo da nave
					ADD		R2, 0100h
					CMP		R2, R1
					BR.Z	LaserGameOver								; Verificar colisao com a asa direita
					BR		ObstTest
LaserGameOver:		JMP		GameOver
; VERIFICAR COLISAO COM OS OBSTACULOS
ObstTest:			MOV		R5, 2										; Contador para mudar o obstaculo em teste
					MOV		R2, AstrdPos								; Testa colisao com asteroide
					BR		ColTest
ChangeObst:			MOV		R2, BHolePos								; Testa colisao com buraco negro
ColTest:			MOV		R4, M[R2]
					DEC		R4
					CMP		R1, R4
					BR.Z	DelObst										; Verifica colisao
					INC		R2
					MOV		R4, END_CONST
					CMP		M[R2], R4
					BR.NZ	ColTest										; Verifica se testou todos os obstaculos
					DEC		R5
					CMP		R5, R0
					BR.NZ	ChangeObst									; Altera o obstaculo em teste
; VERIFICAR ULTIMA POSICAO DO ECRA
					MOV		R2, R0
					MVBL	R2, R1
					CMP		R2, 004Eh
					BR.NZ	DrwLaser
					MOV		M[R3], R0
					BR		NoLaser
; APAGAR LASER
DelObst:			MOV		M[R3], R0
					CMP		R5, 1										; Verifica o obstaculo com que colidiu
					BR.Z	NoLaser
					MOV		R1, M[R2]
					MOV		M[CURSOR], R1
					MOV		R1, DEL
					MOV		M[WRITE], R1								; Apaga Asteroide
					MOV		M[R2], R0
					CALL	ScoreBoard
					BR		NoLaser
; MOVER LASER
DrwLaser:			INC		R1
					MOV		M[CURSOR], R1
					MOV		R2, LASER
					MOV		M[WRITE], R2
					MOV		M[R3], R1
NoLaser:			INC		R3
					MOV		R2, END_CONST
					CMP		M[R3], R2									; Verifica se todos os Lasers se moveram
					JMP.NZ	NextLaser
; RETOMAR
					MOV		R1, SPEED
					MOV		M[TIMER_VAL], R1
					MOV		R1, 1
					MOV		M[TIMER_CTRL], R1							; Retoma a contagem
					MOV		M[LaserTimer], R1							; Retoma o ciclo principal
					
					POP		R5
					POP		R4
					POP		R3
					POP		R2
					POP		R1
					RET
					
; RandomGen: Gera um Numero Aleatorio
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Dependendo do bit menos significativo, gera um novo numero

RandomGen:			PUSH	R1
					PUSH	R2
					PUSH	R3
					
					MOV		R1, M[ObstRndPos]
					MOV		R2, R1
					MOV		R3, 22
					AND		R2, 0001h
					CMP		R2, R0
					BR.Z	RetRandomGen
					
					XOR		R1, 1000000000010110b
					
RetRandomGen:		ROR		R1, 1
					DIV		R1, R3
					INC		R3
					SHL		R3, 8
					ADD		R3, 004Eh
					MOV		M[ObstRndPos], R3
					
					POP		R3
					POP		R2
					POP		R1
					RET
					
; MoveObst: Move os Obstaculos
; 					Entradas:	SP+5 --> Caracter a escrever
;								SP+6 --> Numero que define de que obstaculo se trata
; 					Saidas:		----
; 					Efeitos:	Apaga os obstaculos nas posicoes atuais e escreve-os uma posicao a esquerda
;								Confirma colisao com os tiros e com a nave

MoveObst:			PUSH	R1
					PUSH	R2
					PUSH	R4
					
NextObst:			CMP		M[R3], R0									; Verifica se o obstaculo se encontra no ecra
					JMP.Z	NoObst
; APAGAR OBSTACULO
					MOV		R1, M[R3]
					MOV		M[CURSOR], R1
					MOV		R2, DEL
					MOV		M[WRITE], R2
; VERIFICAR COLISAO COM A NAVE
					MOV		R2, M[NavePos]
					CMP		R2, R1										; Verifica colisao com a asa esquerda
					BR.Z	ObstGameOver
					ADD		R2, 0101h
					CMP		R2, R1										; Verifica colisao com o canhao
					BR.Z	ObstGameOver
					DEC		R2
					CMP		R2, R1										; Verifica colisao com o corpo da nave
					BR.Z	ObstGameOver
					ADD		R2, 0100h
					CMP		R2, R1										; Verifica colisao com a asa direita
					BR.Z	ObstGameOver
					BR		LaserTest
ObstGameOver:		CMP		M[SP+6], R0									; Verifica o obstaculo com que colide
					BR.Z	BHoleGameOver
					CALL	ScoreBoard
BHoleGameOver:		JMP		GameOver
; VERIFICAR COLISAO COM OS TIROS
LaserTest:			MOV		R2, LaserPos
ColTest2:			MOV		R4, M[R2]
					INC		R4
					CMP		R1, R4										; Compara a posicao do obstaculo com a do laser
					BR.Z	DelLaser
					INC		R2
					MOV		R4, END_CONST
					CMP		M[R2], R4
					BR.NZ	ColTest2
; VERIFICAR ULTIMA POSICAO DO ECRA
					MOV		R2, R0
					MVBL	R2, R1
					CMP		R2, R0
					BR.NZ	DrwObst
					MOV		M[R3], R0
					BR		NoObst
; APAGAR LASER
DelLaser:			MOV		R1, M[R2]
					MOV		M[CURSOR], R1
					MOV		R4, DEL
					MOV		M[WRITE], R4
					MOV		M[R2], R0
					CMP		M[SP+6], R0									; Verifica com que obstaculo colidiu
					BR.Z	DrwObst
					MOV		M[R3], R0									; Apaga Asteroide
					CALL	ScoreBoard
					BR		NoObst
; MOVER OBSTACULO
DrwObst:			DEC		R1
					MOV		M[CURSOR], R1
					MOV		R2, M[SP+5]
					MOV		M[WRITE], R2
					MOV		M[R3], R1
NoObst:				INC		R3
					MOV		R2, END_CONST								; Verifica se todos os obstaculos se moveram
					CMP		M[R3], R2
					JMP.NZ	NextObst
					
					POP		R4
					POP		R2
					POP		R1
					RETN	2

; ObstRoutine: Cria Obstaculos
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Cria os asteroides e buracos negros, em posicoes aleatorias

ObstRoutine:		MOV		R3, AstrdPos
					PUSH	1
					PUSH	ASTRD
					CALL	MoveObst									; Move asteroides
					
					MOV		R3, BHolePos
					PUSH	0
					PUSH	B_HOLE
					CALL	MoveObst									; Move buracos negros

					DEC		M[AstrdCnt]									; Decrementa Contadores
					DEC		M[BHoleCnt]
; CRIAR BURACO NEGRO
					CMP		M[BHoleCnt], R0								; Verifica se o buraco negro vai entrar no ecra
					JMP.NZ	CrtAstrd
					MOV		R1, BHolePos
NextBHole:			CMP		M[R1], R0									; Verifica que buraco negro nao se encontra no ecra
					BR.NZ	NoBHole
					
					CALL	RandomGen
					MOV		R2, M[ObstRndPos]							; Cria buraco negro numa posicao aleatoria
					MOV		M[R1], R2
					MOV		M[CURSOR], R2
					MOV		R2, B_HOLE
					MOV		M[WRITE], R2
					BR		ResCnt
					
NoBHole:			INC		R1
					MOV		R3, END_CONST
					CMP		M[R1], R3									; Garante que todos os buracos negros sejam verificados
					BR.NZ	NextBHole
					
ResCnt:				CMP		M[Level], R0
					BR.NZ	HardBHole
					MOV		R1, 24										; Retoma contadores
					MOV		M[BHoleCnt], R1
					MOV		R1, 6
					MOV		M[AstrdCnt], R1
					JMP		EndObst
HardBHole:			MOV		R1, 12
					MOV		M[BHoleCnt], R1
					MOV		R1, 3
					MOV		M[AstrdCnt], R1
					JMP		EndObst

; CRIAR ASTEROIDE
CrtAstrd:			CMP		M[AstrdCnt], R0								; Verifica se o asteroide vai entrar no ecra
					JMP.NZ	EndObst
					MOV		R1, AstrdPos
NextAstrd:			CMP		M[R1], R0									; Verifica que asteroide nao se encontra no ecra
					BR.NZ	NoAstrd
					
					CALL	RandomGen
					MOV		R2, M[ObstRndPos]							; Cria asteroide numa posicao aleatoria
					MOV		M[R1], R2
					MOV		M[CURSOR], R2
					MOV		R2, ASTRD
					MOV		M[WRITE], R2
					BR		ResAstrdCnt
					
NoAstrd:			INC		R1
					MOV		R3, END_CONST
					CMP		M[R1], R3									; Garante que todos os asteroides sejam verificados
					BR.NZ	NextAstrd
					
ResAstrdCnt:		CMP		M[Level], R0
					BR.NZ	HardAstrd
					MOV		R1, 6										; Retoma contador
					MOV		M[AstrdCnt], R1
					BR		EndObst
HardAstrd:			MOV		R1, 3
					MOV		M[AstrdCnt], R1
					
; RETOMAR
EndObst:			MOV		R1, SPEED
					MOV		M[TIMER_VAL], R1
					MOV		R1, 1
					MOV		M[TIMER_CTRL], R1							; Retoma a contagem
					CMP		M[Level], R0
					BR.NZ	HardTimer
					MOV		R1, 2
					BR		RetTimer
HardTimer:			MOV		R1, 1
RetTimer:			MOV		M[ObstTimer], R1							; Retoma o ciclo principal
					
					JMP		MainLoop

; ScoreBoard: Mostra a Pontuacao na Placa
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Mete o numero de asteroides destruidos nos displays de 7 segmentos

ScoreBoard:			PUSH	R1
					PUSH	R2
					PUSH	R3
					PUSH	R4
					
					MOV		R1, MASK_LED
					MOV		M[LED], R1
					MOV		R1, 1
					MOV		M[LEDTimer], R1
					
					MOV		R1, Score
					MOV		R2, 9
					MOV		R3, FFF0h
					
					CMP		M[R1+3], R2
					JMP.Z	RetScore									; Verifica se a pontuacao maxima foi atingida
					
NextDisplay:		CMP		M[R1], R2									; Verifica se o valor maximo a mostrar em cada display foi atingido
					BR.NZ	UpScore
					MOV		M[R1], R0
					MOV		M[R3], R0
					INC		R1
					INC		R3
					MOV		R4, END_CONST
					CMP		M[R1], R4									; Verifica de a Pontuacao foi toda enviada para os displays
					BR.NZ	NextDisplay
					BR		RetScore
UpScore:			INC		M[R1]
					PUSH	M[R1]
					CALL	Converter
					POP		M[R1]
					MOV		R4, M[R1]
					MOV		M[R3], R4
					
RetScore:			POP		R4
					POP		R3
					POP		R2
					POP		R1
					RET
					
; ResVars: Da Reset as Variaveis
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Retoma os valores iniciais de todas as variaveis e enderecos de memoria

; APAGAR LED					
ResVars:			MOV		M[LED], R0
; LIMPAR LCD
					MOV		R2, DEL
					MOV		R1, 8000h
ClrLCDAux:			MOV		M[LCD_CURSOR], R1
					MOV		M[LCD_WRITE], R2
					INC		R1
					CMP		R1, 8010h
					BR.NZ	ClrLCDAux
; RETORNAR OS DISPLAYS A 0
					MOV		R1, FFF0h
					MOV		M[R1], R0
					INC		R1
					MOV		M[R1], R0
					INC		R1
					MOV		M[R1], R0
					INC		R1
					MOV		M[R1], R0
; RETOMAR TABELAS
					MOV		R2, END_CONST					
					MOV		R1, AstrdPos								; Posicao Astrd
					CALL	ResTAB
					MOV		R1, BHolePos								; Posicao BHole
					CALL	ResTAB
					MOV		R1, LaserPos								; Posicao Laser
					CALL	ResTAB
					MOV		R1, Score									; Score
					CALL	ResTAB
					MOV		R1, 6										; Counter Astrd
					MOV		M[AstrdCnt], R1
					MOV		R1, 24										; Counter BHole
					MOV		M[BHoleCnt], R1
					MOV		R1, 0402h									; Restart Posicao Nave
					MOV		M[NavePos], R1
; REINICIALIZAR TIMPORIZADOR
					MOV		R1, 1
					MOV		M[LaserTimer], R1
					INC		R1
					MOV		M[ObstTimer], R1
					
					JMP		Main
					
; ResTAB: Da Reset as Tabelas
; 					Entradas:	----
; 					Saidas:		----
; 					Efeitos:	Retoma os valores iniciais de todas as posicoes da tabela

ResTAB:				MOV		M[R1], R0
					INC		R1
					CMP		M[R1], R2
					BR.NZ	ResTAB
					RET
					
;============================================
;		PROGRAMA PRINCIPAL
;============================================

Main:				MOV		R1, FDFFh
					MOV		SP, R1										; Inicializa o Stack Pointer
					MOV 	R1, FFFFh
					MOV		M[CURSOR], R1								; Inicializa o cursor
; MENU INICIAL
					CALL	StartScreen
					
					MOV		R1, MASK_MENU
					MOV		M[MASK_ADDR], R1							; Define os botões permitidos no menu inicial
					MOV		R1, 1
					MOV		M[CheckStart], R1
StartLoop:			CMP		M[CheckStart], R0
					BR.NZ	StartLoop
					
					CALL	ClrScreen
; JOGO
					CALL	DrwLim
					
					MOV		R1, LCD_POS
					MOV		R2, 8000h									; Corresponde a primeira posicao da primeira linha do LCD
					MOV		R3, END_CONST
WritePosLCD:		MOV		M[LCD_CURSOR], R2
					MOV		R4, M[R1]
					MOV		M[LCD_WRITE], R4							; Escreve o texto no LCD
					INC		R2
					INC		R1
					CMP		M[R1], R3									; Verifica de se chegou ao fim da string a escrever
					BR.NZ	WritePosLCD
					
					MOV		R1, LCD_PAUSE
					MOV		R2, 8010h									; Corresponde a primeira posicao da segunda linha do LCD
					MOV		R3, END_CONST
WritePauseLCD:		MOV		M[LCD_CURSOR], R2
					MOV		R4, M[R1]
					MOV		M[LCD_WRITE], R4							; Escreve o texto no LCD
					INC		R2
					INC		R1
					CMP		M[R1], R3									; Verifica de se chegou ao fim da string a escrever
					BR.NZ	WritePauseLCD
					
					CALL	DrwNave
					
					MOV		R2, END_CONST								; Define a ultima posicao de cada tabela como « ^ »
					MOV		R1, LaserPos
					MOV		M[R1+5], R2
					MOV		R1, Score
					MOV		M[R1+4], R2
; NIVEL DE DIFICULDADE
					CMP		M[Level], R0
					BR.NZ	HardObst
					MOV		R1, AstrdPos
					MOV		M[R1+11], R2
					MOV		R1, BHolePos
					MOV		M[R1+4], R2
					MOV		R3, 2
					MOV		M[ObstTimer], R3
					BR		GoOn
HardObst:			MOV		R1, AstrdPos
					MOV		M[R1+22], R2
					MOV		R1, BHolePos
					MOV		M[R1+8], R2
					MOV		R3, 3
					MOV		M[AstrdCnt], R3
					MOV		R3, 12
					MOV		M[AstrdCnt], R3
					MOV		R3, 1
					MOV		M[ObstTimer], R3
GoOn:				MOV		R1, DecConv
					MOV		M[R1+16], R2
					
					MOV		R3, 1										; Define todas as posicoes da tabela associada ao conversor
NextConv:			MOV		R4, 2
					MOV		M[R1], R3
					MUL		R4, R3
					INC		R1
					CMP		M[R1], R2
					BR.NZ	NextConv
					
					MOV		R1, MASK_GAME
					MOV		M[MASK_ADDR], R1							; Define as interrupcoes permitidas no jogo
					MOV		R1, SPEED
					MOV		M[TIMER_VAL], R1							; Define o número de unidades de tempo a decrementar
					MOV		R1, 1
					MOV		M[TIMER_CTRL], R1							; Inicia a contagem
; CICLO PRINCIPAL
MainLoop:			CMP		M[LEDTimer], R0
					CALL.Z	TurnOff
					CMP		M[CheckDown], R0
					CALL.Z	MoveDown
					CMP		M[CheckUp], R0
					CALL.Z	MoveUp
					CMP		M[CheckLeft], R0
					CALL.Z	MoveLeft
					CMP		M[CheckRight], R0
					CALL.Z	MoveRight
					CMP		M[CheckLaser], R0
					CALL.Z	DrwAmmo
					CMP		M[LaserTimer], R0
					CALL.Z	MoveLaser
					CMP		M[ObstTimer], R0
					JMP.Z	ObstRoutine
					JMP		MainLoop
; MENU FINAL
GameOver:			MOV		R1, MASK_FINAL
					MOV		M[MASK_ADDR], R1							; Define os botões permitidos no menu final
					CALL	ClrScreen
					CALL	FinalScreen
					MOV		R1, 1
					MOV		M[CheckRestart], R1
FinalLoop:			CMP		M[CheckRestart], R0
					BR.Z	Restart
					BR		FinalLoop
Restart:			JMP		ResVars										; Restaura o valor das variaveis