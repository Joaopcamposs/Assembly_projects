#include <main.h>
#include <lcd_8bits.c>

int1 fim500ms, processo, qual_display, acao, acao1, acao2, acao3;
int8 aux500ms, filtro, filtro1, filtro2, filtro3;
unsigned int16 temp, pot;
float his, potC, tempC;

#define AUX_500MS 250
#define V_FILTRO 100

void le_botaoS1();
void le_botaoS2();
void le_botaoS3();
void le_botaoS4();
void le_entradas();
void controla_processo();

#INT_TIMER0
void  TIMER0_isr(void){
   set_timer0(get_timer0() + 6);
   aux500ms--;
   if(aux500ms==0){
      fim500ms = 1;
      aux500ms = AUX_500MS;
   }
}

void main()
{
   setup_adc_ports(AN0_AN1_AN3);
   setup_adc(ADC_CLOCK_INTERNAL);
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_16|RTCC_8_BIT);      //2,0 ms overflow
   enable_interrupts(INT_TIMER0);
   enable_interrupts(GLOBAL);
   his = 0.1;
   aux500ms = AUX_500MS;
   filtro = V_FILTRO;
   filtro1 = V_FILTRO;
   filtro2 = V_FILTRO;
   acao = 0;
   acao1 = 0;
   acao2 = 0;
   fim500ms = 0;
   processo = 0;
   qual_display = 0;
   lcd_init();
   lcd_gotoxy(1,1);
   printf(lcd_write_dat,"SP:");
   lcd_gotoxy(9,1);
   printf(lcd_write_dat,"PV:");
   lcd_gotoxy(1,2);
   printf(lcd_write_dat,"P:");
   lcd_gotoxy(6,2);
   printf(lcd_write_dat,"R:");
   lcd_gotoxy(11,2);
   printf(lcd_write_dat,"H:");
   lcd_gotoxy(13,2);
   printf(lcd_write_dat,"%1.1f", his);
   
   while(TRUE){
      controla_processo();
      if(fim500ms){
         fim500ms = 0;
         le_entradas();
      }
      le_botaoS1();
      le_botaoS2();
      le_botaoS3();
      le_botaoS4();
   }
}

void le_entradas()
{
   set_adc_channel(0);
   delay_us(20);
   temp = read_adc();
   set_adc_channel(1);
   delay_us(20);
   pot = read_adc();
   potC = (50*pot + 30690.0) / 1023,0;
   tempC = ((temp-341)*33.5+7260)/264.0; 
   lcd_gotoxy(8,1);
   printf(lcd_write_dat," ");
   lcd_gotoxy(4,1);
   printf(lcd_write_dat,"%.1f", potC);
   lcd_gotoxy(12,1);
   printf(lcd_write_dat,"%.1f", tempC);  
}

void le_botaoS1()
{
   if(input(S1)==0){
      if(!acao){
         filtro--;
         if(filtro==0){
            acao=1;
            processo = !processo;
         }
      }
   } else{
      filtro = V_FILTRO;
      acao = 0;
   }
}

void le_botaoS2()
{
   if(input(S2)==0){
      if(!acao1){
         filtro1--;
         if(filtro1==0){
            acao1=1;
            if(his>=5.0){
               his = 5.0;
            } else{
               his = his+0.1;
            }
            lcd_gotoxy(13,2);
            printf(lcd_write_dat,"%1.1f", his);
         }
      }
   } else{
      filtro1 = V_FILTRO;
      acao1 = 0;
   }
}

void le_botaoS3()
{
   if(input(S3)==0){
      if(!acao2){
         filtro2--;
         if(filtro2==0){
            acao2=1;
            if(his<=0.1){
               his = 0.1;
            } else{
               his = his-0.1;
            }
            lcd_gotoxy(13,2);
            printf(lcd_write_dat,"%1.1f", his);
         }
      }
   } else{
      filtro2 = V_FILTRO;
      acao2 = 0;
   }
}

void le_botaoS4()
{
   if(input(S4)==0){
      if(!acao3){
         filtro3--;
         if(filtro3==0){
            acao3=1;
            qual_display = !qual_display;
         }
      }
   } else{
      filtro3 = V_FILTRO;
      acao3 = 0;
   }
}

void controla_processo()
{
   if(processo){
      lcd_gotoxy(3,2);
      printf(lcd_write_dat,"ON");
      if(tempC<(potC-his)){
         output_low(FAN);
         output_high(HEATER);
         if(qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"V:OF");
         } else{
            lcd_gotoxy(6,2);
         printf(lcd_write_dat,"R:ON");
         }
      } else if(tempC>(potC+his)){
         output_low(HEATER);
         if(!qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"R:OF");
         }
      }
      if(tempC> (1.2*potC)){
         output_high(fan);
         output_high(buzzer);
         if(qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"V:ON");
         }
      } 
      if(tempC<=potC){
         output_low(fan);
         output_low(buzzer);
         if(qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"V:OF");
         }
      }
   } else{
      output_low(heater);
      output_low(buzzer);
      lcd_gotoxy(3,2);
      printf(lcd_write_dat,"OF");
      if(!qual_display){
         lcd_gotoxy(6,2);
         printf(lcd_write_dat,"R:OF");
      }
      if(tempC>30.0){
         output_high(FAN);
         if(qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"V:ON");
         }
      } else{
         output_low(FAN);
         if(qual_display){
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"V:OF");
         } else{
            lcd_gotoxy(6,2);
            printf(lcd_write_dat,"R:OF");
         }
      }
   }
}
