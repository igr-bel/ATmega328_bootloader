#ifndef __crc_ccitt_included__
#define __crc_ccitt_included__

#define POLYNOM_CCITT				0x1021
#define CCIT_INIT                   0xFFFF

#define lo8(x) ((x) & 0xff)
#define hi8(x) ((x) >> 8)

unsigned int getCRC16_CCITT(unsigned char *p_data, unsigned char len);

#endif //__crc_ccitt_included__
