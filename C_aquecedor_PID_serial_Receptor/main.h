#include <16F877A.h>
#device ADC=10

#FUSES PUT                      //Power Up Timer
#FUSES NOLVP                    //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O

#define B_S1      PIN_B0

#use delay(crystal=8MHz)
#use rs232(baud=9600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8)

