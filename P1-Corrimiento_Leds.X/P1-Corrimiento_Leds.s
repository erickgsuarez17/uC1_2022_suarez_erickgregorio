;AUTOR: ERICK GREGORIO SUAREZ INGA
;NOMBRE: P1-Corrimiento_Leds
;FECHA: 14 DE ENERO DEL 2023
;DESCRIPCIÓN:  programa que permita realizar un corrimiento de leds conectados al puerto C, con un retardo de 500 ms en un numero de
;corrimientos pares y un retardo de 250ms en un numero de corrimientos impares. El corrimiento inicia cuando se presiona el pulsador de la placa
;una vez y se detiene cuando se vuelve a presionar. 
    
PROCESSOR 18F57Q84
    
#include "config_bits.inc" /*config statements should precede project file includes.*/
#include "led_inc.inc"
#include <xc.inc>

PSECT resetVect,class=CODE, reloc=2
resetVect:
    goto Main
PSECT CODE
Main:
    CALL    Config_OSC
    CALL    Config_Port
    NOP


verifica:
    BANKSEL PORTA
    BTFSC   PORTA,3,1					; està en 0? button press? si-> salta instruccion / no -> siguiente intruccion
    GOTO    verifica					; instruccion siguiente
    Led_Stop2:   
	CALL    Delay_250ms				; Salta si es 0
	BTFSS   PORTA,3,1				; està en 1? button no press? no -> salta instruccion / si -> siguiente intruccion
	GOTO    verifica				; salta si es 1
	
    
    Corrimiento_general:
    ;impar -> retardo de 250ms
    Corrimiento_impar:
	BANKSEL PORTE
	BSF	PORTE,0,1
	BANKSEL PORTC
	CLRF	PORTC,1
	BSF	PORTC,0,1
	CALL	Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				   ;mover un bit a la izquierda
	CALL Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				   ;mover un bit a la izquierda
 	CALL Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_250ms,1  
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_250ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_250ms,1
	BCF	PORTE,0,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
    ;corrimiento par tiene un retardo de 500ms
    Corrimiento_par:
	BANKSEL PORTE
	BSF	PORTE,1,1
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	RLNCF   PORTC,1,1				    ;mover un bit a la izquierda
	CALL Delay_500ms,1
	BCF PORTE,1,1
	BTFSS PORTA,3,1
	CALL	Led_Stop
	GOTO Corrimiento_impar
   
Led_Stop:   
    CALL    Delay_1s				; Salta si es 0
    BTFSC   PORTA,3,1				; està en 1? button no press? no -> salta instruccion / si -> siguiente intruccion
    GOTO    verifica2				; salta si es 1
verifica2:
    BANKSEL PORTA
    BTFSC   PORTA,3,1				; està en 0? button press? si-> salta instruccion / no -> siguiente intruccion
    GOTO    verifica2				; instruccion siguiente	 
    RETURN    
	
Config_OSC:
    ;configuración del Oscilador interno a una frecuencia de 4Mhz
    BANKSEL OSCCON1
    MOVLW 0x60	;seleccionamos el bloque del oscilador interno con un div:1
    MOVWF OSCCON1
    MOVLW 0X02	;seleccionamos a una frecuencia de 4Mhz
    MOVWF OSCFRQ
    RETURN
 
Config_Port:	;PORT-LAT-ANSEL-TRIS LED:RF3,  BUTTON:RA3
    ;Config Button
    BANKSEL PORTA
    CLRF    PORTA,1	;PORTA<7,0> = 0
    CLRF    ANSELA,1	;PORTA DIGITAL
    BSF	    TRISA,3,1	;RA3 COMO ENTRADA
    BSF	    WPUA,3,1	;ACTIVAMOS LA RESISTENCIA PULLUP DEL PIN RA3
    ;Config Port E
    BANKSEL PORTE
    CLRF    PORTE,1	;PORTE<7,0> = 0
    CLRF    ANSELE,1	;PORTE DIGITAL
    BCF	    TRISE,0,1	;PORTE<0> COMO SALIDA
    BCF	    TRISE,1,1	;PORTE<1> COMO SALIDA
    ;Config Port C
    BANKSEL PORTC
    CLRF    PORTC,1	;PORTC<7,0>=0
    CLRF    ANSELC,1	;PORTC DIGITAL
    CLRF    TRISC,1	;PORTC COMO SALIDA
    RETURN

END resetVect





