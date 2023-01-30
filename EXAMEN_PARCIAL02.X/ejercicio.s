;AUTOR: ERICK GREGORIO SUAREZ INGA
    
;NOMBRE: PREGUNTA N2
    
;FECHA: 30 DE ENERO DEL 2023

;VERSI�N DEL PROGRAMA: MPLAB X IDE v6.00
    
;DESCRIPCI�N: EN ESTE PROYECTO LES MOSTRARE UN CORRIMIENTO DE LEDS CON 3 PULSADORES
;(EL DE LA PLACA Y 2 EXTERNOS), LOS PULSADORES ESTAN CONFIGURADOS UNO EN EL RF3(LO REINICIA) Y 
;EL OTRO EN RB4(SE DETIENE).
;RA3: Interrupci�n de baja prioridad (INT0)
;RB4: Interrupci�n de baja prioridad (INT1)
;RF2: Interrupci�n de alta prioridad (INT2)
;ESPERO LES HAYA GUSTADO LA PRESENTACI�N Y QUE LO PUEDAN COMPRENDER-
;--------------------------------------------------------------------------------------------------------------------------
PROCESSOR 18F57Q84
#include "config_bits.inc"   /*config statements should precede project file includes.*/
#include <xc.inc>
    
PSECT resetVect,class=CODE,reloc=2
resetVect:
    goto Main
    
PSECT ISRVectLowPriority,class=CODE,reloc=2
ISRVectLowPriority:
    BTFSS   PIR1,0,0	; �Se ha producido la INT0?
    GOTO    Exit0
Leds_on:
    BCF	    PIR1,0,0	; limpiamos el flag de INT0
    GOTO    Reload	;se dara el inicio del corrimiento de leds
Exit0:
    RETFIE

PSECT ISRVectHighPriority,class=CODE,reloc=2
ISRVectHighPriority:
    BTFSS   PIR10,0,0	; �Se ha producido la INT0?
    GOTO    ISRVectHighPrioritya
Leds:
    BCF	    PIR10,0,0	; limpiamos el flag de INT0 para evitar tener reingresos
    GOTO    exit	;se va al proyecto prinicipal
Exit:
    RETFIE


PSECT udata_acs
contador1:  DS 1	    
contador2:  DS 1
contador3:  DS 1
offset:	    DS 1
offset1:    DS 1
counter:    DS 1
counter1:   DS 1 
    
PSECT CODE    
Main:
    CALL    Config_OSC,1
    CALL    Config_Port,1
    CALL    Config_PPS,1
    CALL    Config_INT0_INT1,1
    GOTO    toggle
    
    
toggle:
   BTFSC   PIR10,0,0	; �Se ha producido la INT0?
   GOTO	   ISRVectHighPriority
   BTG	   LATF,3,0
   CALL    Delay_500ms,1
   BTG	   LATF,3,0
   CALL    Delay_500ms,1
   goto	   toggle

Loop:
    BSF	    LATF,3,0	    ;toggle off
    BANKSEL PCLATU
    MOVLW   low highword(Table)
    MOVWF   PCLATU,1	    ;escribimos el byte superior en PCLATU
    MOVLW   high(Table)
    MOVWF   PCLATH,1	    ;escribimos el byte alto en PCLATH.
    RLNCF   offset,0,0	    ;procedemos a definir el valor para el Offset
    CALL    Table
    MOVWF   LATC,0
    CALL    Delay_250ms,1
    DECFSZ  counter,1,0	    ;se va a decrementar hasta llegar a 0, hara 10 secuencias
    GOTO    Next_Seq
    
 Verifica:
    DECFSZ  counter1,1,0    ;se va a decrementar hasta llegar a 0, hara 5 secuencias
    GOTO    Reload2
    Goto    off
    
 Next_Seq:
    INCF    offset,1,0
    GOTO    Loop
    
Reload:
    MOVLW   0x05	; voy a cargar w con el valor de 5
    MOVWF   counter1,0	; nos muestra la carga del contador con el numero de offsets
    MOVLW   0x00	; cargare el valor de w con el valor de 0
    MOVWF   offset,0	; definiremos el valor del offset inicial
    
Reload2:
    MOVLW   0x0A	; prcedemos a cargar w co el valor de 10
    MOVWF   counter,0	; nos mostrara carga del contador con el numero de offsets
    MOVLW   0x00	; cargare el valor de w con el valor de 0
    MOVWF   offset,0	; definimos el valor del offset inicial
    GOTO    Loop	; se dara inicio la secuencia de 10

off:
    NOP
    
    
Config_OSC:
    ;realizaremos la Configuracion del Oscilador Interno a una frecuencia de 4MHz
    BANKSEL OSCCON1
    MOVLW   0x60    ;selecciono el bloque del osc interno(HFINTOSC) con DIV=1
    MOVWF   OSCCON1,1 
    MOVLW   0x02    ;selecciono una frecuencia de Clock = 4MHz
    MOVWF   OSCFRQ,1
    RETURN
   
Config_Port:	
    ;Config Led
    BANKSEL PORTF
    CLRF    PORTF,1	
    BSF	    LATF,3,1
    BSF	    LATF,2,1
    CLRF    ANSELF,1	
    BCF	    TRISF,3,1
    BCF	    TRISF,2,1
    
    ;Config User Button
    BANKSEL PORTA
    CLRF    PORTA,1	
    CLRF    ANSELA,1	
    BSF	    TRISA,3,1	
    BSF	    WPUA,3,1
    
    ;Config Ext Button
    BANKSEL PORTB
    CLRF    PORTB,1	
    CLRF    ANSELB,1	
    BSF	    TRISB,4,1	
    BSF	    WPUB,4,1
    
    ;Config Ext Button2
    BANKSEL PORTF
    CLRF    PORTF,1	
    CLRF    ANSELF,1	
    BSF	    TRISF,2,1	
    BSF	    WPUB,2,1
    
    ;Config PORTC
    BANKSEL PORTC
    CLRF    PORTC,1	
    CLRF    LATC,1	
    CLRF    ANSELC,1	
    CLRF    TRISC,1
    RETURN
    
Config_PPS:
    ;Config INT0
    BANKSEL INT0PPS
    MOVLW   0x03
    MOVWF   INT0PPS,1	; INT0 --> RA3
    
    ;Config INT1
    BANKSEL INT1PPS
    MOVLW   0x0C
    MOVWF   INT1PPS,1	; INT1 --> RB4
    
    ;Config INT2
    BANKSEL INT2PPS
    MOVLW   0x2A
    MOVWF   INT2PPS,1
    
    RETURN
    
;   Secuencia para configurar interrupcion:
;    1. Definir prioridades
;    2. Configurar interrupcion
;    3. Limpiar el flag
;    4. Habilitar la interrupcion
;    5. Habilitar las interrupciones globales
Config_INT0_INT1:
    ;Configuracion de prioridades
    BSF	INTCON0,5,0 ; INTCON0<IPEN> = 1 -- Habilitamos las prioridades
    BANKSEL IPR1
    BCF	IPR1,0,1    ; IPR1<INT0IP> = 0 --  INT0 de baja prioridad
    BSF	IPR6,0,1    ; IPR6<INT1IP> = 0 --  INT1 de alta prioridad
    BSF	IPR10,0,1   ; IPR1<INT2IP> = 1 -- INT2 de alta prioridad
    
    ;Config INT0
    BCF	INTCON0,0,0 ; INTCON0<INT0EDG> = 0 -- INT0 por flanco de bajada
    BCF	PIR1,0,0    ; PIR1<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE1,0,0    ; PIE1<INT0IE> = 1 -- habilitamos la interrupcion ext0
    
    ;Config INT1
    BCF	INTCON0,1,0 ; INTCON0<INT1EDG> = 0 -- INT1 por flanco de bajada
    BCF	PIR6,0,0    ; PIR6<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE6,0,0    ; PIE6<INT0IE> = 1 -- habilitamos la interrupcion ext1
    
    ;Config INT2
    BCF	INTCON0,2,0 ; INTCON0<INT1EDG> = 0 -- INT1 por flanco de bajada
    BCF	PIR10,0,0    ; PIR6<INT0IF> = 0 -- limpiamos el flag de interrupcion
    BSF	PIE10,0,0    ; PIE6<INT0IE> = 1 -- habilitamos la interrupcion ext1
    
    ;Habilitacion de interrupciones
    BSF	INTCON0,7,0 ; INTCON0<GIE/GIEH> = 1 -- habilitamos las interrupciones de forma global y de alta prioridad
    BSF	INTCON0,6,0 ; INTCON0<GIEL> = 1 -- habilitamos las interrupciones de baja prioridad
    RETURN

Table:
    ADDWF   PCL,1,0
    RETLW   10000001B	; offset: 0
    RETLW   01000010B	; offset: 1
    RETLW   00100100B	; offset: 2
    RETLW   00011000B	; offset: 3
    RETLW   00000000B	; offset: 4 -> se apagan todos
    RETLW   00011000B	; offset: 5
    RETLW   00100100B	; offset: 6
    RETLW   01000010B	; offset: 7
    RETLW   10000001B	; offset: 8
    RETLW   00000000B	; offset: 9
    
    
ISRVectHighPrioritya:
    BTFSS   PIR6,0,0	; �Se ha producido la INT0?
    GOTO    Exit
    GOTO    toggle
    
        
Delay_250ms:		    ; 2Tcy -- Call
    MOVLW   250		    ; 1Tcy -- k2
    MOVWF   contador2,0	    ; 1Tcy
; T = (6 + 4k)us	    1Tcy = 1us
Ext_Loop:		    
    MOVLW   249		    ; 1Tcy -- k1
    MOVWF   contador1,0	    ; 1Tcy
Int_Loop:
    NOP			    ; k1*Tcy
    DECFSZ  contador1,1,0   ; (k1-1)+ 3Tcy
    GOTO    Int_Loop	    ; (k1-1)*2Tcy
    DECFSZ  contador2,1,0
    GOTO    Ext_Loop
    RETURN		    ; 2Tcy
;500ms
Delay_500ms:
    MOVLW 2
    MOVWF contador3,0
    Loop_250ms:				    ;2tcy
    MOVLW 250				    ;1tcy
    MOVWF contador2,0			    ;1tcy
    Loop_1ms8:			     
    MOVLW   249				    ;k Tcy
    MOVWF   contador1,0			    ;k tcy
    INT_LOOP8:			    
    Nop					    ;249k TCY
    DECFSZ  contador1,1,0		     ;251k TCY 
    Goto    INT_LOOP8			;496k TCY
    DECFSZ  contador2,1,0		    ;(k-1)+3tcy
    GOTO    Loop_1ms8			    ;(k-1)*2tcy
    DECFSZ  contador3,1,0
    GOTO Loop_250ms
    RETURN  
    
exit:     
End resetVect


