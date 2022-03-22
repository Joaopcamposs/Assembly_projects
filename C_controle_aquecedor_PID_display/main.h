#include <16F877A.h>
#device ADC=10

#FUSES PUT                   	//Power Up Timer
#FUSES NOLVP                 	//No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O

#use delay(crystal=8MHz)
#use FIXED_IO( A_outputs=PIN_A5 )
#use FIXED_IO( C_outputs=PIN_C2,PIN_C1 )
#define BUZZER	PIN_A5
#define S1	PIN_B0
#define S2	PIN_B1
#define S3	PIN_B2
#define S4	PIN_B3
#define FAN	PIN_C1
#define HEATER	PIN_C2


