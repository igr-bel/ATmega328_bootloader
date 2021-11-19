#include "crc16_ccitt.h"

/**
 * @brief Get CRC16
 * 
 * CRC-16/CCITT-FALSE
 * Poly  : 0x1021
 * Init  : 0xFFFF
 * Revert: false
 * XorOut: 0x0000
 * Check : 0x29B1 ("123456789")
 *  
 * @param data Processed data pionter.
 * @param len Length of data in bytes.
 * @return unsigned int CRC16.
 */
unsigned int getCRC16_CCITT(unsigned char *p_data, unsigned char len)
{
    unsigned int crc;
    unsigned char index;

    crc = CCIT_INIT;

    while (len--)
    {

        crc ^= (unsigned int)*p_data++ << 8;

        for (index = 0; index < 8; index++)
        {
            crc = crc & 0x8000 ? (crc << 1) ^ POLYNOM_CCITT : crc << 1;
        }
    }//while

    return crc;
}