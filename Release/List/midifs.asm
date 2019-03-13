
;CodeVisionAVR C Compiler V3.12 Advanced
;(C) Copyright 1998-2014 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Release
;Chip type              : ATmega16A
;Program type           : Application
;Clock frequency        : 4,000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 256 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: No
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega16A
	#pragma AVRPART MEMORY PROG_FLASH 16384
	#pragma AVRPART MEMORY EEPROM 512
	#pragma AVRPART MEMORY INT_SRAM SIZE 1024
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU GICR=0x3B
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

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

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x045F
	.EQU __DSTACK_SIZE=0x0100
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
	.DEF _nPreset_1=R5
	.DEF _nPreset_2=R4
	.DEF _nPreset_3=R7
	.DEF _nPreset_4=R6
	.DEF _nPreset_5=R9
	.DEF _nPreset_6=R8
	.DEF _nPreset_7=R11
	.DEF _nPreset_8=R10
	.DEF _ucPC_sw=R13
	.DEF _ucFX1_sw=R12

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_tbl10_G102:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G102:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0

_0x3:
	.DB  0x1
_0x4:
	.DB  0x1
_0x0:
	.DB  0x50,0x43,0x0,0x43,0x43,0x0,0x20,0x20
	.DB  0x0,0x3C,0x0,0x3E,0x0,0x53,0x61,0x76
	.DB  0x65,0x20,0x74,0x6F,0x20,0x62,0x61,0x6E
	.DB  0x6B,0x23,0x20,0x0,0x4C,0x6F,0x61,0x64
	.DB  0x20,0x62,0x61,0x6E,0x6B,0x23,0x20,0x0
	.DB  0x58,0x61,0x6E,0x4C,0x61,0x62,0x20,0x46
	.DB  0x53,0x20,0x76,0x32,0x2E,0x30,0x0
_0x2000003:
	.DB  0x80,0xC0
_0x2020060:
	.DB  0x1
_0x2020000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x0A
	.DW  0x04
	.DW  __REG_VARS*2

	.DW  0x01
	.DW  _CurPreset
	.DW  _0x3*2

	.DW  0x01
	.DW  _nBnkNum
	.DW  _0x4*2

	.DW  0x02
	.DW  __base_y_G100
	.DW  _0x2000003*2

	.DW  0x01
	.DW  __seed_G101
	.DW  _0x2020060*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  GICR,R31
	OUT  GICR,R30
	OUT  MCUCR,R30

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
	LDI  R26,__SRAM_START
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
	.ORG 0x160

	.CSEG
;/*****************************************************
;This program was produced by the
;CodeWizardAVR V2.03.8a Evaluation
;Automatic Program Generator
;© Copyright 1998-2008 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project :
;Version :
;Date    : 21.11.2008
;Author  : Freeware, for evaluation and non-commercial use only
;Company :
;Comments:
;
;
;Chip type           : ATmega16L
;Program type        : Application
;Clock frequency     : 4,000000 MHz
;Memory model        : Small
;External RAM size   : 0
;Data Stack size     : 256
;*****************************************************/
;
;#include <mega16a.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x40
	.EQU __sm_mask=0xB0
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0xA0
	.EQU __sm_ext_standby=0xB0
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif
;
;// Alphanumeric LCD Module functions
;#asm
   .equ __lcd_port=0x15 ;PORTC
; 0000 001D #endasm
;#include <lcd.h>
;
;#include <stdlib.h>
;#include <delay.h>
;
;// Standard Input/Output functions
;#include <stdio.h>
;
;#define BUTTON_DELAY 300 // ms
;#define ADC_DELAY 30 // ms
;
;
;//номер миди контроллера для каждой функции устройства (можно сделать настраиваемым, но пока жестко закреплено)
;#define FX1 64 // для остальных кнопок(кроме кнопок смены программ)
;#define FX2 65
;#define FX3 66
;#define FX4 67
;#define FX5 68
;#define FX6 69
;#define FX7 70
;#define FX8 71
;#define EXP 11
;
;//Закрепление определенных функций за конкретными контактами мк
;//конфигурационные кнопки
;#define s_inc_sw    PINB.0
;#define s_dec_sw    PINB.1
;#define s_save_sw   PINB.2
;#define s_load_sw   PINB.3
;//кнопки смены программ(пресетов)
;#define P1_sw       PINA.0
;#define P2_sw       PINA.1
;#define P3_sw       PINA.2
;#define P4_sw       PINA.3
;#define P5_sw       PINA.4
;#define P6_sw       PINA.5
;#define P7_sw       PINA.6
;#define P8_sw       PIND.3
;#define PC_sw       PIND.4
;
;//Пока поддерживается только 10 банков настроек
;//Настройки хранятся в энергонезависимой памяти
;//Эти значения(нули) запишутся в память при программировании,
;//далее при включении/выключении железяки будут хранить настроенное значение
;eeprom unsigned char ucP1[10] = {9,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP2[10] = {11,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP3[10] = {12,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP4[10] = {13,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP5[10] = {11,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP6[10] = {13,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP7[10] = {9,0,0,0,0,0,0,0,0,0};
;eeprom unsigned char ucP8[10] = {12,0,0,0,0,0,0,0,0,0};
;
;
;//4 переключаемых программы(пресета)
;unsigned char nPreset_1 = 0;
;unsigned char nPreset_2 = 0;
;unsigned char nPreset_3 = 0;
;unsigned char nPreset_4 = 0;
;unsigned char nPreset_5 = 0;
;unsigned char nPreset_6 = 0;
;unsigned char nPreset_7 = 0;
;unsigned char nPreset_8 = 0;
;unsigned char ucPC_sw = 0;
;
;//Текущие значения контроллеров
;unsigned char ucFX1_sw = 0;
;unsigned char ucFX2_sw = 0;
;unsigned char ucFX3_sw = 0;
;unsigned char ucFX4_sw = 0;
;unsigned char ucFX5_sw = 0;
;unsigned char ucFX6_sw = 0;
;unsigned char ucFX7_sw = 0;
;unsigned char ucFX8_sw = 0;
;//char ADC_v[4];
;unsigned int ADC_voltage = 0;
;unsigned int ADC_voltage_old = 0;
;//первый активный по умолчанию
;int CurPreset = 1;

	.DSEG
;
;//первый банк грузится при включении
;unsigned char nBnkNum = 1;
;
;void MIDI_CC_send(char cCtrlNum, char cVal)
; 0000 0072 {

	.CSEG
_MIDI_CC_send:
; .FSTART _MIDI_CC_send
; 0000 0073               putchar(0xB0);  //отправляем Control Change сообощение  (пока жестко в первый канал)
	ST   -Y,R26
;	cCtrlNum -> Y+1
;	cVal -> Y+0
	LDI  R26,LOW(176)
	CALL _putchar
; 0000 0074               putchar(cCtrlNum);  // с нужным номером миди контроллера
	LDD  R26,Y+1
	CALL _putchar
; 0000 0075               putchar(cVal);  // и нужным значением
	LD   R26,Y
	CALL _putchar
; 0000 0076 }
	JMP  _0x20C0004
; .FEND
;
;void MIDI_PC_send(char cPrgNum)
; 0000 0079 {
_MIDI_PC_send:
; .FSTART _MIDI_PC_send
; 0000 007A               putchar(0xC0);  //отправляем Program Change сообощение  (пока жестко в первый канал)
	ST   -Y,R26
;	cPrgNum -> Y+0
	LDI  R26,LOW(192)
	CALL _putchar
; 0000 007B               putchar(cPrgNum);  // с нужным номером пресета
	LD   R26,Y
	CALL _putchar
; 0000 007C }
	JMP  _0x20C0001
; .FEND
;
;void redraw_main_window(void)// перерисовка рабочего окна для дисплея 16х2
; 0000 007F {
_redraw_main_window:
; .FSTART _redraw_main_window
; 0000 0080 
; 0000 0081        char cPreset_1[4];
; 0000 0082        char cPreset_2[4];
; 0000 0083        char cPreset_3[4];
; 0000 0084        char cPreset_4[4];
; 0000 0085        char cPreset_5[4];
; 0000 0086        char cPreset_6[4];
; 0000 0087        char cPreset_7[4];
; 0000 0088        char cPreset_8[4];
; 0000 0089 
; 0000 008A        lcd_clear();
	SBIW R28,32
;	cPreset_1 -> Y+28
;	cPreset_2 -> Y+24
;	cPreset_3 -> Y+20
;	cPreset_4 -> Y+16
;	cPreset_5 -> Y+12
;	cPreset_6 -> Y+8
;	cPreset_7 -> Y+4
;	cPreset_8 -> Y+0
	CALL _lcd_clear
; 0000 008B        itoa((nPreset_1 + 1), cPreset_1);
	MOV  R30,R5
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,30
	CALL _itoa
; 0000 008C        lcd_puts(cPreset_1);
	MOVW R26,R28
	ADIW R26,28
	CALL _lcd_puts
; 0000 008D 
; 0000 008E        lcd_gotoxy(4, 0);
	LDI  R30,LOW(4)
	CALL SUBOPT_0x1
; 0000 008F        itoa((nPreset_2 + 1), cPreset_2);
	MOV  R30,R4
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,26
	CALL _itoa
; 0000 0090        lcd_puts(cPreset_2);
	MOVW R26,R28
	ADIW R26,24
	CALL _lcd_puts
; 0000 0091 
; 0000 0092        lcd_gotoxy(7, 0);
	LDI  R30,LOW(7)
	CALL SUBOPT_0x1
; 0000 0093        if (ucPC_sw == 0) lcd_putsf("PC");
	TST  R13
	BRNE _0x5
	__POINTW2FN _0x0,0
	CALL _lcd_putsf
; 0000 0094        if (ucPC_sw == 1) lcd_putsf("CC");
_0x5:
	LDI  R30,LOW(1)
	CP   R30,R13
	BRNE _0x6
	__POINTW2FN _0x0,3
	CALL _lcd_putsf
; 0000 0095 
; 0000 0096        lcd_gotoxy(9, 0);
_0x6:
	LDI  R30,LOW(9)
	CALL SUBOPT_0x1
; 0000 0097        itoa((nPreset_3 + 1), cPreset_3);
	MOV  R30,R7
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,22
	CALL _itoa
; 0000 0098        lcd_puts(cPreset_3);
	MOVW R26,R28
	ADIW R26,20
	CALL _lcd_puts
; 0000 0099 
; 0000 009A        lcd_gotoxy(13, 0);
	LDI  R30,LOW(13)
	CALL SUBOPT_0x1
; 0000 009B        itoa((nPreset_4+ 1), cPreset_4);
	MOV  R30,R6
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,18
	CALL _itoa
; 0000 009C        lcd_puts(cPreset_4);
	MOVW R26,R28
	ADIW R26,16
	CALL _lcd_puts
; 0000 009D 
; 0000 009E        lcd_gotoxy(0, 1);
	LDI  R30,LOW(0)
	CALL SUBOPT_0x2
; 0000 009F        itoa((nPreset_5 + 1), cPreset_5);
	MOV  R30,R9
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,14
	CALL _itoa
; 0000 00A0        lcd_puts(cPreset_5);
	MOVW R26,R28
	ADIW R26,12
	CALL _lcd_puts
; 0000 00A1 
; 0000 00A2        lcd_gotoxy(4, 1);
	LDI  R30,LOW(4)
	CALL SUBOPT_0x2
; 0000 00A3        itoa((nPreset_6 + 1), cPreset_6);
	MOV  R30,R8
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,10
	CALL _itoa
; 0000 00A4        lcd_puts(cPreset_6);
	MOVW R26,R28
	ADIW R26,8
	CALL _lcd_puts
; 0000 00A5 
; 0000 00A6        lcd_gotoxy(7, 1);
	LDI  R30,LOW(7)
	CALL SUBOPT_0x2
; 0000 00A7        lcd_putsf("  ");
	__POINTW2FN _0x0,6
	CALL _lcd_putsf
; 0000 00A8        itoa((nPreset_7 + 1), cPreset_7);
	MOV  R30,R11
	CALL SUBOPT_0x0
	MOVW R26,R28
	ADIW R26,6
	CALL _itoa
; 0000 00A9        lcd_puts(cPreset_7);
	MOVW R26,R28
	ADIW R26,4
	CALL _lcd_puts
; 0000 00AA 
; 0000 00AB        lcd_gotoxy(13, 1);
	LDI  R30,LOW(13)
	CALL SUBOPT_0x2
; 0000 00AC        itoa((nPreset_8+ 1), cPreset_8);
	MOV  R30,R10
	CALL SUBOPT_0x0
	CALL SUBOPT_0x3
; 0000 00AD        lcd_puts(cPreset_8);
; 0000 00AE 
; 0000 00AF         //убиваем старый курсор
; 0000 00B0          lcd_gotoxy(3, 0);
	LDI  R30,LOW(3)
	CALL SUBOPT_0x1
; 0000 00B1          lcd_putsf(" ");
	CALL SUBOPT_0x4
; 0000 00B2          lcd_gotoxy(12, 0);
	LDI  R30,LOW(12)
	CALL SUBOPT_0x1
; 0000 00B3          lcd_putsf(" ");
	CALL SUBOPT_0x4
; 0000 00B4          lcd_gotoxy(3, 1);
	LDI  R30,LOW(3)
	CALL SUBOPT_0x2
; 0000 00B5          lcd_putsf(" ");
	CALL SUBOPT_0x4
; 0000 00B6          lcd_gotoxy(12, 1);
	LDI  R30,LOW(12)
	CALL SUBOPT_0x2
; 0000 00B7          lcd_putsf(" ");
	CALL SUBOPT_0x4
; 0000 00B8 
; 0000 00B9         //рисуем новый
; 0000 00BA       switch (CurPreset)
	CALL SUBOPT_0x5
; 0000 00BB        {
; 0000 00BC        		case 1:
	BRNE _0xA
; 0000 00BD                 lcd_gotoxy(3, 0);
	LDI  R30,LOW(3)
	CALL SUBOPT_0x1
; 0000 00BE                 lcd_putsf("<");
	__POINTW2FN _0x0,9
	RJMP _0xC0
; 0000 00BF                 break;
; 0000 00C0             case 2:
_0xA:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0xB
; 0000 00C1                 lcd_gotoxy(3, 0);
	LDI  R30,LOW(3)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RJMP _0xC1
; 0000 00C2                 lcd_putsf(">");
; 0000 00C3     		    break;
; 0000 00C4             case 3:
_0xB:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0xC
; 0000 00C5                 lcd_gotoxy(12, 0);
	LDI  R30,LOW(12)
	CALL SUBOPT_0x1
; 0000 00C6                 lcd_putsf("<");
	__POINTW2FN _0x0,9
	RJMP _0xC0
; 0000 00C7                 break;
; 0000 00C8             case 4:
_0xC:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0xD
; 0000 00C9                 lcd_gotoxy(12, 0);
	LDI  R30,LOW(12)
	ST   -Y,R30
	LDI  R26,LOW(0)
	RJMP _0xC1
; 0000 00CA                 lcd_putsf(">");
; 0000 00CB     		    break;
; 0000 00CC             case 5:
_0xD:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0xE
; 0000 00CD                 lcd_gotoxy(3, 1);
	LDI  R30,LOW(3)
	CALL SUBOPT_0x2
; 0000 00CE                 lcd_putsf("<");
	__POINTW2FN _0x0,9
	RJMP _0xC0
; 0000 00CF                 break;
; 0000 00D0             case 6:
_0xE:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0xF
; 0000 00D1                 lcd_gotoxy(3, 1);
	LDI  R30,LOW(3)
	RJMP _0xC2
; 0000 00D2                 lcd_putsf(">");
; 0000 00D3     		    break;
; 0000 00D4             case 7:
_0xF:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x10
; 0000 00D5                 lcd_gotoxy(12, 1);
	LDI  R30,LOW(12)
	CALL SUBOPT_0x2
; 0000 00D6                 lcd_putsf("<");
	__POINTW2FN _0x0,9
	RJMP _0xC0
; 0000 00D7                 break;
; 0000 00D8             case 8:
_0x10:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x9
; 0000 00D9                 lcd_gotoxy(12, 1);
	LDI  R30,LOW(12)
_0xC2:
	ST   -Y,R30
	LDI  R26,LOW(1)
_0xC1:
	CALL _lcd_gotoxy
; 0000 00DA                 lcd_putsf(">");
	__POINTW2FN _0x0,11
_0xC0:
	CALL _lcd_putsf
; 0000 00DB     		    break;
; 0000 00DC        }
_0x9:
; 0000 00DD }
	ADIW R28,32
	RET
; .FEND
;
;void redraw_save_window(void)// перерисовка конфигурационного окна для дисплея 16х2
; 0000 00E0 {
_redraw_save_window:
; .FSTART _redraw_save_window
; 0000 00E1        char cBnkNum[4];
; 0000 00E2 
; 0000 00E3        lcd_clear();
	SBIW R28,4
;	cBnkNum -> Y+0
	CALL _lcd_clear
; 0000 00E4        lcd_putsf("Save to bank# ");
	__POINTW2FN _0x0,13
	RJMP _0x20C0005
; 0000 00E5        itoa(nBnkNum, cBnkNum);
; 0000 00E6        lcd_puts(cBnkNum);
; 0000 00E7 
; 0000 00E8 }
; .FEND
;
;
;void redraw_load_window(void)// перерисовка конфигурационного окна для дисплея 16х2
; 0000 00EC {
_redraw_load_window:
; .FSTART _redraw_load_window
; 0000 00ED        char cBnkNum[4];
; 0000 00EE 
; 0000 00EF        lcd_clear();
	SBIW R28,4
;	cBnkNum -> Y+0
	CALL _lcd_clear
; 0000 00F0        lcd_putsf("Load bank# ");
	__POINTW2FN _0x0,28
_0x20C0005:
	CALL _lcd_putsf
; 0000 00F1        itoa(nBnkNum, cBnkNum);
	LDS  R30,_nBnkNum
	LDI  R31,0
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x3
; 0000 00F2        lcd_puts(cBnkNum);
; 0000 00F3 }
	ADIW R28,4
	RET
; .FEND
;
;
;
;// Declare your global variables here
;
;void main(void)
; 0000 00FA {
_main:
; .FSTART _main
; 0000 00FB // Declare your local variables here
; 0000 00FC 
; 0000 00FD // Input/Output Ports initialization
; 0000 00FE // Port A initialization
; 0000 00FF // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0100 // State7=P State6=P State5=P State4=P State3=P State2=P State1=P State0=P
; 0000 0101 PORTA=0xFF;
	LDI  R30,LOW(255)
	OUT  0x1B,R30
; 0000 0102 DDRA=0x00;
	LDI  R30,LOW(0)
	OUT  0x1A,R30
; 0000 0103 
; 0000 0104 // Port B initialization
; 0000 0105 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0106 // State7=T State6=T State5=T State4=T State3=P State2=P State1=P State0=P
; 0000 0107 PORTB=0x0F;
	LDI  R30,LOW(15)
	OUT  0x18,R30
; 0000 0108 DDRB=0x00;
	LDI  R30,LOW(0)
	OUT  0x17,R30
; 0000 0109 
; 0000 010A // Port C initialization
; 0000 010B // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 010C // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T
; 0000 010D PORTC=0x00;
	OUT  0x15,R30
; 0000 010E DDRC=0x00;
	OUT  0x14,R30
; 0000 010F 
; 0000 0110 // Port D initialization
; 0000 0111 // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In
; 0000 0112 // State7=T State6=T State5=T State4=T State3=P State2=P State1=T State0=T
; 0000 0113 PORTD=0x1A;
	LDI  R30,LOW(26)
	OUT  0x12,R30
; 0000 0114 DDRD=0x00;
	LDI  R30,LOW(0)
	OUT  0x11,R30
; 0000 0115 
; 0000 0116 // Timer/Counter 0 initialization
; 0000 0117 // Clock source: System Clock
; 0000 0118 // Clock value: Timer 0 Stopped
; 0000 0119 // Mode: Normal top=FFh
; 0000 011A // OC0 output: Disconnected
; 0000 011B TCCR0=0x00;
	OUT  0x33,R30
; 0000 011C TCNT0=0x00;
	OUT  0x32,R30
; 0000 011D OCR0=0x00;
	OUT  0x3C,R30
; 0000 011E 
; 0000 011F // Timer/Counter 1 initialization
; 0000 0120 // Clock source: System Clock
; 0000 0121 // Clock value: Timer 1 Stopped
; 0000 0122 // Mode: Normal top=FFFFh
; 0000 0123 // OC1A output: Discon.
; 0000 0124 // OC1B output: Discon.
; 0000 0125 // Noise Canceler: Off
; 0000 0126 // Input Capture on Falling Edge
; 0000 0127 // Timer 1 Overflow Interrupt: Off
; 0000 0128 // Input Capture Interrupt: Off
; 0000 0129 // Compare A Match Interrupt: Off
; 0000 012A // Compare B Match Interrupt: Off
; 0000 012B TCCR1A=0x00;
	OUT  0x2F,R30
; 0000 012C TCCR1B=0x00;
	OUT  0x2E,R30
; 0000 012D TCNT1H=0x00;
	OUT  0x2D,R30
; 0000 012E TCNT1L=0x00;
	OUT  0x2C,R30
; 0000 012F ICR1H=0x00;
	OUT  0x27,R30
; 0000 0130 ICR1L=0x00;
	OUT  0x26,R30
; 0000 0131 OCR1AH=0x00;
	OUT  0x2B,R30
; 0000 0132 OCR1AL=0x00;
	OUT  0x2A,R30
; 0000 0133 OCR1BH=0x00;
	OUT  0x29,R30
; 0000 0134 OCR1BL=0x00;
	OUT  0x28,R30
; 0000 0135 
; 0000 0136 // Timer/Counter 2 initialization
; 0000 0137 // Clock source: System Clock
; 0000 0138 // Clock value: Timer 2 Stopped
; 0000 0139 // Mode: Normal top=FFh
; 0000 013A // OC2 output: Disconnected
; 0000 013B ASSR=0x00;
	OUT  0x22,R30
; 0000 013C TCCR2=0x00;
	OUT  0x25,R30
; 0000 013D TCNT2=0x00;
	OUT  0x24,R30
; 0000 013E OCR2=0x00;
	OUT  0x23,R30
; 0000 013F 
; 0000 0140 // External Interrupt(s) initialization
; 0000 0141 // INT0: On
; 0000 0142 // INT0 Mode: Falling Edge
; 0000 0143 // INT1: Off
; 0000 0144 // INT2: Off
; 0000 0145 /*GICR|=0x40;
; 0000 0146 MCUCR=0x00;
; 0000 0147 MCUCSR=0x00;
; 0000 0148 GIFR=0x40;*/
; 0000 0149 
; 0000 014A MCUCR=0x00;
	OUT  0x35,R30
; 0000 014B MCUCSR=0x00;
	OUT  0x34,R30
; 0000 014C 
; 0000 014D // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 014E TIMSK=0x00;
	OUT  0x39,R30
; 0000 014F 
; 0000 0150 // USART initialization
; 0000 0151 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 0152 // USART Receiver: Off
; 0000 0153 // USART Transmitter: On
; 0000 0154 // USART Mode: Asynchronous
; 0000 0155 // USART Baud Rate: 31250
; 0000 0156 UCSRA=0x00;
	OUT  0xB,R30
; 0000 0157 UCSRB=0x08;
	LDI  R30,LOW(8)
	OUT  0xA,R30
; 0000 0158 UCSRC=0x86;
	LDI  R30,LOW(134)
	OUT  0x20,R30
; 0000 0159 UBRRH=0x00;
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 015A UBRRL=0x07;
	LDI  R30,LOW(7)
	OUT  0x9,R30
; 0000 015B 
; 0000 015C 
; 0000 015D // Analog Comparator initialization
; 0000 015E // Analog Comparator: Off
; 0000 015F // Analog Comparator Input Capture by Timer/Counter 1: Off
; 0000 0160 ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 0161 SFIOR=0x00;
	LDI  R30,LOW(0)
	OUT  0x30,R30
; 0000 0162 ADMUX=7;
	LDI  R30,LOW(7)
	OUT  0x7,R30
; 0000 0163 ADCSR=0x87;
	LDI  R30,LOW(135)
	OUT  0x6,R30
; 0000 0164 
; 0000 0165 
; 0000 0166 
; 0000 0167 // LCD module initialization
; 0000 0168 lcd_init(16);
	LDI  R26,LOW(16)
	CALL _lcd_init
; 0000 0169 
; 0000 016A       lcd_putsf("XanLab FS v2.0"); //Превед
	__POINTW2FN _0x0,40
	CALL _lcd_putsf
; 0000 016B       delay_ms(1000);
	LDI  R26,LOW(1000)
	LDI  R27,HIGH(1000)
	CALL _delay_ms
; 0000 016C 
; 0000 016D       nPreset_1 = ucP1[nBnkNum - 1];
	CALL SUBOPT_0x6
	CALL SUBOPT_0x7
; 0000 016E             if(nPreset_1 > 127) nPreset_1 = 0; //Если в памяти было что то больше чем 127,
	BRSH _0x12
	CLR  R5
; 0000 016F             //предпологаем, что была память непроинициализированна, устанавливаем значения в 0
; 0000 0170       nPreset_2 = ucP2[nBnkNum - 1];
_0x12:
	CALL SUBOPT_0x6
	CALL SUBOPT_0x8
; 0000 0171             if(nPreset_2 > 127) nPreset_2 = 0;
	BRSH _0x13
	CLR  R4
; 0000 0172       nPreset_3 = ucP3[nBnkNum - 1];
_0x13:
	CALL SUBOPT_0x6
	CALL SUBOPT_0x9
; 0000 0173             if(nPreset_3 > 127) nPreset_3 = 0;
	BRSH _0x14
	CLR  R7
; 0000 0174       nPreset_4 = ucP4[nBnkNum - 1];
_0x14:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xA
; 0000 0175             if(nPreset_4 > 127) nPreset_4 = 0;
	BRSH _0x15
	CLR  R6
; 0000 0176       nPreset_5 = ucP5[nBnkNum - 1];
_0x15:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xB
; 0000 0177             if(nPreset_5 > 127) nPreset_5 = 0;
	BRSH _0x16
	CLR  R9
; 0000 0178       nPreset_6 = ucP6[nBnkNum - 1];
_0x16:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xC
; 0000 0179             if(nPreset_6 > 127) nPreset_6 = 0;
	BRSH _0x17
	CLR  R8
; 0000 017A       nPreset_7 = ucP7[nBnkNum - 1];
_0x17:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xD
; 0000 017B             if(nPreset_7 > 127) nPreset_7 = 0;
	BRSH _0x18
	CLR  R11
; 0000 017C       nPreset_8 = ucP8[nBnkNum - 1];
_0x18:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xE
; 0000 017D             if(nPreset_8 > 127) nPreset_8 = 0;
	BRSH _0x19
	CLR  R10
; 0000 017E 
; 0000 017F       redraw_main_window();
_0x19:
	RCALL _redraw_main_window
; 0000 0180 
; 0000 0181       // Global enable interrupts
; 0000 0182 //#asm("sei")
; 0000 0183 
; 0000 0184 
; 0000 0185 while (1)
_0x1A:
; 0000 0186       {
; 0000 0187         ADCSR |= 0x40;
	SBI  0x6,6
; 0000 0188         ADC_voltage = (ADCW>>2)-3;
	IN   R30,0x4
	IN   R31,0x4+1
	CALL __LSRW2
	SBIW R30,3
	STS  _ADC_voltage,R30
	STS  _ADC_voltage+1,R31
; 0000 0189          if (ADC_voltage > 112)
	LDS  R26,_ADC_voltage
	LDS  R27,_ADC_voltage+1
	CPI  R26,LOW(0x71)
	LDI  R30,HIGH(0x71)
	CPC  R27,R30
	BRLO _0x1D
; 0000 018A            { ADC_voltage=127 ;}
	LDI  R30,LOW(127)
	LDI  R31,HIGH(127)
	STS  _ADC_voltage,R30
	STS  _ADC_voltage+1,R31
; 0000 018B         if ( ADC_voltage != ADC_voltage_old)
_0x1D:
	LDS  R30,_ADC_voltage_old
	LDS  R31,_ADC_voltage_old+1
	LDS  R26,_ADC_voltage
	LDS  R27,_ADC_voltage+1
	CP   R30,R26
	CPC  R31,R27
	BREQ _0x1E
; 0000 018C           {
; 0000 018D            MIDI_CC_send(EXP, ADC_voltage);
	LDI  R30,LOW(11)
	ST   -Y,R30
	LDS  R26,_ADC_voltage
	RCALL _MIDI_CC_send
; 0000 018E            //lcd_gotoxy(0, 0);
; 0000 018F            //itoa(ADC_voltage, ADC_v);
; 0000 0190            //lcd_puts(ADC_v);
; 0000 0191             ADC_voltage_old = ADC_voltage;
	LDS  R30,_ADC_voltage
	LDS  R31,_ADC_voltage+1
	STS  _ADC_voltage_old,R30
	STS  _ADC_voltage_old+1,R31
; 0000 0192             delay_ms(ADC_DELAY);
	LDI  R26,LOW(30)
	LDI  R27,0
	CALL _delay_ms
; 0000 0193           }
; 0000 0194         if (s_inc_sw == 0) //инкремент значения
_0x1E:
	SBIC 0x16,0
	RJMP _0x1F
; 0000 0195          {
; 0000 0196            #asm("cli")
	cli
; 0000 0197           switch (CurPreset)
	CALL SUBOPT_0x5
; 0000 0198            {
; 0000 0199                 case 1:
	BRNE _0x23
; 0000 019A                     if(nPreset_1 < 127)
	LDI  R30,LOW(127)
	CP   R5,R30
	BRSH _0x24
; 0000 019B                         nPreset_1++;
	INC  R5
; 0000 019C                     break;
_0x24:
	RJMP _0x22
; 0000 019D                 case 2:
_0x23:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x25
; 0000 019E                     if(nPreset_2 < 127)
	LDI  R30,LOW(127)
	CP   R4,R30
	BRSH _0x26
; 0000 019F                         nPreset_2++;
	INC  R4
; 0000 01A0                     break;
_0x26:
	RJMP _0x22
; 0000 01A1                 case 3:
_0x25:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x27
; 0000 01A2                     if(nPreset_3 < 127)
	LDI  R30,LOW(127)
	CP   R7,R30
	BRSH _0x28
; 0000 01A3                         nPreset_3++;
	INC  R7
; 0000 01A4                     break;
_0x28:
	RJMP _0x22
; 0000 01A5                 case 4:
_0x27:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x29
; 0000 01A6                     if(nPreset_4 < 127)
	LDI  R30,LOW(127)
	CP   R6,R30
	BRSH _0x2A
; 0000 01A7                         nPreset_4++;
	INC  R6
; 0000 01A8                     break;
_0x2A:
	RJMP _0x22
; 0000 01A9                 case 5:
_0x29:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x2B
; 0000 01AA                     if(nPreset_5 < 127)
	LDI  R30,LOW(127)
	CP   R9,R30
	BRSH _0x2C
; 0000 01AB                         nPreset_5++;
	INC  R9
; 0000 01AC                     break;
_0x2C:
	RJMP _0x22
; 0000 01AD                 case 6:
_0x2B:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x2D
; 0000 01AE                     if(nPreset_6 < 127)
	LDI  R30,LOW(127)
	CP   R8,R30
	BRSH _0x2E
; 0000 01AF                         nPreset_6++;
	INC  R8
; 0000 01B0                     break;
_0x2E:
	RJMP _0x22
; 0000 01B1                 case 7:
_0x2D:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x2F
; 0000 01B2                     if(nPreset_7 < 127)
	LDI  R30,LOW(127)
	CP   R11,R30
	BRSH _0x30
; 0000 01B3                         nPreset_7++;
	INC  R11
; 0000 01B4                     break;
_0x30:
	RJMP _0x22
; 0000 01B5                 case 8:
_0x2F:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x33
; 0000 01B6                     if(nPreset_8 < 127)
	LDI  R30,LOW(127)
	CP   R10,R30
	BRSH _0x32
; 0000 01B7                         nPreset_8++;
	INC  R10
; 0000 01B8                     break;
_0x32:
; 0000 01B9                 default: break;
_0x33:
; 0000 01BA            }
_0x22:
; 0000 01BB                redraw_main_window();
	CALL SUBOPT_0xF
; 0000 01BC                delay_ms(BUTTON_DELAY);
; 0000 01BD            #asm("sei")
	sei
; 0000 01BE         };
_0x1F:
; 0000 01BF 
; 0000 01C0         if (s_dec_sw == 0) // декремент значения
	SBIC 0x16,1
	RJMP _0x34
; 0000 01C1          {
; 0000 01C2            #asm("cli")
	cli
; 0000 01C3           switch (CurPreset)
	CALL SUBOPT_0x5
; 0000 01C4            {
; 0000 01C5                 case 1:
	BRNE _0x38
; 0000 01C6                     if(nPreset_1 > 0)
	LDI  R30,LOW(0)
	CP   R30,R5
	BRSH _0x39
; 0000 01C7                         nPreset_1--;
	DEC  R5
; 0000 01C8                     break;
_0x39:
	RJMP _0x37
; 0000 01C9                 case 2:
_0x38:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x3A
; 0000 01CA                     if(nPreset_2 > 0)
	LDI  R30,LOW(0)
	CP   R30,R4
	BRSH _0x3B
; 0000 01CB                         nPreset_2--;
	DEC  R4
; 0000 01CC                     break;
_0x3B:
	RJMP _0x37
; 0000 01CD                 case 3:
_0x3A:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x3C
; 0000 01CE                     if(nPreset_3 > 0)
	LDI  R30,LOW(0)
	CP   R30,R7
	BRSH _0x3D
; 0000 01CF                         nPreset_3--;
	DEC  R7
; 0000 01D0                     break;
_0x3D:
	RJMP _0x37
; 0000 01D1                 case 4:
_0x3C:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0x3E
; 0000 01D2                     if(nPreset_4 > 0)
	LDI  R30,LOW(0)
	CP   R30,R6
	BRSH _0x3F
; 0000 01D3                         nPreset_4--;
	DEC  R6
; 0000 01D4                     break;
_0x3F:
	RJMP _0x37
; 0000 01D5                 case 5:
_0x3E:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BRNE _0x40
; 0000 01D6                     if(nPreset_5 > 0)
	LDI  R30,LOW(0)
	CP   R30,R9
	BRSH _0x41
; 0000 01D7                         nPreset_5--;
	DEC  R9
; 0000 01D8                     break;
_0x41:
	RJMP _0x37
; 0000 01D9                 case 6:
_0x40:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0x42
; 0000 01DA                     if(nPreset_6 > 0)
	LDI  R30,LOW(0)
	CP   R30,R8
	BRSH _0x43
; 0000 01DB                         nPreset_6--;
	DEC  R8
; 0000 01DC                     break;
_0x43:
	RJMP _0x37
; 0000 01DD                 case 7:
_0x42:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BRNE _0x44
; 0000 01DE                     if(nPreset_7 > 0)
	LDI  R30,LOW(0)
	CP   R30,R11
	BRSH _0x45
; 0000 01DF                         nPreset_7--;
	DEC  R11
; 0000 01E0                     break;
_0x45:
	RJMP _0x37
; 0000 01E1                 case 8:
_0x44:
	CPI  R30,LOW(0x8)
	LDI  R26,HIGH(0x8)
	CPC  R31,R26
	BRNE _0x48
; 0000 01E2                     if(nPreset_8 > 0)
	LDI  R30,LOW(0)
	CP   R30,R10
	BRSH _0x47
; 0000 01E3                         nPreset_8--;
	DEC  R10
; 0000 01E4                     break;
_0x47:
; 0000 01E5                 default: break;
_0x48:
; 0000 01E6            }
_0x37:
; 0000 01E7                redraw_main_window();
	CALL SUBOPT_0xF
; 0000 01E8                delay_ms(BUTTON_DELAY);
; 0000 01E9            #asm("sei")
	sei
; 0000 01EA         };
_0x34:
; 0000 01EB 
; 0000 01EC         if (s_save_sw == 0) // сохранение в банк
	SBIC 0x16,2
	RJMP _0x49
; 0000 01ED          {
; 0000 01EE           redraw_save_window();
	CALL SUBOPT_0x10
; 0000 01EF            delay_ms(BUTTON_DELAY);
; 0000 01F0            while(s_save_sw == 0){};
_0x4A:
	SBIS 0x16,2
	RJMP _0x4A
; 0000 01F1                  while(1)
_0x4D:
; 0000 01F2                  {
; 0000 01F3                   if ((s_inc_sw == 0) && (nBnkNum < 10)) //инкремент банка
	SBIC 0x16,0
	RJMP _0x51
	LDS  R26,_nBnkNum
	CPI  R26,LOW(0xA)
	BRLO _0x52
_0x51:
	RJMP _0x50
_0x52:
; 0000 01F4                     {
; 0000 01F5                     #asm("cli")
	cli
; 0000 01F6                      nBnkNum++;
	LDS  R30,_nBnkNum
	SUBI R30,-LOW(1)
	STS  _nBnkNum,R30
; 0000 01F7                      redraw_save_window();
	CALL SUBOPT_0x10
; 0000 01F8                      delay_ms(BUTTON_DELAY);
; 0000 01F9                      #asm("sei")
	sei
; 0000 01FA                     }
; 0000 01FB                   if ((s_dec_sw == 0) && (nBnkNum > 1)) //декремент банка
_0x50:
	SBIC 0x16,1
	RJMP _0x54
	LDS  R26,_nBnkNum
	CPI  R26,LOW(0x2)
	BRSH _0x55
_0x54:
	RJMP _0x53
_0x55:
; 0000 01FC                     {
; 0000 01FD                     #asm("cli")
	cli
; 0000 01FE                      nBnkNum--;
	LDS  R30,_nBnkNum
	SUBI R30,LOW(1)
	STS  _nBnkNum,R30
; 0000 01FF                      redraw_save_window();
	CALL SUBOPT_0x10
; 0000 0200                      delay_ms(BUTTON_DELAY);
; 0000 0201                      #asm("sei")
	sei
; 0000 0202                     }
; 0000 0203                   if (s_save_sw == 0) //сохранить банк
_0x53:
	SBIC 0x16,2
	RJMP _0x56
; 0000 0204                     {
; 0000 0205                     #asm("cli")
	cli
; 0000 0206                      ucP1[nBnkNum-1] = nPreset_1;
	CALL SUBOPT_0x6
	SUBI R30,LOW(-_ucP1)
	SBCI R31,HIGH(-_ucP1)
	MOVW R26,R30
	MOV  R30,R5
	CALL SUBOPT_0x11
; 0000 0207                      ucP2[nBnkNum-1] = nPreset_2;
	SUBI R30,LOW(-_ucP2)
	SBCI R31,HIGH(-_ucP2)
	MOVW R26,R30
	MOV  R30,R4
	CALL SUBOPT_0x11
; 0000 0208                      ucP3[nBnkNum-1] = nPreset_3;
	SUBI R30,LOW(-_ucP3)
	SBCI R31,HIGH(-_ucP3)
	MOVW R26,R30
	MOV  R30,R7
	CALL SUBOPT_0x11
; 0000 0209                      ucP4[nBnkNum-1] = nPreset_4;
	SUBI R30,LOW(-_ucP4)
	SBCI R31,HIGH(-_ucP4)
	MOVW R26,R30
	MOV  R30,R6
	CALL SUBOPT_0x11
; 0000 020A                      ucP5[nBnkNum-1] = nPreset_5;
	SUBI R30,LOW(-_ucP5)
	SBCI R31,HIGH(-_ucP5)
	MOVW R26,R30
	MOV  R30,R9
	CALL SUBOPT_0x11
; 0000 020B                      ucP6[nBnkNum-1] = nPreset_6;
	SUBI R30,LOW(-_ucP6)
	SBCI R31,HIGH(-_ucP6)
	MOVW R26,R30
	MOV  R30,R8
	CALL SUBOPT_0x11
; 0000 020C                      ucP7[nBnkNum-1] = nPreset_7;
	SUBI R30,LOW(-_ucP7)
	SBCI R31,HIGH(-_ucP7)
	MOVW R26,R30
	MOV  R30,R11
	CALL SUBOPT_0x11
; 0000 020D                      ucP8[nBnkNum-1] = nPreset_8;
	SUBI R30,LOW(-_ucP8)
	SBCI R31,HIGH(-_ucP8)
	MOVW R26,R30
	MOV  R30,R10
	CALL __EEPROMWRB
; 0000 020E                      redraw_main_window();
	CALL SUBOPT_0xF
; 0000 020F                      delay_ms(BUTTON_DELAY);
; 0000 0210                      while(s_save_sw == 0){};
_0x57:
	SBIS 0x16,2
	RJMP _0x57
; 0000 0211                      #asm("sei")
	sei
; 0000 0212                      break;
	RJMP _0x4F
; 0000 0213                     }
; 0000 0214                   }
_0x56:
	RJMP _0x4D
_0x4F:
; 0000 0215 
; 0000 0216          };
_0x49:
; 0000 0217 
; 0000 0218         if (s_load_sw == 0) // загрузка из банка
	SBIC 0x16,3
	RJMP _0x5A
; 0000 0219          {
; 0000 021A            redraw_load_window();
	CALL SUBOPT_0x12
; 0000 021B            delay_ms(BUTTON_DELAY);
; 0000 021C            while(s_load_sw == 0){};
_0x5B:
	SBIS 0x16,3
	RJMP _0x5B
; 0000 021D                  while(1)
_0x5E:
; 0000 021E                  {
; 0000 021F                   if ((s_inc_sw == 0) && (nBnkNum < 10)) //инкремент банка
	SBIC 0x16,0
	RJMP _0x62
	LDS  R26,_nBnkNum
	CPI  R26,LOW(0xA)
	BRLO _0x63
_0x62:
	RJMP _0x61
_0x63:
; 0000 0220                     {
; 0000 0221                     #asm("cli")
	cli
; 0000 0222                      nBnkNum++;
	LDS  R30,_nBnkNum
	SUBI R30,-LOW(1)
	STS  _nBnkNum,R30
; 0000 0223                      redraw_load_window();
	CALL SUBOPT_0x12
; 0000 0224                      delay_ms(BUTTON_DELAY);
; 0000 0225                      #asm("sei")
	sei
; 0000 0226                     }
; 0000 0227                   if ((s_dec_sw == 0) && (nBnkNum > 1)) //декремент банка
_0x61:
	SBIC 0x16,1
	RJMP _0x65
	LDS  R26,_nBnkNum
	CPI  R26,LOW(0x2)
	BRSH _0x66
_0x65:
	RJMP _0x64
_0x66:
; 0000 0228                     {
; 0000 0229                     #asm("cli")
	cli
; 0000 022A                      nBnkNum--;
	LDS  R30,_nBnkNum
	SUBI R30,LOW(1)
	STS  _nBnkNum,R30
; 0000 022B                      redraw_load_window();
	CALL SUBOPT_0x12
; 0000 022C                      delay_ms(BUTTON_DELAY);
; 0000 022D                      #asm("sei")
	sei
; 0000 022E                     }
; 0000 022F                   if (s_load_sw == 0) //загрузить банк
_0x64:
	SBIC 0x16,3
	RJMP _0x67
; 0000 0230                     {
; 0000 0231                     #asm("cli")
	cli
; 0000 0232                      nPreset_1 = ucP1[nBnkNum-1];
	CALL SUBOPT_0x6
	CALL SUBOPT_0x7
; 0000 0233                         if(nPreset_1 > 127) nPreset_1 = 0;
	BRSH _0x68
	CLR  R5
; 0000 0234                      nPreset_2 = ucP2[nBnkNum-1];
_0x68:
	CALL SUBOPT_0x6
	CALL SUBOPT_0x8
; 0000 0235                         if(nPreset_2 > 127) nPreset_2 = 0;
	BRSH _0x69
	CLR  R4
; 0000 0236                      nPreset_3 = ucP3[nBnkNum-1];
_0x69:
	CALL SUBOPT_0x6
	CALL SUBOPT_0x9
; 0000 0237                         if(nPreset_3 > 127) nPreset_3 = 0;
	BRSH _0x6A
	CLR  R7
; 0000 0238                      nPreset_4 = ucP4[nBnkNum-1];
_0x6A:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xA
; 0000 0239                         if(nPreset_4 > 127) nPreset_4 = 0;
	BRSH _0x6B
	CLR  R6
; 0000 023A                      nPreset_5 = ucP5[nBnkNum-1];
_0x6B:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xB
; 0000 023B                         if(nPreset_5 > 127) nPreset_5 = 0;
	BRSH _0x6C
	CLR  R9
; 0000 023C                      nPreset_6 = ucP6[nBnkNum-1];
_0x6C:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xC
; 0000 023D                         if(nPreset_6 > 127) nPreset_6 = 0;
	BRSH _0x6D
	CLR  R8
; 0000 023E                      nPreset_7 = ucP7[nBnkNum-1];
_0x6D:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xD
; 0000 023F                         if(nPreset_7 > 127) nPreset_7 = 0;
	BRSH _0x6E
	CLR  R11
; 0000 0240                      nPreset_8 = ucP8[nBnkNum-1];
_0x6E:
	CALL SUBOPT_0x6
	CALL SUBOPT_0xE
; 0000 0241                         if(nPreset_8 > 127) nPreset_8 = 0;
	BRSH _0x6F
	CLR  R10
; 0000 0242                      CurPreset = 1;
_0x6F:
	CALL SUBOPT_0x13
; 0000 0243                      MIDI_PC_send(nPreset_1);  // Включаем первый пресет
	MOV  R26,R5
	CALL _MIDI_PC_send
; 0000 0244                      redraw_main_window();
	CALL SUBOPT_0xF
; 0000 0245                      delay_ms(BUTTON_DELAY);
; 0000 0246                      while(s_load_sw == 0){};
_0x70:
	SBIS 0x16,3
	RJMP _0x70
; 0000 0247                      #asm("sei")
	sei
; 0000 0248                      break;
	RJMP _0x60
; 0000 0249                     }
; 0000 024A                   }
_0x67:
	RJMP _0x5E
_0x60:
; 0000 024B           }
; 0000 024C 
; 0000 024D         if (P1_sw == 0) // смена программы(пресета)
_0x5A:
	SBIC 0x19,0
	RJMP _0x73
; 0000 024E         { #asm("cli")
	cli
; 0000 024F          if (ucPC_sw == 0)
	TST  R13
	BRNE _0x74
; 0000 0250            {
; 0000 0251             MIDI_PC_send(nPreset_1);  // Включаем пресет
	MOV  R26,R5
	CALL _MIDI_PC_send
; 0000 0252             CurPreset = 1;// изменяем номер активного пресета
	CALL SUBOPT_0x13
; 0000 0253             redraw_main_window();
	CALL _redraw_main_window
; 0000 0254             delay_ms(BUTTON_DELAY);
	RJMP _0xC3
; 0000 0255              }
; 0000 0256          else
_0x74:
; 0000 0257          {
; 0000 0258             if(ucFX1_sw == 0)// Если был выключен - включить и наоборот
	TST  R12
	BRNE _0x76
; 0000 0259                 ucFX1_sw = 127;
	LDI  R30,LOW(127)
	MOV  R12,R30
; 0000 025A             else
	RJMP _0x77
_0x76:
; 0000 025B                 ucFX1_sw = 0;
	CLR  R12
; 0000 025C             MIDI_CC_send(FX1, ucFX1_sw);   //отправить комманду
_0x77:
	LDI  R30,LOW(64)
	ST   -Y,R30
	MOV  R26,R12
	CALL _MIDI_CC_send
; 0000 025D             delay_ms(BUTTON_DELAY);
_0xC3:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 025E             }
; 0000 025F           while(P1_sw == 0){};
_0x78:
	SBIS 0x19,0
	RJMP _0x78
; 0000 0260             #asm("sei")
	sei
; 0000 0261         }
; 0000 0262 
; 0000 0263         if (P2_sw == 0) // смена программы(пресета)
_0x73:
	SBIC 0x19,1
	RJMP _0x7B
; 0000 0264         { #asm("cli")
	cli
; 0000 0265          if (ucPC_sw == 0)
	TST  R13
	BRNE _0x7C
; 0000 0266            {
; 0000 0267             MIDI_PC_send(nPreset_2);  // Включаем пресет
	MOV  R26,R4
	CALL _MIDI_PC_send
; 0000 0268             CurPreset = 2;// изменяем номер активного пресета
	LDI  R30,LOW(2)
	LDI  R31,HIGH(2)
	CALL SUBOPT_0x14
; 0000 0269             redraw_main_window();
; 0000 026A             delay_ms(BUTTON_DELAY);
	RJMP _0xC4
; 0000 026B              }
; 0000 026C          else
_0x7C:
; 0000 026D          {
; 0000 026E             if(ucFX2_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX2_sw
	CPI  R30,0
	BRNE _0x7E
; 0000 026F                 ucFX2_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xC5
; 0000 0270             else
_0x7E:
; 0000 0271                 ucFX2_sw = 0;
	LDI  R30,LOW(0)
_0xC5:
	STS  _ucFX2_sw,R30
; 0000 0272             MIDI_CC_send(FX2, ucFX2_sw);   //отправить комманду
	LDI  R30,LOW(65)
	ST   -Y,R30
	LDS  R26,_ucFX2_sw
	CALL _MIDI_CC_send
; 0000 0273             delay_ms(BUTTON_DELAY);
_0xC4:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 0274             }
; 0000 0275             while(P2_sw == 0){};
_0x80:
	SBIS 0x19,1
	RJMP _0x80
; 0000 0276             #asm("sei")
	sei
; 0000 0277         }
; 0000 0278 
; 0000 0279         if (P3_sw == 0) // смена программы(пресета)
_0x7B:
	SBIC 0x19,2
	RJMP _0x83
; 0000 027A         { #asm("cli")
	cli
; 0000 027B          if (ucPC_sw == 0)
	TST  R13
	BRNE _0x84
; 0000 027C            {
; 0000 027D             MIDI_PC_send(nPreset_3);  // Включаем пресет
	MOV  R26,R7
	CALL _MIDI_PC_send
; 0000 027E             CurPreset = 3;// изменяем номер активного пресета
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	CALL SUBOPT_0x14
; 0000 027F             redraw_main_window();
; 0000 0280             delay_ms(BUTTON_DELAY);
	RJMP _0xC6
; 0000 0281             }
; 0000 0282          else
_0x84:
; 0000 0283          {
; 0000 0284             if(ucFX3_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX3_sw
	CPI  R30,0
	BRNE _0x86
; 0000 0285                 ucFX3_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xC7
; 0000 0286             else
_0x86:
; 0000 0287                 ucFX3_sw = 0;
	LDI  R30,LOW(0)
_0xC7:
	STS  _ucFX3_sw,R30
; 0000 0288             MIDI_CC_send(FX3, ucFX3_sw);   //отправить комманду
	LDI  R30,LOW(66)
	ST   -Y,R30
	LDS  R26,_ucFX3_sw
	CALL _MIDI_CC_send
; 0000 0289             delay_ms(BUTTON_DELAY);
_0xC6:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 028A             }
; 0000 028B             while(P3_sw == 0){};
_0x88:
	SBIS 0x19,2
	RJMP _0x88
; 0000 028C             #asm("sei")
	sei
; 0000 028D         }
; 0000 028E 
; 0000 028F         if (P4_sw == 0) // смена программы(пресета)
_0x83:
	SBIC 0x19,3
	RJMP _0x8B
; 0000 0290         { #asm("cli")
	cli
; 0000 0291           if (ucPC_sw == 0)
	TST  R13
	BRNE _0x8C
; 0000 0292            {
; 0000 0293             MIDI_PC_send(nPreset_4);  // Включаем пресет
	MOV  R26,R6
	CALL _MIDI_PC_send
; 0000 0294             CurPreset = 4;// изменяем номер активного пресета
	LDI  R30,LOW(4)
	LDI  R31,HIGH(4)
	CALL SUBOPT_0x15
; 0000 0295             redraw_main_window();
; 0000 0296             delay_ms(BUTTON_DELAY);
; 0000 0297             while(P4_sw == 0){}; }
_0x8D:
	SBIS 0x19,3
	RJMP _0x8D
; 0000 0298          else
	RJMP _0x90
_0x8C:
; 0000 0299          {
; 0000 029A             if(ucFX4_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX4_sw
	CPI  R30,0
	BRNE _0x91
; 0000 029B                 ucFX4_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xC8
; 0000 029C             else
_0x91:
; 0000 029D                 ucFX4_sw = 0;
	LDI  R30,LOW(0)
_0xC8:
	STS  _ucFX4_sw,R30
; 0000 029E             MIDI_CC_send(FX4, ucFX4_sw);   //отправить комманду
	LDI  R30,LOW(67)
	ST   -Y,R30
	LDS  R26,_ucFX4_sw
	CALL SUBOPT_0x16
; 0000 029F             delay_ms(BUTTON_DELAY);
; 0000 02A0              }
_0x90:
; 0000 02A1              while(P4_sw == 0){};
_0x93:
	SBIS 0x19,3
	RJMP _0x93
; 0000 02A2             #asm("sei")
	sei
; 0000 02A3         }
; 0000 02A4 
; 0000 02A5         if (P5_sw == 0) // смена значения контроллера(вкл\выкл эффект)
_0x8B:
	SBIC 0x19,4
	RJMP _0x96
; 0000 02A6         { #asm("cli")
	cli
; 0000 02A7         if (ucPC_sw == 0)
	TST  R13
	BRNE _0x97
; 0000 02A8            {
; 0000 02A9             MIDI_PC_send(nPreset_5);  // Включаем пресет
	MOV  R26,R9
	CALL _MIDI_PC_send
; 0000 02AA             CurPreset = 5;// изменяем номер активного пресета
	LDI  R30,LOW(5)
	LDI  R31,HIGH(5)
	CALL SUBOPT_0x15
; 0000 02AB             redraw_main_window();
; 0000 02AC             delay_ms(BUTTON_DELAY);
; 0000 02AD             while(P5_sw == 0){};
_0x98:
	SBIS 0x19,4
	RJMP _0x98
; 0000 02AE            }
; 0000 02AF          else
	RJMP _0x9B
_0x97:
; 0000 02B0          {
; 0000 02B1             if(ucFX5_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX5_sw
	CPI  R30,0
	BRNE _0x9C
; 0000 02B2                 ucFX5_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xC9
; 0000 02B3             else
_0x9C:
; 0000 02B4                 ucFX5_sw = 0;
	LDI  R30,LOW(0)
_0xC9:
	STS  _ucFX5_sw,R30
; 0000 02B5             MIDI_CC_send(FX5, ucFX5_sw);   //отправить комманду
	LDI  R30,LOW(68)
	ST   -Y,R30
	LDS  R26,_ucFX5_sw
	CALL SUBOPT_0x16
; 0000 02B6             delay_ms(BUTTON_DELAY);
; 0000 02B7             }
_0x9B:
; 0000 02B8             while(P5_sw == 0){};
_0x9E:
	SBIS 0x19,4
	RJMP _0x9E
; 0000 02B9             #asm("sei")
	sei
; 0000 02BA         }
; 0000 02BB 
; 0000 02BC         if (P6_sw == 0) // смена значения контроллера(вкл\выкл эффект)
_0x96:
	SBIC 0x19,5
	RJMP _0xA1
; 0000 02BD         { #asm("cli")
	cli
; 0000 02BE          if (ucPC_sw == 0)
	TST  R13
	BRNE _0xA2
; 0000 02BF            {
; 0000 02C0             MIDI_PC_send(nPreset_6);  // Включаем пресет
	MOV  R26,R8
	CALL _MIDI_PC_send
; 0000 02C1             CurPreset = 6;// изменяем номер активного пресета
	LDI  R30,LOW(6)
	LDI  R31,HIGH(6)
	CALL SUBOPT_0x14
; 0000 02C2             redraw_main_window();
; 0000 02C3             delay_ms(BUTTON_DELAY);
	RJMP _0xCA
; 0000 02C4             }
; 0000 02C5          else
_0xA2:
; 0000 02C6          { if(ucFX6_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX6_sw
	CPI  R30,0
	BRNE _0xA4
; 0000 02C7                 ucFX6_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xCB
; 0000 02C8             else
_0xA4:
; 0000 02C9                 ucFX6_sw = 0;
	LDI  R30,LOW(0)
_0xCB:
	STS  _ucFX6_sw,R30
; 0000 02CA             MIDI_CC_send(FX6, ucFX6_sw);   //отправить комманду
	LDI  R30,LOW(69)
	ST   -Y,R30
	LDS  R26,_ucFX6_sw
	CALL _MIDI_CC_send
; 0000 02CB             delay_ms(BUTTON_DELAY);
_0xCA:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 02CC             }
; 0000 02CD             while(P6_sw == 0){};
_0xA6:
	SBIS 0x19,5
	RJMP _0xA6
; 0000 02CE             #asm("sei")
	sei
; 0000 02CF         }
; 0000 02D0 
; 0000 02D1         if (P7_sw == 0) // смена значения контроллера(вкл\выкл эффект)
_0xA1:
	SBIC 0x19,6
	RJMP _0xA9
; 0000 02D2         { #asm("cli")
	cli
; 0000 02D3          if (ucPC_sw == 0)
	TST  R13
	BRNE _0xAA
; 0000 02D4            {
; 0000 02D5             MIDI_PC_send(nPreset_7);  // Включаем пресет
	MOV  R26,R11
	CALL _MIDI_PC_send
; 0000 02D6             CurPreset = 7;// изменяем номер активного пресета
	LDI  R30,LOW(7)
	LDI  R31,HIGH(7)
	CALL SUBOPT_0x14
; 0000 02D7             redraw_main_window();
; 0000 02D8             delay_ms(BUTTON_DELAY);
	RJMP _0xCC
; 0000 02D9            }
; 0000 02DA          else
_0xAA:
; 0000 02DB          { if(ucFX7_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX7_sw
	CPI  R30,0
	BRNE _0xAC
; 0000 02DC                 ucFX7_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xCD
; 0000 02DD             else
_0xAC:
; 0000 02DE                 ucFX7_sw = 0;
	LDI  R30,LOW(0)
_0xCD:
	STS  _ucFX7_sw,R30
; 0000 02DF             MIDI_CC_send(FX7, ucFX7_sw);   //отправить комманду
	LDI  R30,LOW(70)
	ST   -Y,R30
	LDS  R26,_ucFX7_sw
	CALL _MIDI_CC_send
; 0000 02E0             delay_ms(BUTTON_DELAY);
_0xCC:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 02E1          }
; 0000 02E2          while(P7_sw == 0){};
_0xAE:
	SBIS 0x19,6
	RJMP _0xAE
; 0000 02E3          #asm("sei")
	sei
; 0000 02E4         }
; 0000 02E5 
; 0000 02E6         if (P8_sw == 0 )
_0xA9:
	SBIC 0x10,3
	RJMP _0xB1
; 0000 02E7         { #asm("cli")
	cli
; 0000 02E8           if (ucPC_sw == 0)
	TST  R13
	BRNE _0xB2
; 0000 02E9            {
; 0000 02EA             MIDI_PC_send(nPreset_8);  // Включаем пресет
	MOV  R26,R10
	CALL _MIDI_PC_send
; 0000 02EB             CurPreset = 8;// изменяем номер активного пресета
	LDI  R30,LOW(8)
	LDI  R31,HIGH(8)
	CALL SUBOPT_0x14
; 0000 02EC             redraw_main_window();
; 0000 02ED             delay_ms(BUTTON_DELAY);}
	RJMP _0xCE
; 0000 02EE          else
_0xB2:
; 0000 02EF            { if(ucFX8_sw == 0)// Если был выключен - включить и наоборот
	LDS  R30,_ucFX8_sw
	CPI  R30,0
	BRNE _0xB4
; 0000 02F0                 ucFX8_sw = 127;
	LDI  R30,LOW(127)
	RJMP _0xCF
; 0000 02F1             else
_0xB4:
; 0000 02F2                 ucFX8_sw = 0;
	LDI  R30,LOW(0)
_0xCF:
	STS  _ucFX8_sw,R30
; 0000 02F3             MIDI_CC_send(FX8, ucFX8_sw);   //отправить комманду
	LDI  R30,LOW(71)
	ST   -Y,R30
	LDS  R26,_ucFX8_sw
	CALL _MIDI_CC_send
; 0000 02F4             delay_ms(BUTTON_DELAY);
_0xCE:
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	CALL _delay_ms
; 0000 02F5           }
; 0000 02F6           while(P8_sw == 0){};
_0xB6:
	SBIS 0x10,3
	RJMP _0xB6
; 0000 02F7           #asm("sei")
	sei
; 0000 02F8          }
; 0000 02F9        /* if (P8_sw == 0) // смена значения контроллера(вкл\выкл эффект)
; 0000 02FA         {
; 0000 02FB         #asm("cli")
; 0000 02FC             if(ucFX4_sw == 0)
; 0000 02FD                 ucFX4_sw = 127;
; 0000 02FE             else
; 0000 02FF                 ucFX4_sw = 0;
; 0000 0300             MIDI_CC_send(FX4, ucFX4_sw);
; 0000 0301         delay_ms(BUTTON_DELAY);
; 0000 0302         while(P8_sw == 0){};
; 0000 0303         #asm("sei")
; 0000 0304         }     */
; 0000 0305 
; 0000 0306 
; 0000 0307        if (PC_sw == 0) // смена значения контроллера(вкл\выкл эффект)
_0xB1:
	SBIC 0x10,4
	RJMP _0xB9
; 0000 0308         {
; 0000 0309         #asm("cli")
	cli
; 0000 030A             if(ucPC_sw == 0)
	TST  R13
	BRNE _0xBA
; 0000 030B                 ucPC_sw = 1;
	LDI  R30,LOW(1)
	MOV  R13,R30
; 0000 030C             else
	RJMP _0xBB
_0xBA:
; 0000 030D                 ucPC_sw = 0;
	CLR  R13
; 0000 030E         redraw_main_window();
_0xBB:
	CALL _redraw_main_window
; 0000 030F         delay_ms(200);
	LDI  R26,LOW(200)
	LDI  R27,0
	CALL _delay_ms
; 0000 0310         while(PC_sw == 0){};
_0xBC:
	SBIS 0x10,4
	RJMP _0xBC
; 0000 0311         #asm("sei")
	sei
; 0000 0312         }
; 0000 0313      }
_0xB9:
	JMP  _0x1A
; 0000 0314   };
_0xBF:
	RJMP _0xBF
; .FEND
    .equ __lcd_direction=__lcd_port-1
    .equ __lcd_pin=__lcd_port-2
    .equ __lcd_rs=0
    .equ __lcd_rd=1
    .equ __lcd_enable=2
    .equ __lcd_busy_flag=7

	.DSEG

	.CSEG
__lcd_delay_G100:
; .FSTART __lcd_delay_G100
    ldi   r31,15
__lcd_delay0:
    dec   r31
    brne  __lcd_delay0
	RET
; .FEND
__lcd_ready:
; .FSTART __lcd_ready
    in    r26,__lcd_direction
    andi  r26,0xf                 ;set as input
    out   __lcd_direction,r26
    sbi   __lcd_port,__lcd_rd     ;RD=1
    cbi   __lcd_port,__lcd_rs     ;RS=0
__lcd_busy:
	RCALL __lcd_delay_G100
    sbi   __lcd_port,__lcd_enable ;EN=1
	RCALL __lcd_delay_G100
    in    r26,__lcd_pin
    cbi   __lcd_port,__lcd_enable ;EN=0
	RCALL __lcd_delay_G100
    sbi   __lcd_port,__lcd_enable ;EN=1
	RCALL __lcd_delay_G100
    cbi   __lcd_port,__lcd_enable ;EN=0
    sbrc  r26,__lcd_busy_flag
    rjmp  __lcd_busy
	RET
; .FEND
__lcd_write_nibble_G100:
; .FSTART __lcd_write_nibble_G100
    andi  r26,0xf0
    or    r26,r27
    out   __lcd_port,r26          ;write
    sbi   __lcd_port,__lcd_enable ;EN=1
	CALL __lcd_delay_G100
    cbi   __lcd_port,__lcd_enable ;EN=0
	CALL __lcd_delay_G100
	RET
; .FEND
__lcd_write_data:
; .FSTART __lcd_write_data
	ST   -Y,R26
    cbi  __lcd_port,__lcd_rd 	  ;RD=0
    in    r26,__lcd_direction
    ori   r26,0xf0 | (1<<__lcd_rs) | (1<<__lcd_rd) | (1<<__lcd_enable) ;set as output
    out   __lcd_direction,r26
    in    r27,__lcd_port
    andi  r27,0xf
    ld    r26,y
	RCALL __lcd_write_nibble_G100
    ld    r26,y
    swap  r26
	RCALL __lcd_write_nibble_G100
    sbi   __lcd_port,__lcd_rd     ;RD=1
	JMP  _0x20C0002
; .FEND
__lcd_read_nibble_G100:
; .FSTART __lcd_read_nibble_G100
    sbi   __lcd_port,__lcd_enable ;EN=1
	CALL __lcd_delay_G100
    in    r30,__lcd_pin           ;read
    cbi   __lcd_port,__lcd_enable ;EN=0
	CALL __lcd_delay_G100
    andi  r30,0xf0
	RET
; .FEND
_lcd_read_byte0_G100:
; .FSTART _lcd_read_byte0_G100
	CALL __lcd_delay_G100
	RCALL __lcd_read_nibble_G100
    mov   r26,r30
	RCALL __lcd_read_nibble_G100
    cbi   __lcd_port,__lcd_rd     ;RD=0
    swap  r30
    or    r30,r26
	RET
; .FEND
_lcd_gotoxy:
; .FSTART _lcd_gotoxy
	ST   -Y,R26
	CALL __lcd_ready
	LD   R30,Y
	LDI  R31,0
	SUBI R30,LOW(-__base_y_G100)
	SBCI R31,HIGH(-__base_y_G100)
	LD   R30,Z
	LDD  R26,Y+1
	ADD  R26,R30
	CALL __lcd_write_data
	LDD  R30,Y+1
	STS  __lcd_x,R30
	LD   R30,Y
	STS  __lcd_y,R30
_0x20C0004:
	ADIW R28,2
	RET
; .FEND
_lcd_clear:
; .FSTART _lcd_clear
	CALL __lcd_ready
	LDI  R26,LOW(2)
	CALL __lcd_write_data
	CALL __lcd_ready
	LDI  R26,LOW(12)
	CALL __lcd_write_data
	CALL __lcd_ready
	LDI  R26,LOW(1)
	CALL __lcd_write_data
	LDI  R30,LOW(0)
	STS  __lcd_y,R30
	STS  __lcd_x,R30
	RET
; .FEND
_lcd_putchar:
; .FSTART _lcd_putchar
	ST   -Y,R26
    push r30
    push r31
    ld   r26,y
    set
    cpi  r26,10
    breq __lcd_putchar1
    clt
	LDS  R30,__lcd_maxx
	LDS  R26,__lcd_x
	CP   R26,R30
	BRLO _0x2000004
	__lcd_putchar1:
	LDS  R30,__lcd_y
	SUBI R30,-LOW(1)
	STS  __lcd_y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDS  R26,__lcd_y
	RCALL _lcd_gotoxy
	brts __lcd_putchar0
_0x2000004:
	LDS  R30,__lcd_x
	SUBI R30,-LOW(1)
	STS  __lcd_x,R30
    rcall __lcd_ready
    sbi  __lcd_port,__lcd_rs ;RS=1
	LD   R26,Y
	CALL __lcd_write_data
__lcd_putchar0:
    pop  r31
    pop  r30
	JMP  _0x20C0002
; .FEND
_lcd_puts:
; .FSTART _lcd_puts
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
_0x2000005:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x2000007
	MOV  R26,R17
	RCALL _lcd_putchar
	RJMP _0x2000005
_0x2000007:
	RJMP _0x20C0003
; .FEND
_lcd_putsf:
; .FSTART _lcd_putsf
	ST   -Y,R27
	ST   -Y,R26
	ST   -Y,R17
_0x2000008:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ADIW R30,1
	STD  Y+1,R30
	STD  Y+1+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R17,R30
	CPI  R30,0
	BREQ _0x200000A
	MOV  R26,R17
	RCALL _lcd_putchar
	RJMP _0x2000008
_0x200000A:
_0x20C0003:
	LDD  R17,Y+0
	ADIW R28,3
	RET
; .FEND
__long_delay_G100:
; .FSTART __long_delay_G100
    clr   r26
    clr   r27
__long_delay0:
    sbiw  r26,1         ;2 cycles
    brne  __long_delay0 ;2 cycles
	RET
; .FEND
__lcd_init_write_G100:
; .FSTART __lcd_init_write_G100
	ST   -Y,R26
    cbi  __lcd_port,__lcd_rd 	  ;RD=0
    in    r26,__lcd_direction
    ori   r26,0xf7                ;set as output
    out   __lcd_direction,r26
    in    r27,__lcd_port
    andi  r27,0xf
    ld    r26,y
	CALL __lcd_write_nibble_G100
    sbi   __lcd_port,__lcd_rd     ;RD=1
	JMP  _0x20C0002
; .FEND
_lcd_init:
; .FSTART _lcd_init
	ST   -Y,R26
    cbi   __lcd_port,__lcd_enable ;EN=0
    cbi   __lcd_port,__lcd_rs     ;RS=0
	LD   R30,Y
	STS  __lcd_maxx,R30
	SUBI R30,-LOW(128)
	__PUTB1MN __base_y_G100,2
	LD   R30,Y
	SUBI R30,-LOW(192)
	__PUTB1MN __base_y_G100,3
	CALL SUBOPT_0x17
	CALL SUBOPT_0x17
	CALL SUBOPT_0x17
	RCALL __long_delay_G100
	LDI  R26,LOW(32)
	RCALL __lcd_init_write_G100
	RCALL __long_delay_G100
	LDI  R26,LOW(40)
	CALL SUBOPT_0x18
	LDI  R26,LOW(4)
	CALL SUBOPT_0x18
	LDI  R26,LOW(133)
	CALL SUBOPT_0x18
    in    r26,__lcd_direction
    andi  r26,0xf                 ;set as input
    out   __lcd_direction,r26
    sbi   __lcd_port,__lcd_rd     ;RD=1
	CALL _lcd_read_byte0_G100
	CPI  R30,LOW(0x5)
	BREQ _0x200000B
	LDI  R30,LOW(0)
	JMP  _0x20C0001
_0x200000B:
	CALL __lcd_ready
	LDI  R26,LOW(6)
	CALL __lcd_write_data
	CALL _lcd_clear
	LDI  R30,LOW(1)
	JMP  _0x20C0001
; .FEND

	.CSEG
_itoa:
; .FSTART _itoa
	ST   -Y,R27
	ST   -Y,R26
    ld   r26,y+
    ld   r27,y+
    ld   r30,y+
    ld   r31,y+
    adiw r30,0
    brpl __itoa0
    com  r30
    com  r31
    adiw r30,1
    ldi  r22,'-'
    st   x+,r22
__itoa0:
    clt
    ldi  r24,low(10000)
    ldi  r25,high(10000)
    rcall __itoa1
    ldi  r24,low(1000)
    ldi  r25,high(1000)
    rcall __itoa1
    ldi  r24,100
    clr  r25
    rcall __itoa1
    ldi  r24,10
    rcall __itoa1
    mov  r22,r30
    rcall __itoa5
    clr  r22
    st   x,r22
    ret

__itoa1:
    clr	 r22
__itoa2:
    cp   r30,r24
    cpc  r31,r25
    brlo __itoa3
    inc  r22
    sub  r30,r24
    sbc  r31,r25
    brne __itoa2
__itoa3:
    tst  r22
    brne __itoa4
    brts __itoa5
    ret
__itoa4:
    set
__itoa5:
    subi r22,-0x30
    st   x+,r22
    ret
; .FEND

	.DSEG

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x40
	.EQU __sm_mask=0xB0
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0xA0
	.EQU __sm_ext_standby=0xB0
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_putchar:
; .FSTART _putchar
	ST   -Y,R26
putchar0:
     sbis usr,udre
     rjmp putchar0
     ld   r30,y
     out  udr,r30
_0x20C0002:
_0x20C0001:
	ADIW R28,1
	RET
; .FEND

	.CSEG

	.CSEG

	.CSEG

	.ESEG
_ucP1:
	.DB  0x9,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP2:
	.DB  0xB,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP3:
	.DB  0xC,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP4:
	.DB  0xD,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP5:
	.DB  0xB,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP6:
	.DB  0xD,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP7:
	.DB  0x9,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0
_ucP8:
	.DB  0xC,0x0,0x0,0x0
	.DB  0x0,0x0,0x0,0x0
	.DB  0x0,0x0

	.DSEG
_ucFX2_sw:
	.BYTE 0x1
_ucFX3_sw:
	.BYTE 0x1
_ucFX4_sw:
	.BYTE 0x1
_ucFX5_sw:
	.BYTE 0x1
_ucFX6_sw:
	.BYTE 0x1
_ucFX7_sw:
	.BYTE 0x1
_ucFX8_sw:
	.BYTE 0x1
_ADC_voltage:
	.BYTE 0x2
_ADC_voltage_old:
	.BYTE 0x2
_CurPreset:
	.BYTE 0x2
_nBnkNum:
	.BYTE 0x1
__base_y_G100:
	.BYTE 0x4
__lcd_x:
	.BYTE 0x1
__lcd_y:
	.BYTE 0x1
__lcd_maxx:
	.BYTE 0x1
__seed_G101:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x0:
	LDI  R31,0
	ADIW R30,1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x1:
	ST   -Y,R30
	LDI  R26,LOW(0)
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0x2:
	ST   -Y,R30
	LDI  R26,LOW(1)
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x3:
	MOVW R26,R28
	ADIW R26,2
	CALL _itoa
	MOVW R26,R28
	JMP  _lcd_puts

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4:
	__POINTW2FN _0x0,7
	JMP  _lcd_putsf

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x5:
	LDS  R30,_CurPreset
	LDS  R31,_CurPreset+1
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 24 TIMES, CODE SIZE REDUCTION:43 WORDS
SUBOPT_0x6:
	LDS  R30,_nBnkNum
	LDI  R31,0
	SBIW R30,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x7:
	SUBI R30,LOW(-_ucP1)
	SBCI R31,HIGH(-_ucP1)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R5,R30
	LDI  R30,LOW(127)
	CP   R30,R5
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x8:
	SUBI R30,LOW(-_ucP2)
	SBCI R31,HIGH(-_ucP2)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R4,R30
	LDI  R30,LOW(127)
	CP   R30,R4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x9:
	SUBI R30,LOW(-_ucP3)
	SBCI R31,HIGH(-_ucP3)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R7,R30
	LDI  R30,LOW(127)
	CP   R30,R7
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xA:
	SUBI R30,LOW(-_ucP4)
	SBCI R31,HIGH(-_ucP4)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R6,R30
	LDI  R30,LOW(127)
	CP   R30,R6
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xB:
	SUBI R30,LOW(-_ucP5)
	SBCI R31,HIGH(-_ucP5)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R9,R30
	LDI  R30,LOW(127)
	CP   R30,R9
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xC:
	SUBI R30,LOW(-_ucP6)
	SBCI R31,HIGH(-_ucP6)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R8,R30
	LDI  R30,LOW(127)
	CP   R30,R8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xD:
	SUBI R30,LOW(-_ucP7)
	SBCI R31,HIGH(-_ucP7)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R11,R30
	LDI  R30,LOW(127)
	CP   R30,R11
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xE:
	SUBI R30,LOW(-_ucP8)
	SBCI R31,HIGH(-_ucP8)
	MOVW R26,R30
	CALL __EEPROMRDB
	MOV  R10,R30
	LDI  R30,LOW(127)
	CP   R30,R10
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:17 WORDS
SUBOPT_0xF:
	CALL _redraw_main_window
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x10:
	CALL _redraw_save_window
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x11:
	CALL __EEPROMWRB
	RJMP SUBOPT_0x6

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x12:
	CALL _redraw_load_window
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x13:
	LDI  R30,LOW(1)
	LDI  R31,HIGH(1)
	STS  _CurPreset,R30
	STS  _CurPreset+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:13 WORDS
SUBOPT_0x14:
	STS  _CurPreset,R30
	STS  _CurPreset+1,R31
	JMP  _redraw_main_window

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x15:
	STS  _CurPreset,R30
	STS  _CurPreset+1,R31
	RJMP SUBOPT_0xF

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x16:
	CALL _MIDI_CC_send
	LDI  R26,LOW(300)
	LDI  R27,HIGH(300)
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x17:
	CALL __long_delay_G100
	LDI  R26,LOW(48)
	JMP  __lcd_init_write_G100

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x18:
	CALL __lcd_write_data
	JMP  __long_delay_G100


	.CSEG
_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x3E8
	wdr
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

__LSRW2:
	LSR  R31
	ROR  R30
	LSR  R31
	ROR  R30
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

;END OF CODE MARKER
__END_OF_CODE:
