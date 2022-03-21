; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
#include "p16f628a.inc"
; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

 #define BANCO0	BCF STATUS,RP0
 #define BANCO1	BSF STATUS,RP0 
 
 CBLOCK 0X20
    FLAGS	;0X20
    TEMPO1	;0X21
    TEMPO2	;0X22    
    TEMPO3
 ENDC
 
 #define    PISCADOR	FLAGS,0
 #define    PISCAPISCA	FLAGS,1
 #define    LAMPADA	PORTA,0
 #define    BOTAO1	PORTA,1 
 #define    BOTAO2	PORTA,2
 
V_TEMPO    equ	    .250
V_TEMPO3   equ	    .4
 
RES_VECT  CODE    0x0000            
    BANCO1
    BCF	    TRISA,0
    BANCO0
    MOVLW   .7
    MOVWF   CMCON
    BCF	    LAMPADA
    BCF	    PISCADOR
    
LE_BOTAO
    BTFSS   BOTAO1
    GOTO    BOTAO_ACIONADO1
    BTFSS   BOTAO2
    GOTO    BOTAO_ACIONADO2
    BTFSC   PISCADOR
    GOTO    VERIFICA
    GOTO    LE_BOTAO
    
DESLIGA
    BCF	    LAMPADA
    BCF	    PISCADOR
    GOTO    LE_BOTAO

BOTAO_ACIONADO1
    BTFSC   PISCADOR
    GOTO    DESLIGA
    BSF	    LAMPADA
    BSF	    PISCADOR
    BSF	    PISCAPISCA
    GOTO    LE_BOTAO
    
BOTAO_ACIONADO2
    BTFSC   PISCADOR
    GOTO    DESLIGA
    BSF	    LAMPADA
    BSF	    PISCADOR
    BCF	    PISCAPISCA
    GOTO    LE_BOTAO

VERIFICA
    BTFSC   PISCAPISCA
    GOTO    PISCANDO_2HZ
    GOTO    PISCANDO_0.5HZ

PISCANDO_2HZ
    CALL    DELAY_500MS
    BTFSS   LAMPADA
    GOTO    ACENDE_LAMPADA
    BCF	    LAMPADA
    GOTO    LE_BOTAO
    
PISCANDO_0.5HZ
    MOVLW   V_TEMPO3
    MOVWF   TEMPO3
    CALL    DELAY2
    BTFSS   LAMPADA
    GOTO    ACENDE_LAMPADA
    BCF	    LAMPADA
    GOTO    LE_BOTAO
    
ACENDE_LAMPADA
    BSF	    LAMPADA
    GOTO    LE_BOTAO
    
DELAY_500MS
    MOVLW   V_TEMPO	    
    MOVWF   TEMPO2	   
INICIA_TEMPO1    
    MOVLW   .250	    
    MOVWF   TEMPO1	    
  
DEC_TEMPO1
    NOP			       
    NOP			    
    NOP			      
    NOP			    
    NOP			    
    DECFSZ  TEMPO1,F	    
    GOTO    DEC_TEMPO1	    
    DECFSZ  TEMPO2,F	    
    GOTO    INICIA_TEMPO1     
    RETURN		    
    
DELAY2
    MOVLW   .250	    
    MOVWF   TEMPO2
    
INICIA_TEMPO1_2    
    MOVLW   .250	    
    MOVWF   TEMPO1	    
   
DEC_TEMPO1_2
    NOP			      
    NOP			    
    NOP			       
    NOP			    
    NOP			    
    DECFSZ  TEMPO1,F	    
    GOTO    DEC_TEMPO1_2	    
    DECFSZ  TEMPO2,F	    
    GOTO    INICIA_TEMPO1_2   
    DECFSZ  TEMPO3,F	    
    GOTO    DELAY2   
    RETURN		    
    
    END