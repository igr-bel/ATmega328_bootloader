
//------------------------------------- INCLUDES ------------------------------
#include "defines.h"
#include "flash.h"
#include "crc16_modbus.h"
#include "crc16_ccitt.h"
#include <stdio.h>

//------------------------------------- DEFINES -------------------------------
// #define DBG

// Baud rate used for communication with the bootloader
#define	BAUD_RATE   115200
// baud rate register value calculation
#define	BRREG_VALUE	(_MCU_CLOCK_FREQUENCY_/(8*BAUD_RATE)-1)

#define DEVICE_ID           '1'

#define TIMER1_OVF_PERIOD   100 // time period between two timer 1 overflows [ms]
#define TIMER1_CLK_DIV      64  // value for timer 1 clock division coeficient
#define TIMER1_CNT_INIT     (65536-(_MCU_CLOCK_FREQUENCY_*TIMER1_OVF_PERIOD)/(TIMER1_CLK_DIV*1000))

#define PKG_WAIT_TIMEOUT            5000

#define DATA_REGISTER_EMPTY         (1<<UDRE0)
#define RX_COMPLETE                 (1<<RXC0)
#define FRAMING_ERROR               (1<<FE0)
#define PARITY_ERROR                (1<<UPE0)
#define DATA_OVERRUN                (1<<DOR0)
#define USART_DATA_READY            rx_counter0!=0

#define true                        1
#define false                       0

// Pakage parser
#define DATA_BUFF_SIZE              150
#define STD_PKG_SIZE                27
#define BIN_PKG_SIZE                143
#define SERVICE_DATA_SIZE           15
#define DATA_START_BYTE             10

//EEPROM ADDRESSES
#define DEV_ID_ADDR                 0x01    //1b
#define FW_VERSION_ADDR             0x02    //1b
#define FW_SIZE_ADDR                0x03    //2b
#define LAST_WR_PAGE_ADDR           0x05    //2b
#define DOWNLOAD_CMPLT_ADDR         0x07    //1b
#define NEW_FW_VERSION_ADDR         0x08    //1b
#define EEPROM_CRC_ADDR             0x09    //2b
#define EEPROM_DATA_SIZE            8       //w/o CRC

//------------------------------------- GLOBAL VARIABLES ----------------------
volatile unsigned int timer_1_delay_cnt;

char lookup[] = {'0','1','2','3','4','5','6','7','8','9',
                 'A','B','C','D','E','F'};

ADDR_t address = 0x00;
unsigned int data_buff[DATA_BUFF_SIZE];
unsigned char eprom_crc_buff[EEPROM_DATA_SIZE];

unsigned int loop_index = 0;
char i, j;
unsigned int page_counter = 0x00;
unsigned int last_pkg_size;
unsigned int new_fw_size;
unsigned int loaded_data_size;

// USART Receiver buffer
#define RX_BUFFER_SIZE0 150
char rx_buffer0[RX_BUFFER_SIZE0];

unsigned char rx_wr_index0 = 0, rx_rd_index0 = 0;
unsigned char rx_counter0 = 0;

unsigned int i_temp_var;
unsigned int j_temp_var;

// This flag is set on USART Receiver buffer overflow
bit rx_buffer_overflow0;

// State machine
enum
{
    IDLE = 0,
    ASK_FW_PKG,
    WAIT_BOOT_EN,
    WAIT_STD_PKG,
    WAIT_BIN_DATA,
    PARSE_START_PKG,
    PARSE_STD_PKG,
    PARSE_BIN_PKG,
    CHECK_NEW_DATA,
    EXE_CMD,
    UPD_EEPROM,
    UPD_DATA_BUFF,
    UPD_FLASH,
    ERASE_UNUSE_PAGES,
    SEND_UPG_STATUS,

    EXIT_BOOT
};

enum
{
    DATA_OK = 0,
    DATA_ERR
};

enum
{
    PKG_NULL = 0,
    PKG_INF,
    PKG_RQS,
    PKG_RQL,
    PKG_UGR,
    PKG_BIN,
    PKG_CMD,
    PKG_FWV,
    PKG_FWL,

    PKG_ERR
};

volatile unsigned char last_pkg_type;

unsigned char current_state;
unsigned char prev_state;

//------------------------------------- FLAGS ---------------------------------
unsigned char fw_version_saved = false;
unsigned char fw_length_saved = false;
unsigned char last_fw_part_flg = false;

//------------------------------------- TIMER INTERRUPT -----------------------
// Timer1 overflow interrupt service routine
// Occurs every 1 ms
interrupt [TIM1_OVF] void timer1_ovf_isr(void)
{
    // Reinitialize Timer1 value
    TCNT1H = TIMER1_CNT_INIT >> 8;
    TCNT1L = TIMER1_CNT_INIT & 0xff;

    // decrement the delay counter
    if (timer_1_delay_cnt) --timer_1_delay_cnt;
}//tim1 isr

//------------------------------------- USART INTERRUPT -----------------------
// USART Receiver interrupt service routine
interrupt [USART_RXC] void usart_rx_isr(void)
{
    char status, data;
    status = UCSR0A;
    data = UDR0;
    if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
    {
        rx_buffer0[rx_wr_index0++] = data;

        if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0 = 0;

        if (++rx_counter0 == RX_BUFFER_SIZE0)
        {
            rx_counter0=0;
            rx_buffer_overflow0=1;
        }
    }
}//usart isr

//------------------------------------- PROTOTYPES ----------------------------
void startup_init(void);
void timer_1_stop();
void timer_1_start(unsigned int time_ms);

char chip_erase(void); 
unsigned int read_prog_mem(ADDR_t addr);
char write_prog_mem(ADDR_t addr, unsigned int data);
char write_page(ADDR_t addr);
char write_eeprom_mem(ADDR_t addr, unsigned char data);
char read_eeprom_mem(ADDR_t addr);
unsigned char BlockLoad(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address);
unsigned char BlockRead(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address);
void return_signature(void);
void exit_bootloader(void);

void new_state(unsigned char new_state);
unsigned char check_save_pkg(unsigned int data_length);
void get_pkg_type(void);
void req_start_byte(unsigned int addr);
void req_data_length(unsigned int length);
void send_upgd_result(unsigned int result);
void update_eeprom_crc(void);

char get_char(void);
void atoh(unsigned char *ascii_ptr, unsigned char *hex_ptr, unsigned int len);
//------------------------------------- MAIN ----------------------------------
void main(void)
{
    startup_init();

    timer_1_start(10000);

    // Global enable interrupts
    #asm("sei")

    // go to wait boot enable
    new_state(WAIT_BOOT_EN);

    //--------------------------------- BOOT MODE -----------------------------
    // main loop
    #ifdef DBG
        putchar('\n');
        putchar('#');
        putchar('>');
        putchar('\n');
    #endif

    while (1)
    {
        #asm("wdr")

        //----------------------------- STATE MACHINE -------------------------
        switch (current_state)
        {
            case WAIT_BOOT_EN:
                //check EEPROM correct data
                for(loop_index = 1; loop_index < EEPROM_DATA_SIZE+1; loop_index++)
                {
                    eprom_crc_buff[loop_index] = read_eeprom_mem(loop_index);
                }
                i_temp_var = 0x0000;
                i_temp_var = read_eeprom_mem(EEPROM_CRC_ADDR+1);
                i_temp_var <<= 8;
                i_temp_var = read_eeprom_mem(EEPROM_CRC_ADDR);
                if(i_temp_var == getCRC16_CCITT(&eprom_crc_buff[1], EEPROM_DATA_SIZE))
                {
                    write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0x0000);

                    // Last update session not coplete
                    loaded_data_size = 0x0000;
                    loaded_data_size = read_eeprom_mem(LAST_WR_PAGE_ADDR+1);
                    loaded_data_size <<= 8;
                    loaded_data_size |= read_eeprom_mem(LAST_WR_PAGE_ADDR);
                    if(loaded_data_size != 0xFFFF)
                    {
                        timer_1_stop();
                        page_counter = loaded_data_size / PAGESIZE;
                        new_state(ASK_FW_PKG);
                        break;
                    }//if
                }

                while (timer_1_delay_cnt)
                {
                    #asm("wdr")
            
                    if (rx_counter0 == STD_PKG_SIZE)
                    {
                        if(check_save_pkg(STD_PKG_SIZE) == DATA_OK)
                        {
                            get_pkg_type();
                            if((last_pkg_type == PKG_FWV) || (last_pkg_type == PKG_FWL))
                            {
                                new_state(PARSE_START_PKG);
                                break;
                            } 
                        }
                    }
                }//while(timer delay)
                timer_1_stop();

                if(timer_1_delay_cnt == 0)
                {
                    exit_bootloader();
                }
                break;

            case WAIT_STD_PKG:
                if(timer_1_delay_cnt == 0)
                {
                    exit_bootloader();
                }

                if (rx_counter0 == STD_PKG_SIZE)
                {
                    if(check_save_pkg(STD_PKG_SIZE) == DATA_OK)
                    {
                        get_pkg_type();
                    }
                }

                switch (last_pkg_type)
                {
                    case PKG_FWV:
                    case PKG_FWL:
                        timer_1_stop();
                        new_state(PARSE_START_PKG);
                        break;
                    
                    default:
                        break;
                }//switch
                break;

            case PARSE_START_PKG:
                if ( last_pkg_type == PKG_FWV ) 
                {
                    atoh( ((unsigned char *)data_buff)+DATA_START_BYTE, (unsigned char *)&i_temp_var, 4 );
                    write_eeprom_mem(NEW_FW_VERSION_ADDR, (unsigned char)(i_temp_var>>8));
                    fw_version_saved = true;
                    last_pkg_type = PKG_NULL;
                    new_state(WAIT_STD_PKG);
                    timer_1_start(PKG_WAIT_TIMEOUT);
                }

                if( last_pkg_type == PKG_FWL )
                {
                    atoh( ((unsigned char *)data_buff)+DATA_START_BYTE, (unsigned char *)&i_temp_var, 4 );
                    write_eeprom_mem(FW_SIZE_ADDR, (unsigned char)(i_temp_var>>8));
                    write_eeprom_mem(FW_SIZE_ADDR+1, (unsigned char)i_temp_var);
                    new_fw_size = 0x0000;
                    new_fw_size = read_eeprom_mem(FW_SIZE_ADDR+1);
                    new_fw_size <<= 8;
                    new_fw_size |= read_eeprom_mem(FW_SIZE_ADDR);
                    fw_length_saved = true;
                    last_pkg_type = PKG_NULL;
                    new_state(WAIT_STD_PKG);
                    timer_1_start(PKG_WAIT_TIMEOUT);
                }

                // All startup data is recieved. Clear FW counter. Start download FW.
                if ( fw_version_saved && fw_length_saved )
                {
                    write_eeprom_mem(LAST_WR_PAGE_ADDR, 0x00);
                    write_eeprom_mem(LAST_WR_PAGE_ADDR+1, 0x00);
                    write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0xFF);
                    page_counter = 0;

                    new_state(ASK_FW_PKG);
                }

                break;

            case ASK_FW_PKG:
                // Request BIN data next from last writed page
                loaded_data_size = 0x0000;
                loaded_data_size = read_eeprom_mem(LAST_WR_PAGE_ADDR+1);
                loaded_data_size <<= 8;
                loaded_data_size |= read_eeprom_mem(LAST_WR_PAGE_ADDR);

                req_start_byte(loaded_data_size);

                new_fw_size = 0x0000;    // full data size
                new_fw_size = read_eeprom_mem(FW_SIZE_ADDR+1);
                new_fw_size <<= 8;
                new_fw_size |= read_eeprom_mem(FW_SIZE_ADDR);

                if( (new_fw_size - loaded_data_size) < PAGESIZE)
                {
                    last_pkg_size = new_fw_size - loaded_data_size;
                    last_fw_part_flg = true;
                }
                else
                {
                    last_pkg_size = PAGESIZE;
                }

                req_data_length(last_pkg_size);

                timer_1_start(PKG_WAIT_TIMEOUT);
                new_state(WAIT_BIN_DATA);
                break;

            case WAIT_BIN_DATA:
                if(timer_1_delay_cnt == 0)
                {
                    exit_bootloader();
                }

                last_pkg_type = PKG_NULL;
                if (rx_counter0 == (last_pkg_size + SERVICE_DATA_SIZE))
                {
                    if(check_save_pkg(last_pkg_size + SERVICE_DATA_SIZE) == DATA_OK)
                    {
                        get_pkg_type();
                    }
                }

                if(last_pkg_type == PKG_BIN)
                {
                    timer_1_stop();
                    last_pkg_type = PKG_NULL;                 
                    new_state(UPD_DATA_BUFF);
                }
                break;

            case UPD_DATA_BUFF:
                address = page_counter * 0x40 + UPPER_FLASH_OFFSET;
                if (last_pkg_size < PAGESIZE)
                {
                    for(loop_index = last_pkg_size; loop_index < PAGESIZE; loop_index++)
                    {
                        ((unsigned char *)data_buff)[loop_index + DATA_START_BYTE] = 0xFF;
                    }
                }
                BlockLoad(PAGESIZE, (unsigned int *)((unsigned char *)(data_buff) + DATA_START_BYTE), 'F', &address);

                last_pkg_size += loaded_data_size;
                write_eeprom_mem(LAST_WR_PAGE_ADDR+1, (unsigned char)(last_pkg_size>>8));
                write_eeprom_mem(LAST_WR_PAGE_ADDR, (unsigned char)last_pkg_size);
                update_eeprom_crc();
                
                page_counter++;

                new_state(ASK_FW_PKG);
                if(last_fw_part_flg || (last_pkg_size == new_fw_size))
                {
                    new_state(UPD_FLASH);
                }
                break;

            case UPD_FLASH:
                for(loop_index = 0; loop_index < page_counter; loop_index++)
                {
                    address = loop_index * 0x40 + UPPER_FLASH_OFFSET;
                    BlockRead(PAGESIZE, data_buff, 'F', &address);
                    address -= UPPER_FLASH_OFFSET;
                    BlockLoad(PAGESIZE, data_buff, 'F', &address);
                }
                // Update FW version in EEPROM
                write_eeprom_mem(FW_VERSION_ADDR, read_eeprom_mem(NEW_FW_VERSION_ADDR));
                // Set "update successful" flag in EEPROM
                write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0x01);
                // Reset loaded data counter in EEPROM
                write_eeprom_mem(LAST_WR_PAGE_ADDR, 0xFF);
                write_eeprom_mem(LAST_WR_PAGE_ADDR+1, 0xFF);
                // Send update result to host
                send_upgd_result((unsigned int)read_eeprom_mem(DOWNLOAD_CMPLT_ADDR));

                new_state(ERASE_UNUSE_PAGES);
                break;

            case ERASE_UNUSE_PAGES:
                for(loop_index = page_counter; loop_index < NUM_OF_PAGES; loop_index++)
                {
                    _WAIT_FOR_SPM();
                    address = (loop_index * 0x40) << 1;
                    _PAGE_ERASE(address);
                }
                
                new_state(EXIT_BOOT);
                break;

            case EXIT_BOOT:
                exit_bootloader();
                break;
            
            case IDLE:
            default:
                break;
        }//switch (state machine)

    }//while(1)
}//main()

//------------------------------------- FUNCTIONS -----------------------------
/**
 * @brief Hardware initialisation.
 * 
 * USART 115200
 * TC1 - timer period 100 ms, in ISR decrement startup_delay_cnt.
 * WDT period 8 sec.
 * 
 */
void startup_init(void)
{
    // USART initialization
    // Communication Parameters: 8 Data, 1 Stop, No Parity
    // USART Receiver: On
    // USART Transmitter: On
    // USART0 Mode: Asynchronous
    // USART Baud Rate: 115200
    UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (0<<U2X0) | (0<<MPCM0);
    UCSR0B=(1<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
    UCSR0C=(0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
    UBRR0H=0x00;
    UBRR0L=0x03;

    // Timer/Counter 1 initialization
    // Clock source: System Clock
    // Clock divisor: 64
    // Mode: Normal top=0xFFFF
    // Timer Period: 100 ms
    // Timer1 Overflow Interrupt: On
    TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (0<<WGM10);
    // TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (1<<CS10);
    // TCNT1H=TIMER1_CNT_INIT >> 8;
    // TCNT1L=TIMER1_CNT_INIT & 0xFF;

    // Timer/Counter 1 Interrupt(s) initialization
    // TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (1<<TOIE1);

    // Watchdog Timer initialization
    // Watchdog Timer Prescaler: OSC/1024k
    // Watchdog timeout action: Reset
    #pragma optsize-
    WDTCSR=(0<<WDIF) | (0<<WDIE) | (1<<WDP3) | (1<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (1<<WDP0);
    WDTCSR=(0<<WDIF) | (0<<WDIE) | (1<<WDP3) | (0<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (1<<WDP0);
    #ifdef _OPTIMIZE_SIZE_
    #pragma optsize+
    #endif
}//startup_ini()
//-----------------------------------------------------------------------------
/**
 * @brief TC1 stop, turn off before out from boot section.
 * 
 */
void timer_1_stop()
{
    TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (0<<CS11) | (0<<CS10);
    TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (0<<TOIE1);
}//timer_1_stop()
//-----------------------------------------------------------------------------
/**
 * @brief Load delay conter and start timer 1.
 * 
 * @param time_ms - Timer delay in ms (counts only in hundreds ms).
 */
void timer_1_start(unsigned int time_ms)
{
    timer_1_delay_cnt = time_ms / 100; //convert to timer 1 overflow periods

    TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (1<<CS10);
    TCNT1H=TIMER1_CNT_INIT >> 8;
    TCNT1L=TIMER1_CNT_INIT & 0xFF;

    TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (1<<TOIE1);  
}//timer_1_start()
//-----------------------------------------------------------------------------
/**
 * @brief Write data buffer in FLASH or EEPROM memory.
 * 
 * For flash: load data buffer in temp area and write page from address. 
 * 
 * For eeprom: write num of size data (in bytes) in eeprom from address.
 * 
 * 
 * @param size sizo of writing data (in bytes).
 * @param p_data_buff pointer to data buffer.
 * @param mem_type type of writing memory.
 * @param address start memory address. For EEPROM in bytes. For FLASH in words.
 * @return unsigned char. [error code]
 */
unsigned char BlockLoad(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address)
{
    ADDR_t temp_addr;
    ADDR_t inc_addr;
    unsigned int index = 0;
    unsigned int data_size;

//vvv============== FOR REDUCE PROG SIZE        
    // EEPROM memory type.
    // if(mem_type == 'E')
    // {
    //     temp_addr = *address;
    //     data_size = size;
    //     if((temp_addr + data_size) > EEPROM_END) // Check enough EEPROM memory 
    //     {
    //         return 1;
    //     }
    //     // Then program the EEPROM 
    //     for(index = 0; index < size; index++)
    //     {
    //         _WAIT_FOR_SPM();
    //         *((eeprom unsigned char *) temp_addr++) = ((unsigned char *) p_data_buff)[index]; // Write byte.
    //     }

    //     return 0;
    // }//EEPROM
//^^^============== FOR REDUCE PROG SIZE

    // Flash memory type.
    if(mem_type == 'F')
    { // NOTE: For flash programming, 'address' is given in words.
        temp_addr = *address << 1; //Convert word-address to byte-address
        inc_addr = *address << 1; //Convert word-address to byte-address
        _PAGE_ERASE(temp_addr);
        data_size = size >> 1; //Convert to words
        
        for(index = 0; index < data_size; index++)
        {
            _WAIT_FOR_SPM();
            _FILL_TEMP_WORD(inc_addr, ((unsigned int *) p_data_buff)[index]);
            inc_addr += 2;
        }// Loop until all words written.

        _PAGE_WRITE(temp_addr);
        _WAIT_FOR_SPM();
        _ENABLE_RWW_SECTION();

        return 0;
    }//FLASH

    return 0;
}//BlockLoad()
//-----------------------------------------------------------------------------
/**
 * @brief Read block data from EEPROM or FLASH.
 * 
 * For flash: load size data from (address) to buffer. 
 * 
 * For eeprom: read num of size eeprom data (in bytes) from address.
 * 
 * @param size size of reading data (in bytes).
 * @param p_data_buff pointer to data buffer.
 * @param mem_type type of reading memory. 'E' - EEPROM. 'F' - FLASH.
 * @param address start memory address. For EEPROM in bytes. For FLASH in words.
 * @return unsigned char. [TODO: error code]
 */
unsigned char BlockRead(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address)
{
    ADDR_t temp_addr = *address;
    unsigned int index = 0;
    unsigned int data_size;

//vvv============== FOR REDUCE PROG SIZE
    // EEPROM memory type.
    // if(mem_type == 'E')
    // {
    //     data_size = size;
    //     for(index = 0; index < data_size; index++)
    //     {
    //         _WAIT_FOR_SPM();
    //         ((unsigned char *) p_data_buff)[index] = (*((eeprom unsigned char *) temp_addr++));
    //     }

    //     return 0;
    // }//EEPROM
//^^^============== FOR REDUCE PROG SIZE

    // Flash memory type.
    if(mem_type == 'F')
    {
        temp_addr <<= 1; // Convert address to bytes.
        data_size = size;
        for(index = 0; index < data_size; index += 2)
        {
            _WAIT_FOR_SPM();
            _ENABLE_RWW_SECTION();
            ((unsigned char *) p_data_buff)[index] = _LOAD_PROGRAM_MEMORY(temp_addr);
            ((unsigned char *) p_data_buff)[index + 1] = _LOAD_PROGRAM_MEMORY(temp_addr + 1);
            temp_addr += 2;
        }

        return 0;
    }//FLASH
    return 1; //invalid memory type
}//BlockRead()
//-----------------------------------------------------------------------------
/**
 * @brief Erase chip before write new data.
 * 
 * @return char. [TODO: error code]
 */
char chip_erase(void)
{
    for(address = 0; address < APP_END; address += PAGESIZE)
    { // NOTE: Here we use address as a byte-address, not word-address, for convenience.
        _WAIT_FOR_SPM();
        _PAGE_ERASE( address );
    }

    return 0;
}//chip_erase()
//-----------------------------------------------------------------------------
/**
 * @brief Read one word from FLASH.
 * 
 * @param addr data address in words.
 * @return unsigned int.
*/
unsigned int read_prog_mem(ADDR_t addr)
{
    unsigned int temp_data = 0x0000;
    ADDR_t temp_addr;

    temp_addr = addr;

    _WAIT_FOR_SPM();
    _ENABLE_RWW_SECTION();
    ((unsigned char *) &temp_data)[1] = _LOAD_PROGRAM_MEMORY((temp_addr << 1) + 1 );
    ((unsigned char *) &temp_data)[0] = _LOAD_PROGRAM_MEMORY((temp_addr << 1) + 0 );

    return temp_data;
}//read_prog_mem()
//-----------------------------------------------------------------------------
/**
 * @brief Load one word of data to temp buffer before write to flash page.
 * 
 * @param addr Address of data in words.
 * @param data Word of data for load.
 * @return char [TODO: error code]
 */
char write_prog_mem(ADDR_t addr, unsigned int data)
{
    ADDR_t temp_addr;
    unsigned int temp_data;

    temp_addr = addr << 1; //Convert word-address to byte-address
    temp_data = data;

    _WAIT_FOR_SPM();
    _FILL_TEMP_WORD(temp_addr, temp_data);

    return 0;
}//write_prog_mem()
//-----------------------------------------------------------------------------
/**
 * @brief Write data from temp buffer to flash page. 
 * 
 * Call after load data via function write_prog_mem().
 * 
 * @param addr address of page in words.
 * @return char [TODO: error code]
 */
char write_page(ADDR_t addr)
{
    ADDR_t temp_addr;

    temp_addr = addr << 1 ; // Convert word-address to byte-address

    if( temp_addr >= (APP_END>>1) ) // Protect bootloader area.
    {
        return 1;
    }
    else
    {
        _WAIT_FOR_SPM();
        _PAGE_WRITE( temp_addr );
    }

    return 0;
}//write_page()
//-----------------------------------------------------------------------------
/**
 * @brief Write one byte of data to EEPROM.
 * 
 * @param addr Address of byte in EEPROM.
 * @param data Byte of data to be written.
 * @return char [TODO: error code]
 */
char write_eeprom_mem(ADDR_t addr, unsigned char data)
{
    _WAIT_FOR_SPM();
    *((eeprom unsigned char *) addr) = data;
    
    // Wait for completion of write
    while(EECR & (1<<EEPE));

    return 0;
}//write_eeprom_mem()
//-----------------------------------------------------------------------------
/**
 * @brief Read byte of data from EEPROM.
 * 
 * @param addr address of data in bytes.
 * @return char byte of read data.
 */
char read_eeprom_mem(ADDR_t addr)
{
    char read_data;
    
    read_data = (*((eeprom unsigned char *) addr));

    return read_data;
}//read_eeprom_mem()
//-----------------------------------------------------------------------------
/**
 * @brief Exit boot loader mode. 
 * 
 * Switch to execute the application (jmp to 0x00 address).
 * 
 */
void exit_bootloader(void)
{
    timer_1_stop();

    _WAIT_FOR_SPM();
    _ENABLE_RWW_SECTION();

    // Jump to Reset vector 0x0000 in Application Section.
    // disable interrupts
    #asm("cli")

    #pragma optsize-
    // will use the interrupt vectors from the application section
    MCUCR=(1<<IVCE);
    MCUCR=(0<<IVSEL) | (0<<IVCE);
    #ifdef _OPTIMIZE_SIZE_
        #pragma optsize+
    #endif

    // start execution from address 0
    #asm("jmp 0")
}//exit_bootloader()
//-----------------------------------------------------------------------------
/**
 * @brief Return signature of chip.
 * 
 * Print to USART 3 bytes of chip signature.
 * 
 */
void return_signature(void)
{						
    putchar( SIGNATURE_BYTE_0 );
    putchar( SIGNATURE_BYTE_1 );
    putchar( SIGNATURE_BYTE_2 );
}//return_signature()
//-----------------------------------------------------------------------------
/**
 * @brief Get the char from ring USART RX-buffer
 * 
 * @return Next data char.
 */
char get_char(void)
{
    char data;

    while (rx_counter0==0);

    data = rx_buffer0[rx_rd_index0++];
    if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0 = 0;

    #asm("cli")
    --rx_counter0;
    #asm("sei")
    return data;
}//get_char()
//-----------------------------------------------------------------------------
/**
 * @brief Change STATE MACHINE state, and save previous state.
 * 
 * @param new_state 
 */
void new_state(unsigned char new_state)
{
    prev_state = current_state;
    current_state = new_state;
}//new_state()
//-----------------------------------------------------------------------------
/**
 * @brief Check and save input data. 
 * 
 * Check CRC, header and ID. Save pkg to data buff.
 * 
 * (Convert CRC ascii to hex.)
 * 
 * @return unsigned char - error code.
 */
unsigned char check_save_pkg(unsigned int data_length)
{
    unsigned char err_code = DATA_ERR;
    unsigned char i;
    unsigned int in_crc;
    unsigned int clc_crc;

    unsigned char crc_ok;
    unsigned char head_ok;
    unsigned char id_ok;

    if(get_char() != 'B')
    {
        return;
    }
    else
    {
        rx_counter0++;
        rx_rd_index0--;
    }

    for(i = 0; i < data_length; i++)
    {
        ((unsigned char *)data_buff)[i] = get_char();
    }

    // Get last 4 bytes of string and convert to 2-bytes hex CRC-16
    atoh( ((unsigned char *)data_buff)+data_length-4, (unsigned char *)&in_crc, 4 );
    // Change HB/LB of input CRC
    in_crc = (in_crc >> 8) | (in_crc << 8);
    // Calculate CRC-16
    clc_crc = getCRC16_CCITT((unsigned char *) data_buff, data_length - 4);
    crc_ok = (in_crc == clc_crc) ? true : false;

    // Check header
    if( ((unsigned char *)data_buff)[0] == 'B' && 
        ((unsigned char *)data_buff)[1] == 'L' && 
        ((unsigned char *)data_buff)[2] == 'D'
        )
        {
            head_ok = true;
        }
    else head_ok = false;

    // Check ID
    id_ok = ( ((unsigned char *)data_buff)[4] == DEVICE_ID ) ? true: false;
    
    err_code = ( crc_ok && head_ok && id_ok ) ? DATA_OK : DATA_ERR;

    #ifdef DBG
        printf("\n[INF] crc-%d, head-%d, id-%d\n", crc_ok, head_ok, id_ok);
    #endif

    return err_code;
}//check_save_pkg()
//-----------------------------------------------------------------------------
/**
 * @brief Convert ASCII string to hex.
 * 
 * @param ascii_ptr Pointer to start ascii string.
 * @param hex_ptr Pointer to result hex value.
 * @param len Length of string in bytes.
 */
void atoh(unsigned char *ascii_ptr, unsigned char *hex_ptr, unsigned int len)
{
    int i;

    for(i = 0; i < (len / 2); i++)
    {
        *(hex_ptr+i)   = (*(ascii_ptr+(2*i)) <= '9') ? ((*(ascii_ptr+(2*i)) - '0') * 16 ) :  (((*(ascii_ptr+(2*i)) - 'A') + 10) << 4);
        *(hex_ptr+i)  |= (*(ascii_ptr+(2*i)+1) <= '9') ? (*(ascii_ptr+(2*i)+1) - '0') :  (*(ascii_ptr+(2*i)+1) - 'A' + 10);
    }
}//atoh()
//-----------------------------------------------------------------------------
/**
 * @brief Read packege, set the last_pkg_type.
 * 
 */
void get_pkg_type(void)
{
    last_pkg_type = PKG_NULL;

    if( ((unsigned char *)data_buff)[6] == 'F' && 
        ((unsigned char *)data_buff)[7] == 'W' && 
        ((unsigned char *)data_buff)[8] == 'V'
        )
        {
            last_pkg_type = PKG_FWV;
        }

    if( ((unsigned char *)data_buff)[6] == 'F' && 
        ((unsigned char *)data_buff)[7] == 'W' && 
        ((unsigned char *)data_buff)[8] == 'L'
        )
        {
            last_pkg_type = PKG_FWL;
        }
        
    if( ((unsigned char *)data_buff)[6] == 'B' && 
        ((unsigned char *)data_buff)[7] == 'I' && 
        ((unsigned char *)data_buff)[8] == 'N'
        )
        {
            last_pkg_type = PKG_BIN;
        }

//vvv============== FOR REDUCE PROG SIZE
    // if( ((unsigned char *)data_buff)[6] == 'C' && 
    //     ((unsigned char *)data_buff)[7] == 'M' && 
    //     ((unsigned char *)data_buff)[8] == 'D'
    //     )
    //     {
    //         last_pkg_type = PKG_CMD;
    //     }
//^^^============== FOR REDUCE PROG SIZE

}//get_pkg_Type()
//-----------------------------------------------------------------------------
/**
 * @brief Send request with start address of next FW package.
 * 
 * @param addr - address in bytes.
 */
void req_start_byte(unsigned int addr)
{
    ((unsigned char *)data_buff)[0] = 'B';
    ((unsigned char *)data_buff)[1] = 'L';
    ((unsigned char *)data_buff)[2] = 'D';
    ((unsigned char *)data_buff)[3] = ',';
    ((unsigned char *)data_buff)[4] = DEVICE_ID;
    ((unsigned char *)data_buff)[5] = ',';
    ((unsigned char *)data_buff)[6] = 'R';
    ((unsigned char *)data_buff)[7] = 'Q';
    ((unsigned char *)data_buff)[8] = 'S';
    ((unsigned char *)data_buff)[9] = ',';

    j = 13;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&addr)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&addr)[i] & 0xf0) >> 4];
    }

    ((unsigned char *)data_buff)[14] = ',';
    for (loop_index = 15; loop_index < 22; loop_index++)
    {
        ((unsigned char *)data_buff)[loop_index] = 0x30;
    }
    ((unsigned char *)data_buff)[22] = ',';

    i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
    j = 26;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
    }

    //send request strign
    for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
    {
        putchar( ((unsigned char *)data_buff)[loop_index] );
    }
    putchar('\r');
    putchar('\n');
}//req_start_byte()
//-----------------------------------------------------------------------------
/**
 * @brief Send request with length of next FW package.
 * 
 * @param length - length of packege in bytes.
 */
void req_data_length(unsigned int length)
{
    ((unsigned char *)data_buff)[0] = 'B';
    ((unsigned char *)data_buff)[1] = 'L';
    ((unsigned char *)data_buff)[2] = 'D';
    ((unsigned char *)data_buff)[3] = ',';
    ((unsigned char *)data_buff)[4] = DEVICE_ID;
    ((unsigned char *)data_buff)[5] = ',';
    ((unsigned char *)data_buff)[6] = 'R';
    ((unsigned char *)data_buff)[7] = 'Q';
    ((unsigned char *)data_buff)[8] = 'L';
    ((unsigned char *)data_buff)[9] = ',';

    j = 13;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&length)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&length)[i] & 0xf0) >> 4];
    }

    ((unsigned char *)data_buff)[14] = ',';
    for (loop_index = 15; loop_index < 22; loop_index++)
    {
        ((unsigned char *)data_buff)[loop_index] = 0x30;
    }
    ((unsigned char *)data_buff)[22] = ',';

    i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
    j = 26;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
    }

    //send request strign
    for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
    {
        putchar( ((unsigned char *)data_buff)[loop_index] );
    }
    putchar('\r');
    putchar('\n');
}//req_data_length()
//-----------------------------------------------------------------------------
/**
 * @brief Send update flash result.
 * 
 * @param result 
 */
void send_upgd_result(unsigned int result)
{
    ((unsigned char *)data_buff)[0] = 'B';
    ((unsigned char *)data_buff)[1] = 'L';
    ((unsigned char *)data_buff)[2] = 'D';
    ((unsigned char *)data_buff)[3] = ',';
    ((unsigned char *)data_buff)[4] = DEVICE_ID;
    ((unsigned char *)data_buff)[5] = ',';
    ((unsigned char *)data_buff)[6] = 'U';
    ((unsigned char *)data_buff)[7] = 'G';
    ((unsigned char *)data_buff)[8] = 'R';
    ((unsigned char *)data_buff)[9] = ',';

    j = 13;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&result)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&result)[i] & 0xf0) >> 4];
    }

    ((unsigned char *)data_buff)[14] = ',';
    for (loop_index = 15; loop_index < 22; loop_index++)
    {
        ((unsigned char *)data_buff)[loop_index] = 0x30;
    }
    ((unsigned char *)data_buff)[22] = ',';

    i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
    j = 26;
    for (i = 0; i < 2; i++)
    {
        ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
        ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
    }

    //send res strign
    for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
    {
        putchar( ((unsigned char *)data_buff)[loop_index] );
    }
    putchar('\r');
    putchar('\n');
}
//-----------------------------------------------------------------------------
/**
 * @brief Get new EEPROM data? calculate CRC and save.
 * 
 */
void update_eeprom_crc(void)
{
    for(loop_index = 1; loop_index < EEPROM_DATA_SIZE+1; loop_index++)
    {
        eprom_crc_buff[loop_index] = read_eeprom_mem(loop_index);
    }

    i_temp_var = getCRC16_CCITT((unsigned char *)&eprom_crc_buff[1], EEPROM_DATA_SIZE);

    write_eeprom_mem(EEPROM_CRC_ADDR, (unsigned char)i_temp_var);
    write_eeprom_mem(EEPROM_CRC_ADDR+1, (unsigned char)(i_temp_var >> 8));

    return;
}//update_eeprom_crc()
//-----------------------------------------------------------------------------
