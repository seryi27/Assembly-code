;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3b
; Sergio Cordero Rojas & Elias Hernandis Prieto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; CONSTANTES

OFFSETPILABUFFER = 16
LONGITUDPAIS = 3
LONGITUDEMPRESA = 4
LONGITUDPRODUCTO = 5
LONGITUDCONTROL = 1

DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA p�blico

_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS p�blico

_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definici�n del segmento de c�digo
ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP


PUBLIC _createBarCode					;; Hacer visible y accesible la funci�n desde C
_createBarCode PROC FAR 					;; En C es int unsigned long int factorial(unsigned int n)

PUSH BP 							;; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
MOV BP, SP							;; Igualar BP el contenido de SP
PUSH ES	; LO GUARDAMOS PORQUE LES CARGA EL SEGMENTO EN ES
PUSH BX DI CX DX ; LOS GUARDAMOS PORQUE OPERAMOS CON ELLOS


LES BX, [BP + OFFSETPILABUFFER] ; Carga en ES:BX la dirección larga del puntero recibido
                 ; como último parámetro de entrada (el buffer para escribir el código de barras)


; -----------------------

; CARGAMOS EN DX:AX EL CÓDIGO DE PAIS
MOV DX, 0
MOV AX, [BP + 6] ; CARGAR EL PRIMER ARGUMENTO
MOV SI, LONGITUDPAIS
CALL ITOA

; INCREMENTAR BX PARA LA ESCRITURA DEL SIGUIENTE CAMPO
ADD BX, LONGITUDPAIS

;--------------------------

; CARGAMOS EN DX:AX EL CÓDIGO DE EMPRESA
MOV DX, 0
MOV AX, [BP + 8] ; CARGAR EL SEGUNDO ARGUMENTO
MOV SI, LONGITUDEMPRESA
CALL ITOA

; INCREMENTAR BX PARA LA ESCRITURA DEL SIGUIENTE CAMPO
ADD BX, LONGITUDEMPRESA

;--------------------------

; CARGAMOS EN DX:AX EL CÓDIGO DE PRODUCTO
MOV AX, [BP + 10] ; CARGAR EL TERCER ARGUMENTO, QUE ES DE DOS PALABRAS DE LONGITUD
MOV DX, [BP + 12]
MOV SI, LONGITUDPRODUCTO
CALL ITOA

; INCREMENTAR BX PARA LA ESCRITURA DEL SIGUIENTE CAMPO
ADD BX, LONGITUDPRODUCTO

; --------------------------

; CARGAMOS EL DIGITO DE CONTROL
MOV DX, 0
MOV AH, 0
MOV AL, [BP + 14]
MOV SI, LONGITUDCONTROL
CALL ITOA

ADD BX, LONGITUDCONTROL

; ----------------------------

; ESCRIBIMOS EL CARACTER \0 PARA DELIMITAR LA CADENA

MOV BYTE PTR ES:[BX], 0

POP DX CX DI BX ES BP

RET
_createBarCode ENDP							;; Termina la funcion factorial


; ESCRIBE EL ASCII CORRESPONDIENTE A PASAR EL ENTERO GUARDADO EN DX:AX
; EN LA DIRECCIÓN DE MEMORIA APUNTADA POR ES:BX.
; UTILIZA PARA ELLO <SI> CARACTERES ASCII.
;
; ASUME QUE EL NÚMERO EN DX:AX ES SIN SIGNO
ITOA PROC NEAR
  PUSH SI DX CX AX

  DEC SI ; QUEREMOS EMPEZAR A ESCRIBIR EN LA POSICIÓN N-1 SI N ES EL NÚMERO DE DÍGITOS

  MOV CX, 10 ; DIVIDIMOS POR 10
  PROCESARCARACTER:
    DIV CX ; DX = RESTO, AX = COCIENTE
    ADD DX, '0'
    MOV ES:[BX][SI], DL ; ESCRIBIMOS LA VERSIÓN ASCII DEL RESTO
    DEC SI ; DECREMENTAR LA POSICIÓN DE LA CADENA EN LA QUE ESCRIBIMOS
		MOV DX, 0 ; VOLVER A PONER DX A 0 PARA LA DIVISIÓN LARGA

    JNS PROCESARCARACTER ; SI NO HEMOS ACABADO DE ESCRIBIR LOS N DIGITOS CONTINUAMOS

  POP AX CX DX SI
  RET
ITOA ENDP

_TEXT ENDS
END
