;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Andrés Lemus 21634
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Proyecto
;Creado: 23/08/2022
;Última Modificación: 31/08/22
;*******************************************************************************
PROCESSOR 16F887
#include <xc.inc>
;*******************************************************************************
;Palabra de Configuración
;*******************************************************************************

;CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF            ; Brown Out Reset Selection bits (BOR enabled)
  CONFIG  IESO = OFF             ; Internal External Switchover bit (Internal/External Switchover mode is enabled)
  CONFIG  FCMEN = OFF            ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

;CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)


;*******************************************************************************
;Variables
;*******************************************************************************
PSECT udata_shr
    ban: DS 1
    estado: DS 1
    CDIS: DS 1
    DIS: DS 1
    contseg: DS 1
    contlseg: DS 1
    contldec: DS 1
    contlmin: DS 1
    contldecmin: DS 1
    contlhora: DS 1
    contldechora: DS 1
    contmesu: DS 1
    contmesud: DS 1
    contlmes: DS 1
    W_TEMP: DS 1
    STATUS_TEMP: DS 1
    
PSECT udata_bank0
    contldia: DS 1
    contdiau: DS 1
    contdiad: DS 1
    cantmes: DS 1
    feb: DS 1
    
;*******************************************************************************
;Vector Reset
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto main
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
PUSH:
    MOVWF W_TEMP	    ;GUARDAR EL VALOR DE W (EN UNA VARIABLE)
    SWAPF STATUS, W	    ;MOVER EL VALOR DE STATUS A W (VOLTEADOS)
    MOVWF STATUS_TEMP	    ;MOVER EL VALOR DE STATUS (AHORA EN W) A UNA VARIABLE
    
ISR:
    BANKSEL TMR1L
    MOVLW 0xDC
    MOVWF TMR1L
    MOVLW 0X0B
    MOVWF TMR1H
    
    BTFSC PIR1, 0	    ;REVISAR EL BIT DE INTERRUPCIONES DEL Timer0
    CALL TIMER		    ;IR A LA FUNCIóN DEL Timer0
    BTFSC INTCON, 0
    CALL PRTB
  
POP:
    SWAPF STATUS_TEMP, W    ;MOVER EL VALOR DE STATUS GUARDADO EN UNA VARIABLE A W
    MOVWF STATUS	    ;MOVER EL VALOR DE STATUS (AHORA EN W) A STATUS
    SWAPF W_TEMP, F	    ;VOLTEAR LOS NIBBLES PARA QUE AL MOVERLOS A W ESTEN EN ORDEN 
    SWAPF W_TEMP, W	    ;MOVER EL VALOR DE W GUARDADO A W
    RETFIE		    ;REGRESAR DE LA INTERRUPCIóN
 
PRTB:
    BTFSS INTCON, 0	    ; RBIF = 1 ?
    GOTO POP
    BTFSS PORTB, 5
    CALL REVISION1
    BTFSC estado, 0
    GOTO ESTADO0_ISR
    BTFSC estado, 1
    GOTO ESTADO1_ISR
    BTFSC estado, 2
    GOTO ESTADO2_ISR
    
ESTADO0_ISR:
    BTFSS PORTB, 6
    BSF estado, 1
    BTFSS PORTB, 6
    BCF estado, 0
    BCF INTCON, 0	    ; RBIF = 0
    BSF CDIS, 0
    BCF CDIS, 1
    BCF CDIS, 2
    BCF CDIS, 3
    BCF CDIS, 4
    BCF CDIS, 5
    GOTO POP
    
ESTADO1_ISR:
    BTFSS PORTB, 6
    BSF estado, 2
    BTFSS PORTB, 6
    BCF estado, 1
    BCF INTCON, 0	    ; RBIF = 0
    BSF DIS, 0
    GOTO POP
    
ESTADO2_ISR:
    BTFSS PORTB, 6
    BSF estado, 0
    BTFSS PORTB, 6
    BCF estado, 2
    BCF INTCON, 0	    ; RBIF = 0
    BSF DIS, 0
    GOTO POP
    
REVISION1:
    BTFSC CDIS, 0
    GOTO CDIS0ISR
    BTFSC CDIS, 1
    GOTO CDIS1ISR
    BTFSC CDIS, 2
    GOTO CDIS2ISR
    BTFSC CDIS, 3
    GOTO CDIS3ISR
    BTFSC CDIS, 4
    GOTO CDIS4ISR
    BTFSC CDIS, 5
    GOTO CDIS5ISR
    GOTO POP
    
CDIS0ISR:
    BCF CDIS, 0
    BSF CDIS, 1
    BCF INTCON, 0
    RETURN
    
CDIS1ISR:
    BCF CDIS, 1
    BSF CDIS, 2
    BCF INTCON, 0
    RETURN
    
CDIS2ISR:
    BCF CDIS, 2
    BSF CDIS, 3
    BCF INTCON, 0
    RETURN
  
CDIS3ISR:
    BCF CDIS, 3
    BSF CDIS, 4
    BCF INTCON, 0
    RETURN
    
CDIS4ISR:
    BCF CDIS, 4
    BSF CDIS, 5
    BCF INTCON, 0
    RETURN
    
CDIS5ISR:
    BCF CDIS, 5
    BSF CDIS, 0
    BCF INTCON, 0
    RETURN
    
TIMER:
    BCF PIR1, 0
    BANKSEL TMR1L
    MOVLW 0xDC
    MOVWF TMR1L
    MOVLW 0X0B
    MOVWF TMR1H
    GOTO VERI1
    
VERI1:
    BTFSS estado, 0
    RETURN
    INCF contlseg, F	    ;INCREMENTAR CONTADOR DE UNIDADES DE SEGUNDO
    MOVF contlseg, W	    ;MOVER EL VALOR DEL CONTADOR A W
    SUBLW 10		    ;RESTAR 10 DE W
    BTFSS STATUS, 2	    ;REVISAR SI LA RESTA ES 0
    RETURN		    ;SI LA RESTA NO ES 0, RETORNAR
    CLRF contlseg		    ;SI ES 0, REINCIAR EL CONTADOR
    BANKSEL TMR1L
    GOTO VERI2
    
VERI2:
    INCF contldec, F	    ;INCREMENTAR CONTADOR DE DECENAS DE SEGUNDO
    MOVF contldec, W	    ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 6		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    RETURN		    ;SI NO ES 0, RETORNAMOS
    CLRF contlseg		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF contldec              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    GOTO VERI3

VERI3:
    INCF contlmin, F         ;INCREMENTAR CONTADOR DE DECENAS DE SEGUNDO
    MOVF contlmin, W        ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 10		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    RETURN		    ;SI NO ES 0, RETORNAMOS
    CLRF contlmin		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF contldec              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    CLRF contlseg
    GOTO VERI4

VERI4:
    INCF contldecmin, F	    ;INCREMENTAR CONTADOR DE DECENAS DE SEGUNDO
    MOVF contldecmin, W	    ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 6		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    RETURN		    ;SI NO ES 0, RETORNAMOS
    CLRF contldecmin
    CLRF contlmin
    CLRF contlseg		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF contldec              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    GOTO VERI5

VERI5:
    INCF contlhora, F	    ;INCREMENTAR CONTADOR DE DECENAS DE SEGUNDO
    MOVF contldechora, W	    ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 2		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    GOTO $+4		    ;SI NO ES 0, RETORNAMOS
    MOVF contlhora, W
    SUBLW 4
    BTFSS STATUS, 2
    GOTO $+8
    CLRF contldechora
    CLRF contlhora
    CLRF contldecmin
    CLRF contlmin
    CLRF contlseg		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF contldec              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    GOTO VERI6
    MOVF contlhora, W	    ;MOVER EL VALOR DEL CONTADOR A W 
    SUBLW 10		    ;RESTAR 6 DE W, YA QUE QUEREMOS QUE CUANDO LLEGUE A 60 SE REINICIE
    BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA ES 0
    RETURN		    ;SI NO ES 0, RETORNAMOS
    INCF contldechora
    CLRF contlhora
    CLRF contldecmin
    CLRF contlmin
    CLRF contlseg		    ;SI ES 0 LIMPIAR EL CONTADOR DE UNIDADES DE SEGUNDOS
    CLRF contldec              ;SI ES 0 LIMPIAR EL CONTADOR DE DECENAS DE SEGUNDOS
    RETURN

VERI6:
    INCF contdiau
    INCF contldia
    CALL CHEQUEO
    BTFSS cantmes, 0
    GOTO
    MOVF contldia
    SUBLW 31
    BTFSS STATUS, 2
    RETURN
    MOVLW 1
    MOVWF contldia
    MOVLW 1
    MOVWF contdiau
    CLRF contdiad
    RETURN
    
CHEQUEO:
    MOVF contlmes
    SUBLW 1
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 3
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 4
    BTFSC STATUS, 2
    BCF cantmes, 0
    MOVF contlmes
    SUBLW 5
    BTFSC STATUS, 2
    BSF cantmes, 1
    MOVF contlmes
    SUBLW 6
    BTFSC STATUS, 2
    BCF cantmes, 0
    MOVF contlmes
    SUBLW 7
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 8
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 9
    BTFSC STATUS, 2
    BCF cantmes, 0
    MOVF contlmes
    SUBLW 10
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 11
    BTFSC STATUS, 2
    BCF cantmes, 0
    MOVF contlmes
    SUBLW 12
    BTFSC STATUS, 2
    BSF cantmes, 0
    MOVF contlmes
    SUBLW 2
    BTFSC STATUS, 2
    CALL CHEQUEO2
    RETURN
    
CHEQUEO2:
    BSF feb, 0
    RETURN
;*******************************************************************************
;Código Principal
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0100
 
tabla:			    ;TABLA DE VALORES PARA DISPLAY
    CLRF PCLATH
    BSF PCLATH, 0
    ANDLW 0x0F		    ;SE PONE UN LíMITE DE 15
    ADDWF PCL		    ;SUMA ENTRE PCL Y W
    RETLW 00111111B;0
    RETLW 00000110B;1
    RETLW 01011011B;2
    RETLW 01001111B;3
    RETLW 01100110B;4
    RETLW 01101101B;5
    RETLW 01111101B;6
    RETLW 00000111B;7
    RETLW 01111111B;8
    RETLW 01100111B;9
    RETLW 01110111B;A
    RETLW 01111100B;B
    RETLW 00111001B;C
    RETLW 01011110B;D
    RETLW 01111001B;E
    RETLW 01110001B;F
    
main:
    global estado, DIS, CDIS
    BANKSEL ANSEL	    ;PONER PUERTOS COMO DIGITALES
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISA
    CLRF TRISA
    CLRF TRISC		    ;PUERTO B COMO SALIDA
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    CLRF TRISE		    ;PUERTO E COMO SALIDA
    
    BANKSEL TRISB
    BSF TRISB, 3
    BSF TRISB, 4
    BSF TRISB, 5
    BSF TRISB, 6	    ;RB7 COMO ENTRADA
    
    BANKSEL PORTA	    ;LIMPIAR PUERTOS, PARA INICIARLOS VACIOS
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC 
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL WPUB	    ;DETERMINAR PINES QUE VAN A LLEVAR PULL-UPS
    BSF WPUB, 3
    BSF WPUB, 4
    BSF WPUB, 5
    BSF WPUB, 6		    ;SI PULL-UP
    
    BANKSEL IOCB	    ;DETERMINAR PINES QUE VAN A LLEVAR INTERRUPCIóN ON-CHANGE
    BCF IOCB, 3
    BCF IOCB, 4
    BSF IOCB, 5
    BSF IOCB, 6		    ;SI INTERRUPCIóN
    
    BANKSEL INTCON	    ;ACTIVAR INTERRUPCIONES
    BSF INTCON, 7	    ;ACRIVAR BIT DE INTERRUPCIONES GLOBALES
    BSF INTCON, 6
    BSF INTCON, 3	    ;ACTIVAR BIT DE INTERRUPCIONES DEL PUERTO B
    BCF INTCON, 0
    
    BANKSEL PIE1
    BSF PIE1, 0
    
    BANKSEL PIR1
    BCF PIR1, 0
    
    BANKSEL T1CON
    BSF T1CON, 5
    BCF T1CON, 4
    BCF T1CON, 1
    BSF T1CON, 0
    
    BANKSEL TMR1L
    MOVLW 0xDC
    MOVWF TMR1L
    MOVLW 0X0B
    MOVWF TMR1H

    BANKSEL OSCCON
    BSF OSCCON, 6	    ;CONFIGURAR OSCILADOR INTERNO A 1MHz
    BCF OSCCON, 5
    BCF OSCCON, 4    
    BSF OSCCON, 0	    ;DETERMINAR QUE SE UTLIZARá OSCILADOR INTERNO
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	    ;LIMPIAR BIT PARA QUE SE PUEDAN USAR PULL-UPS DEL PUERTO B
    BCF OPTION_REG, 5	    ;UTILIZAR EL Timer0 CON EL OSCILADOR INTERNO 
    BCF OPTION_REG, 3	    ;UTILIZAR PRESCALER CON EL Timer0
    
    BSF OPTION_REG, 2	    ;PRESCALER DE 256
    BSF OPTION_REG, 1	    
    BSF OPTION_REG, 0
    
    BSF cantmes, 0
    MOVLW 1
    MOVWF contmesu
    MOVLW 1
    MOVWF contdiau
    MOVLW 1
    MOVWF contlmes
    MOVLW 1
    MOVWF contldia
    CLRF contseg	    ;LIMPIAR VARIBLE DE DECENAS DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF contlseg	    ;LIMPIAR VARIBLE DE UNIDADES DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF contldec	    ;LIMPIAR VARIBLE DE CONTADOR PARA DELAY DE 1s PARA QUE INICIE EN 0
    CLRF contlmin
    CLRF contldecmin
    CLRF contlhora
    CLRF contldechora
    BSF estado, 0
    CLRF ban
    BSF DIS, 0
    CLRF CDIS
    BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    MOVLW 207		    ;MOVER VALOR PARA DELAY DE 20ms a W
    MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0

LOOP:
    BTFSC estado, 0
    GOTO HORA
    BTFSC estado, 1
    GOTO CONFIGHORA
    BTFSC estado, 2
    GOTO FECHA
    ;BTFSC estado, 3
    ;GOTO CONFIGFECHA
    
HORA:
    BSF INTCON, 6
    BTFSC DIS, 0
    GOTO DIS0
    BTFSC DIS, 1
    GOTO DIS1
    BTFSC DIS, 2
    GOTO DIS2
    BTFSC DIS, 3
    GOTO DIS3
    BTFSC DIS, 4
    GOTO DIS4
    BTFSC DIS, 5
    GOTO DIS5
    
CONFIGHORA:
    BCF INTCON, 6
    BTFSC DIS, 0
    GOTO DIS0
    BTFSC DIS, 1
    GOTO DIS1
    BTFSC DIS, 2
    GOTO DIS2
    BTFSC DIS, 3
    GOTO DIS3
    BTFSC DIS, 4
    GOTO DIS4
    BTFSC DIS, 5
    GOTO DIS5
    
FECHA:
    BSF INTCON, 6
    BCF TRISD, 5
    BCF TRISD, 6
    BTFSC DIS, 0
    GOTO DIS0
    BTFSC DIS, 1
    GOTO DIS1
    BTFSC DIS, 2
    GOTO DIS2
    BTFSC DIS, 3
    GOTO DIS3
    BTFSC DIS, 4
    GOTO DIS4
    BTFSC DIS, 5
    GOTO DIS5
    
DIS0:
    BSF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 0
    CALL CON0
    MOVF contlseg, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS0
    MOVWF PORTC    
    BSF DIS, 1
    BCF DIS, 0
    GOTO VERIFICACION
    
DIS1:
    BCF TRISD, 0
    BSF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 1
    CALL CON1
    MOVF contldec, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS1
    MOVWF PORTC    
    BSF DIS, 2
    BCF DIS, 1
    GOTO VERIFICACION
    
DIS2:
    BCF TRISD, 0
    BCF TRISD, 1
    BSF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    
    BTFSS estado, 2
    GOTO $+9
    MOVF contmesu, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS2
    MOVWF PORTC    
    BSF DIS, 3
    BCF DIS, 2
    GOTO VERIFICACION
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 2
    CALL CON2
    MOVF contlmin, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS2
    MOVWF PORTC    
    BSF DIS, 3
    BCF DIS, 2
    GOTO VERIFICACION

DIS3:
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BSF TRISD, 3
    BCF TRISD, 4
    BCF TRISD, 5
    
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 3
    CALL CON3
    MOVF contldecmin, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS3
    MOVWF PORTC    
    BSF DIS, 4
    BCF DIS, 3
    GOTO VERIFICACION
    
DIS4:
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BSF TRISD, 4
    BCF TRISD, 5
    
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 4
    CALL CON4
    MOVF contlhora, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS4
    MOVWF PORTC    
    BSF DIS, 5
    BCF DIS, 4
    GOTO VERIFICACION
    
DIS5:
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    BCF TRISD, 4
    BSF TRISD, 5
    
    BTFSS estado, 1
    GOTO $+3
    BTFSC CDIS, 5
    CALL CON5
    MOVF contldechora, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS5
    MOVWF PORTC    
    BSF DIS, 0
    BCF DIS, 5
    GOTO VERIFICACION
    
VERIFICACION:
    BTFSS INTCON, 2
    GOTO VERIFICACION
    BCF INTCON, 2
    BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    MOVLW 207		    ;MOVER VALOR PARA DELAY DE 20ms a W
    MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0
    GOTO LOOP   
    
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    
CON0:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN0
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC0
    RETURN
    
CON1:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN1
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC1
    RETURN
    
CON2:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN2
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC2
    RETURN
    
CON3:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN3
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC3
    RETURN
    
CON4:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN4
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC4
    RETURN
    
CON5:
    BTFSS PORTB, 3
    CALL ANTI1
    BTFSC PORTB, 3
    CALL IN5
    BTFSS PORTB, 4
    CALL ANTI2
    BTFSC PORTB, 4
    CALL DC5
    RETURN
    
IN0:
    BTFSS ban, 0
    RETURN
    INCF contlseg
    CALL LIMO0
    CLRF ban
    RETURN
DC0:
    BTFSS ban, 1
    RETURN
    DECF contlseg
    CALL LIMU0
    CLRF ban
    RETURN
    
IN1:
    BTFSS ban, 0
    RETURN
    INCF contldec
    CALL LIMO1
    CLRF ban
    RETURN
DC1:
    BTFSS ban, 1
    RETURN
    DECF contldec
    CALL LIMU1
    CLRF ban
    RETURN
    
IN2:
    BTFSS ban, 0
    RETURN
    INCF contlmin
    CALL LIMO2
    CLRF ban
    RETURN
DC2:
    BTFSS ban, 1
    RETURN
    DECF contlmin
    CALL LIMU2
    CLRF ban
    RETURN
    
IN3:
    BTFSS ban, 0
    RETURN
    INCF contldecmin
    CALL LIMO3
    CLRF ban
    RETURN
DC3:
    BTFSS ban, 1
    RETURN
    DECF contldecmin
    CALL LIMU3
    CLRF ban
    RETURN
    
IN4:
    BTFSS ban, 0
    RETURN
    INCF contlhora
    CALL LIMO4
    CLRF ban
    RETURN
DC4:
    BTFSS ban, 1
    RETURN
    DECF contlhora
    CALL LIMU4
    CLRF ban
    RETURN
    
IN5:
    BTFSS ban, 0
    RETURN
    INCF contldechora
    CALL LIMO5
    CLRF ban
    RETURN
DC5:
    BTFSS ban, 1
    RETURN
    DECF contldechora
    CALL LIMU5
    CLRF ban
    RETURN
    
LIMO0:
    MOVF contlseg, W
    SUBLW 10
    BTFSS STATUS, 2
    RETURN
    CLRF contlseg
    RETURN
    
LIMU0:
    MOVF contlseg, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 9
    MOVWF contlseg
    RETURN
    
LIMO1:
    MOVF contldec, W
    SUBLW 6
    BTFSS STATUS, 2
    RETURN
    CLRF contldec
    RETURN
    
LIMU1:
    MOVF contldec, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 5
    MOVWF contldec
    RETURN
    
LIMO2:
    MOVF contlmin, W
    SUBLW 10
    BTFSS STATUS, 2
    RETURN
    CLRF contlmin
    RETURN
    
LIMU2:
    MOVF contlmin, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 9
    MOVWF contlmin
    RETURN
    
LIMO3:
    MOVF contldecmin, W
    SUBLW 6
    BTFSS STATUS, 2
    RETURN
    CLRF contldecmin
    RETURN
    
LIMU3:
    MOVF contldecmin, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 5
    MOVWF contldecmin
    RETURN
    
LIMO4:
    MOVF contlhora, W
    SUBLW 10
    BTFSS STATUS, 2
    RETURN
    CLRF contlhora
    RETURN
    
LIMU4:
    MOVF contlhora, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 9
    MOVWF contlhora
    RETURN
    
LIMO5:
    MOVF contldechora, W
    SUBLW 3
    BTFSS STATUS, 2
    RETURN
    CLRF contldechora
    RETURN
    
LIMU5:
    MOVF contldechora, W
    ANDLW 15
    SUBLW 15
    BTFSS STATUS, 2
    RETURN
    MOVLW 2
    MOVWF contldechora
    RETURN
    
ANTI1:
    BSF ban, 0
    RETURN
    
ANTI2:
    BSF ban, 1
    RETURN
 
END