;
; Divisor16bits.asm
;
; Created: 4/14/2022 5:56:58 PM
; Author : dinos
;

.include<m328pdef.inc>
.org 0x000
rjmp START
 
;			 r25	 result
; X-register r27:r26 remainder
; Y-register r28:r29 dividend
; Z-register r30:r31 divisor

START:
// ############### SERIAL CONFIG ####################
USART_Init: ; Inicializa el puerto serial *********************
	ldi r16, 0b00000110	;modo asincrono, paridad deshabil, 8 bits de datos
	sts ucsr0c, r16
	;------- configura baud rate de 9600 cargar a ubrrn
	ldi r17, 0b00000000
	ldi r16, 0b01100111
	sts ubrr0h, r17
	sts ubrr0l, r16
	ldi r16, 0b00011000	;rxen= 1 txen =1 habilita pines rx y tx
	sts ucsr0b, r16

// ############### AVAILABLE REGS ####################
	/*
	r16, r17, r18, r19
	r20, r21, r22, r23, r24
	*/
CICLO:
multi:
	ldi r19, 10 ; mul
	ldi r16, 0b11111111 ; 0b11111111
	ldi r18, 0b00000011 ; 0b00000011
	mul r16, r19
	movw r17:r16, r1:r0  ; 0b00001001 0b11110110
	mul r18, r19
	mov r18, r0
	add r17, r18
	; r17, r16 == 0b00100111 0b11110110
	mov r29, r17
	mov r28, r16
	ldi r30, 0b11111110
	ldi r31, 0b00000111
	call div16b

/*	sub r16, r22
	sbc r17, r23
	ldi r18, 180
	sub r16, r18 ;print D*/
	ldi r17, 48
	mov r16, r25
	add r16, r17
	call UART_TRANSMIT
	ldi r16, '\n'
	call UART_TRANSMIT
	call espera1s
	rjmp CICLO

// ############## TRANSMISION SERIAL ###################
UART_Transmit: ;transmisión de datos en TX
	lds r18, ucsr0a		;carga el valor a la bandera T
	bst r18, 5		;Revisa si el buffer esta vacio
	brtc UART_Transmit ;brinca si T=0 (no esta vacio)
	sts udr0, r16	;envia el dato guardado en r16
	ret

// ############### RETARDO 1 SEGUNDO ###################
espera1s: ;delay duración de 1 segundo aprox.
	ldi r29,100		; 1
repetir2:
	ldi r30,100		; 1
repetir1:
	ldi r31,199		; 1
repetir:
	nop				; 1
	nop				; 1
	nop				; 1
	nop				; 1
	nop				; 1
	dec r31			; 1
	brne repetir	; 2
	dec r30			; 1
	brne repetir1	; 2
	dec r29			; 1
	brne repetir2	; 2
	ret

// ############### DIVISION 16 BITS #####################
div16b:
chkzero:
	ldi r25, 0
	cpi r30, 0
	brne divis
	cpi r31, 0
	breq findiv
divis:
	movw r27:r26, r29:r28
	sub r28, r30
	sbc r29, r31
	brcs findiv
	inc r25
	rjmp divis
findiv:
	ret