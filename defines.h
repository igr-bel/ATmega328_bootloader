#ifndef	_DEFINES_INCLUDED_
#define	_DEFINES_INCLUDED_	
	
#include	<io.h>	

/* definitions for SPM control */		
#define	SPMCR_REG	SPMCSR
#asm
     #define WR_SPMCR_REG_R22 out 0x37,r22
#endasm

#ifndef _MODEL_SMALL_
    #define _MODEL_SMALL_
#endif

/* definitions for device recognition */		
#define	PARTCODE	        0x44

#define	_ATMEGA328              // device select: _ATMEGAxxxx
#define	_B2048                  // boot size select: _Bxxxx (words), powers of two only

#define	PAGESIZE            128         //in bytes (ATMega328P - page size 64 words)
#define	PAGESIZE_W          64
#define NUM_OF_PAGES        224
#define	APP_END             0x37C0
#define	EEPROM_END          1023
#define UPPER_FLASH_OFFSET  0x1C00
#define PAGE_ADDR_INC       0x40

#define	SIGNATURE_BYTE_2	0x1E
#define	SIGNATURE_BYTE_1	0x95
#define	SIGNATURE_BYTE_0	0x0F

#ifdef _MODEL_SMALL_
    typedef unsigned int ADDR_t; // for ATmega328 16bit word FLASH address is enough
#else
    typedef unsigned long ADDR_t;
#endif

#endif	///_DEFINES_INCLUDED_	