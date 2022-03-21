; PIC16F628A Configuration Bit Settings
#include "p16f628a.inc"
; __config 0xFF70
 __CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _CP_OFF

 #define    BANCO0  BCF	STATUS,RP0
 #define    BANCO1  BSF	STATUS,RP0
 
 ;variaveis
 CBLOCK 0X20
    CONT
    CONT2
    CONT3
    FLAGS
    AUX_TMR0
    SEQUENCIA
    W_TEMP
    S_TEMP
 ENDC

#define ACAO	    FLAGS,0
#define FIM_364MS   FLAGS,1
#define	LIGADO	    FLAGS,2
#define	CHECA_SEQ   FLAGS,3
#define LIGADO1	    FLAGS,4
#define LED0	    PORTB,0
#define LED1	    PORTB,1
#define LED2	    PORTB,2
#define LED3	    PORTB,3
#define LED4	    PORTB,4
#define LED5	    PORTB,5
#define LED6	    PORTB,6
#define LED7	    PORTB,7
#define	LIGA	    PORTA,1
#define PAUSA	    PORTA,2
#define ZERAR	    PORTA,3
 
V_TMR0	    equ	    .6
V_AUX_TMR0  equ	    .101
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    INICIO
INT_VECT  CODE    0x0004            ; processor interrupt vector 
    MOVWF   W_TEMP
    MOVF    STATUS,W
    MOVWF   S_TEMP
    BTFSS   INTCON,T0IF
    GOTO    SAI_INTERRUPCAO
    BCF	    INTCON,T0IF
    MOVLW   V_TMR0
    ADDWF   TMR0,F
    DECFSZ  AUX_TMR0,F
    GOTO    SAI_INTERRUPCAO
    MOVLW   V_AUX_TMR0
    MOVWF   AUX_TMR0
    BSF	    FIM_364MS
SAI_INTERRUPCAO
    MOVF    S_TEMP,W
    MOVWF   STATUS
    MOVF    W_TEMP,W
    RETFIE
  
MAIN_PROG CODE
 INICIO
    BANCO1
    MOVLW   B'11010011'
    MOVWF   OPTION_REG
    BCF	    TRISA,0
    CLRF    TRISB
    BANCO0
    MOVLW   .7
    MOVWF   CMCON    
    BCF	    ACAO
    BCF	    LIGADO
    BCF	    FIM_364MS
    BCF	    CHECA_SEQ
    BCF	    LIGADO1
    MOVLW   V_AUX_TMR0
    MOVWF   AUX_TMR0
    MOVLW   V_TMR0
    MOVWF   TMR0
    BSF	    INTCON,T0IE
    BSF	    INTCON,GIE  
    MOVLW   B'00001000'
    MOVWF   CONT
    MOVLW   B'00010000'
    MOVWF   CONT2 
  
LE_BOTAO
    BTFSS   PAUSA
    GOTO    PAUSA_ACIONADO
    BTFSC   ACAO
    GOTO    ACAO_ATIVO
    BTFSS   ZERAR
    GOTO    ZERAR_ATIVO
    BTFSS   LIGA
    GOTO    LIGA_ATIVO
    GOTO    LE_BOTAO
    
PAUSA_ACIONADO
    BCF	    ACAO    
    GOTO    LE_BOTAO
    
ZERAR_ATIVO
    BTFSC   ACAO
    GOTO    LE_BOTAO
    CLRF    PORTB
    CLRF    CONT3
    MOVLW   B'00001000'
    MOVWF   CONT
    MOVLW   B'00010000'
    MOVWF   CONT2
    BCF	    FIM_364MS
    BCF	    LIGADO
    BCF	    CHECA_SEQ
    BCF	    LIGADO1
    GOTO    LE_BOTAO
    
LIGA_ATIVO   
    BSF	    ACAO    
    BCF	    FIM_364MS
    MOVLW   V_AUX_TMR0
    MOVWF   AUX_TMR0
    MOVLW   V_TMR0
    MOVWF   TMR0
    GOTO    LE_BOTAO 
    
ACAO_ATIVO
    BTFSS   FIM_364MS
    GOTO    LE_BOTAO
    BCF	    FIM_364MS
    BTFSS   CHECA_SEQ
    GOTO    QUAL_SEQUENCIA
    GOTO    QUAL_SEQUENCIA1
    GOTO    LE_BOTAO
    
QUAL_SEQUENCIA
    BTFSS   LIGADO
    GOTO    SEQUENCIA1
    GOTO    SEQUENCIA2
    
QUAL_SEQUENCIA1
    BTFSS   LIGADO1
    GOTO    SEQUENCIA3
    GOTO    SEQUENCIA4
    
SEQUENCIA1
    BCF      STATUS,C
    CLRF     CONT3
    RLF	     CONT, 1
    RRF	     CONT2,1	
    MOVFW    CONT
    IORWF    CONT3
    MOVFW    CONT2
    IORWF    CONT3
    MOVFW    CONT3
    MOVWF    PORTB
    BTFSC    CONT3,7
    BSF	     LIGADO
    GOTO     LE_BOTAO
    
SEQUENCIA2
    BCF      STATUS,C
    CLRF     CONT3
    RRF	     CONT, 1
    RLF	     CONT2,1	
    MOVFW    CONT
    IORWF    CONT3
    MOVFW    CONT2
    IORWF    CONT3
    MOVFW    CONT3
    MOVWF    PORTB
    BTFSC    CONT3,4  
    GOTO     MUDA_SEQ
    GOTO     LE_BOTAO
    
MUDA_SEQ
    BCF	     LIGADO
    BSF	     CHECA_SEQ
    MOVLW    B'00001000'
    MOVWF    CONT
    MOVLW    B'00010000'
    MOVWF    CONT2
    GOTO     LE_BOTAO
    
SEQUENCIA3
    BCF      STATUS,C
    CLRF     CONT3
    RLF	     CONT,1 
    MOVLW    B'00010000'
    IORWF    CONT	
    RRF	     CONT2,1
    MOVLW    B'00001000'
    IORWF    CONT2
    MOVFW    CONT
    IORWF    CONT3
    MOVFW    CONT2
    IORWF    CONT3
    MOVFW    CONT3
    MOVWF    PORTB
    BTFSC    CONT3,7
    BSF	     LIGADO1
    GOTO     LE_BOTAO
    
SEQUENCIA4
    BCF      STATUS,C
    CLRF     CONT3
    RRF	     CONT,1 
    MOVLW    B'00001000'
    SUBWF    CONT
    BCF      STATUS,C
    RLF	     CONT2,1
    MOVLW    B'00010000'
    SUBWF    CONT2
    MOVFW    CONT
    IORWF    CONT3
    MOVFW    CONT2
    IORWF    CONT3
    MOVFW    CONT3
    MOVWF    PORTB
    BTFSS    CONT3,4
    GOTO     MUDA_SEQ1
    GOTO     LE_BOTAO
    
MUDA_SEQ1
    BCF	     LIGADO1
    BCF	     CHECA_SEQ
    MOVLW    B'00001000'
    MOVWF    CONT
    MOVLW    B'00010000'
    MOVWF    CONT2
    GOTO     LE_BOTAO

REINICIA
    CLRF    SEQUENCIA
    MOVLW   B'00010000'
    MOVWF   CONT
    MOVLW   B'00001000'
    MOVWF   CONT2
    GOTO    LE_BOTAO
  
    END