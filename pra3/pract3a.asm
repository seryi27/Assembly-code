;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3a
; Sergio Cordero Rojas & Elias Hernandis Prieto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; CONSTANTES
LONGITUDPAIS 			= 3
LONGITUDEMPRESA 	= 4
LONGITUDPRODUCTO 	= 5
LONGITUDBARCODE   = 12


DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA p�blico

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS p�blico

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definici�n del segmento de c�digo
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP


PUBLIC _computeControlDigit
_computeControlDigit PROC FAR
	PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							;; Igualar BP el contenido de SP
	PUSH ES	; LO GUARDAMOS PORQUE LES CARGA EL SEGMENTO EN ES
	PUSH BX DI CX DX ; LOS GUARDAMOS PORQUE OPERAMOS CON ELLOS


	LES BX, [BP + 6] ; Carga en ES:BX la dirección larga del puntero recibido
									 ; como primer parámetro de entrada

	; SUMAR LOS VALORES DE LOS DÍGITOS IMPARES

	; PRIMERO PASAMOS A BINARIO LOS DIGITOS RECIBIDOS
	MOV DI, 0 ; ÍNDICE DEL DIGITO QUE ESTAMOS PROCESANDO
	MOV CX, 0 ; INICIALIZAR EL RESULTADO A 0
	MOV AX, 0 ; PONER AX A 0 PORQUE SOLO VAMOS A CARGAR UN BYTE A AL
	LOOP1:
		MOV AL, ES:[BX][DI] ; ACUMULAR EL resultado
		SUB AX, 30H ; RESTAR '0' PARA OBTENER EL VALOR NUMÉRICO DE UN CARACTER ASCII

		; SI EL ÚLTIMO BIT DE DI ES 1, EL ELEMENTO ES IMPAR
		TEST DI, 00000001B
		JZ COMUN ; SALTAMOS CUANDO ES PAR, YA QUE NUESTROS CARACTERES ESTÁN INDEXADOS EMPEZANDO EN 0

		IMPAR: ; SI EL NUMERO ES PAR, MULTIPLICAMOS POR 3
		MOV DL, 3
		MUL DL ; MULTIPLICAR AX POR 3

		COMUN: ; CASO COMUN PARA ELEMENTOS EN POSICIONES PARES O IMPARES
		ADD CX, AX ; ACUMULAR EL RESULTADO EN CX
		INC DI
		CMP DI, LONGITUDBARCODE ; TODO PASAR A CONSTANTE
		JNZ LOOP1

	PASO2:
		; AGRUPAMOS LOS PASOS C Y D DESCRITOS EN EL ENUNCIADO DE LA SIGUIENTE FORMA
		; - DIVIDIMOS AX (EL VALOR B DEL ENUNCIADO) ENTRE 10
		; - SI EL RESTO ES 0:
		;   	DEVOLVEMOS 0
		; - SI EL RESTO NO ES 0:
		; 		DEVOLVEMOS 10 - EL RESTO

		MOV AX, CX ; MOVER EL RESULTADO ACUMULADO A AX PARA REALIZAR LA DIVISIÓN

		MOV BL, 10
		DIV BL ; AH = RESTO DE DIVIDIR AX ENTRE BL
		CMP AH, 0
		JZ DEVOLVER0

		MOV BX, 10
		SUB BL, AH ; RESTAR EL RESTO (AH) DE 10 (BX)
		MOV AX, BX ; PREPARAR EL RETORNO
		JMP RETORNAR

	DEVOLVER0:
		MOV AX, 0

	RETORNAR:
		; POPS
		POP DX CX DI BX ES BP
		RET
_computeControlDigit ENDP							;; Termina la funcion factorial




PUBLIC _decodeBarCode
_decodeBarCode PROC FAR
	PUSH BP
	MOV BP, SP
	PUSH AX BX DX DI SI ES DS

	LES BX, [BP + 6] ; Carga en ES:BX la dirección larga del puntero recibido
									 ; como primer parámetro de entrada

; ------  LEER EL CODIGO DE PAIS (primeros 3 dígitos) ---------
	MOV SI, LONGITUDPAIS ; QUEREMOS LEER 3 DÍGITOS
	CALL ATOI ; OBTENEMOS EN DX:AX EL CÓDIGO DE PAIS

	; CARGAR LA DIRECCIÓN DONDE DEBEMOS GUARDAR EL CÓDIGO DE PAÍS
	LDS DI, [BP + 10] ; CARGAR LA DIRECCIÓN DEL CÓDIGO DE PAÍS

	; COPIAR EL CÓDIGO DE PAIS A LA DIRECCIÓN DADA (INT)
	MOV DS:[DI], AX
	; NO COPIAMOS DX PORQUE SE TRATA DE UN ENTERO EN C Y ADEMÁS DX SERÁ
	; 0 YA QUE EL CÓDIGO DE PAÍS ES MENOR QUE 1000

; ------- LEER EL CÓDIGO DE EMPRESA (SIGUIENTES 4 DÍGITOS) ---------

	; NOS MOVEMOS AL CÓDIGO DE EMPRESA (SIGUIENTES 4 DÍGITOS)
	ADD BX, LONGITUDPAIS

	MOV SI, LONGITUDEMPRESA ; QUEREMOS LEER 4 DÍGITOS

	CALL ATOI

	; CARGAR LA DIRECCIÓN DONDE DEBEMOS GUARDAR EL CÓDIGO DE EMPRESA
	LDS DI, [BP + 14] ; CARGAR LA DIRECCIÓN DEL CÓDIGO DE EMPRESA

	; COPIAR EL CÓDIGO DE EMPRESA A LA DIRECCIÓN DADA (INT)
	MOV DS:[DI], AX
	; NO COPIAMOS DX PORQUE SE TRATA DE UN ENTERO EN C Y ADEMÁS DX SERÁ
	; 0 YA QUE EL CÓDIGO DE PAÍS ES MENOR QUE 1000

; ------- LEER EL CÓDIGO DE PRODUCTO (SIGUIENTES 5 DÍGITOS) ---------
	; NOS MOVEMOS AL CÓDIGO DE PRODUCTO (SIGUIENTES 4 DÍGITOS)
	ADD BX, LONGITUDEMPRESA

	MOV SI, LONGITUDPRODUCTO ; QUEREMOS LEER 5 DÍGITOS

	CALL ATOI

	; CARGAR LA DIRECCIÓN DONDE DEBEMOS GUARDAR EL CÓDIGO DE PRODUCTO
	LDS DI, [BP + 18] ; CARGAR LA DIRECCIÓN DEL CÓDIGO DE PRODUCTO

	; COPIAR EL CÓDIGO DE PRODUCTO A LA DIRECCIÓN DADA (LONG INT)
	MOV DS:[DI+0], AX
	MOV DS:[DI+2], DX

; ------- LEER EL DÍGITO DE CONTROL ---------
	ADD BX, LONGITUDPRODUCTO
	MOV AL, ES:[BX] ; LEER EL DÍGITO DE CONTROL, NO HACE FALTA CONVERTIRLO
	SUB AL, '0'

	; CARGAR LA DIRECCIÓN DONDE DEBEMOS GUARDAR EL DÍGITO DE CONTROL
	LDS DI, [BP + 22] ; CARGAR LA DIRECCIÓN DEL DÍGITO DE CONTROL

	MOV DS:[DI], AL ; GUARDAR EL DÍGITO DE CONTROL

	POP DS ES SI DI DX BX AX
	POP BP
	RET

_decodeBarCode ENDP


; CONVIERTE "SI" CARACTERES DECIMALES EMPEZANDO EN ES:BX A UN ENTERO
; BINARIO DE 16 BITS QUE DEVUELVE EN DX:AX
;
; SOPORTA NÚMEROS DECIMALES SIN SIGNO DE HASTA 5 DÍGITOS (0-99999)
ATOI PROC NEAR
	PUSH DI CX BP

	MOV DI, 0 ; INDICE DE ACCESO A LA TABLA DE CARACTERES
	MOV BP, 10 ; MULTIPLICAMOS POR 10 CADA VEZ
	DEC SI ; REDUCIMOS EN UNO EL LÍMITE PARA NO MULTIPLICAR POR 10 LAS UNIDADES

	MOV DX, 0 ; ACUMULADOR DX:AX PARA LA CONVERSIÓN A ENTERO
	MOV AX, 0
	PROCESARDIGITO:
		MOV CX, 0 ; REGISTRO PARA TRAER DE MEMORIA LOS CARACTERES Y EXTENDERLOS A 2 BYTES
		MOV CL, ES:BX[DI] ; OBTENEMOS EL CARACTER DEL DI-ESIMO DIGITO
		SUB CX, '0'				; PASAR DE CARACTER ASCII A VALOR NUMÉRICO DE UN DIGITO
		ADD AX, CX				; SUMARLO AL ACUMULADOR
		MUL BP						; MULTIPLICAR POR 10
		INC DI						; INCREMENTAR EL ÍNDICE DEL ARRAY DE CARACTERES

		CMP DI, SI				; SI HEMOS PROCESADO TODO MENOS LAS UNIDADES SALIMOS DEL BUBLE
		JNZ PROCESARDIGITO

	; PROCESAR LAS UNIDADES, QUE SOLO REQUIEREN SUMAR
	MOV CX, 0
	MOV CL, ES:BX[DI] ; CARGAR LAS UNIDADES
	SUB CX, '0'				; PASAR DE CARACTER ASCII A VALOR NUMÉRICO DE UN DÍGITO
	ADD AX, CX				; SUMAR LAS UNIDADES
	ADC DX, 0					; MANTENER EL ACCAREO PARA NÚMEROS QUE NO CABEN EN UN BYTE

	; RECUPERAR LOS REGISTROS
	INC SI ; VOLVER A INCREMENTAR SI PARA DEJARLO IGUAL
	POP BP CX DI
	RET

	; TODO: COMO PODEMOS DEJAR SI PARA QUE NO TENGAMOS QUE VOLVER A HACER UN LEA
	; AL PROCESAR EL SIGUIENTE CAMPO DEL CÓDIGO DE BARRAS
ATOI ENDP
_TEXT ENDS
END
