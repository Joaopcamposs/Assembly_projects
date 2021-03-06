#include <16F877A.h>
#device ADC=10

#FUSES PUT                      //Power Up Timer
#FUSES NOLVP                    //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O

#use delay(crystal=8MHz)

#use rs232(baud=9600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8)

#use FIXED_IO( C_outputs=PIN_C2 )

#define B_S1      PIN_B0
#define B_S2      PIN_B1
#define B_S3      PIN_B2
#define B_S4      PIN_B3
#define HEATER    PIN_C2

