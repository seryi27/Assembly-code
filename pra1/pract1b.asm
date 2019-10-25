;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; Sergio Cordero Rojas y Elias Hernandis Prieto
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
;-- rellenar con los datos solicitados
CONTADOR 	DB 	?
TOME		DW 	0CAFEH
TABLA100	DB 	100 DUP(?)
ERROR1 		DB 	"Atención: Entrada de datos incorrecta."
DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
MOV AX, DATOS
MOV DS, AX
MOV AX, PILA
MOV SS, AX
MOV AX, EXTRA
MOV ES, AX
MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES
; COMIENZO DEL PROGRAMA

; Copiar el tercer carácter de la cadena ERROR1 en la posición 63H de TABLA100
MOV AL, ERROR1[2]
MOV TABLA100[63H], AL

; Copiar el contenido de la variable TOME a partir de la posición 23H de TABLA100
MOV AX, TOME
MOV WORD PTR TABLA100[23H], AX

; Copiar el byte más significativo de TOME a la variable CONTADOR
; Como ya tenemos en AX el valor de TOME no es necesario volver a copiarlo
MOV CONTADOR, AH

; FIN DEL PROGRAMA
MOV AX, 4C00H
INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO