; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
#include "p16f628a.inc"
; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

 #define BANCO0 BCF STATUS,RP0
 #define BANCO1 BSF STATUS,RP0
 
 CBLOCK 0X20
    FLAGS
    TEMPO1
    TEMPO2
 ENDC
 
 #define    PISCANDO	FLAGS,0
 #define    LAMPADA	PORTA,0
 #define    LIGA	PORTA,1
 #define    DESLIGA	PORTA,2
 
RES_VECT  CODE    0x0000            ; processor reset vector
    BANCO1
    BCF	    TRISA,0
    BANCO0
    MOVLW   .7
    MOVWF   CMCON
    BCF	    LAMPADA
    BCF	    PISCANDO
    
LE_DESLIGA
    BTFSS   DESLIGA
    GOTO    DESLIGA_ACIONADO
    BTFSC   PISCANDO
    GOTO    PISCANDO_ATIVO
    BTFSC   LIGA
    GOTO    LE_DESLIGA
    BSF	    LAMPADA
    BSF	    PISCANDO
    GOTO    LE_DESLIGA
DESLIGA_ACIONADO
    BCF	    LAMPADA
    BCF	    PISCANDO
    GOTO    LE_DESLIGA
PISCANDO_ATIVO
    CALL   DELAY_500MS
    BTFSS   LAMPADA
    GOTO    ACENDE_LAMPADA
    BCF	    LAMPADA
    GOTO    LE_DESLIGA
ACENDE_LAMPADA
    BSF	    LAMPADA
    GOTO    LE_DESLIGA
    
DELAY_500MS
    MOVLW   .250		;1uS
    MOVWF   TEMPO2		;1uS
INICIA_TEMPO1
    MOVLW   .250		;1uS
    MOVWF   TEMPO1		;1uS
;=================================== 2000 uS
DEC_TEMPO1
    NOP				;1uS	    ;GASTANDO TEMPO DE EXECUCAO PARA CHEGAR AO TEMPO EXATO DESEJADO
    NOP				;1uS
    NOP				;1uS
    NOP				;1uS
    NOP				;1uS
    DECFSZ  TEMPO1,F		;1uS
    GOTO    DEC_TEMPO1		;2uS
;===================================
    DECFSZ  TEMPO2,F		;1uS
    GOTO    INICIA_TEMPO1	;2uS
    
    RETURN			;2uS
    
    
    
    
    
    
    END