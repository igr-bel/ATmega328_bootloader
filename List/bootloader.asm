
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Release
;Chip type              : ATmega328P
;Program type           : Boot Loader
;Clock frequency        : 7,372800 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 512 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': No
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega328P
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2048
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x08FF
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _address=R4
	.DEF _address_msb=R5
	.DEF _loop_index=R6
	.DEF _loop_index_msb=R7
	.DEF _i=R9
	.DEF _j=R8
	.DEF _page_counter=R10
	.DEF _page_counter_msb=R11
	.DEF _last_pkg_size=R12
	.DEF _last_pkg_size_msb=R13

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x3800

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  _timer1_ovf_isr
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  _usart_rx_isr
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800
	JMP  0x3800

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0

_0x3:
	.DB  0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37
	.DB  0x38,0x39,0x41,0x42,0x43,0x44,0x45,0x46

__GLOBAL_INI_TBL:
	.DW  0x08
	.DW  0x04
	.DW  __REG_VARS*2

	.DW  0x10
	.DW  _lookup
	.DW  _0x3*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF THE BOOT LOADER
	LDI  R31,1
	OUT  MCUCR,R31
	LDI  R31,2
	OUT  MCUCR,R31

;DISABLE WATCHDOG
	LDI  R31,0x18
	WDR
	IN   R26,MCUSR
	CBR  R26,8
	OUT  MCUSR,R26
	STS  WDTCSR,R31
	STS  WDTCSR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x300

	.CSEG
;
;//------------------------------------- INCLUDES ------------------------------
;#include "defines.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
     #define WR_SPMCR_REG_R22 out 0x37,r22
;#include "flash.h"
;#include "crc16_modbus.h"
;#include "crc16_ccitt.h"
;#include <stdio.h>
;
;//------------------------------------- DEFINES -------------------------------
;// #define DBG
;
;// Baud rate used for communication with the bootloader
;#define	BAUD_RATE   115200
;// baud rate register value calculation
;#define	BRREG_VALUE	(_MCU_CLOCK_FREQUENCY_/(8*BAUD_RATE)-1)
;
;#define DEVICE_ID           '1'
;
;#define TIMER1_OVF_PERIOD   100 // time period between two timer 1 overflows [ms]
;#define TIMER1_CLK_DIV      64  // value for timer 1 clock division coeficient
;#define TIMER1_CNT_INIT     (65536-(_MCU_CLOCK_FREQUENCY_*TIMER1_OVF_PERIOD)/(TIMER1_CLK_DIV*1000))
;
;#define PKG_WAIT_TIMEOUT            5000
;
;#define DATA_REGISTER_EMPTY         (1<<UDRE0)
;#define RX_COMPLETE                 (1<<RXC0)
;#define FRAMING_ERROR               (1<<FE0)
;#define PARITY_ERROR                (1<<UPE0)
;#define DATA_OVERRUN                (1<<DOR0)
;#define USART_DATA_READY            rx_counter0!=0
;
;#define true                        1
;#define false                       0
;
;// Pakage parser
;#define DATA_BUFF_SIZE              150
;#define STD_PKG_SIZE                27
;#define BIN_PKG_SIZE                143
;#define SERVICE_DATA_SIZE           15
;#define DATA_START_BYTE             10
;
;//EEPROM ADDRESSES
;#define DEV_ID_ADDR                 0x01    //1b
;#define FW_VERSION_ADDR             0x02    //1b
;#define FW_SIZE_ADDR                0x03    //2b
;#define LAST_WR_PAGE_ADDR           0x05    //2b
;#define DOWNLOAD_CMPLT_ADDR         0x07    //1b
;#define NEW_FW_VERSION_ADDR         0x08    //1b
;#define EEPROM_CRC_ADDR             0x09    //2b
;#define EEPROM_DATA_SIZE            8       //w/o CRC
;
;//------------------------------------- GLOBAL VARIABLES ----------------------
;volatile unsigned int timer_1_delay_cnt;
;
;char lookup[] = {'0','1','2','3','4','5','6','7','8','9',
;                 'A','B','C','D','E','F'};

	.DSEG
;
;ADDR_t address = 0x00;
;unsigned int data_buff[DATA_BUFF_SIZE];
;unsigned char eprom_crc_buff[EEPROM_DATA_SIZE];
;
;unsigned int loop_index = 0;
;char i, j;
;unsigned int page_counter = 0x00;
;unsigned int last_pkg_size;
;unsigned int new_fw_size;
;unsigned int loaded_data_size;
;
;// USART Receiver buffer
;#define RX_BUFFER_SIZE0 150
;char rx_buffer0[RX_BUFFER_SIZE0];
;
;unsigned char rx_wr_index0 = 0, rx_rd_index0 = 0;
;unsigned char rx_counter0 = 0;
;
;unsigned int i_temp_var;
;unsigned int j_temp_var;
;
;// This flag is set on USART Receiver buffer overflow
;bit rx_buffer_overflow0;
;
;// State machine
;enum
;{
;    IDLE = 0,
;    ASK_FW_PKG,
;    WAIT_BOOT_EN,
;    WAIT_STD_PKG,
;    WAIT_BIN_DATA,
;    PARSE_START_PKG,
;    PARSE_STD_PKG,
;    PARSE_BIN_PKG,
;    CHECK_NEW_DATA,
;    EXE_CMD,
;    UPD_EEPROM,
;    UPD_DATA_BUFF,
;    UPD_FLASH,
;    ERASE_UNUSE_PAGES,
;    SEND_UPG_STATUS,
;
;    EXIT_BOOT
;};
;
;enum
;{
;    DATA_OK = 0,
;    DATA_ERR
;};
;
;enum
;{
;    PKG_NULL = 0,
;    PKG_INF,
;    PKG_RQS,
;    PKG_RQL,
;    PKG_UGR,
;    PKG_BIN,
;    PKG_CMD,
;    PKG_FWV,
;    PKG_FWL,
;
;    PKG_ERR
;};
;
;volatile unsigned char last_pkg_type;
;
;unsigned char current_state;
;unsigned char prev_state;
;
;//------------------------------------- FLAGS ---------------------------------
;unsigned char fw_version_saved = false;
;unsigned char fw_length_saved = false;
;unsigned char last_fw_part_flg = false;
;
;//------------------------------------- TIMER INTERRUPT -----------------------
;// Timer1 overflow interrupt service routine
;// Occurs every 1 ms
;interrupt [TIM1_OVF] void timer1_ovf_isr(void)
; 0000 008B {

	.CSEG
_timer1_ovf_isr:
; .FSTART _timer1_ovf_isr
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 008C     // Reinitialize Timer1 value
; 0000 008D     TCNT1H = TIMER1_CNT_INIT >> 8;
	CALL SUBOPT_0x0
; 0000 008E     TCNT1L = TIMER1_CNT_INIT & 0xff;
; 0000 008F 
; 0000 0090     // decrement the delay counter
; 0000 0091     if (timer_1_delay_cnt) --timer_1_delay_cnt;
	CALL SUBOPT_0x1
	BREQ _0x4
	LDI  R26,LOW(_timer_1_delay_cnt)
	LDI  R27,HIGH(_timer_1_delay_cnt)
	LD   R30,X+
	LD   R31,X+
	SBIW R30,1
	ST   -X,R31
	ST   -X,R30
; 0000 0092 }//tim1 isr
_0x4:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;//------------------------------------- USART INTERRUPT -----------------------
;// USART Receiver interrupt service routine
;interrupt [USART_RXC] void usart_rx_isr(void)
; 0000 0097 {
_usart_rx_isr:
; .FSTART _usart_rx_isr
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0098     char status, data;
; 0000 0099     status = UCSR0A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	LDS  R17,192
; 0000 009A     data = UDR0;
	LDS  R16,198
; 0000 009B     if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x5
; 0000 009C     {
; 0000 009D         rx_buffer0[rx_wr_index0++] = data;
	LDS  R30,_rx_wr_index0
	SUBI R30,-LOW(1)
	STS  _rx_wr_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R16
; 0000 009E 
; 0000 009F         if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0 = 0;
	LDS  R26,_rx_wr_index0
	CPI  R26,LOW(0x96)
	BRNE _0x6
	LDI  R30,LOW(0)
	STS  _rx_wr_index0,R30
; 0000 00A0 
; 0000 00A1         if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x6:
	LDS  R26,_rx_counter0
	SUBI R26,-LOW(1)
	STS  _rx_counter0,R26
	CPI  R26,LOW(0x96)
	BRNE _0x7
; 0000 00A2         {
; 0000 00A3             rx_counter0=0;
	LDI  R30,LOW(0)
	STS  _rx_counter0,R30
; 0000 00A4             rx_buffer_overflow0=1;
	SBI  0x1E,0
; 0000 00A5         }
; 0000 00A6     }
_0x7:
; 0000 00A7 }//usart isr
_0x5:
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
; .FEND
;
;//------------------------------------- PROTOTYPES ----------------------------
;void startup_init(void);
;void timer_1_stop();
;void timer_1_start(unsigned int time_ms);
;
;char chip_erase(void);
;unsigned int read_prog_mem(ADDR_t addr);
;char write_prog_mem(ADDR_t addr, unsigned int data);
;char write_page(ADDR_t addr);
;char write_eeprom_mem(ADDR_t addr, unsigned char data);
;char read_eeprom_mem(ADDR_t addr);
;unsigned char BlockLoad(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address);
;unsigned char BlockRead(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address);
;void return_signature(void);
;void exit_bootloader(void);
;
;void new_state(unsigned char new_state);
;unsigned char check_save_pkg(unsigned int data_length);
;void get_pkg_type(void);
;void req_start_byte(unsigned int addr);
;void req_data_length(unsigned int length);
;void send_upgd_result(unsigned int result);
;void update_eeprom_crc(void);
;
;char get_char(void);
;void atoh(unsigned char *ascii_ptr, unsigned char *hex_ptr, unsigned int len);
;//------------------------------------- MAIN ----------------------------------
;void main(void)
; 0000 00C5 {
_main:
; .FSTART _main
; 0000 00C6     startup_init();
	RCALL _startup_init
; 0000 00C7 
; 0000 00C8     timer_1_start(10000);
	LDI  R26,LOW(10000)
	LDI  R27,HIGH(10000)
	RCALL _timer_1_start
; 0000 00C9 
; 0000 00CA     // Global enable interrupts
; 0000 00CB     #asm("sei")
	sei
; 0000 00CC 
; 0000 00CD     // go to wait boot enable
; 0000 00CE     new_state(WAIT_BOOT_EN);
	LDI  R26,LOW(2)
	RCALL _new_state
; 0000 00CF 
; 0000 00D0     //--------------------------------- BOOT MODE -----------------------------
; 0000 00D1     // main loop
; 0000 00D2     #ifdef DBG
; 0000 00D3         putchar('\n');
; 0000 00D4         putchar('#');
; 0000 00D5         putchar('>');
; 0000 00D6         putchar('\n');
; 0000 00D7     #endif
; 0000 00D8 
; 0000 00D9     while (1)
_0xA:
; 0000 00DA     {
; 0000 00DB         #asm("wdr")
	wdr
; 0000 00DC 
; 0000 00DD         //----------------------------- STATE MACHINE -------------------------
; 0000 00DE         switch (current_state)
	LDS  R30,_current_state
; 0000 00DF         {
; 0000 00E0             case WAIT_BOOT_EN:
	CPI  R30,LOW(0x2)
	BREQ PC+2
	RJMP _0x10
; 0000 00E1                 //check EEPROM correct data
; 0000 00E2                 for(loop_index = 1; loop_index < EEPROM_DATA_SIZE+1; loop_index++)
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	MOVW R6,R30
_0x12:
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CP   R6,R30
	CPC  R7,R31
	BRSH _0x13
; 0000 00E3                 {
; 0000 00E4                     eprom_crc_buff[loop_index] = read_eeprom_mem(loop_index);
	MOVW R30,R6
	SUBI R30,LOW(-_eprom_crc_buff)
	SBCI R31,HIGH(-_eprom_crc_buff)
	PUSH R31
	PUSH R30
	MOVW R26,R6
	RCALL _read_eeprom_mem
	POP  R26
	POP  R27
	ST   X,R30
; 0000 00E5                 }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0x12
_0x13:
; 0000 00E6                 i_temp_var = 0x0000;
	LDI  R30,LOW(0)
	STS  _i_temp_var,R30
	STS  _i_temp_var+1,R30
; 0000 00E7                 i_temp_var = read_eeprom_mem(EEPROM_CRC_ADDR+1);
	LDI  R26,LOW(10)
	CALL SUBOPT_0x2
; 0000 00E8                 i_temp_var <<= 8;
	LDS  R31,_i_temp_var
	LDI  R30,LOW(0)
	CALL SUBOPT_0x3
; 0000 00E9                 i_temp_var = read_eeprom_mem(EEPROM_CRC_ADDR);
	LDI  R26,LOW(9)
	CALL SUBOPT_0x2
; 0000 00EA                 if(i_temp_var == getCRC16_CCITT(&eprom_crc_buff[1], EEPROM_DATA_SIZE))
	CALL SUBOPT_0x4
	LDS  R26,_i_temp_var
	LDS  R27,_i_temp_var+1
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x14
; 0000 00EB                 {
; 0000 00EC                     write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0x0000);
	CALL SUBOPT_0x5
	LDI  R26,LOW(0)
	RCALL _write_eeprom_mem
; 0000 00ED 
; 0000 00EE                     // Last update session not coplete
; 0000 00EF                     loaded_data_size = 0x0000;
	CALL SUBOPT_0x6
; 0000 00F0                     loaded_data_size = read_eeprom_mem(LAST_WR_PAGE_ADDR+1);
; 0000 00F1                     loaded_data_size <<= 8;
; 0000 00F2                     loaded_data_size |= read_eeprom_mem(LAST_WR_PAGE_ADDR);
; 0000 00F3                     if(loaded_data_size != 0xFFFF)
	CPI  R26,LOW(0xFFFF)
	LDI  R30,HIGH(0xFFFF)
	CPC  R27,R30
	BREQ _0x15
; 0000 00F4                     {
; 0000 00F5                         timer_1_stop();
	RCALL _timer_1_stop
; 0000 00F6                         page_counter = loaded_data_size / PAGESIZE;
	CALL SUBOPT_0x7
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CALL __DIVW21U
	MOVW R10,R30
; 0000 00F7                         new_state(ASK_FW_PKG);
	LDI  R26,LOW(1)
	RCALL _new_state
; 0000 00F8                         break;
	RJMP _0xF
; 0000 00F9                     }//if
; 0000 00FA                 }
_0x15:
; 0000 00FB 
; 0000 00FC                 while (timer_1_delay_cnt)
_0x14:
_0x16:
	CALL SUBOPT_0x1
	BREQ _0x18
; 0000 00FD                 {
; 0000 00FE                     #asm("wdr")
	wdr
; 0000 00FF 
; 0000 0100                     if (rx_counter0 == STD_PKG_SIZE)
	LDS  R26,_rx_counter0
	CPI  R26,LOW(0x1B)
	BRNE _0x19
; 0000 0101                     {
; 0000 0102                         if(check_save_pkg(STD_PKG_SIZE) == DATA_OK)
	LDI  R26,LOW(27)
	LDI  R27,0
	RCALL _check_save_pkg
	CPI  R30,0
	BRNE _0x1A
; 0000 0103                         {
; 0000 0104                             get_pkg_type();
	RCALL _get_pkg_type
; 0000 0105                             if((last_pkg_type == PKG_FWV) || (last_pkg_type == PKG_FWL))
	LDS  R26,_last_pkg_type
	CPI  R26,LOW(0x7)
	BREQ _0x1C
	LDS  R26,_last_pkg_type
	CPI  R26,LOW(0x8)
	BRNE _0x1B
_0x1C:
; 0000 0106                             {
; 0000 0107                                 new_state(PARSE_START_PKG);
	LDI  R26,LOW(5)
	RCALL _new_state
; 0000 0108                                 break;
	RJMP _0x18
; 0000 0109                             }
; 0000 010A                         }
_0x1B:
; 0000 010B                     }
_0x1A:
; 0000 010C                 }//while(timer delay)
_0x19:
	RJMP _0x16
_0x18:
; 0000 010D                 timer_1_stop();
	RCALL _timer_1_stop
; 0000 010E 
; 0000 010F                 if(timer_1_delay_cnt == 0)
	CALL SUBOPT_0x1
	BRNE _0x1E
; 0000 0110                 {
; 0000 0111                     exit_bootloader();
	RCALL _exit_bootloader
; 0000 0112                 }
; 0000 0113                 break;
_0x1E:
	RJMP _0xF
; 0000 0114 
; 0000 0115             case WAIT_STD_PKG:
_0x10:
	CPI  R30,LOW(0x3)
	BRNE _0x1F
; 0000 0116                 if(timer_1_delay_cnt == 0)
	CALL SUBOPT_0x1
	BRNE _0x20
; 0000 0117                 {
; 0000 0118                     exit_bootloader();
	RCALL _exit_bootloader
; 0000 0119                 }
; 0000 011A 
; 0000 011B                 if (rx_counter0 == STD_PKG_SIZE)
_0x20:
	LDS  R26,_rx_counter0
	CPI  R26,LOW(0x1B)
	BRNE _0x21
; 0000 011C                 {
; 0000 011D                     if(check_save_pkg(STD_PKG_SIZE) == DATA_OK)
	LDI  R26,LOW(27)
	LDI  R27,0
	RCALL _check_save_pkg
	CPI  R30,0
	BRNE _0x22
; 0000 011E                     {
; 0000 011F                         get_pkg_type();
	RCALL _get_pkg_type
; 0000 0120                     }
; 0000 0121                 }
_0x22:
; 0000 0122 
; 0000 0123                 switch (last_pkg_type)
_0x21:
	LDS  R30,_last_pkg_type
; 0000 0124                 {
; 0000 0125                     case PKG_FWV:
	CPI  R30,LOW(0x7)
	BREQ _0x27
; 0000 0126                     case PKG_FWL:
	CPI  R30,LOW(0x8)
	BRNE _0x29
_0x27:
; 0000 0127                         timer_1_stop();
	RCALL _timer_1_stop
; 0000 0128                         new_state(PARSE_START_PKG);
	LDI  R26,LOW(5)
	RCALL _new_state
; 0000 0129                         break;
; 0000 012A 
; 0000 012B                     default:
_0x29:
; 0000 012C                         break;
; 0000 012D                 }//switch
; 0000 012E                 break;
	RJMP _0xF
; 0000 012F 
; 0000 0130             case PARSE_START_PKG:
_0x1F:
	CPI  R30,LOW(0x5)
	BRNE _0x2A
; 0000 0131                 if ( last_pkg_type == PKG_FWV )
	LDS  R26,_last_pkg_type
	CPI  R26,LOW(0x7)
	BRNE _0x2B
; 0000 0132                 {
; 0000 0133                     atoh( ((unsigned char *)data_buff)+DATA_START_BYTE, (unsigned char *)&i_temp_var, 4 );
	CALL SUBOPT_0x8
; 0000 0134                     write_eeprom_mem(NEW_FW_VERSION_ADDR, (unsigned char)(i_temp_var>>8));
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CALL SUBOPT_0x9
; 0000 0135                     fw_version_saved = true;
	LDI  R30,LOW(1)
	STS  _fw_version_saved,R30
; 0000 0136                     last_pkg_type = PKG_NULL;
	CALL SUBOPT_0xA
; 0000 0137                     new_state(WAIT_STD_PKG);
; 0000 0138                     timer_1_start(PKG_WAIT_TIMEOUT);
; 0000 0139                 }
; 0000 013A 
; 0000 013B                 if( last_pkg_type == PKG_FWL )
_0x2B:
	LDS  R26,_last_pkg_type
	CPI  R26,LOW(0x8)
	BRNE _0x2C
; 0000 013C                 {
; 0000 013D                     atoh( ((unsigned char *)data_buff)+DATA_START_BYTE, (unsigned char *)&i_temp_var, 4 );
	CALL SUBOPT_0x8
; 0000 013E                     write_eeprom_mem(FW_SIZE_ADDR, (unsigned char)(i_temp_var>>8));
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x9
; 0000 013F                     write_eeprom_mem(FW_SIZE_ADDR+1, (unsigned char)i_temp_var);
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	CALL SUBOPT_0xB
; 0000 0140                     new_fw_size = 0x0000;
	CALL SUBOPT_0xC
; 0000 0141                     new_fw_size = read_eeprom_mem(FW_SIZE_ADDR+1);
; 0000 0142                     new_fw_size <<= 8;
; 0000 0143                     new_fw_size |= read_eeprom_mem(FW_SIZE_ADDR);
; 0000 0144                     fw_length_saved = true;
	LDI  R30,LOW(1)
	STS  _fw_length_saved,R30
; 0000 0145                     last_pkg_type = PKG_NULL;
	CALL SUBOPT_0xA
; 0000 0146                     new_state(WAIT_STD_PKG);
; 0000 0147                     timer_1_start(PKG_WAIT_TIMEOUT);
; 0000 0148                 }
; 0000 0149 
; 0000 014A                 // All startup data is recieved. Clear FW counter. Start download FW.
; 0000 014B                 if ( fw_version_saved && fw_length_saved )
_0x2C:
	LDS  R30,_fw_version_saved
	CPI  R30,0
	BREQ _0x2E
	LDS  R30,_fw_length_saved
	CPI  R30,0
	BRNE _0x2F
_0x2E:
	RJMP _0x2D
_0x2F:
; 0000 014C                 {
; 0000 014D                     write_eeprom_mem(LAST_WR_PAGE_ADDR, 0x00);
	CALL SUBOPT_0xD
	LDI  R26,LOW(0)
	CALL SUBOPT_0xE
; 0000 014E                     write_eeprom_mem(LAST_WR_PAGE_ADDR+1, 0x00);
	LDI  R26,LOW(0)
	RCALL _write_eeprom_mem
; 0000 014F                     write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0xFF);
	CALL SUBOPT_0x5
	LDI  R26,LOW(255)
	RCALL _write_eeprom_mem
; 0000 0150                     page_counter = 0;
	CLR  R10
	CLR  R11
; 0000 0151 
; 0000 0152                     new_state(ASK_FW_PKG);
	LDI  R26,LOW(1)
	RCALL _new_state
; 0000 0153                 }
; 0000 0154 
; 0000 0155                 break;
_0x2D:
	RJMP _0xF
; 0000 0156 
; 0000 0157             case ASK_FW_PKG:
_0x2A:
	CPI  R30,LOW(0x1)
	BRNE _0x30
; 0000 0158                 // Request BIN data next from last writed page
; 0000 0159                 loaded_data_size = 0x0000;
	CALL SUBOPT_0x6
; 0000 015A                 loaded_data_size = read_eeprom_mem(LAST_WR_PAGE_ADDR+1);
; 0000 015B                 loaded_data_size <<= 8;
; 0000 015C                 loaded_data_size |= read_eeprom_mem(LAST_WR_PAGE_ADDR);
; 0000 015D 
; 0000 015E                 req_start_byte(loaded_data_size);
	RCALL _req_start_byte
; 0000 015F 
; 0000 0160                 new_fw_size = 0x0000;    // full data size
	CALL SUBOPT_0xC
; 0000 0161                 new_fw_size = read_eeprom_mem(FW_SIZE_ADDR+1);
; 0000 0162                 new_fw_size <<= 8;
; 0000 0163                 new_fw_size |= read_eeprom_mem(FW_SIZE_ADDR);
; 0000 0164 
; 0000 0165                 if( (new_fw_size - loaded_data_size) < PAGESIZE)
	CALL SUBOPT_0xF
	CPI  R30,LOW(0x80)
	LDI  R26,HIGH(0x80)
	CPC  R31,R26
	BRSH _0x31
; 0000 0166                 {
; 0000 0167                     last_pkg_size = new_fw_size - loaded_data_size;
	CALL SUBOPT_0xF
	MOVW R12,R30
; 0000 0168                     last_fw_part_flg = true;
	LDI  R30,LOW(1)
	STS  _last_fw_part_flg,R30
; 0000 0169                 }
; 0000 016A                 else
	RJMP _0x32
_0x31:
; 0000 016B                 {
; 0000 016C                     last_pkg_size = PAGESIZE;
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	MOVW R12,R30
; 0000 016D                 }
_0x32:
; 0000 016E 
; 0000 016F                 req_data_length(last_pkg_size);
	MOVW R26,R12
	RCALL _req_data_length
; 0000 0170 
; 0000 0171                 timer_1_start(PKG_WAIT_TIMEOUT);
	LDI  R26,LOW(5000)
	LDI  R27,HIGH(5000)
	RCALL _timer_1_start
; 0000 0172                 new_state(WAIT_BIN_DATA);
	LDI  R26,LOW(4)
	RCALL _new_state
; 0000 0173                 break;
	RJMP _0xF
; 0000 0174 
; 0000 0175             case WAIT_BIN_DATA:
_0x30:
	CPI  R30,LOW(0x4)
	BRNE _0x33
; 0000 0176                 if(timer_1_delay_cnt == 0)
	CALL SUBOPT_0x1
	BRNE _0x34
; 0000 0177                 {
; 0000 0178                     exit_bootloader();
	RCALL _exit_bootloader
; 0000 0179                 }
; 0000 017A 
; 0000 017B                 last_pkg_type = PKG_NULL;
_0x34:
	LDI  R30,LOW(0)
	STS  _last_pkg_type,R30
; 0000 017C                 if (rx_counter0 == (last_pkg_size + SERVICE_DATA_SIZE))
	MOVW R30,R12
	ADIW R30,15
	LDS  R26,_rx_counter0
	LDI  R27,0
	CP   R30,R26
	CPC  R31,R27
	BRNE _0x35
; 0000 017D                 {
; 0000 017E                     if(check_save_pkg(last_pkg_size + SERVICE_DATA_SIZE) == DATA_OK)
	MOVW R26,R12
	ADIW R26,15
	RCALL _check_save_pkg
	CPI  R30,0
	BRNE _0x36
; 0000 017F                     {
; 0000 0180                         get_pkg_type();
	RCALL _get_pkg_type
; 0000 0181                     }
; 0000 0182                 }
_0x36:
; 0000 0183 
; 0000 0184                 if(last_pkg_type == PKG_BIN)
_0x35:
	LDS  R26,_last_pkg_type
	CPI  R26,LOW(0x5)
	BRNE _0x37
; 0000 0185                 {
; 0000 0186                     timer_1_stop();
	RCALL _timer_1_stop
; 0000 0187                     last_pkg_type = PKG_NULL;
	LDI  R30,LOW(0)
	STS  _last_pkg_type,R30
; 0000 0188                     new_state(UPD_DATA_BUFF);
	LDI  R26,LOW(11)
	RCALL _new_state
; 0000 0189                 }
; 0000 018A                 break;
_0x37:
	RJMP _0xF
; 0000 018B 
; 0000 018C             case UPD_DATA_BUFF:
_0x33:
	CPI  R30,LOW(0xB)
	BREQ PC+2
	RJMP _0x38
; 0000 018D                 address = page_counter * 0x40 + UPPER_FLASH_OFFSET;
	MOVW R30,R10
	CALL SUBOPT_0x10
; 0000 018E                 if (last_pkg_size < PAGESIZE)
	CP   R12,R30
	CPC  R13,R31
	BRSH _0x39
; 0000 018F                 {
; 0000 0190                     for(loop_index = last_pkg_size; loop_index < PAGESIZE; loop_index++)
	MOVW R6,R12
_0x3B:
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CP   R6,R30
	CPC  R7,R31
	BRSH _0x3C
; 0000 0191                     {
; 0000 0192                         ((unsigned char *)data_buff)[loop_index + DATA_START_BYTE] = 0xFF;
	MOVW R30,R6
	__ADDW1MN _data_buff,10
	LDI  R26,LOW(255)
	STD  Z+0,R26
; 0000 0193                     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0x3B
_0x3C:
; 0000 0194                 }
; 0000 0195                 BlockLoad(PAGESIZE, (unsigned int *)((unsigned char *)(data_buff) + DATA_START_BYTE), 'F', &address);
_0x39:
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _data_buff,10
	CALL SUBOPT_0x11
	RCALL _BlockLoad
; 0000 0196 
; 0000 0197                 last_pkg_size += loaded_data_size;
	LDS  R30,_loaded_data_size
	LDS  R31,_loaded_data_size+1
	__ADDWRR 12,13,30,31
; 0000 0198                 write_eeprom_mem(LAST_WR_PAGE_ADDR+1, (unsigned char)(last_pkg_size>>8));
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	ST   -Y,R31
	ST   -Y,R30
	MOV  R26,R13
	RCALL _write_eeprom_mem
; 0000 0199                 write_eeprom_mem(LAST_WR_PAGE_ADDR, (unsigned char)last_pkg_size);
	CALL SUBOPT_0xD
	MOV  R26,R12
	RCALL _write_eeprom_mem
; 0000 019A                 update_eeprom_crc();
	RCALL _update_eeprom_crc
; 0000 019B 
; 0000 019C                 page_counter++;
	MOVW R30,R10
	ADIW R30,1
	MOVW R10,R30
; 0000 019D 
; 0000 019E                 new_state(ASK_FW_PKG);
	LDI  R26,LOW(1)
	RCALL _new_state
; 0000 019F                 if(last_fw_part_flg || (last_pkg_size == new_fw_size))
	LDS  R30,_last_fw_part_flg
	CPI  R30,0
	BRNE _0x3E
	LDS  R30,_new_fw_size
	LDS  R31,_new_fw_size+1
	CP   R30,R12
	CPC  R31,R13
	BRNE _0x3D
_0x3E:
; 0000 01A0                 {
; 0000 01A1                     new_state(UPD_FLASH);
	LDI  R26,LOW(12)
	RCALL _new_state
; 0000 01A2                 }
; 0000 01A3                 break;
_0x3D:
	RJMP _0xF
; 0000 01A4 
; 0000 01A5             case UPD_FLASH:
_0x38:
	CPI  R30,LOW(0xC)
	BRNE _0x40
; 0000 01A6                 for(loop_index = 0; loop_index < page_counter; loop_index++)
	CLR  R6
	CLR  R7
_0x42:
	__CPWRR 6,7,10,11
	BRSH _0x43
; 0000 01A7                 {
; 0000 01A8                     address = loop_index * 0x40 + UPPER_FLASH_OFFSET;
	MOVW R30,R6
	CALL SUBOPT_0x10
; 0000 01A9                     BlockRead(PAGESIZE, data_buff, 'F', &address);
	CALL SUBOPT_0x12
	RCALL _BlockRead
; 0000 01AA                     address -= UPPER_FLASH_OFFSET;
	LDI  R30,LOW(7168)
	LDI  R31,HIGH(7168)
	__SUBWRR 4,5,30,31
; 0000 01AB                     BlockLoad(PAGESIZE, data_buff, 'F', &address);
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	CALL SUBOPT_0x12
	RCALL _BlockLoad
; 0000 01AC                 }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0x42
_0x43:
; 0000 01AD                 // Update FW version in EEPROM
; 0000 01AE                 write_eeprom_mem(FW_VERSION_ADDR, read_eeprom_mem(NEW_FW_VERSION_ADDR));
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(8)
	LDI  R27,0
	RCALL _read_eeprom_mem
	MOV  R26,R30
	RCALL _write_eeprom_mem
; 0000 01AF                 // Set "update successful" flag in EEPROM
; 0000 01B0                 write_eeprom_mem(DOWNLOAD_CMPLT_ADDR, 0x01);
	CALL SUBOPT_0x5
	LDI  R26,LOW(1)
	RCALL _write_eeprom_mem
; 0000 01B1                 // Reset loaded data counter in EEPROM
; 0000 01B2                 write_eeprom_mem(LAST_WR_PAGE_ADDR, 0xFF);
	CALL SUBOPT_0xD
	LDI  R26,LOW(255)
	CALL SUBOPT_0xE
; 0000 01B3                 write_eeprom_mem(LAST_WR_PAGE_ADDR+1, 0xFF);
	LDI  R26,LOW(255)
	RCALL _write_eeprom_mem
; 0000 01B4                 // Send update result to host
; 0000 01B5                 send_upgd_result((unsigned int)read_eeprom_mem(DOWNLOAD_CMPLT_ADDR));
	LDI  R26,LOW(7)
	LDI  R27,0
	RCALL _read_eeprom_mem
	LDI  R31,0
	MOVW R26,R30
	RCALL _send_upgd_result
; 0000 01B6 
; 0000 01B7                 new_state(ERASE_UNUSE_PAGES);
	LDI  R26,LOW(13)
	RCALL _new_state
; 0000 01B8                 break;
	RJMP _0xF
; 0000 01B9 
; 0000 01BA             case ERASE_UNUSE_PAGES:
_0x40:
	CPI  R30,LOW(0xD)
	BRNE _0x44
; 0000 01BB                 for(loop_index = page_counter; loop_index < NUM_OF_PAGES; loop_index++)
	MOVW R6,R10
_0x46:
	LDI  R30,LOW(224)
	LDI  R31,HIGH(224)
	CP   R6,R30
	CPC  R7,R31
	BRSH _0x47
; 0000 01BC                 {
; 0000 01BD                     _WAIT_FOR_SPM();
_0x48:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x48
; 0000 01BE                     address = (loop_index * 0x40) << 1;
	MOVW R30,R6
	CALL __LSLW2
	CALL __LSLW4
	LSL  R30
	ROL  R31
	MOVW R4,R30
; 0000 01BF                     _PAGE_ERASE(address);
	ST   -Y,R5
	ST   -Y,R4
	LDI  R26,LOW(3)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 01C0                 }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0x46
_0x47:
; 0000 01C1 
; 0000 01C2                 new_state(EXIT_BOOT);
	LDI  R26,LOW(15)
	RCALL _new_state
; 0000 01C3                 break;
	RJMP _0xF
; 0000 01C4 
; 0000 01C5             case EXIT_BOOT:
_0x44:
	CPI  R30,LOW(0xF)
	BRNE _0x4B
; 0000 01C6                 exit_bootloader();
	RCALL _exit_bootloader
; 0000 01C7                 break;
; 0000 01C8 
; 0000 01C9             case IDLE:
_0x4B:
; 0000 01CA             default:
; 0000 01CB                 break;
; 0000 01CC         }//switch (state machine)
_0xF:
; 0000 01CD 
; 0000 01CE     }//while(1)
	RJMP _0xA
; 0000 01CF }//main()
_0x4E:
	RJMP _0x4E
; .FEND
;
;//------------------------------------- FUNCTIONS -----------------------------
;/**
; * @brief Hardware initialisation.
; *
; * USART 115200
; * TC1 - timer period 100 ms, in ISR decrement startup_delay_cnt.
; * WDT period 8 sec.
; *
; */
;void startup_init(void)
; 0000 01DB {
_startup_init:
; .FSTART _startup_init
; 0000 01DC     // USART initialization
; 0000 01DD     // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 01DE     // USART Receiver: On
; 0000 01DF     // USART Transmitter: On
; 0000 01E0     // USART0 Mode: Asynchronous
; 0000 01E1     // USART Baud Rate: 115200
; 0000 01E2     UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (0<<U2X0) | (0<<MPCM0);
	LDI  R30,LOW(0)
	STS  192,R30
; 0000 01E3     UCSR0B=(1<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (1<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
	LDI  R30,LOW(152)
	STS  193,R30
; 0000 01E4     UCSR0C=(0<<UMSEL01) | (0<<UMSEL00) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
	LDI  R30,LOW(6)
	STS  194,R30
; 0000 01E5     UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  197,R30
; 0000 01E6     UBRR0L=0x03;
	LDI  R30,LOW(3)
	STS  196,R30
; 0000 01E7 
; 0000 01E8     // Timer/Counter 1 initialization
; 0000 01E9     // Clock source: System Clock
; 0000 01EA     // Clock divisor: 64
; 0000 01EB     // Mode: Normal top=0xFFFF
; 0000 01EC     // Timer Period: 100 ms
; 0000 01ED     // Timer1 Overflow Interrupt: On
; 0000 01EE     TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<WGM11) | (0<<WGM10);
	LDI  R30,LOW(0)
	STS  128,R30
; 0000 01EF     // TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (1<<CS10);
; 0000 01F0     // TCNT1H=TIMER1_CNT_INIT >> 8;
; 0000 01F1     // TCNT1L=TIMER1_CNT_INIT & 0xFF;
; 0000 01F2 
; 0000 01F3     // Timer/Counter 1 Interrupt(s) initialization
; 0000 01F4     // TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (1<<TOIE1);
; 0000 01F5 
; 0000 01F6     // Watchdog Timer initialization
; 0000 01F7     // Watchdog Timer Prescaler: OSC/1024k
; 0000 01F8     // Watchdog timeout action: Reset
; 0000 01F9     #pragma optsize-
; 0000 01FA     WDTCSR=(0<<WDIF) | (0<<WDIE) | (1<<WDP3) | (1<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (1<<WDP0);
	LDI  R30,LOW(57)
	STS  96,R30
; 0000 01FB     WDTCSR=(0<<WDIF) | (0<<WDIE) | (1<<WDP3) | (0<<WDCE) | (1<<WDE) | (0<<WDP2) | (0<<WDP1) | (1<<WDP0);
	LDI  R30,LOW(41)
	STS  96,R30
; 0000 01FC     #ifdef _OPTIMIZE_SIZE_
; 0000 01FD     #pragma optsize+
; 0000 01FE     #endif
; 0000 01FF }//startup_ini()
	RET
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief TC1 stop, turn off before out from boot section.
; *
; */
;void timer_1_stop()
; 0000 0206 {
_timer_1_stop:
; .FSTART _timer_1_stop
; 0000 0207     TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (0<<CS11) | (0<<CS10);
	LDI  R30,LOW(0)
	STS  129,R30
; 0000 0208     TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (0<<TOIE1);
	STS  111,R30
; 0000 0209 }//timer_1_stop()
	RET
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Load delay conter and start timer 1.
; *
; * @param time_ms - Timer delay in ms (counts only in hundreds ms).
; */
;void timer_1_start(unsigned int time_ms)
; 0000 0211 {
_timer_1_start:
; .FSTART _timer_1_start
; 0000 0212     timer_1_delay_cnt = time_ms / 100; //convert to timer 1 overflow periods
	ST   -Y,R27
	ST   -Y,R26
;	time_ms -> Y+0
	LD   R26,Y
	LDD  R27,Y+1
	LDI  R30,LOW(100)
	LDI  R31,HIGH(100)
	CALL __DIVW21U
	STS  _timer_1_delay_cnt,R30
	STS  _timer_1_delay_cnt+1,R31
; 0000 0213 
; 0000 0214     TCCR1B=(0<<ICNC1) | (0<<ICES1) | (0<<WGM13) | (0<<WGM12) | (0<<CS12) | (1<<CS11) | (1<<CS10);
	LDI  R30,LOW(3)
	STS  129,R30
; 0000 0215     TCNT1H=TIMER1_CNT_INIT >> 8;
	CALL SUBOPT_0x0
; 0000 0216     TCNT1L=TIMER1_CNT_INIT & 0xFF;
; 0000 0217 
; 0000 0218     TIMSK1=(0<<ICIE1) | (0<<OCIE1B) | (0<<OCIE1A) | (1<<TOIE1);
	LDI  R30,LOW(1)
	STS  111,R30
; 0000 0219 }//timer_1_start()
	JMP  _0x2060003
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Write data buffer in FLASH or EEPROM memory.
; *
; * For flash: load data buffer in temp area and write page from address.
; *
; * For eeprom: write num of size data (in bytes) in eeprom from address.
; *
; *
; * @param size sizo of writing data (in bytes).
; * @param p_data_buff pointer to data buffer.
; * @param mem_type type of writing memory.
; * @param address start memory address. For EEPROM in bytes. For FLASH in words.
; * @return unsigned char. [error code]
; */
;unsigned char BlockLoad(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address)
; 0000 022A {
_BlockLoad:
; .FSTART _BlockLoad
; 0000 022B     ADDR_t temp_addr;
; 0000 022C     ADDR_t inc_addr;
; 0000 022D     unsigned int index = 0;
; 0000 022E     unsigned int data_size;
; 0000 022F 
; 0000 0230 //vvv============== FOR REDUCE PROG SIZE
; 0000 0231     // EEPROM memory type.
; 0000 0232     // if(mem_type == 'E')
; 0000 0233     // {
; 0000 0234     //     temp_addr = *address;
; 0000 0235     //     data_size = size;
; 0000 0236     //     if((temp_addr + data_size) > EEPROM_END) // Check enough EEPROM memory
; 0000 0237     //     {
; 0000 0238     //         return 1;
; 0000 0239     //     }
; 0000 023A     //     // Then program the EEPROM
; 0000 023B     //     for(index = 0; index < size; index++)
; 0000 023C     //     {
; 0000 023D     //         _WAIT_FOR_SPM();
; 0000 023E     //         *((eeprom unsigned char *) temp_addr++) = ((unsigned char *) p_data_buff)[index]; // Write byte.
; 0000 023F     //     }
; 0000 0240 
; 0000 0241     //     return 0;
; 0000 0242     // }//EEPROM
; 0000 0243 //^^^============== FOR REDUCE PROG SIZE
; 0000 0244 
; 0000 0245     // Flash memory type.
; 0000 0246     if(mem_type == 'F')
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,2
	CALL __SAVELOCR6
;	size -> Y+13
;	*p_data_buff -> Y+11
;	mem_type -> Y+10
;	*address -> Y+8
;	temp_addr -> R16,R17
;	inc_addr -> R18,R19
;	index -> R20,R21
;	data_size -> Y+6
	__GETWRN 20,21,0
	LDD  R26,Y+10
	CPI  R26,LOW(0x46)
	BRNE _0x4F
; 0000 0247     { // NOTE: For flash programming, 'address' is given in words.
; 0000 0248         temp_addr = *address << 1; //Convert word-address to byte-address
	CALL SUBOPT_0x13
	MOVW R16,R30
; 0000 0249         inc_addr = *address << 1; //Convert word-address to byte-address
	CALL SUBOPT_0x13
	MOVW R18,R30
; 0000 024A         _PAGE_ERASE(temp_addr);
	ST   -Y,R17
	ST   -Y,R16
	LDI  R26,LOW(3)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 024B         data_size = size >> 1; //Convert to words
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	LSR  R31
	ROR  R30
	STD  Y+6,R30
	STD  Y+6+1,R31
; 0000 024C 
; 0000 024D         for(index = 0; index < data_size; index++)
	__GETWRN 20,21,0
_0x51:
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CP   R20,R30
	CPC  R21,R31
	BRSH _0x52
; 0000 024E         {
; 0000 024F             _WAIT_FOR_SPM();
_0x53:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x53
; 0000 0250             _FILL_TEMP_WORD(inc_addr, ((unsigned int *) p_data_buff)[index]);
	ST   -Y,R19
	ST   -Y,R18
	MOVW R30,R20
	LDD  R26,Y+13
	LDD  R27,Y+13+1
	LSL  R30
	ROL  R31
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(1)
	CALL ___AddrToZWordToR1R0ByteToSPMCR_SPM
; 0000 0251             inc_addr += 2;
	__ADDWRN 18,19,2
; 0000 0252         }// Loop until all words written.
	__ADDWRN 20,21,1
	RJMP _0x51
_0x52:
; 0000 0253 
; 0000 0254         _PAGE_WRITE(temp_addr);
	ST   -Y,R17
	ST   -Y,R16
	LDI  R26,LOW(5)
	CALL ___AddrToZByteToSPMCR_SPM
; 0000 0255         _WAIT_FOR_SPM();
_0x56:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x56
; 0000 0256         _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x14
; 0000 0257 
; 0000 0258         return 0;
; 0000 0259     }//FLASH
; 0000 025A 
; 0000 025B     return 0;
_0x4F:
_0x2060006:
	LDI  R30,LOW(0)
	CALL __LOADLOCR6
	ADIW R28,15
	RET
; 0000 025C }//BlockLoad()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Read block data from EEPROM or FLASH.
; *
; * For flash: load size data from (address) to buffer.
; *
; * For eeprom: read num of size eeprom data (in bytes) from address.
; *
; * @param size size of reading data (in bytes).
; * @param p_data_buff pointer to data buffer.
; * @param mem_type type of reading memory. 'E' - EEPROM. 'F' - FLASH.
; * @param address start memory address. For EEPROM in bytes. For FLASH in words.
; * @return unsigned char. [TODO: error code]
; */
;unsigned char BlockRead(unsigned int size, unsigned int * p_data_buff, unsigned char mem_type, ADDR_t *address)
; 0000 026C {
_BlockRead:
; .FSTART _BlockRead
; 0000 026D     ADDR_t temp_addr = *address;
; 0000 026E     unsigned int index = 0;
; 0000 026F     unsigned int data_size;
; 0000 0270 
; 0000 0271 //vvv============== FOR REDUCE PROG SIZE
; 0000 0272     // EEPROM memory type.
; 0000 0273     // if(mem_type == 'E')
; 0000 0274     // {
; 0000 0275     //     data_size = size;
; 0000 0276     //     for(index = 0; index < data_size; index++)
; 0000 0277     //     {
; 0000 0278     //         _WAIT_FOR_SPM();
; 0000 0279     //         ((unsigned char *) p_data_buff)[index] = (*((eeprom unsigned char *) temp_addr++));
; 0000 027A     //     }
; 0000 027B 
; 0000 027C     //     return 0;
; 0000 027D     // }//EEPROM
; 0000 027E //^^^============== FOR REDUCE PROG SIZE
; 0000 027F 
; 0000 0280     // Flash memory type.
; 0000 0281     if(mem_type == 'F')
	ST   -Y,R27
	ST   -Y,R26
	CALL __SAVELOCR6
;	size -> Y+11
;	*p_data_buff -> Y+9
;	mem_type -> Y+8
;	*address -> Y+6
;	temp_addr -> R16,R17
;	index -> R18,R19
;	data_size -> R20,R21
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CALL __GETW1P
	MOVW R16,R30
	__GETWRN 18,19,0
	LDD  R26,Y+8
	CPI  R26,LOW(0x46)
	BRNE _0x59
; 0000 0282     {
; 0000 0283         temp_addr <<= 1; // Convert address to bytes.
	LSL  R16
	ROL  R17
; 0000 0284         data_size = size;
	__GETWRS 20,21,11
; 0000 0285         for(index = 0; index < data_size; index += 2)
	__GETWRN 18,19,0
_0x5B:
	__CPWRR 18,19,20,21
	BRSH _0x5C
; 0000 0286         {
; 0000 0287             _WAIT_FOR_SPM();
_0x5D:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x5D
; 0000 0288             _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x14
; 0000 0289             ((unsigned char *) p_data_buff)[index] = _LOAD_PROGRAM_MEMORY(temp_addr);
	MOVW R30,R18
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADD  R26,R30
	ADC  R27,R31
	MOVW R30,R16
	LPM  R30,Z
	ST   X,R30
; 0000 028A             ((unsigned char *) p_data_buff)[index + 1] = _LOAD_PROGRAM_MEMORY(temp_addr + 1);
	MOVW R30,R18
	ADIW R30,1
	LDD  R26,Y+9
	LDD  R27,Y+9+1
	ADD  R26,R30
	ADC  R27,R31
	MOVW R30,R16
	ADIW R30,1
	LPM  R30,Z
	ST   X,R30
; 0000 028B             temp_addr += 2;
	__ADDWRN 16,17,2
; 0000 028C         }
	__ADDWRN 18,19,2
	RJMP _0x5B
_0x5C:
; 0000 028D 
; 0000 028E         return 0;
	LDI  R30,LOW(0)
	RJMP _0x2060005
; 0000 028F     }//FLASH
; 0000 0290     return 1; //invalid memory type
_0x59:
	LDI  R30,LOW(1)
_0x2060005:
	CALL __LOADLOCR6
	ADIW R28,13
	RET
; 0000 0291 }//BlockRead()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Erase chip before write new data.
; *
; * @return char. [TODO: error code]
; */
;char chip_erase(void)
; 0000 0299 {
; 0000 029A     for(address = 0; address < APP_END; address += PAGESIZE)
; 0000 029B     { // NOTE: Here we use address as a byte-address, not word-address, for convenience.
; 0000 029C         _WAIT_FOR_SPM();
; 0000 029D         _PAGE_ERASE( address );
; 0000 029E     }
; 0000 029F 
; 0000 02A0     return 0;
; 0000 02A1 }//chip_erase()
;//-----------------------------------------------------------------------------
;/**
; * @brief Read one word from FLASH.
; *
; * @param addr data address in words.
; * @return unsigned int.
;*/
;unsigned int read_prog_mem(ADDR_t addr)
; 0000 02AA {
; 0000 02AB     unsigned int temp_data = 0x0000;
; 0000 02AC     ADDR_t temp_addr;
; 0000 02AD 
; 0000 02AE     temp_addr = addr;
;	addr -> Y+4
;	temp_data -> R16,R17
;	temp_addr -> R18,R19
; 0000 02AF 
; 0000 02B0     _WAIT_FOR_SPM();
; 0000 02B1     _ENABLE_RWW_SECTION();
; 0000 02B2     ((unsigned char *) &temp_data)[1] = _LOAD_PROGRAM_MEMORY((temp_addr << 1) + 1 );
; 0000 02B3     ((unsigned char *) &temp_data)[0] = _LOAD_PROGRAM_MEMORY((temp_addr << 1) + 0 );
; 0000 02B4 
; 0000 02B5     return temp_data;
; 0000 02B6 }//read_prog_mem()
;//-----------------------------------------------------------------------------
;/**
; * @brief Load one word of data to temp buffer before write to flash page.
; *
; * @param addr Address of data in words.
; * @param data Word of data for load.
; * @return char [TODO: error code]
; */
;char write_prog_mem(ADDR_t addr, unsigned int data)
; 0000 02C0 {
; 0000 02C1     ADDR_t temp_addr;
; 0000 02C2     unsigned int temp_data;
; 0000 02C3 
; 0000 02C4     temp_addr = addr << 1; //Convert word-address to byte-address
;	addr -> Y+6
;	data -> Y+4
;	temp_addr -> R16,R17
;	temp_data -> R18,R19
; 0000 02C5     temp_data = data;
; 0000 02C6 
; 0000 02C7     _WAIT_FOR_SPM();
; 0000 02C8     _FILL_TEMP_WORD(temp_addr, temp_data);
; 0000 02C9 
; 0000 02CA     return 0;
; 0000 02CB }//write_prog_mem()
;//-----------------------------------------------------------------------------
;/**
; * @brief Write data from temp buffer to flash page.
; *
; * Call after load data via function write_prog_mem().
; *
; * @param addr address of page in words.
; * @return char [TODO: error code]
; */
;char write_page(ADDR_t addr)
; 0000 02D6 {
; 0000 02D7     ADDR_t temp_addr;
; 0000 02D8 
; 0000 02D9     temp_addr = addr << 1 ; // Convert word-address to byte-address
;	addr -> Y+2
;	temp_addr -> R16,R17
; 0000 02DA 
; 0000 02DB     if( temp_addr >= (APP_END>>1) ) // Protect bootloader area.
; 0000 02DC     {
; 0000 02DD         return 1;
; 0000 02DE     }
; 0000 02DF     else
; 0000 02E0     {
; 0000 02E1         _WAIT_FOR_SPM();
; 0000 02E2         _PAGE_WRITE( temp_addr );
; 0000 02E3     }
; 0000 02E4 
; 0000 02E5     return 0;
; 0000 02E6 }//write_page()
;//-----------------------------------------------------------------------------
;/**
; * @brief Write one byte of data to EEPROM.
; *
; * @param addr Address of byte in EEPROM.
; * @param data Byte of data to be written.
; * @return char [TODO: error code]
; */
;char write_eeprom_mem(ADDR_t addr, unsigned char data)
; 0000 02F0 {
_write_eeprom_mem:
; .FSTART _write_eeprom_mem
; 0000 02F1     _WAIT_FOR_SPM();
	ST   -Y,R26
;	addr -> Y+1
;	data -> Y+0
_0x71:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x71
; 0000 02F2     *((eeprom unsigned char *) addr) = data;
	LD   R30,Y
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __EEPROMWRB
; 0000 02F3 
; 0000 02F4     // Wait for completion of write
; 0000 02F5     while(EECR & (1<<EEPE));
_0x74:
	SBIC 0x1F,1
	RJMP _0x74
; 0000 02F6 
; 0000 02F7     return 0;
	LDI  R30,LOW(0)
	JMP  _0x2060002
; 0000 02F8 }//write_eeprom_mem()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Read byte of data from EEPROM.
; *
; * @param addr address of data in bytes.
; * @return char byte of read data.
; */
;char read_eeprom_mem(ADDR_t addr)
; 0000 0301 {
_read_eeprom_mem:
; .FSTART _read_eeprom_mem
; 0000 0302     char read_data;
; 0000 0303 
; 0000 0304     read_data = (*((eeprom unsigned char *) addr));
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
;	addr -> Y+1
;	read_data -> R17
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	CALL __EEPROMRDB
	MOV  R17,R30
; 0000 0305 
; 0000 0306     return read_data;
	LDD  R17,Y+0
	JMP  _0x2060002
; 0000 0307 }//read_eeprom_mem()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Exit boot loader mode.
; *
; * Switch to execute the application (jmp to 0x00 address).
; *
; */
;void exit_bootloader(void)
; 0000 0310 {
_exit_bootloader:
; .FSTART _exit_bootloader
; 0000 0311     timer_1_stop();
	RCALL _timer_1_stop
; 0000 0312 
; 0000 0313     _WAIT_FOR_SPM();
_0x77:
	IN   R30,0x37
	SBRC R30,0
	RJMP _0x77
; 0000 0314     _ENABLE_RWW_SECTION();
	CALL SUBOPT_0x14
; 0000 0315 
; 0000 0316     // Jump to Reset vector 0x0000 in Application Section.
; 0000 0317     // disable interrupts
; 0000 0318     #asm("cli")
	cli
; 0000 0319 
; 0000 031A     #pragma optsize-
; 0000 031B     // will use the interrupt vectors from the application section
; 0000 031C     MCUCR=(1<<IVCE);
	LDI  R30,LOW(1)
	OUT  0x35,R30
; 0000 031D     MCUCR=(0<<IVSEL) | (0<<IVCE);
	LDI  R30,LOW(0)
	OUT  0x35,R30
; 0000 031E     #ifdef _OPTIMIZE_SIZE_
; 0000 031F         #pragma optsize+
; 0000 0320     #endif
; 0000 0321 
; 0000 0322     // start execution from address 0
; 0000 0323     #asm("jmp 0")
	jmp 0
; 0000 0324 }//exit_bootloader()
	RET
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Return signature of chip.
; *
; * Print to USART 3 bytes of chip signature.
; *
; */
;void return_signature(void)
; 0000 032D {
; 0000 032E     putchar( SIGNATURE_BYTE_0 );
; 0000 032F     putchar( SIGNATURE_BYTE_1 );
; 0000 0330     putchar( SIGNATURE_BYTE_2 );
; 0000 0331 }//return_signature()
;//-----------------------------------------------------------------------------
;/**
; * @brief Get the char from ring USART RX-buffer
; *
; * @return Next data char.
; */
;char get_char(void)
; 0000 0339 {
_get_char:
; .FSTART _get_char
; 0000 033A     char data;
; 0000 033B 
; 0000 033C     while (rx_counter0==0);
	ST   -Y,R17
;	data -> R17
_0x7A:
	LDS  R30,_rx_counter0
	CPI  R30,0
	BREQ _0x7A
; 0000 033D 
; 0000 033E     data = rx_buffer0[rx_rd_index0++];
	LDS  R30,_rx_rd_index0
	SUBI R30,-LOW(1)
	STS  _rx_rd_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	LD   R17,Z
; 0000 033F     if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0 = 0;
	LDS  R26,_rx_rd_index0
	CPI  R26,LOW(0x96)
	BRNE _0x7D
	LDI  R30,LOW(0)
	STS  _rx_rd_index0,R30
; 0000 0340 
; 0000 0341     #asm("cli")
_0x7D:
	cli
; 0000 0342     --rx_counter0;
	LDS  R30,_rx_counter0
	SUBI R30,LOW(1)
	STS  _rx_counter0,R30
; 0000 0343     #asm("sei")
	sei
; 0000 0344     return data;
	MOV  R30,R17
	LD   R17,Y+
	RET
; 0000 0345 }//get_char()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Change STATE MACHINE state, and save previous state.
; *
; * @param new_state
; */
;void new_state(unsigned char new_state)
; 0000 034D {
_new_state:
; .FSTART _new_state
; 0000 034E     prev_state = current_state;
	ST   -Y,R26
;	new_state -> Y+0
	LDS  R30,_current_state
	STS  _prev_state,R30
; 0000 034F     current_state = new_state;
	LD   R30,Y
	STS  _current_state,R30
; 0000 0350 }//new_state()
	JMP  _0x2060001
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Check and save input data.
; *
; * Check CRC, header and ID. Save pkg to data buff.
; *
; * (Convert CRC ascii to hex.)
; *
; * @return unsigned char - error code.
; */
;unsigned char check_save_pkg(unsigned int data_length)
; 0000 035C {
_check_save_pkg:
; .FSTART _check_save_pkg
; 0000 035D     unsigned char err_code = DATA_ERR;
; 0000 035E     unsigned char i;
; 0000 035F     unsigned int in_crc;
; 0000 0360     unsigned int clc_crc;
; 0000 0361 
; 0000 0362     unsigned char crc_ok;
; 0000 0363     unsigned char head_ok;
; 0000 0364     unsigned char id_ok;
; 0000 0365 
; 0000 0366     if(get_char() != 'B')
	ST   -Y,R27
	ST   -Y,R26
	SBIW R28,3
	CALL __SAVELOCR6
;	data_length -> Y+9
;	err_code -> R17
;	i -> R16
;	in_crc -> R18,R19
;	clc_crc -> R20,R21
;	crc_ok -> Y+8
;	head_ok -> Y+7
;	id_ok -> Y+6
	LDI  R17,1
	RCALL _get_char
	CPI  R30,LOW(0x42)
	BREQ _0x7E
; 0000 0367     {
; 0000 0368         return;
	LDI  R30,LOW(0)
	RJMP _0x2060004
; 0000 0369     }
; 0000 036A     else
_0x7E:
; 0000 036B     {
; 0000 036C         rx_counter0++;
	LDS  R30,_rx_counter0
	SUBI R30,-LOW(1)
	STS  _rx_counter0,R30
; 0000 036D         rx_rd_index0--;
	LDS  R30,_rx_rd_index0
	SUBI R30,LOW(1)
	STS  _rx_rd_index0,R30
; 0000 036E     }
; 0000 036F 
; 0000 0370     for(i = 0; i < data_length; i++)
	LDI  R16,LOW(0)
_0x81:
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	MOV  R26,R16
	LDI  R27,0
	CP   R26,R30
	CPC  R27,R31
	BRSH _0x82
; 0000 0371     {
; 0000 0372         ((unsigned char *)data_buff)[i] = get_char();
	MOV  R30,R16
	LDI  R31,0
	SUBI R30,LOW(-_data_buff)
	SBCI R31,HIGH(-_data_buff)
	PUSH R31
	PUSH R30
	RCALL _get_char
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0373     }
	SUBI R16,-1
	RJMP _0x81
_0x82:
; 0000 0374 
; 0000 0375     // Get last 4 bytes of string and convert to 2-bytes hex CRC-16
; 0000 0376     atoh( ((unsigned char *)data_buff)+data_length-4, (unsigned char *)&in_crc, 4 );
	LDD  R30,Y+9
	LDD  R31,Y+9+1
	SUBI R30,LOW(-_data_buff)
	SBCI R31,HIGH(-_data_buff)
	SBIW R30,4
	ST   -Y,R31
	ST   -Y,R30
	IN   R30,SPL
	IN   R31,SPH
	SBIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	PUSH R19
	PUSH R18
	LDI  R26,LOW(4)
	LDI  R27,0
	RCALL _atoh
	POP  R18
	POP  R19
; 0000 0377     // Change HB/LB of input CRC
; 0000 0378     in_crc = (in_crc >> 8) | (in_crc << 8);
	MOV  R30,R19
	ANDI R31,HIGH(0x0)
	MOVW R26,R30
	MOV  R31,R18
	LDI  R30,LOW(0)
	OR   R30,R26
	OR   R31,R27
	MOVW R18,R30
; 0000 0379     // Calculate CRC-16
; 0000 037A     clc_crc = getCRC16_CCITT((unsigned char *) data_buff, data_length - 4);
	CALL SUBOPT_0x15
	LDD  R26,Y+11
	SUBI R26,LOW(4)
	CALL _getCRC16_CCITT
	MOVW R20,R30
; 0000 037B     crc_ok = (in_crc == clc_crc) ? true : false;
	__CPWRR 20,21,18,19
	BRNE _0x83
	LDI  R30,LOW(1)
	RJMP _0x84
_0x83:
	LDI  R30,LOW(0)
_0x84:
	STD  Y+8,R30
; 0000 037C 
; 0000 037D     // Check header
; 0000 037E     if( ((unsigned char *)data_buff)[0] == 'B' &&
; 0000 037F         ((unsigned char *)data_buff)[1] == 'L' &&
; 0000 0380         ((unsigned char *)data_buff)[2] == 'D'
; 0000 0381         )
	LDS  R26,_data_buff
	CPI  R26,LOW(0x42)
	BRNE _0x87
	__GETB2MN _data_buff,1
	CPI  R26,LOW(0x4C)
	BRNE _0x87
	__GETB2MN _data_buff,2
	CPI  R26,LOW(0x44)
	BREQ _0x88
_0x87:
	RJMP _0x86
_0x88:
; 0000 0382         {
; 0000 0383             head_ok = true;
	LDI  R30,LOW(1)
	RJMP _0xCB
; 0000 0384         }
; 0000 0385     else head_ok = false;
_0x86:
	LDI  R30,LOW(0)
_0xCB:
	STD  Y+7,R30
; 0000 0386 
; 0000 0387     // Check ID
; 0000 0388     id_ok = ( ((unsigned char *)data_buff)[4] == DEVICE_ID ) ? true: false;
	__GETB2MN _data_buff,4
	CPI  R26,LOW(0x31)
	BRNE _0x8A
	LDI  R30,LOW(1)
	RJMP _0x8B
_0x8A:
	LDI  R30,LOW(0)
_0x8B:
	STD  Y+6,R30
; 0000 0389 
; 0000 038A     err_code = ( crc_ok && head_ok && id_ok ) ? DATA_OK : DATA_ERR;
	LDD  R30,Y+8
	CPI  R30,0
	BREQ _0x8D
	LDD  R30,Y+7
	CPI  R30,0
	BREQ _0x8D
	LDD  R30,Y+6
	CPI  R30,0
	BRNE _0x8E
_0x8D:
	RJMP _0x8F
_0x8E:
	LDI  R30,LOW(0)
	RJMP _0x90
_0x8F:
	LDI  R30,LOW(1)
_0x90:
	MOV  R17,R30
; 0000 038B 
; 0000 038C     #ifdef DBG
; 0000 038D         printf("\n[INF] crc-%d, head-%d, id-%d\n", crc_ok, head_ok, id_ok);
; 0000 038E     #endif
; 0000 038F 
; 0000 0390     return err_code;
_0x2060004:
	CALL __LOADLOCR6
	ADIW R28,11
	RET
; 0000 0391 }//check_save_pkg()
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Convert ASCII string to hex.
; *
; * @param ascii_ptr Pointer to start ascii string.
; * @param hex_ptr Pointer to result hex value.
; * @param len Length of string in bytes.
; */
;void atoh(unsigned char *ascii_ptr, unsigned char *hex_ptr, unsigned int len)
; 0000 039B {
_atoh:
; .FSTART _atoh
; 0000 039C     int i;
; 0000 039D 
; 0000 039E     for(i = 0; i < (len / 2); i++)
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
	ST   -Y,R16
;	*ascii_ptr -> Y+6
;	*hex_ptr -> Y+4
;	len -> Y+2
;	i -> R16,R17
	__GETWRN 16,17,0
_0x93:
	LDD  R30,Y+2
	LDD  R31,Y+2+1
	LSR  R31
	ROR  R30
	CP   R16,R30
	CPC  R17,R31
	BRSH _0x94
; 0000 039F     {
; 0000 03A0         *(hex_ptr+i)   = (*(ascii_ptr+(2*i)) <= '9') ? ((*(ascii_ptr+(2*i)) - '0') * 16 ) :  (((*(ascii_ptr+(2*i)) - 'A' ...
	CALL SUBOPT_0x16
	CALL SUBOPT_0x17
	LD   R26,X
	CPI  R26,LOW(0x3A)
	BRSH _0x95
	CALL SUBOPT_0x17
	LD   R30,X
	SUBI R30,LOW(48)
	LDI  R26,LOW(16)
	MUL  R30,R26
	MOVW R30,R0
	RJMP _0x96
_0x95:
	CALL SUBOPT_0x17
	LD   R30,X
	SUBI R30,LOW(55)
	SWAP R30
	ANDI R30,0xF0
_0x96:
	MOVW R26,R22
	ST   X,R30
; 0000 03A1         *(hex_ptr+i)  |= (*(ascii_ptr+(2*i)+1) <= '9') ? (*(ascii_ptr+(2*i)+1) - '0') :  (*(ascii_ptr+(2*i)+1) - 'A' + 1 ...
	CALL SUBOPT_0x16
	LD   R0,Z
	CALL SUBOPT_0x18
	LDD  R26,Z+1
	CPI  R26,LOW(0x3A)
	BRSH _0x98
	CALL SUBOPT_0x18
	LDD  R30,Z+1
	SUBI R30,LOW(48)
	RJMP _0x99
_0x98:
	CALL SUBOPT_0x18
	LDD  R30,Z+1
	SUBI R30,LOW(55)
_0x99:
	OR   R30,R0
	MOVW R26,R22
	ST   X,R30
; 0000 03A2     }
	__ADDWRN 16,17,1
	RJMP _0x93
_0x94:
; 0000 03A3 }//atoh()
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,8
	RET
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Read packege, set the last_pkg_type.
; *
; */
;void get_pkg_type(void)
; 0000 03AA {
_get_pkg_type:
; .FSTART _get_pkg_type
; 0000 03AB     last_pkg_type = PKG_NULL;
	LDI  R30,LOW(0)
	STS  _last_pkg_type,R30
; 0000 03AC 
; 0000 03AD     if( ((unsigned char *)data_buff)[6] == 'F' &&
; 0000 03AE         ((unsigned char *)data_buff)[7] == 'W' &&
; 0000 03AF         ((unsigned char *)data_buff)[8] == 'V'
; 0000 03B0         )
	__GETB2MN _data_buff,6
	CPI  R26,LOW(0x46)
	BRNE _0x9C
	__GETB2MN _data_buff,7
	CPI  R26,LOW(0x57)
	BRNE _0x9C
	__GETB2MN _data_buff,8
	CPI  R26,LOW(0x56)
	BREQ _0x9D
_0x9C:
	RJMP _0x9B
_0x9D:
; 0000 03B1         {
; 0000 03B2             last_pkg_type = PKG_FWV;
	LDI  R30,LOW(7)
	STS  _last_pkg_type,R30
; 0000 03B3         }
; 0000 03B4 
; 0000 03B5     if( ((unsigned char *)data_buff)[6] == 'F' &&
_0x9B:
; 0000 03B6         ((unsigned char *)data_buff)[7] == 'W' &&
; 0000 03B7         ((unsigned char *)data_buff)[8] == 'L'
; 0000 03B8         )
	__GETB2MN _data_buff,6
	CPI  R26,LOW(0x46)
	BRNE _0x9F
	__GETB2MN _data_buff,7
	CPI  R26,LOW(0x57)
	BRNE _0x9F
	__GETB2MN _data_buff,8
	CPI  R26,LOW(0x4C)
	BREQ _0xA0
_0x9F:
	RJMP _0x9E
_0xA0:
; 0000 03B9         {
; 0000 03BA             last_pkg_type = PKG_FWL;
	LDI  R30,LOW(8)
	STS  _last_pkg_type,R30
; 0000 03BB         }
; 0000 03BC 
; 0000 03BD     if( ((unsigned char *)data_buff)[6] == 'B' &&
_0x9E:
; 0000 03BE         ((unsigned char *)data_buff)[7] == 'I' &&
; 0000 03BF         ((unsigned char *)data_buff)[8] == 'N'
; 0000 03C0         )
	__GETB2MN _data_buff,6
	CPI  R26,LOW(0x42)
	BRNE _0xA2
	__GETB2MN _data_buff,7
	CPI  R26,LOW(0x49)
	BRNE _0xA2
	__GETB2MN _data_buff,8
	CPI  R26,LOW(0x4E)
	BREQ _0xA3
_0xA2:
	RJMP _0xA1
_0xA3:
; 0000 03C1         {
; 0000 03C2             last_pkg_type = PKG_BIN;
	LDI  R30,LOW(5)
	STS  _last_pkg_type,R30
; 0000 03C3         }
; 0000 03C4 
; 0000 03C5 //vvv============== FOR REDUCE PROG SIZE
; 0000 03C6     // if( ((unsigned char *)data_buff)[6] == 'C' &&
; 0000 03C7     //     ((unsigned char *)data_buff)[7] == 'M' &&
; 0000 03C8     //     ((unsigned char *)data_buff)[8] == 'D'
; 0000 03C9     //     )
; 0000 03CA     //     {
; 0000 03CB     //         last_pkg_type = PKG_CMD;
; 0000 03CC     //     }
; 0000 03CD //^^^============== FOR REDUCE PROG SIZE
; 0000 03CE 
; 0000 03CF }//get_pkg_Type()
_0xA1:
	RET
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Send request with start address of next FW package.
; *
; * @param addr - address in bytes.
; */
;void req_start_byte(unsigned int addr)
; 0000 03D7 {
_req_start_byte:
; .FSTART _req_start_byte
; 0000 03D8     ((unsigned char *)data_buff)[0] = 'B';
	CALL SUBOPT_0x19
;	addr -> Y+0
; 0000 03D9     ((unsigned char *)data_buff)[1] = 'L';
; 0000 03DA     ((unsigned char *)data_buff)[2] = 'D';
; 0000 03DB     ((unsigned char *)data_buff)[3] = ',';
; 0000 03DC     ((unsigned char *)data_buff)[4] = DEVICE_ID;
; 0000 03DD     ((unsigned char *)data_buff)[5] = ',';
; 0000 03DE     ((unsigned char *)data_buff)[6] = 'R';
; 0000 03DF     ((unsigned char *)data_buff)[7] = 'Q';
; 0000 03E0     ((unsigned char *)data_buff)[8] = 'S';
	LDI  R30,LOW(83)
	CALL SUBOPT_0x1A
; 0000 03E1     ((unsigned char *)data_buff)[9] = ',';
; 0000 03E2 
; 0000 03E3     j = 13;
; 0000 03E4     for (i = 0; i < 2; i++)
_0xA5:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xA6
; 0000 03E5     {
; 0000 03E6         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&addr)[i] & 0xf];
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1C
	CALL SUBOPT_0x1D
; 0000 03E7         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&addr)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x1E
	MOVW R26,R0
	ST   X,R30
; 0000 03E8     }
	INC  R9
	RJMP _0xA5
_0xA6:
; 0000 03E9 
; 0000 03EA     ((unsigned char *)data_buff)[14] = ',';
	CALL SUBOPT_0x1F
; 0000 03EB     for (loop_index = 15; loop_index < 22; loop_index++)
_0xA8:
	CALL SUBOPT_0x20
	BRSH _0xA9
; 0000 03EC     {
; 0000 03ED         ((unsigned char *)data_buff)[loop_index] = 0x30;
	CALL SUBOPT_0x21
	LDI  R30,LOW(48)
	ST   X,R30
; 0000 03EE     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xA8
_0xA9:
; 0000 03EF     ((unsigned char *)data_buff)[22] = ',';
	CALL SUBOPT_0x22
; 0000 03F0 
; 0000 03F1     i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
	CALL SUBOPT_0x23
; 0000 03F2     j = 26;
; 0000 03F3     for (i = 0; i < 2; i++)
_0xAB:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xAC
; 0000 03F4     {
; 0000 03F5         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1C
	ST   X,R30
; 0000 03F6         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1E
	ST   X,R30
; 0000 03F7     }
	INC  R9
	RJMP _0xAB
_0xAC:
; 0000 03F8 
; 0000 03F9     //send request strign
; 0000 03FA     for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
	CLR  R6
	CLR  R7
_0xAE:
	CALL SUBOPT_0x25
	BRSH _0xAF
; 0000 03FB     {
; 0000 03FC         putchar( ((unsigned char *)data_buff)[loop_index] );
	CALL SUBOPT_0x21
	LD   R26,X
	CALL _putchar
; 0000 03FD     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xAE
_0xAF:
; 0000 03FE     putchar('\r');
	CALL SUBOPT_0x26
; 0000 03FF     putchar('\n');
; 0000 0400 }//req_start_byte()
	JMP  _0x2060003
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Send request with length of next FW package.
; *
; * @param length - length of packege in bytes.
; */
;void req_data_length(unsigned int length)
; 0000 0408 {
_req_data_length:
; .FSTART _req_data_length
; 0000 0409     ((unsigned char *)data_buff)[0] = 'B';
	CALL SUBOPT_0x19
;	length -> Y+0
; 0000 040A     ((unsigned char *)data_buff)[1] = 'L';
; 0000 040B     ((unsigned char *)data_buff)[2] = 'D';
; 0000 040C     ((unsigned char *)data_buff)[3] = ',';
; 0000 040D     ((unsigned char *)data_buff)[4] = DEVICE_ID;
; 0000 040E     ((unsigned char *)data_buff)[5] = ',';
; 0000 040F     ((unsigned char *)data_buff)[6] = 'R';
; 0000 0410     ((unsigned char *)data_buff)[7] = 'Q';
; 0000 0411     ((unsigned char *)data_buff)[8] = 'L';
	LDI  R30,LOW(76)
	CALL SUBOPT_0x1A
; 0000 0412     ((unsigned char *)data_buff)[9] = ',';
; 0000 0413 
; 0000 0414     j = 13;
; 0000 0415     for (i = 0; i < 2; i++)
_0xB1:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xB2
; 0000 0416     {
; 0000 0417         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&length)[i] & 0xf];
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1C
	CALL SUBOPT_0x1D
; 0000 0418         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&length)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x1E
	MOVW R26,R0
	ST   X,R30
; 0000 0419     }
	INC  R9
	RJMP _0xB1
_0xB2:
; 0000 041A 
; 0000 041B     ((unsigned char *)data_buff)[14] = ',';
	CALL SUBOPT_0x1F
; 0000 041C     for (loop_index = 15; loop_index < 22; loop_index++)
_0xB4:
	CALL SUBOPT_0x20
	BRSH _0xB5
; 0000 041D     {
; 0000 041E         ((unsigned char *)data_buff)[loop_index] = 0x30;
	CALL SUBOPT_0x21
	LDI  R30,LOW(48)
	ST   X,R30
; 0000 041F     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xB4
_0xB5:
; 0000 0420     ((unsigned char *)data_buff)[22] = ',';
	CALL SUBOPT_0x22
; 0000 0421 
; 0000 0422     i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
	CALL SUBOPT_0x23
; 0000 0423     j = 26;
; 0000 0424     for (i = 0; i < 2; i++)
_0xB7:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xB8
; 0000 0425     {
; 0000 0426         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1C
	ST   X,R30
; 0000 0427         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1E
	ST   X,R30
; 0000 0428     }
	INC  R9
	RJMP _0xB7
_0xB8:
; 0000 0429 
; 0000 042A     //send request strign
; 0000 042B     for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
	CLR  R6
	CLR  R7
_0xBA:
	CALL SUBOPT_0x25
	BRSH _0xBB
; 0000 042C     {
; 0000 042D         putchar( ((unsigned char *)data_buff)[loop_index] );
	CALL SUBOPT_0x21
	LD   R26,X
	CALL _putchar
; 0000 042E     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xBA
_0xBB:
; 0000 042F     putchar('\r');
	CALL SUBOPT_0x26
; 0000 0430     putchar('\n');
; 0000 0431 }//req_data_length()
	RJMP _0x2060003
; .FEND
;//-----------------------------------------------------------------------------
;/**
; * @brief Send update flash result.
; *
; * @param result
; */
;void send_upgd_result(unsigned int result)
; 0000 0439 {
_send_upgd_result:
; .FSTART _send_upgd_result
; 0000 043A     ((unsigned char *)data_buff)[0] = 'B';
	ST   -Y,R27
	ST   -Y,R26
;	result -> Y+0
	LDI  R30,LOW(66)
	STS  _data_buff,R30
; 0000 043B     ((unsigned char *)data_buff)[1] = 'L';
	LDI  R30,LOW(76)
	__PUTB1MN _data_buff,1
; 0000 043C     ((unsigned char *)data_buff)[2] = 'D';
	LDI  R30,LOW(68)
	__PUTB1MN _data_buff,2
; 0000 043D     ((unsigned char *)data_buff)[3] = ',';
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,3
; 0000 043E     ((unsigned char *)data_buff)[4] = DEVICE_ID;
	LDI  R30,LOW(49)
	__PUTB1MN _data_buff,4
; 0000 043F     ((unsigned char *)data_buff)[5] = ',';
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,5
; 0000 0440     ((unsigned char *)data_buff)[6] = 'U';
	LDI  R30,LOW(85)
	__PUTB1MN _data_buff,6
; 0000 0441     ((unsigned char *)data_buff)[7] = 'G';
	LDI  R30,LOW(71)
	__PUTB1MN _data_buff,7
; 0000 0442     ((unsigned char *)data_buff)[8] = 'R';
	LDI  R30,LOW(82)
	CALL SUBOPT_0x1A
; 0000 0443     ((unsigned char *)data_buff)[9] = ',';
; 0000 0444 
; 0000 0445     j = 13;
; 0000 0446     for (i = 0; i < 2; i++)
_0xBD:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xBE
; 0000 0447     {
; 0000 0448         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&result)[i] & 0xf];
	CALL SUBOPT_0x1B
	CALL SUBOPT_0x1C
	CALL SUBOPT_0x1D
; 0000 0449         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&result)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x1E
	MOVW R26,R0
	ST   X,R30
; 0000 044A     }
	INC  R9
	RJMP _0xBD
_0xBE:
; 0000 044B 
; 0000 044C     ((unsigned char *)data_buff)[14] = ',';
	CALL SUBOPT_0x1F
; 0000 044D     for (loop_index = 15; loop_index < 22; loop_index++)
_0xC0:
	CALL SUBOPT_0x20
	BRSH _0xC1
; 0000 044E     {
; 0000 044F         ((unsigned char *)data_buff)[loop_index] = 0x30;
	CALL SUBOPT_0x21
	LDI  R30,LOW(48)
	ST   X,R30
; 0000 0450     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xC0
_0xC1:
; 0000 0451     ((unsigned char *)data_buff)[22] = ',';
	CALL SUBOPT_0x22
; 0000 0452 
; 0000 0453     i_temp_var = getCRC16_CCITT((unsigned char *)data_buff, 23);
	CALL SUBOPT_0x23
; 0000 0454     j = 26;
; 0000 0455     for (i = 0; i < 2; i++)
_0xC3:
	LDI  R30,LOW(2)
	CP   R9,R30
	BRSH _0xC4
; 0000 0456     {
; 0000 0457         ((unsigned char *)data_buff)[j--] = lookup[((unsigned char *)&i_temp_var)[i] & 0xf];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1C
	ST   X,R30
; 0000 0458         ((unsigned char *)data_buff)[j--] = lookup[(((unsigned char *)&i_temp_var)[i] & 0xf0) >> 4];
	CALL SUBOPT_0x24
	CALL SUBOPT_0x1E
	ST   X,R30
; 0000 0459     }
	INC  R9
	RJMP _0xC3
_0xC4:
; 0000 045A 
; 0000 045B     //send res strign
; 0000 045C     for (loop_index = 0; loop_index < STD_PKG_SIZE; loop_index++)
	CLR  R6
	CLR  R7
_0xC6:
	CALL SUBOPT_0x25
	BRSH _0xC7
; 0000 045D     {
; 0000 045E         putchar( ((unsigned char *)data_buff)[loop_index] );
	CALL SUBOPT_0x21
	LD   R26,X
	CALL _putchar
; 0000 045F     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xC6
_0xC7:
; 0000 0460     putchar('\r');
	CALL SUBOPT_0x26
; 0000 0461     putchar('\n');
; 0000 0462 }
	RJMP _0x2060003
; .FEND
;//-----------------------------------------------------------------------------
;void update_eeprom_crc(void)
; 0000 0465 {
_update_eeprom_crc:
; .FSTART _update_eeprom_crc
; 0000 0466     for(loop_index = 1; loop_index < EEPROM_DATA_SIZE+1; loop_index++)
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	MOVW R6,R30
_0xC9:
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CP   R6,R30
	CPC  R7,R31
	BRSH _0xCA
; 0000 0467     {
; 0000 0468         eprom_crc_buff[loop_index] = read_eeprom_mem(loop_index);
	MOVW R30,R6
	SUBI R30,LOW(-_eprom_crc_buff)
	SBCI R31,HIGH(-_eprom_crc_buff)
	PUSH R31
	PUSH R30
	MOVW R26,R6
	RCALL _read_eeprom_mem
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0469     }
	MOVW R30,R6
	ADIW R30,1
	MOVW R6,R30
	RJMP _0xC9
_0xCA:
; 0000 046A 
; 0000 046B     i_temp_var = getCRC16_CCITT((unsigned char *)&eprom_crc_buff[1], EEPROM_DATA_SIZE);
	CALL SUBOPT_0x4
	CALL SUBOPT_0x3
; 0000 046C 
; 0000 046D     write_eeprom_mem(EEPROM_CRC_ADDR, (unsigned char)i_temp_var);
	LDI  R30,LOW(9)
	LDI  R31,HIGH(9)
	CALL SUBOPT_0xB
; 0000 046E     write_eeprom_mem(EEPROM_CRC_ADDR+1, (unsigned char)(i_temp_var >> 8));
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL SUBOPT_0x9
; 0000 046F 
; 0000 0470     return;
	RET
; 0000 0471 }//update_eeprom_crc()
; .FEND
;//-----------------------------------------------------------------------------
;#include "defines.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif
     #define WR_SPMCR_REG_R22 out 0x37,r22
;
;#pragma warn-
;
;unsigned char __AddrToZByteToSPMCR_LPM(void flash *addr, unsigned char ctrl)
; 0001 0006 {

	.CSEG
; 0001 0007 #asm
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 0008      ldd  r30,y+1
; 0001 0009      ldd  r31,y+2
; 0001 000A      ld   r22,y
; 0001 000B      WR_SPMCR_REG_R22
; 0001 000C      lpm
; 0001 000D      mov  r30,r0
; 0001 000E #endasm
; 0001 000F }
;
;void __DataToR0ByteToSPMCR_SPM(unsigned char data, unsigned char ctrl)
; 0001 0012 {
___DataToR0ByteToSPMCR_SPM:
; .FSTART ___DataToR0ByteToSPMCR_SPM
; 0001 0013 #asm
	ST   -Y,R26
;	data -> Y+1
;	ctrl -> Y+0
; 0001 0014      ldd  r0,y+1
     ldd  r0,y+1
; 0001 0015      ld   r22,y
     ld   r22,y
; 0001 0016      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 0017      spm
     spm
; 0001 0018 #endasm
; 0001 0019 }
_0x2060003:
	ADIW R28,2
	RET
; .FEND
;
;void __AddrToZWordToR1R0ByteToSPMCR_SPM(void flash *addr, unsigned int data, unsigned char ctrl)
; 0001 001C {
___AddrToZWordToR1R0ByteToSPMCR_SPM:
; .FSTART ___AddrToZWordToR1R0ByteToSPMCR_SPM
; 0001 001D #asm
	ST   -Y,R26
;	*addr -> Y+3
;	data -> Y+1
;	ctrl -> Y+0
; 0001 001E      ldd  r30,y+3
     ldd  r30,y+3
; 0001 001F      ldd  r31,y+4
     ldd  r31,y+4
; 0001 0020      ldd  r0,y+1
     ldd  r0,y+1
; 0001 0021      ldd  r1,y+2
     ldd  r1,y+2
; 0001 0022      ld   r22,y
     ld   r22,y
; 0001 0023      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 0024      spm
     spm
; 0001 0025 #endasm
; 0001 0026 }
	ADIW R28,5
	RET
; .FEND
;
;void __AddrToZByteToSPMCR_SPM(void flash *addr, unsigned char ctrl)
; 0001 0029 {
___AddrToZByteToSPMCR_SPM:
; .FSTART ___AddrToZByteToSPMCR_SPM
; 0001 002A #asm
	ST   -Y,R26
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 002B      ldd  r30,y+1
     ldd  r30,y+1
; 0001 002C      ldd  r31,y+2
     ldd  r31,y+2
; 0001 002D      ld   r22,y
     ld   r22,y
; 0001 002E      WR_SPMCR_REG_R22
     WR_SPMCR_REG_R22
; 0001 002F      spm
     spm
; 0001 0030 #endasm
; 0001 0031 }
_0x2060002:
	ADIW R28,3
	RET
; .FEND
;
;void __AddrToZ24WordToR1R0ByteToSPMCR_SPM(void flash *addr, unsigned int data, unsigned char ctrl)
; 0001 0034 {
; 0001 0035 #asm
;	*addr -> Y+3
;	data -> Y+1
;	ctrl -> Y+0
; 0001 0036      ldd  r30,y+3
; 0001 0037      ldd  r31,y+4
; 0001 0038      ldd  r22,y+5
; 0001 0039      out  rampz,r22
; 0001 003A      ldd  r0,y+1
; 0001 003B      ldd  r1,y+2
; 0001 003C      ld   r22,y
; 0001 003D      WR_SPMCR_REG_R22
; 0001 003E      spm
; 0001 003F #endasm
; 0001 0040 }
;
;void __AddrToZ24ByteToSPMCR_SPM(void flash *addr, unsigned char ctrl)
; 0001 0043 {
; 0001 0044 #asm
;	*addr -> Y+1
;	ctrl -> Y+0
; 0001 0045      ldd  r30,y+1
; 0001 0046      ldd  r31,y+2
; 0001 0047      ldd  r22,y+3
; 0001 0048      out  rampz,r22
; 0001 0049      ld   r22,y
; 0001 004A      WR_SPMCR_REG_R22
; 0001 004B      spm
; 0001 004C #endasm
; 0001 004D }
;
;#ifdef _WARNINGS_ON_
;#pragma warn+
;#endif
;
;#include "crc16_ccitt.h"
;
;/**
; * @brief Get CRC16
; *
; * CRC-16/CCITT-FALSE
; * Poly  : 0x1021
; * Init  : 0xFFFF
; * Revert: false
; * XorOut: 0x0000
; * Check : 0x29B1 ("123456789")
; *
; * @param data Processed data pionter.
; * @param len Length of data in bytes.
; * @return unsigned int CRC16.
; */
;unsigned int getCRC16_CCITT(unsigned char *p_data, unsigned char len)
; 0002 0012 {

	.CSEG
_getCRC16_CCITT:
; .FSTART _getCRC16_CCITT
; 0002 0013     unsigned int crc;
; 0002 0014     unsigned char index;
; 0002 0015 
; 0002 0016     crc = CCIT_INIT;
	ST   -Y,R26
	CALL __SAVELOCR4
;	*p_data -> Y+5
;	len -> Y+4
;	crc -> R16,R17
;	index -> R19
	__GETWRN 16,17,-1
; 0002 0017 
; 0002 0018     while (len--)
_0x40003:
	LDD  R30,Y+4
	SUBI R30,LOW(1)
	STD  Y+4,R30
	SUBI R30,-LOW(1)
	BREQ _0x40005
; 0002 0019     {
; 0002 001A 
; 0002 001B         crc ^= (unsigned int)*p_data++ << 8;
	LDD  R26,Y+5
	LDD  R27,Y+5+1
	LD   R30,X+
	STD  Y+5,R26
	STD  Y+5+1,R27
	MOV  R31,R30
	LDI  R30,0
	__EORWRR 16,17,30,31
; 0002 001C 
; 0002 001D         for (index = 0; index < 8; index++)
	LDI  R19,LOW(0)
_0x40007:
	CPI  R19,8
	BRSH _0x40008
; 0002 001E         {
; 0002 001F             crc = crc & 0x8000 ? (crc << 1) ^ POLYNOM_CCITT : crc << 1;
	SBRS R17,7
	RJMP _0x40009
	MOVW R30,R16
	LSL  R30
	ROL  R31
	LDI  R26,LOW(4129)
	LDI  R27,HIGH(4129)
	EOR  R30,R26
	EOR  R31,R27
	RJMP _0x4000A
_0x40009:
	MOVW R30,R16
	LSL  R30
	ROL  R31
_0x4000A:
	MOVW R16,R30
; 0002 0020         }
	SUBI R19,-1
	RJMP _0x40007
_0x40008:
; 0002 0021     }//while
	RJMP _0x40003
_0x40005:
; 0002 0022 
; 0002 0023     return crc;
	MOVW R30,R16
	CALL __LOADLOCR4
	ADIW R28,7
	RET
; 0002 0024 }
; .FEND
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_adc_noise_red=0x02
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.SET power_ctrl_reg=smcr
	#endif

	.CSEG
_putchar:
; .FSTART _putchar
	ST   -Y,R26
_0x2000006:
	LDS  R30,192
	ANDI R30,LOW(0x20)
	BREQ _0x2000006
	LD   R30,Y
	STS  198,R30
_0x2060001:
	ADIW R28,1
	RET
; .FEND

	.CSEG

	.CSEG

	.DSEG
_timer_1_delay_cnt:
	.BYTE 0x2
_lookup:
	.BYTE 0x10
_data_buff:
	.BYTE 0x12C
_eprom_crc_buff:
	.BYTE 0x8
_new_fw_size:
	.BYTE 0x2
_loaded_data_size:
	.BYTE 0x2
_rx_buffer0:
	.BYTE 0x96
_rx_wr_index0:
	.BYTE 0x1
_rx_rd_index0:
	.BYTE 0x1
_rx_counter0:
	.BYTE 0x1
_i_temp_var:
	.BYTE 0x2
_last_pkg_type:
	.BYTE 0x1
_current_state:
	.BYTE 0x1
_prev_state:
	.BYTE 0x1
_fw_version_saved:
	.BYTE 0x1
_fw_length_saved:
	.BYTE 0x1
_last_fw_part_flg:
	.BYTE 0x1

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	LDI  R30,LOW(211)
	STS  133,R30
	LDI  R30,LOW(0)
	STS  132,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1:
	LDS  R30,_timer_1_delay_cnt
	LDS  R31,_timer_1_delay_cnt+1
	SBIW R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x2:
	LDI  R27,0
	CALL _read_eeprom_mem
	LDI  R31,0
	STS  _i_temp_var,R30
	STS  _i_temp_var+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x3:
	STS  _i_temp_var,R30
	STS  _i_temp_var+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x4:
	__POINTW1MN _eprom_crc_buff,1
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(8)
	JMP  _getCRC16_CCITT

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:35 WORDS
SUBOPT_0x6:
	LDI  R30,LOW(0)
	STS  _loaded_data_size,R30
	STS  _loaded_data_size+1,R30
	LDI  R26,LOW(6)
	LDI  R27,0
	CALL _read_eeprom_mem
	LDI  R31,0
	STS  _loaded_data_size,R30
	STS  _loaded_data_size+1,R31
	LDS  R31,_loaded_data_size
	LDI  R30,LOW(0)
	STS  _loaded_data_size,R30
	STS  _loaded_data_size+1,R31
	LDI  R26,LOW(5)
	LDI  R27,0
	CALL _read_eeprom_mem
	LDS  R26,_loaded_data_size
	LDS  R27,_loaded_data_size+1
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	STS  _loaded_data_size,R30
	STS  _loaded_data_size+1,R31
	LDS  R26,_loaded_data_size
	LDS  R27,_loaded_data_size+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x7:
	LDS  R26,_loaded_data_size
	LDS  R27,_loaded_data_size+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x8:
	__POINTW1MN _data_buff,10
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_i_temp_var)
	LDI  R31,HIGH(_i_temp_var)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R26,LOW(4)
	LDI  R27,0
	JMP  _atoh

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x9:
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_i_temp_var+1
	MOV  R26,R30
	JMP  _write_eeprom_mem

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xA:
	LDI  R30,LOW(0)
	STS  _last_pkg_type,R30
	LDI  R26,LOW(3)
	CALL _new_state
	LDI  R26,LOW(5000)
	LDI  R27,HIGH(5000)
	JMP  _timer_1_start

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xB:
	ST   -Y,R31
	ST   -Y,R30
	LDS  R26,_i_temp_var
	JMP  _write_eeprom_mem

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:31 WORDS
SUBOPT_0xC:
	LDI  R30,LOW(0)
	STS  _new_fw_size,R30
	STS  _new_fw_size+1,R30
	LDI  R26,LOW(4)
	LDI  R27,0
	CALL _read_eeprom_mem
	LDI  R31,0
	STS  _new_fw_size,R30
	STS  _new_fw_size+1,R31
	LDS  R31,_new_fw_size
	LDI  R30,LOW(0)
	STS  _new_fw_size,R30
	STS  _new_fw_size+1,R31
	LDI  R26,LOW(3)
	LDI  R27,0
	CALL _read_eeprom_mem
	LDS  R26,_new_fw_size
	LDS  R27,_new_fw_size+1
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	STS  _new_fw_size,R30
	STS  _new_fw_size+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xD:
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xE:
	CALL _write_eeprom_mem
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xF:
	RCALL SUBOPT_0x7
	LDS  R30,_new_fw_size
	LDS  R31,_new_fw_size+1
	SUB  R30,R26
	SBC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x10:
	CALL __LSLW2
	CALL __LSLW4
	SUBI R30,LOW(-7168)
	SBCI R31,HIGH(-7168)
	MOVW R4,R30
	LDI  R30,LOW(128)
	LDI  R31,HIGH(128)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x11:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(70)
	ST   -Y,R30
	LDI  R26,LOW(4)
	LDI  R27,HIGH(4)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x12:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_data_buff)
	LDI  R31,HIGH(_data_buff)
	RJMP SUBOPT_0x11

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x13:
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	CALL __GETW1P
	LSL  R30
	ROL  R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x14:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R26,LOW(17)
	JMP  ___DataToR0ByteToSPMCR_SPM

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x15:
	LDI  R30,LOW(_data_buff)
	LDI  R31,HIGH(_data_buff)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x16:
	MOVW R30,R16
	LDD  R26,Y+4
	LDD  R27,Y+4+1
	ADD  R30,R26
	ADC  R31,R27
	MOVW R22,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x17:
	MOVW R30,R16
	LSL  R30
	ROL  R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R26,R30
	ADC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x18:
	MOVW R30,R16
	LSL  R30
	ROL  R31
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	ADD  R30,R26
	ADC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x19:
	ST   -Y,R27
	ST   -Y,R26
	LDI  R30,LOW(66)
	STS  _data_buff,R30
	LDI  R30,LOW(76)
	__PUTB1MN _data_buff,1
	LDI  R30,LOW(68)
	__PUTB1MN _data_buff,2
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,3
	LDI  R30,LOW(49)
	__PUTB1MN _data_buff,4
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,5
	LDI  R30,LOW(82)
	__PUTB1MN _data_buff,6
	LDI  R30,LOW(81)
	__PUTB1MN _data_buff,7
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1A:
	__PUTB1MN _data_buff,8
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,9
	LDI  R30,LOW(13)
	MOV  R8,R30
	CLR  R9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:52 WORDS
SUBOPT_0x1B:
	MOV  R30,R8
	DEC  R8
	LDI  R31,0
	SUBI R30,LOW(-_data_buff)
	SBCI R31,HIGH(-_data_buff)
	MOVW R0,R30
	MOV  R30,R9
	LDI  R31,0
	MOVW R26,R28
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x1C:
	ANDI R30,LOW(0xF)
	LDI  R31,0
	SUBI R30,LOW(-_lookup)
	SBCI R31,HIGH(-_lookup)
	LD   R30,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	MOVW R26,R0
	ST   X,R30
	RJMP SUBOPT_0x1B

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:22 WORDS
SUBOPT_0x1E:
	ANDI R30,LOW(0xF0)
	SWAP R30
	ANDI R30,0xF
	LDI  R31,0
	SUBI R30,LOW(-_lookup)
	SBCI R31,HIGH(-_lookup)
	LD   R30,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1F:
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,14
	LDI  R30,LOW(15)
	LDI  R31,HIGH(15)
	MOVW R6,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x20:
	LDI  R30,LOW(22)
	LDI  R31,HIGH(22)
	CP   R6,R30
	CPC  R7,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x21:
	LDI  R26,LOW(_data_buff)
	LDI  R27,HIGH(_data_buff)
	ADD  R26,R6
	ADC  R27,R7
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x22:
	LDI  R30,LOW(44)
	__PUTB1MN _data_buff,22
	RJMP SUBOPT_0x15

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x23:
	LDI  R26,LOW(23)
	CALL _getCRC16_CCITT
	RCALL SUBOPT_0x3
	LDI  R30,LOW(26)
	MOV  R8,R30
	CLR  R9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:42 WORDS
SUBOPT_0x24:
	MOV  R30,R8
	DEC  R8
	LDI  R31,0
	SUBI R30,LOW(-_data_buff)
	SBCI R31,HIGH(-_data_buff)
	MOVW R26,R30
	MOV  R30,R9
	LDI  R31,0
	SUBI R30,LOW(-_i_temp_var)
	SBCI R31,HIGH(-_i_temp_var)
	LD   R30,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x25:
	LDI  R30,LOW(27)
	LDI  R31,HIGH(27)
	CP   R6,R30
	CPC  R7,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x26:
	LDI  R26,LOW(13)
	CALL _putchar
	LDI  R26,LOW(10)
	JMP  _putchar


	.CSEG
__LSLW4:
	LSL  R30
	ROL  R31
__LSLW3:
	LSL  R30
	ROL  R31
__LSLW2:
	LSL  R30
	ROL  R31
	LSL  R30
	ROL  R31
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
