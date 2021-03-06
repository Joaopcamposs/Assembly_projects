//s1 - liga/desliga
//s2 - altera/seleciona parametro
//s3 - incrementa
//s4 - decrementa

#include <main.h>
#include <lcd_8bits.c>

int1     processo, fim_tempo;
int1     acao1, acao2, acao3, acao4;

int8     parametro = 0;
int8     filtro1=100;
int8     filtro2=100;
int8     filtro3=100;
int8     filtro4=100;

int16    aux_tempo = 500;
int16    sensor, potenciometro;
int16    largura_PWM;

float    erro, erro_anterior;
float    Proporcional, Integral, Derivativo;
float    SP_temperatura, PV_temperatura;
float    PID;
float    KP = 1.0, KI = 1.0, TD = 1.0;

//ordem do vetor dado RX
//[0]-SP, [1]-PV, [2]-P, [3]-Param, [4]-Kp, [5]-Ki, [6]-Td

#define  LARGURA_MAX_PWM   799      //largura maxima do PWM
#define  TA                0.5      //intervalo de calculo do PID

void printa_lcd();
void envia_serial();
void controlador_PID();
void le_entradas_analogicas();
int8 selec_parametro();

#INT_TIMER0
void  TIMER0_isr(void) {
   set_timer0(get_timer0() + 6);                         //somar 6 ao timer 0 - para 250 pulsos
   aux_tempo--;
   if (aux_tempo == 0)
   {
      aux_tempo = 500;
      fim_tempo = 1;
   }
}

void main()
{
   setup_adc_ports(AN0_AN1_AN3);
   setup_adc(ADC_CLOCK_INTERNAL);
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_8|RTCC_8_BIT);      //1,0 ms overflow
   setup_timer_2(T2_DIV_BY_4,99,1);                        //200 us overflow, 200 us interrupt

   setup_ccp1(CCP_PWM);
   set_pwm1_duty((int16)0);
   
   lcd_init();

   //envia_serial();
   
   enable_interrupts(INT_TIMER0);
   enable_interrupts(GLOBAL);

   while(TRUE) //laco principal
   {
      if (fim_tempo) //
      {
         fim_tempo = 0;
         le_entradas_analogicas();
         printa_lcd();
         envia_serial();
         
         if (processo)
         {
            controlador_PID();
            largura_PWM = (int16)PID;
            if (largura_PWM > LARGURA_MAX_PWM)  
               largura_PWM = LARGURA_MAX_PWM;
            set_pwm1_duty(largura_PWM);
         }
      }
      
      if (processo == 0) //se processo estiver desligado
      {
         if (input(B_S1) == 0) //ligar processo
         {
            if(acao1 == 0)
            {
               filtro1--;
               if(filtro1 == 0)
               {
                  acao1 = 1; 
                  processo = 1;
                  aux_tempo = 500;
                  fim_tempo = 0;
                  printa_lcd();
                  envia_serial();
               }
            }
         }
         else {
            filtro1 = 100;
            acao1 = 0;
         }
         
         if (input(B_S3) == 0) //incrementar
         {            
            if(acao3 == 0)
            { 
               filtro3--;
               if(filtro3 == 0)
               {
                  acao3=1;
                  if(parametro == 1){//Ki
                     KI = KI + 0.001;
                     printa_lcd();
                     envia_serial();
                  }
                  if(parametro == 2){//Td
                     TD = TD + 0.001;
                     printa_lcd();
                     envia_serial();
                  }
                  if(parametro == 0){//Kp
                     KP = KP + 0.001;
                     printa_lcd();
                     envia_serial();
                  }
               }
            }
         }
         else {
            filtro3 = 100;
            acao3 = 0;
         }
         
         if (input(B_S4) == 0) //decrementa
         {            
            if(acao4 == 0)
            {
               filtro4--;
               if(filtro4 == 0)
               {
                  acao4=1;
                  if(parametro == 1){//Ki
                     KI = KI - 0.001;
                     printa_lcd();
                     envia_serial();
                  }else
                  if(parametro == 2){//Td
                     TD = TD - 0.001;
                     printa_lcd();
                     envia_serial();
                  }else
                  if(parametro == 0){//Kp
                     KP = KP - 0.001;
                     printa_lcd();
                     envia_serial();
                  }
               }
            }
         }
         else {
            filtro4 = 100;
            acao4 = 0;
         }
      }
      
      if (input(B_S2) == 0) //altera parametro
      {
         if(acao2 == 0)
         {
            filtro2--;
            if(filtro2 == 0)
            {
               acao2=1;
               selec_parametro();
               printa_lcd();
               envia_serial();
            }
         }
      }
      else {
         filtro2 = 100;
         acao2 = 0;
      }
      
      if (processo == 1 && input(B_S1) == 0) //desligar processo
      {
         processo = 0;
         set_pwm1_duty((int16)0);
         PID = 0.0;
         Integral = 0.0;
         printa_lcd();
         envia_serial();
      }
   }
}

void printa_lcd(){
   lcd_gotoxy(1,1);
   printf(lcd_write_dat,"SP:");
   lcd_gotoxy(4,1);
   printf(lcd_write_dat,"%3.1f",SP_temperatura);
   
   lcd_gotoxy(9,1);
   printf(lcd_write_dat,"PV:");
   lcd_gotoxy(12,1);
   printf(lcd_write_dat,"%3.1f",PV_temperatura);
   
   lcd_gotoxy(1,2);
   printf(lcd_write_dat,"P:");
   lcd_gotoxy(3,2);
   if(processo == 1)
      printf(lcd_write_dat,"ON");
   else
      printf(lcd_write_dat,"OF");
      
      if(parametro == 0){//Kp
         lcd_gotoxy(8,2);
         printf(lcd_write_dat,"Kp:");
         lcd_gotoxy(11,2);
         printf(lcd_write_dat,"%.3f", KP);
      }else
      if(parametro == 1){//Ki
         lcd_gotoxy(8,2);
         printf(lcd_write_dat,"Ki:");
         lcd_gotoxy(11,2);
         printf(lcd_write_dat,"%.3f", KI);
      }else
      if(parametro == 2){//Td
         lcd_gotoxy(8,2);
         printf(lcd_write_dat,"Td:");
         lcd_gotoxy(11,2);
         printf(lcd_write_dat,"%.3f",TD);
      }     
}

void envia_serial(){ //funcao para enviar dados para a comunicacao serial

      printf("$%.1f,%.1f,%d,%d,%.3f,%.3f,%.3f@", SP_temperatura,PV_temperatura,processo,parametro,KP,KI,TD);
}

int8 selec_parametro(){ //funcao para alterar parametro selecionado
   if(parametro == 2){
      parametro = 0;
   }
   else{
      parametro++;
   }
   
   return parametro;
}

void controlador_PID(){ //funcao controladora do pid
   erro = (SP_temperatura - PV_temperatura);
   Proporcional = KP * erro;
   Integral += (((TA * erro_anterior) + (((erro - erro_anterior)*TA)/2)) * KI);
   Derivativo = ((erro - erro_anterior) / TA) * TD;
   PID = Proporcional + Integral + Derivativo;
   erro_anterior = erro;
   if (PID < 0.0) PID = 0.0;
}

void le_entradas_analogicas(){ //funcao que le entradas analogicas (heater)
     set_adc_channel(1);                          //le o canal 0 - sensor de temperatura
     delay_us(10);                                //atraso para estabiliza??o da tens?o na entrada do ADC
     sensor = read_adc();                         //le o valor convertido do canal 0
     set_adc_channel(0);                          //le o canal 1 - valor do potenci?metro
     delay_us(10);                                //atraso para estabiliza??o da tens?o na entrada do ADC
     potenciometro = read_adc();                 //le o valor convertido do canal 1
     SP_temperatura = sensor * 0.1238 - 14.62;
     if (SP_temperatura < 30.0) SP_temperatura = 30.0;
     if (SP_temperatura > 80.0) SP_temperatura = 80.0;     
     PV_temperatura = potenciometro * 0.1238 - 14.62;
}

