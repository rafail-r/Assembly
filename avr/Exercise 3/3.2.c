/*
 * 3.1.c
 *
 * Created: 22/12/2014 6:05:03 μμ
 *  Author: Rafail
 */ 


#include <avr/io.h>

int main(void)
{
	
	DDRC = 0x00;	// portC: input
	DDRA = 0x07;	// portA: output (3 LSB)
	unsigned char A, B, C, D, E, F0, F1, F2;
	
	while(1)
	{
		A = PINC & 0x01;
		B = (PINC & 0x02)>>1;
		C = (PINC & 0x04)>>2;
		D = (PINC & 0x08)>>3;
		E = (PINC & 0x10)>>4;
		F0 = !((A && B)||(B && C)||(C && D)||(D && E));
		F1 = (A && B & C && D)||((!D) && (!E));
		F2 = F0||F1;
		PORTA = (F2 << 2) + (F1 << 1) + F0;
	}
}