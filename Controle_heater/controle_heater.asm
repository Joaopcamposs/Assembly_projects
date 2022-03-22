#include "p16f877a.inc"
; __config 0xFF71
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

#define BANCO0      BCF STATUS,RP0
#define BANCO1      BSF STATUS,RP0
 
 ;variaveis
 CBLOCK 0X20
    FLAGS
    UNIDADE
    DEZENA
    CENTENA
    MILHAR
    W_TEMP
    S_TEMP
    VALOR_ADC
    VALOR_ADC0
    VALOR_ADC1
    AUX_TEMPO
    AUX_PWM
    X
    Y
    DELAY_ADC
 ENDC
 
#define ACAO		FLAGS,0
#define FIM_200MS	FLAGS,1
#define QUAL_CANAL	FLAGS,2
#define PROCESSO	FLAGS,3
#define DISPLAY		PORTD
#define D_UNIDADE	PORTB,4
#define D_DEZENA	PORTB,5
#define D_CENTENA	PORTB,6
#define D_MILHAR	PORTB,7
#define S1		PORTB,0
#define S2		PORTB,1
#define S3		PORTB,2
#define S4		PORTB,3
#define HEATER		PORTC,2
#DEFINE	FAN		PORTC,1
 
V_TMR0      equ     .6
V_AUX_TEMPO equ     .200

 
;programa ===================================================
RES_VECT    CODE    0x0000
    GOTO    START

INTERRUPT_VECT  CODE    0x0004
    MOVWF   W_TEMP
    MOVF    STATUS,W
    MOVWF   S_TEMP
    BTFSS   INTCON,T0IF
    GOTO    SAI_INTERRUPCAO
    BCF     INTCON,T0IF    
    MOVLW   V_TMR0
    ADDWF   TMR0,F
CONTA_200MS
    DECFSZ  AUX_TEMPO,F
    GOTO    TESTA_DISPLAY_UNIDADE
    BSF     FIM_200MS
    MOVLW   V_AUX_TEMPO
    MOVWF   AUX_TEMPO
TESTA_DISPLAY_UNIDADE
    BTFSS   D_UNIDADE
    GOTO    TESTA_DISPLAY_DEZENA
    BCF     D_UNIDADE
    MOVF    DEZENA,W
    CALL    TABELA
    MOVWF   DISPLAY
    BSF     D_DEZENA
    GOTO    SAI_INTERRUPCAO
TESTA_DISPLAY_DEZENA
    BTFSS   D_DEZENA
    GOTO    TESTA_DISPLAY_CENTENA
    BCF     D_DEZENA
    MOVF    CENTENA,W
    CALL    TABELA
    MOVWF   DISPLAY
    BSF     D_CENTENA
    GOTO    SAI_INTERRUPCAO
TESTA_DISPLAY_CENTENA    
    BTFSS   D_CENTENA
    GOTO    TESTA_DISPLAY_MILHAR
    BCF     D_CENTENA
    MOVF    MILHAR,W
    CALL    TABELA
    MOVWF   DISPLAY
    BSF     D_MILHAR
    GOTO    SAI_INTERRUPCAO
TESTA_DISPLAY_MILHAR
    BCF     D_MILHAR
    MOVF    UNIDADE,W
    CALL    TABELA
    MOVWF   DISPLAY
    BSF     D_UNIDADE
SAI_INTERRUPCAO
    MOVF    S_TEMP,W
    MOVWF   STATUS
    MOVF    W_TEMP,W
    RETFIE
    
START
    BANCO1
    CLRF    TRISD	    ;aciona os segmentos dos displays
    BCF     TRISB,4	    ;aciona o catodo do display da unidade
    BCF     TRISB,5	    ;aciona o catodo do display da dezena
    BCF     TRISB,6	    ;aciona o catodo do display da centena
    BCF     TRISB,7	    ;aciona o catodo do display da milhar
    BCF     TRISC,1	    ;configura como sa�da o pino RC1 - ACIONA VENTILADOR(PWM2)
    BCF     TRISC,2	    ;configura como sa�da o pino RC2 - ACIONA AQUECEDOR(PWM1)
    ;====================================================================
    MOVLW   B'01010001'	    ;valor para configurar o TIMER0
    MOVWF   OPTION_REG	    ;carrega valor no TIMER0
    ;====================================================================
    MOVLW   B'01000100'	    ;bit 7 - justificar � esquerda
			    ;bit 6 - clock gerado por RC
			    ;bit 5 e 4 - n�o usado
			    ;bit 3,2,1,0 - seleciona AN0, AN1 e AN3 como entradas anal�gicas
    MOVWF   ADCON1	    ;carregar valor no ADCON1
    ;====================================================================
    MOVLW   .63		    ;carrega a constante 63 para definir frequ�ncia
    MOVWF   PR2		    ;do PWM
    ;====================================================================
    BANCO0
    ;====================================================================
    ;configura��o do TIMER2
    MOVLW   B'00000100'	    ;bit 7 - n�o usado
			    ;bit 6,5,4,3 - define POSTSCALER - n�o usado no PWM
			    ;bit 2 - liga o TIMER2
			    ;bit 1,0 - PRESCALER = 1:1 (00)	
    MOVWF   T2CON	    ;carregar valor no T2CON
    ;====================================================================
    MOVLW   B'11000001'	    ;bit 7 e 6 - clock gerado por RC
			    ;bit 5,4,3 - seleciona a entrada AN0 para leitura
			    ;bit 2 - inicia e indica que a convers�o finalizou
			    ;bit 1 - n�o usado
			    ;bit 0 - liga o conversor           
    MOVWF   ADCON0	    ;carregar valor no ADCON0    
    ;====================================================================
    ;configura��o do PWM1
    CLRF    CCPR1L	    ;limpa o registro que define largura do pulso
    MOVLW   B'00001111'	    ;bit 7 e 6 - n�o usado
			    ;bit 5,4 - s�o os 2 bits LSB do numero de 10bits que define largura do PWM
			    ;bit 3,2,10 - seleciona modo PWM
    MOVWF   CCP1CON	    ;carregar valor no registro de configura��o do PWM1			
    ;====================================================================
    ;configura��o do PWM2
    CLRF    CCPR2L	    ;limpa o registro que define largura do pulso
    MOVLW   B'00001111'	    ;bit 7 e 6 - n�o usado
			    ;bit 5,4 - s�o os 2 bits LSB do numero de 10bits que define largura do PWM
			    ;bit 3,2,10 - seleciona modo PWM
    MOVWF   CCP2CON	    ;carregar valor no registro de configura��o do PWM2			
    ;====================================================================
    CLRF    DISPLAY
    BCF     D_UNIDADE
    BCF     D_DEZENA
    BCF     D_CENTENA
    BCF     D_MILHAR    
    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA
    CLRF    MILHAR    
    BCF     FIM_200MS
    MOVLW   V_AUX_TEMPO
    MOVWF   AUX_TEMPO
    BCF     ACAO
    BCF     QUAL_CANAL
    BCF     HEATER
    BCF	    FAN
    MOVLW   V_TMR0
    MOVWF   TMR0
    BSF     INTCON,T0IE
    BSF     INTCON,GIE    
LACO_PRINCIPAL
    BTFSS   S1			;testa se bot�o S1 n�o est� pressionado
    BCF     QUAL_CANAL		;se estiver, zera o QUAL_CANAL
    BTFSS   S2			;testa se bot�o S2 n�o est� pressionado
    BSF     QUAL_CANAL		;se estiver, seta o QUAL_CANAL
    BTFSS   S3			;testa se bot�o S3 n�o est� pressionado
    BSF     PROCESSO		;se estiver, liga o controlador de temperatura
    BTFSS   S4			;testa se bot�o S4 n�o est� pressionado
    CALL    DESLIGA_PROCESSO	;se estiver, v� para a rotina que deslida o controlador de temperatura
    BTFSS   FIM_200MS
    GOTO    LACO_PRINCIPAL
    BCF     FIM_200MS
    ;le e converte a entrada anal�gica AN0 ==============================
    MOVLW   B'11000111'		;seleciona canal AN0        
    ANDWF   ADCON0,F		;carregar valor no ADCON0
    ;temporizar antes de ativar a convers�o ==============================
    MOVLW   .19
    MOVWF   DELAY_ADC
    DECFSZ  DELAY_ADC,F
    GOTO    $-1
    ;====================================================================
    ;inicia a convers�o
    BSF     ADCON0,GO
    ;aguarda o final da convers�o
    BTFSC   ADCON0,GO
    GOTO    $-1
    ;====================================================================
    MOVF    ADRESH,W		;l� os 8 bits mais significativos da convers�o AD
    MOVWF   VALOR_ADC0		;carrega na vari�vel VALOR_ADC0
    MOVWF   Y
    ;==================================================================== 
    ;le e converte a entrada anal�gica AN1 ==============================
    BSF     ADCON0,3		;seleciona para o canal AN1 ADCON0 = xx001xxx 
    ;temporizar antes de ativar a convers�o ==============================
    MOVLW   .19
    MOVWF   DELAY_ADC
    DECFSZ  DELAY_ADC,F
    GOTO    $-1
    ;====================================================================
    ;inicia a convers�o
    BSF     ADCON0,GO
    ;aguarda o final da convers�o
    BTFSC   ADCON0,GO
    GOTO    $-1
    ;====================================================================
    MOVF    ADRESH,W		;l� os 8 bits mais significativos da convers�o AD
    MOVWF   VALOR_ADC1		;carrega na vari�vel VALOR_ADC1
    BTFSS   PROCESSO		;testa se o controle de temp esta ativado
    GOTO    TESTA_CANAL
CONTROLA_HEATER
    MOVF    VALOR_ADC1,W
    MOVWF   X
    MOVF   VALOR_ADC0,W
    SUBWF   X,F
    BTFSC   STATUS,C
    GOTO    PWM1
    CLRF    CCPR1L
CONTROLA_FAN    
    BCF	    STATUS,C
    MOVF    VALOR_ADC0
    MOVWF   Y
    MOVF    VALOR_ADC1,W
    SUBWF   Y,F
    BTFSC   STATUS,C
    GOTO    PWM2
    CLRF    CCPR2L
    GOTO    TESTA_CANAL
    
PWM1     
    MOVF    VALOR_ADC1,W
    MOVWF   AUX_PWM
    ;desloca os 2 LSB para a posi��o 5 e 4 e carrega no CCP1CON
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    MOVLW   B'00110000'
    ANDWF   AUX_PWM,F
    MOVLW   B'11001111'
    ANDWF   CCP1CON,F
    MOVF    AUX_PWM,W
    IORWF   CCP1CON,F
    ;desloca e carrega os 6 MSB no CCPR1L
    MOVF    VALOR_ADC1,W
    MOVWF   AUX_PWM
    BCF	    STATUS,C
    RRF	    AUX_PWM,F
    BCF	    STATUS,C
    RRF	    AUX_PWM,F
    MOVF    AUX_PWM,W
    MOVWF   CCPR1L
    GOTO    CONTROLA_FAN
    
PWM2
    MOVF    VALOR_ADC1,W
    MOVWF   AUX_PWM
    ;desloca os 2 LSB para a posi��o 5 e 4 e carrega no CCP1CON
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    RLF	    AUX_PWM,F
    MOVLW   B'00110000'
    ANDWF   AUX_PWM,F
    MOVLW   B'11001111'
    ANDWF   CCP2CON,F
    MOVF    AUX_PWM,w
    IORWF   CCP2CON,F
    ;desloca e carrega os 6 MSB no CCPR1L
    MOVF    VALOR_ADC1,W
    MOVWF   AUX_PWM
    BCF	    STATUS,C
    RRF	    AUX_PWM,F
    BCF	    STATUS,C
    RRF	    AUX_PWM,F
    MOVF    AUX_PWM,W
    MOVWF   CCPR2L
    
TESTA_CANAL
    BTFSC   QUAL_CANAL
    GOTO    MOSTRA_CANAL_0
MOSTRA_CANAL_1			;preparar para mostrar o canal 1 (potenciometro)
    MOVF    VALOR_ADC1,W
    MOVWF   VALOR_ADC    
    GOTO    MOSTRA_NO_DISPLAY
MOSTRA_CANAL_0			;preparar para mostrar o canal 0 (sensor)   
    MOVF    VALOR_ADC0,W
    MOVWF   VALOR_ADC
MOSTRA_NO_DISPLAY    
    CLRF    UNIDADE
    CLRF    DEZENA
    CLRF    CENTENA
    CLRF    MILHAR
    
EXTRAI_CENTENA
    MOVLW   .100
    SUBWF   VALOR_ADC,W
    BTFSS   STATUS,C
    GOTO    EXTRAI_DEZENA
    MOVWF   VALOR_ADC
    INCF    CENTENA,F
    GOTO    EXTRAI_CENTENA
EXTRAI_DEZENA
    MOVLW   .10
    SUBWF   VALOR_ADC,W
    BTFSS   STATUS,C
    GOTO    EXTRAI_UNIDADE
    MOVWF   VALOR_ADC
    INCF    DEZENA,F
    GOTO    EXTRAI_DEZENA
EXTRAI_UNIDADE
    MOVF    VALOR_ADC,W
    MOVWF   UNIDADE
    GOTO    LACO_PRINCIPAL    
   
DESLIGA_PROCESSO
    BCF	    PROCESSO
    CLRF    CCPR1L
    CLRF    CCPR2L
    RETURN
    
TABELA
    ADDWF   PCL,F   ;DEFINE O INDICE (SALTO) DENTRO DA TABELA
    RETLW   .63     ;N�MERO 0 NO DISPLAY
    RETLW   .6      ;N�MERO 1 NO DISPLAY
    RETLW   .91     ;N�MERO 2 NO DISPLAY
    RETLW   .79     ;N�MERO 3 NO DISPLAY
    RETLW   .102    ;N�MERO 4 NO DISPLAY
    RETLW   .109    ;N�MERO 5 NO DISPLAY
    RETLW   .125    ;N�MERO 6 NO DISPLAY
    RETLW   .7      ;N�MERO 7 NO DISPLAY
    RETLW   .127    ;N�MERO 8 NO DISPLAY
    RETLW   .111    ;N�MERO 9 NO DISPLAY
    RETLW   .0      ;N�MERO APAGADO NO DISPLAY    
    END