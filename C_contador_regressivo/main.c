#include <main.h>

int display[]= {63, 6, 91, 79, 102, 109, 125, 7, 127, 111};
int cont, cont1, cont2, cont3, AUX_100MS=100, AUX_5S, aux;
int filtro, filtro1, filtro2, filtro3;
int1 acao, acao1, acao2, acao3, acao4, acao5, fim100ms, FIM5S;

#define  V_FILTRO    100

void le_botaoS1();
void le_botaoS2();
void le_botaoS3();
void le_botaoS4();

#INT_TIMER0
void  TIMER0_isr(void) 
{
    AUX_100MS--;
    if(AUX_100MS==0)
    {
      fim100ms=1;
      AUX_100MS=100;
      AUX_5S--;
      
      if(AUX_5S==0){
         FIM5S=1;  
      }
   }
   
   if(aux==4){
      aux=0;
   }
   
   if(aux==0)
   {
      output_low(PIN_B4);
      output_high(PIN_B7);
      output_d(display[cont3]);
      aux++;
      
   }else if(aux==1)
   {
      output_low(PIN_B7);
      output_high(PIN_B6);
      output_d(display[cont2]);
      aux++;
      
   }else if(aux==2)
   {
      output_low(PIN_B6);
      output_high(PIN_B5);
      output_d(display[cont1]+128);
      aux++;
      
   }else{
      output_low(PIN_B5);
      output_high(PIN_B4);
      output_d(display[cont]);
      aux++;
   }
}

void main()
{
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_4|RTCC_8_BIT);      //1,0 ms overflow
   enable_interrupts(INT_RTCC);
   enable_interrupts(INT_TIMER0);
   enable_interrupts(GLOBAL);
   cont=0;
   acao=0;
   acao5=1;
   aux=0;
   AUX_100MS=0;
   while(TRUE)
   {
      if(fim100ms==1)
      {
         fim100ms=0;
         if(acao==1)
         {
                 if(cont==0)
                 {
                     cont=9;
                     if(cont1==0)
                     {
                        cont1=9;
                        if(cont2==0)
                        {
                           cont2=9;
                           if(cont3==0)
                           {
                              cont=0;
                              cont1=0;
                              cont2=0;
                              if(acao5==0)
                              {
                                 output_high(BUZZER);
                                 AUX_5S=50;
                                 acao=0;
                                 acao5=1;
                              }
                           }
                           else{
                              cont3--;
                           }
                        }
                        else{
                           cont2--;
                        }
                     }
                     else{
                        cont1--;
                     }
                  }
                  else{
                     cont--;
                  }
         }
      }
      if(FIM5S==1){
         output_low(BUZZER);
         FIM5S=0;
      }
      
      le_botaoS1();
      le_botaoS2();
      le_botaoS3();
      le_botaoS4();
   }

}

void le_botaoS1()
{
   if(input(S1) == 0)
   {
      if(acao4 == 0)
      {
            filtro--;
            if (filtro == 0)
            {
               acao4=1;
               if(acao==0){
                  acao=1;
               }
               else{
                  acao=0;
               }
            }
      }
   }
   else{
      acao4=0;
      filtro = V_FILTRO;
   }
}

void le_botaoS2()
{
   if (input(S2) == 0)
   {
      if(acao1 == 0)
      {
            filtro1--;
            if (filtro1 == 0)
            {
               if(acao==0){
               cont=0;
               cont1=0;
               cont2=0;
               cont3=0;
               acao=0;
               acao5=1;
               output_low(BUZZER);
               acao1=1;
               }
            }
      }
   }
   else{
      acao1=0;
      filtro1 = V_FILTRO;
   }
}

void le_botaoS3()
{
   if (input(S3) == 0)
   {
      if(acao2 == 0)
      {
            filtro2--;
            if (filtro2 == 0)
            {
               if(acao==0)
               {
                  acao5=0;
                  if(cont==9)
                  {
                     cont=0;
                     if(cont1==9)
                     {
                        cont1=0;
                        if(cont2==9)
                        {
                           cont2=0;
                           if(cont3==9)
                           {
                              cont3 = 0;
                           }else{
                              cont3++;
                           }
                        }
                        else{
                           cont2++;
                        }
                     }
                     else{
                        cont1++;
                     }
                  }
                  else{
                     cont++;
                  }
               acao2=1;
               }
            }
      }
   }
   else{
      acao2=0;
      filtro2 = V_FILTRO;
   }
}

void le_botaoS4()
{
   if (input(S4) == 0)
   {
      if(acao3 == 0)
      {
            filtro3--;
            if (filtro3 == 0)
            {
               if(acao==0)
               {
                  acao5=0;
                  if(cont==0)
                  {
                     cont=9;
                     if(cont1==0)
                     {
                        cont1=9;
                        if(cont2==0)
                        {
                           cont2=9;
                           if(cont3==0)
                           {
                              cont3 = 9;
                           }
                           else{
                              cont3--;
                           }
                        }
                        else{
                           cont2--;
                           }
                     }
                     else{
                        cont1--;
                        }
                  }
                  else{
                     cont--;
                  }
                  acao3=1;
               }
            }
      }
   }
   else{
      acao3=0;
      filtro3 = V_FILTRO;
   }
}

