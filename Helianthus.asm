;Movimientos----
DATO  	EQU 0X20		;Me sirve como variable auxiliar
ContadorY 	EQU 0X21		;Lleva la cuenta de la cantidad de movientos en y
ContadorMiniX 	EQU 0X22	;Lleva la cuenta de cantidad de movimientos pequeños en X
LimiteY 	EQU 0X23		;Maxima cantidad de movimientos en y antes de regresar
LimiteminiX	EQU 0X24	;Maxima cantidad de movimientos pequeños en X
Variable	EQU 0X25		;Variable para el delay
ContadorX	EQU 0X26		;Cantidad de veces que me movere en miniX
LimiteX	EQU 0X27		;Cantidad de movimientos máximos en X
;Poder medir y guardar luz----
ADC	EQU	0X28
VALOR	EQU	0X29		;Obtiene el valor de luz actual
VALORMAX	EQU	0X30	;Valor máximo de luz
CounterA	EQU	0X31	;Contador Espera Jeff
CounterB	EQU	0X32	;Contador Espera Jeff
CounterC	EQU	0X33	;Contador Espera Jeff
;------------------------------------
RegresoX	EQU	0X34	;Será el nuevo límite para X
RegresoY 	EQU	0X35	;Será el nuevo límmite para Y
;Comunicacion----
varB	EQU	0x36	;Numero Máximo de otra maquina
varC	EQU	0x37	;Numero mínimo de otra maquina
;Imprimir----
varE	EQU	0x38	;Variable a Mostrar en el display
cont	EQU	0x39 	;Contador para saber que resultado mostrar el Imprimir resultados.

INICIO

	ORG		0X00
	GOTO	START
;--------------------DEFINIR ENTRADAS Y SALIDAS-----------------------
START
	;En los puertos: 1 -> entra | 0 -> sale
	;BIT SET FILE
	BSF 	STATUS, 5	; COLOCAMOS 1 EN EL BIT 5 DE REG. ESTATUS
	CLRF	TRISB		;Todo B es salida
	CLRF	TRISD		;Todo D es salida
	MOVLW	B'00001111'	;Set 1 en los ultimos 4 bits de c
	MOVWF	TRISC
    	bsf	TRISE, 2
    	bsf	TRISE, 1
	bsf	TRISA, 3
	BCF	STATUS, RP0	;TODOS LOS PINES DE B SON SALIDAS
;----------------INICIALIZAR VARIABLES -------------------------------
	MOVLW	0X00
	MOVWF 	PORTB  		;SET 0 a todas las patas del puerto B
	MOVLW	0X00
	MOVWF 	PORTD  		;SET 0 a todas las patas del puerto D
	MOVLW	0X00
	MOVWF 	cont
	MOVLW	0X00
	MOVWF 	VALORMAX
	MOVLW	0X00
	MOVWF 	RegresoX
	MOVLW	0X00
	MOVWF 	RegresoY
	MOVLW	B'00001000'
	MOVWF	varB
	MOVLW	B'00000101'
	MOVWF	varC
	MOVLW	0X00
	MOVWF 	CounterA
	MOVLW	0X00
	MOVWF 	CounterB
	MOVLW	0X00
	MOVWF 	CounterC
	MOVLW 	0xFF		;255	
	MOVWF 	LimiteY 		;LimiteY = 255	12|10 
	MOVLW 	0x20		;32	2|0
	MOVWF 	LimiteminiX		;LimiteminiX = 32	2|0
	MOVLW	0x10		;16	1|0
	MOVWF	LimiteX	;LimiteX = 16	1|0
	CALL 	LIMPIARY		;CONTADORY = 0
	CALL 	LIMPIARMINIX		;CONTADORMINIX = 0
	CALL 	LIMIPIARX	;CONTADORx = 0
;-------------------------PROGRAMAR FOTORESISTENCIA-----------------
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
	movlw b'01000001' ;A/D conversion Fosc/8
	movwf ADCON0
	;     	     7     6     5    4    3    2       1 0
	; 1Fh ADCON0 ADCS1 ADCS0 CHS2 CHS1 CHS0 GO/DONE ? ADON
	bsf STATUS,RP0 ;Ir banco 1
	bcf STATUS,RP1
	movlw b'00000111'
	movwf OPTION_REG ;TMR0 preescaler, 1:156
	;                7    6      5    4    3   2   1   0 
	; 81h OPTION_REG RBPU INTEDG T0CS T0SE PSA PS2 PS1 PS0
	movlw b'00001110' ;A/D Port AN0/RA0
	movwf ADCON1
	;            7    6     5 4 3     2     1     0 
	; 9Fh ADCON1 ADFM ADCS2 ? ? PCFG3 PCFG2 PCFG1 PCFG0
	bsf TRISA,0 ;RA0 linea de entrada para el ADC
	bcf STATUS,RP0 ;Ir banco 0
	bcf STATUS,RP1
;--------------------------- CICLOS -----------------------------------
					
CICLOX

	CALL	CICLOMINIX		;Mover en x, analizar y, regresar en y 
	INCF	ContadorX,1	;ContadorX++
	MOVF	LimiteX, W	;W = LimiteX
	SUBWF	ContadorX, w	;W = LimiteX - ContadorX
	BTFSS	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO	CICLOX		;REPETIR HASTA QUE ContadorX = LimiteX
	CALL	LIMIPIARX	;ContadorX = 0
	CALL 	CICLOXREVERSA
	CALL	LIMIPIARX
	GOTO 	CICLOPOSX

CICLOXREVERSA
	CALL 	CICLOMINIXREVERSA	;REGRESAR TODO EN X PARA NO ENREDAR CABLES
	INCF	ContadorX,1	;ContadorX++
	MOVF	LimiteX, W	;W = LimiteX
	SUBWF	ContadorX, w	;W = LimiteX - ContadorX
	BTFSS	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO	CICLOXREVERSA	;REPETIR HASTA QUE ContadorX = LimiteX
	RETURN

CICLOMINIX
	CALL 	EJEX		;ROTA EN EJE X
	INCF	ContadorMiniX,1	;ContadorMiniX++
	MOVF  	LimiteminiX, w	;W = LimiteminiX
	SUBWF 	ContadorMiniX,w	;W = W - ContadorMiniX
	BTFSS 	STATUS,Z 	;SALTO SI LA RESTA DIO CERO
	GOTO 	CICLOMINIX		;REPETIR SI ContadorMiniX !=  LimiteminiX
	CALL	CICLOY 		;MOVERME EN EJE Y y REGRESAR
	CALL 	LIMPIARMINIX		;ContadorMiniX = 0
	RETURN

CICLOMINIXREVERSA
	CALL 	REVERSEEJEX	;ROTAR EN REVERSA EN EL EJE X
	INCF 	ContadorMiniX,1	;ContadorMiniX++ 
	MOVF  	LimiteminiX, w	;W = LimiteminiX
	SUBWF 	ContadorMiniX,w	;W = LimiteminiX - ContadorMiniX
	BTFSS 	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO 	CICLOMINIXREVERSA	;REPETIR SI ContadorMiniX != LimiteminiX
	CALL 	LIMPIARMINIX		;ContadorMiniX = 0
	RETURN

CICLOY
	CALL 	EJEY		;ROTAR EN EL EJE Y				
;-------------GUARDAR VALOR DE LA FOTORESISTENCIA---------------------------
;AQUI VA EL CODIGO DE JEFF DE BUCLE Y LOS ESPERA.
bucle:
	;btfss INTCON,T0IF
	;goto _bucle ;Esperar que el timer0 desborde
	; SE DEBE DE COLOCAR UN DELAY PARA QUE ESPERE LA CONVERSION
	BSF  STATUS,Z
	CALL _PRESPERA
	bcf INTCON,T0IF ;Limpiar el indicador de desborde
	bsf ADCON0,GO ;Comenzar conversion A/D
_espera:
	btfsc ADCON0,GO ;ADCON0 es 0? (la conversion esta completa?)
	goto _espera ;No, ir _espera
	movf ADRESH,W ;Si, W=ADRESH
	; 1Eh ADRESH A/D Result Register High Byte
	; 9Eh ADRESL A/D Result Register Low Byte 
	movwf ADC ;ADC=W
	movfw ADC ;W = ADC
    	goto  Escala9
_PRESPERA:
	MOVLW 0X55
	MOVWF CounterA
	MOVWF COUNTERb
	MOVWF COUNTERc	
	CALL ESPE
	RETURN	
	
ESPE:
	DECFSZ	CounterA,0X01
	GOTO	ESPE
	CALL	ESPE2
	RETURN
ESPE2:
	DECFSZ	COUNTERb,0X01
	GOTO	ESPE2
	CALL	ESPE3
	RETURN
ESPE3:
	DECFSZ	COUNTERc,0X01
	GOTO	ESPE3
	RETURN
	;----OBTENER EL VALOR SEGÚN LA ESCALA----
Escala9:
    movlw D'210'	;La escala 9: 195-210
    subwf ADC, W
    btfss STATUS, C
    goto Escala8
    movlw B'00001001'
    movwf Valor
    call Nueve
    goto Comparar

Escala8:
    movlw D'194'	;La escala 8: 175-194
    subwf ADC, W
    btfss STATUS, C
    goto Escala7
    movlw B'00001000'
    movwf Valor
    call Ocho
    goto Comparar

Escala7:		;La escala 7: 159-174
    movlw D'174'
    subwf ADC, W
    btfss STATUS, C
    goto Escala6
    movlw B'00000111'
    movwf Valor
    call Siete
    goto Comparar

Escala6:		;La escala 6: 139-158
    movlw D'158'
    subwf ADC, W
    btfss STATUS, C
    goto Escala5
    movlw B'00000110'
    movwf Valor
    call Seis
    goto Comparar

Escala5:		;La escala 5: 118-138
    movlw D'138'
    subwf ADC, W
    btfss STATUS, C
    goto Escala4
    movlw B'00000101'
    movwf Valor
    call Cinco
    goto Comparar

Escala4:		;La escala 4: 83-117
    movlw D'117'
    subwf ADC, W
    btfss STATUS, C
    goto Escala3
    movlw B'00000100'
    movwf Valor
    call Cuatro
    goto Comparar

Escala3:		;La escala 3: 52-82
    movlw D'82'
    subwf ADC, W
    btfss STATUS, C
    goto Escala2
    movlw B'00000011'
    movwf Valor
    call Tres
    goto Comparar

Escala2:		;La escala 2: 29-51
    movlw D'51'
    subwf ADC, W
    btfss STATUS, C
    goto Escala1
    movlw B'00000010'
    movwf Valor
    call Dos
    goto Comparar

Escala1:		;La escala 1: 1-28
    movlw D'28'
    subwf ADC, W
    btfss STATUS, C
    goto Escala0
    movlw B'00000001'
    movwf Valor
    call Uno
    goto Comparar

Escala0:		;La escala 0: 0
    movlw B'00000000'
    movwf Valor
    call Cero
    goto Comparar
Intercambiar:
	MOVFW	Valor
	MOVWF	ValorMax
	MOVFW	ContadorY
	MOVWF	RegresoY
	MOVFW	ContadorX
	MOVWF	RegresoX
	Return
Comparar:
	MOVFW	ValorMax	;w = valorMAX
	SUBWF	Valor, W	;W = Valor - ValorMax
	BTFSC	STATUS, C
	CALL	Intercambiar

		
;------------------------------------------------------------------------
	INCF	ContadorY,1	;ContadorY++ 
	MOVF  	LimiteY, w	;W = LimiteY
	SUBWF 	ContadorY,w	;W = W - ContadorY
	BTFSS 	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO 	CICLOY		;REPETIR SI COUNT !=  LimiteY
	CALL 	LIMPIARY		;ContadorY = 0
	CALL 	CICLOYREVERSA	;REGRESAR Y
	return
CICLOYREVERSA
	CALL 	REVERSEEJEY	;ROTAR EN REVERSA EN EL EJE Y
	INCF	ContadorY,1	;ContadorY++	 
	MOVF  	LimiteY, w	;W = LimiteY
	SUBWF 	ContadorY,w	;W = LimiteY - ContadorY
	BTFSS 	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO 	CICLOYREVERSA	;REPETIR SI ContadorY != LimiteY
	CALL 	LIMPIARY		;ContadorY = 0
	RETURN
;---------------------------------- REGRESAR A LA POSICIÓN ---------------------------------
CICLOPOSX

	CALL	CICLOMINIPOSX		;Mover en x, analizar y, regresar en y 
	INCF	ContadorX,1	;ContadorX++
	MOVF	RegresoX, W	;W = RegresoX
	SUBWF	ContadorX, w	;W = LimiteX - ContadorX
	BTFSS	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO	CICLOPOSX		;REPETIR HASTA QUE ContadorX = RegresoX
	CALL	LIMIPIARX	;ContadorX = 0
	GOTO 	CICLOPOSY

CICLOPOSY
	CALL 	EJEY		;ROTAR EN EL EJE Y			
	INCF	ContadorY,1	;ContadorY++ 
	MOVF  	RegresoY, w	;W = LimiteY
	SUBWF 	ContadorY,w	;W = W - ContadorY
	BTFSS 	STATUS,Z	;SALTO SI LA RESTA DIO 0
	GOTO 	CICLOPOSY		;REPETIR SI COUNT !=  CICLOPOSY
	CALL 	LIMPIARY		;ContadorY = 0
	GOTO	MENUIMPR

CICLOMINIPOSX
	CALL 	EJEX		;ROTA EN EJE X
	INCF	ContadorMiniX,1	;ContadorMiniX++
	MOVF  	LimiteminiX, w	;W = LimiteminiX
	SUBWF 	ContadorMiniX,w	;W = W - ContadorMiniX
	BTFSS 	STATUS,Z 	;SALTO SI LA RESTA DIO CERO
	GOTO 	CICLOMINIPOSX		;REPETIR SI ContadorMiniX !=  LimiteminiX
	CALL 	LIMPIARMINIX		;ContadorMiniX = 0
	RETURN

;------------------------------RETRASO-------------------------------
RETRASO 			; = 0.0001 segundos
	MOVLW	0xA5	;165
	MOVWF	Variable	;pl = 165
ESPERA
	DECFSZ	Variable, f	;Decrementar f, saltar si es 0
	GOTO	ESPERA
	RETURN
;-----------LIMPIAR CONTADORES-----------------------------------------------
LIMPIARY
	MOVLW 	0x00  
	MOVWF 	ContadorY  
	RETURN
LIMPIARMINIX
	MOVLW 	0x00  ;se asigna la literal a w (0x00)
	MOVWF 	ContadorMiniX ;muevo w a COUNT 
	RETURN
LIMIPIARX
	MOVLW 	0x00 
	MOVWF 	ContadorX 
	RETURN
;----------------ROTAR EN LOS EJES -----------------------------------------
EJEX
	CALL	MV07
	CALL	MV03
	CALL	MV11
	CALL	MV09
	CALL	MV13
	CALL	MV12
	CALL	MV14
	CALL	MV06
	RETURN
EJEY	
	CALL	MVY7
	CALL	MVY3
	CALL	MVY11
	CALL	MVY9
	CALL	MVY13
	CALL	MVY12
	CALL	MVY14
	CALL	MVY6
	RETURN
REVERSEEJEY
	CALL	MVY6
	CALL	MVY14
	CALL	MVY12
	CALL	MVY13
	CALL	MVY9
	CALL	MVY11	
	CALL	MVY3
	CALL	MVY7
	RETURN
REVERSEEJEX
	CALL  	MV06
	CALL	MV14
	CALL	MV12
	CALL	MV13
	CALL	MV09
	CALL	MV11
	CALL	MV03
	CALL	MV07
	RETURN
;----------------------------MOVIEMIENTOS----------------------------------
MV	
	CALL 	RETRASO		;Retraso de 0.0001 segundos
	MOVF	DATO, W		;W = DATO
	MOVWF	PORTB		;MOVER W AL PUERTO B
	RETURN
MV03
	MOVLW	B'00110000'
	MOVWF	DATO		;DATO = 0|3
	CALL	MV		;MUEVE DATO AL PUERTO B
	RETURN
MV06
	MOVLW	B'01100000'
	MOVWF	DATO		;DATO = 0|6
	CALL	MV		;MUEVE DATO AL PUERTO D
	RETURN
MV07
	MOVLW	B'01110000'
	MOVWF	DATO		;DATO = 0|7
	CALL	MV		;MUEVE DATO AL PUERTO D
	RETURN
MV09
	MOVLW	B'10010000'	;DATO = 0|9
	MOVWF	DATO		;MUEVE DATO AL PUERTO D
	CALL	MV
	RETURN
MV11
	MOVLW 	B'10110000'
	MOVWF	DATO
	CALL	MV
	RETURN	
MV12
	MOVLW	B'11000000'
	MOVWF	DATO		;DATO = 0|12
	CALL	MV		;MUEVE DATO AL PUERTO D
	RETURN
MV13	MOVLW	B'11010000' 
	MOVWF	DATO 
	CALL	MV 
	RETURN

MV14	MOVLW	B'11100000' 
	MOVWF	DATO 
	CALL	MV 
	RETURN

MVY3
	MOVLW	B'00000011'
	MOVWF	DATO		;DATO = 3|0
	CALL	MV		;MUEVE AL PUERTO D
	RETURN
MVY6
	MOVLW	B'00000110'
	MOVWF	DATO		;DATO = 6|0
	CALL	MV		;MUEVE AL PUERTO D
	RETURN
MVY7
	MOVLW	B'00000111'
	MOVWF	DATO		;DATO = 7|0
	CALL	MV		;MUEVE AL PUERTO D
	RETURN
MVY9
	MOVLW	B'00001001'
	MOVWF	DATO		;DATO = 9|0
	CALL	MV		;MUEVE AL PUERTO D
	RETURN
MVY11	
	MOVLW 	B'00001011'
	MOVWF	DATO
	CALL	MV
	RETURN
MVY12
	MOVLW	B'00001100'
	MOVWF	DATO		;DATO = 12|0
	CALL	MV		;MUEVE AL PUERTO D
	RETURN	

MVY13	MOVLW	B'00001101' 
	MOVWF	DATO 
	CALL	MV 
	RETURN

MVY14	MOVLW	B'00001110' 
	MOVWF	DATO 
	CALL	MV 
	RETURN
;----------------------------------MOSTRAR RESULTADOS EN DISPLAY---------------------------------
MENUIMPR: 
	CALL	MENU
	CALL	RETRASO 
	GOTO	MENUIMPR
	
MENU ;Verificar si presiono el boton, anadir uno al contador.
	BTFSC	PORTA,3	
	CALL	Incrementar
	;Segun el valor de contador, asignar el valor de varE e imprimir
	GOTO	SwitchCont
Incrementar ;CONT++, SI ES MAYOR A 3 SE RESETEA. =========================	
	INCF	cont,1
	BTFSC	cont,2
	CALL	ResetCont
	RETURN
ResetCont
	MOVLW	B'00000000'
	MOVWF	cont
	RETURN
SwitchCont	;Switch con el contador. casos 0,1,2,3 ========================
	BTFSC	cont,0
	GOTO	CI	;Caso Impar
	GOTO	CP	;Caso Par
CP:
	BTFSC	cont,1
	GOTO	case2	;10
	GOTO	case0	;00
CI:
	BTFSC	cont,1
	GOTO	case3	;11
	GOTO	case1	;01
case0:
	MOVFW	ValorMax
	MOVWF	varE
	GOTO	Imprimir
case1:
	MOVFW	varB
	MOVWF	varE
	GOTO	Imprimir
case2:
	MOVFW	varC
	MOVWF	varE
	GOTO	Imprimir
case3:
	MOVLW	B'00000010'
	MOVWF	varE
	GOTO	Imprimir

Imprimir;MUESTRA EN UN DISPLAY EL VALOR DE varE =========================
	;primer bit de entrada de varE
	BTFSC	varE,0
	GOTO	IMPAR;1,3,5,7,9
	GOTO	PAR ;0,2,4,6,8
PAR ;0,2,4,6,8
	;Segundo bit de entrada de varE
	BTFSC	varE,1
	GOTO	PAR4 ;2,6
	GOTO	PAR2 ;0,4,8
	
PAR2 ;0,4,8
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	CUATRO
	GOTO	PAR3 ;0,8
	
PAR3 ;0,8
	;cuarto bit de entrada de C
	BTFSC	varE,3
	GOTO	OCHO
	GOTO	CERO
PAR4 ;2,6
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	SEIS
	GOTO	DOS
IMPAR ;1,3,5,7,9
	;Segundo bit de entrada de C
	BTFSC	varE,1
	GOTO	IMPAR4 ;3,7
	GOTO	IMPAR2 ;1,5,9
IMPAR2 ;1,5,9
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	CINCO
	GOTO	IMPAR3 ;1,9
IMPAR3 ;1,9
	;cuarto bit de entrada de C
	BTFSC	varE,3
	GOTO	NUEVE
	GOTO	UNO
IMPAR4 ;3,7
	;tercer bit de entrada de C
	BTFSC	varE,2
	GOTO	SIETE
	GOTO	TRES	
CERO
	MOVLW	B'00111111'
	MOVWF	PORTD
	RETURN
UNO
	MOVLW	B'00000110'
	MOVWF	PORTD
	RETURN 
DOS
	MOVLW	B'01011011'
	MOVWF	PORTD
	RETURN
TRES
	MOVLW	B'01001111'
	MOVWF	PORTD
	RETURN 

CUATRO
	MOVLW	B'01100110'
	MOVWF	PORTD
	RETURN 
CINCO
	MOVLW	B'01101101'
	MOVWF	PORTD
	RETURN 
SEIS
	MOVLW	B'01111101'
	MOVWF	PORTD
	RETURN 
SIETE
	MOVLW	B'00000111'
	MOVWF	PORTD
	RETURN 

OCHO	
	MOVLW	B'01111111'
	MOVWF	PORTD
	RETURN 
NUEVE
	MOVLW	B'01100111'
	MOVWF	PORTD
	RETURN