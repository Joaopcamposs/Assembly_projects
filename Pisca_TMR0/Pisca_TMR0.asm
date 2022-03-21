; PIC16F628A Configuration Bit Settings
; Assembly source line config statements
#include "p16f628a.inc"
; CONFIG
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

 #define    BANCO0  BCF STATUS,RP0
 #define    BANCO1  BSF	STATUS,RP1
 
 CBLOCK 0x020
    FLAGS
    AUX_TMR0
    W_TEMP
    S_TEMP
 ENDC
 
 #define PISCANDO   FLAGS,0
 #define FIM_500MS  FLAGS,1
 #define LED	    PORTA,0
 #define LIGA	    PORTA,1
 #define DESLIGA    PORTA,2
 
V_TMR0	    equ	    .131
V_AUX_TMR0  equ	    .125
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO INICIO
INT_VECT  CODE	  0x0004	    ; processor interrupt vector
    MOVWF   W_TEMP
    MOVF    STATUS,W
    MOVWF   S_TEMP
    BTFSS   INTCON,T0IF
    GOTO    SAI_INTERRUPCAO
    BCF	    INTCON,T0IF
    MOVLW   V_TMR0		    ;PEGA O VALOR DE 131
    ADDWF   TMR0,F		    ;ADICIONA AO TIMER 0
    DECFSZ  AUX_TMR0,F		    
    GOTO    SAI_INTERRUPCAO
    MOVLW   V_AUX_TMR0		    ;PEGA O VALOR DE 125
    MOVWF   AUX_TMR0		    ;CARREGA EM AUX_TMR0
    BSF	    FIM_500MS
SAI_INTERRUPCAO
    MOVF    S_TEMP,W
    MOVWF   STATUS
    MOVF    W_TEMP,W
    RETFIE			    ;RETORNA PARA ONDE TAVA NO PROGRAMA
  
MAIN_PROG CODE                      ; let linker place main program
INICIO
    BANCO1
    BCF	    TRISA,0		    ;TORNA SAIDA
    MOVLW   B'11010100'
    MOVWF   OPTION_REG
    BANCO0
    MOVLW   .7			    ;DESLIGA COMPARADORES DE TENSAO
    MOVWF   CMCON
    BCF	    LED
    BCF	    PISCANDO
    BCF	    FIM_500MS
    MOVLW   V_AUX_TMR0
    MOVWF   AUX_TMR0
    MOVLW   V_TMR0
    MOVWF   TMR0
    BSF	    INTCON,T0IE
    BSF	    INTCON,GIE
    
LE_DESLIGA
    BTFSS   DESLIGA			;TESTA SE DESLIGA = 1 (DESLIGADO)
    GOTO    DESLIGA_ACIONADO
    BTFSC   PISCANDO			;TESTA SE PISCANDO = 0 (DESLIGADO)
    GOTO    PISCANDO_ATIVO
    BTFSS   LIGA			;TESTE SE LIGA = 1 (DESLIGADO)
    GOTO    LIGA_ATIVO
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
DESLIGA_ACIONADO
    BCF	    LED
    BCF	    PISCANDO
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
LIGA_ATIVO
    BSF	    LED
    BCF	    FIM_500MS
    MOVLW   V_AUX_TMR0
    MOVWF   AUX_TMR0
    MOVLW   V_TMR0
    MOVWF   TMR0
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
PISCANDO_ATIVO
    BTFSS   FIM_500MS			;TESTA SE FIM_500MS = 1 (NAO ZERADO)
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
    BCF	    FIM_500MS
    BTFSS   LED				;TESTA SE LED = 1 (LIGADO)
    GOTO    ACENDE_LED
    BCF	    LED
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
ACENDE_LED
    BSF	    LED
    GOTO    LE_DESLIGA			;VOLTA AO INICIO
    
    END