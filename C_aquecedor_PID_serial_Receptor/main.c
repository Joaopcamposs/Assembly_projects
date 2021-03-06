#include <main.h>
#include <lcd_8bits.c>
#include <String.h>

#define INI_P '$'       //inicio dos dados transferidos pelo protocolo
#define SEP_P ','       //separador de dados do protocolo
#define END_P '@'       //fim dos dados transferidos pelo protocolo

int1  fim_rx;
char  rx_dado;
char  dado[36];
int8  indice;

char SP[4], PV[4], P, Param, KP[5], KI[5], TD[5];

//ordem do vetor dado
//[0]-SP, [1]-PV, [2]-P, [3]-Param, [4]-Kp, [5]-Ki, [6]-Td

void pega_valores();
void atualizar_display();

#INT_RDA
void  RDA_isr(void) 
{   
   rx_dado = getc();                //le o dado serial armazenado no buffer de recepcao serial
   dado[indice] = rx_dado;          //armazena o dado recebido no vetor de dados
   indice++;                        //incrementa a posicao do vetor
   if(rx_dado == END_P)              //verifica se chegou todos os dados do pacote
   {
      fim_rx = 1;                   //se sim, sinaliza que o pacote est? completo
      indice = 0;                   //iniciliza a posi??o do vetor
   } 
}

#INT_TIMER0
void  TIMER0_isr(void) 
{

}

void main()
{
   setup_adc_ports(AN0_AN1_AN3);
   setup_adc(ADC_CLOCK_INTERNAL);
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_8|RTCC_8_BIT);      //1,0 ms overflow
   
   lcd_init();

   enable_interrupts(INT_RDA);
   disable_interrupts(INT_TIMER0);
   enable_interrupts(GLOBAL);
   
   pega_valores();
   atualizar_display();

   while(TRUE)
   {
      if(fim_rx)
      {    
         pega_valores();
         
         atualizar_display();
         
         fim_rx = 0;
      }
   }

}

void pega_valores(){   
   
      int8 k = 1;                         //pula o valor de inicio
         for(int8 j=0;j<4;j++){          //SP
            SP[j] = dado[k];
            k++;    
         }k++;
         
         for(int8 j=0;j<4;j++){          //PV
            PV[j] = dado[k];
            k++;
         }k++;
         
         for(int8 j=0;j<1;j++){          //P
            P = dado[k];
            k++;
         }k++;
         
         for(int8 j=0;j<1;j++){          //Param
            Param = dado[k];
            k++;
         }k++;
         
         for(int8 j=0;j<5;j++){          //KP
            KP[j] = dado[k];
            k++;
         }k++;
         
         for(int8 j=0;j<5;j++){          //KI
            KI[j] = dado[k];
            k++;
         }k++;
         
         for(int8 j=0;j<5;j++){          //TD
            TD[j] = dado[k];
            k++;
         }
}

void atualizar_display(){
   lcd_gotoxy(1,1);
   printf(lcd_write_dat,"SP:");
   lcd_gotoxy(4,1);
   for(int8 i=0;i<4;i++){
      printf(lcd_write_dat,"%c", SP[i]); //dado SP
   }
   
   lcd_gotoxy(9,1);
   printf(lcd_write_dat,"PV:");
   lcd_gotoxy(12,1);
   for(int8 i=0;i<4;i++){
      printf(lcd_write_dat,"%c", PV[i]); //dado PV
   }
   
   lcd_gotoxy(1,2);
   printf(lcd_write_dat,"P:");
   lcd_gotoxy(3,2);
   if(P == '1') //dado estado do processo
      printf(lcd_write_dat,"ON");
   else
      printf(lcd_write_dat,"OF");
   
   
   if(Param == '0'){ //Kp
      lcd_gotoxy(8,2);
      printf(lcd_write_dat,"Kp:");
      lcd_gotoxy(11,2);
      for(int8 i=0;i<5;i++){
         printf(lcd_write_dat,"%c", KP[i]);
      }
   }else
   if(Param == '1'){ //Ki
      lcd_gotoxy(8,2);
      printf(lcd_write_dat,"Ki:");
      lcd_gotoxy(11,2);
      for(int8 i=0;i<5;i++){
         printf(lcd_write_dat,"%c", KI[i]);
      }
   }else
   if(Param == '2'){ //Td
      lcd_gotoxy(8,2);
      printf(lcd_write_dat,"Td:");
      lcd_gotoxy(11,2);
      for(int8 i=0;i<5;i++){
         printf(lcd_write_dat,"%c", TD[i]);
      }
   }
}


