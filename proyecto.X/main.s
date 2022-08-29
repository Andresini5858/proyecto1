;*******************************************************************************
;Universidad del Valle de Guatemala
;IE2023 Programación de Microncontroladores
;Autor: Andrés Lemus 21634
;Compilador: PIC-AS (v2.40), MPLAB X IDE (v6.00)
;Proyecto: Proyecto
;Creado: 23/08/2022
;Última Modificación: 23/08/22
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
    estado1: DS 1
    estado2: DS 1
    delM: DS 1
    NL: DS 1
    NH: DS 1
    DIS: DS 1
    contseg: DS 1
    contlseg: DS 1
    contldec: DS 1
    contlmin: DS 1
    contldecmin: DS 1
    W_TEMP: DS 1
    STATUS_TEMP: DS 1
    
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
    BTFSC PIR1, 0	    ;REVISAR EL BIT DE INTERRUPCIONES DEL Timer0
    CALL TIMER		    ;IR A LA FUNCIóN DEL Timer0
    GOTO POP
  
POP:
    SWAPF STATUS_TEMP, W    ;MOVER EL VALOR DE STATUS GUARDADO EN UNA VARIABLE A W
    MOVWF STATUS	    ;MOVER EL VALOR DE STATUS (AHORA EN W) A STATUS
    SWAPF W_TEMP, F	    ;VOLTEAR LOS NIBBLES PARA QUE AL MOVERLOS A W ESTEN EN ORDEN 
    SWAPF W_TEMP, W	    ;MOVER EL VALOR DE W GUARDADO A W
    RETFIE		    ;REGRESAR DE LA INTERRUPCIóN
    
TIMER:
    BCF PIR1, 0
    ;BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    ;MOVLW 246		    ;MOVER VALOR PARA DELAY DE 20ms a W
    ;MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0
    ;INCF delM, F
    ;INCF contseg, F	    ;INCREMENTAMOS CONTADOR PARA DELAY DE 1s
    ;MOVF contseg, W	    ;MOVEMOS EL CONTADOR DE 1s W
    ;SUBLW 50		    ;RESTAMOS 50 DE W
    ;BTFSS STATUS, 2	    ;CHEQUEAR SI LA RESTA DE 0 SI NO ES 0, RETORNAR
    ;RETURN
    ;CLRF contseg
    BANKSEL TMR1L
    MOVLW 0xDC
    MOVWF TMR1L
    MOVLW 0X0B
    MOVWF TMR1H
    GOTO VERI1
    
VERI1:
    INCF contlseg, F	    ;INCREMENTAR CONTADOR DE UNIDADES DE SEGUNDO
    MOVF contlseg, W	    ;MOVER EL VALOR DEL CONTADOR A W
    SUBLW 10		    ;RESTAR 10 DE W
    BTFSS STATUS, 2	    ;REVISAR SI LA RESTA ES 0
    RETURN		    ;SI LA RESTA NO ES 0, RETORNAR
    CLRF contlseg		    ;SI ES 0, REINCIAR EL CONTADOR
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
    BANKSEL ANSEL	    ;PONER PUERTOS COMO DIGITALES
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISA
    CLRF TRISA		    ;PUERTO A COMO SALIDA 
    CLRF TRISC		    ;PUERTO B COMO SALIDA
    BCF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    CLRF TRISE		    ;PUERTO E COMO SALIDA
    
    BANKSEL TRISB
    BSF TRISB, 3
    BSF TRISB, 4
    BSF TRISB, 5
    BSF TRISB, 6	    ;RB6 COMO ENTRADA	    
    BSF TRISB, 7	    ;RB7 COMO ENTRADA
    
    BANKSEL PORTA	    ;LIMPIAR PUERTOS, PARA INICIARLOS VACIOS
    CLRF PORTA
    CLRF PORTB
    CLRF PORTC 
    CLRF PORTD
    CLRF PORTE
    
    BANKSEL WPUB	    ;DETERMINAR PINES QUE VAN A LLEVAR PULL-UPS
    BSF WPUB, 3
    BSF WPUB, 4
    BSF WPUB, 5		    ;SI PULL-UP
    BSF WPUB, 6		    ;SI PULL-UP
    BSF WPUB, 7		    ;SI PULL-UP
    
    BANKSEL IOCB	    ;DETERMINAR PINES QUE VAN A LLEVAR INTERRUPCIóN ON-CHANGE
    BSF IOCB, 3
    BSF IOCB, 4
    BSF IOCB, 5
    BSF IOCB, 6		    ;SI INTERRUPCIóN
    BSF IOCB, 7		    ;SI INTERRUPCIóN
    
    BANKSEL INTCON	    ;ACTIVAR INTERRUPCIONES
    BSF INTCON, 7	    ;ACRIVAR BIT DE INTERRUPCIONES GLOBALES
    BSF INTCON, 6
    ;BSF INTCON, 3	    ;ACTIVAR BIT DE INTERRUPCIONES DEL PUERTO B
    
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
    
    ;CLRF NL
    ;CLRF NH
    ;CLRF DIS
    CLRF delM
    CLRF contseg	    ;LIMPIAR VARIBLE DE DECENAS DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF contlseg	    ;LIMPIAR VARIBLE DE UNIDADES DE SEGUNDOS PARA QUE INICIE EN 0
    CLRF contldec	    ;LIMPIAR VARIBLE DE CONTADOR PARA DELAY DE 1s PARA QUE INICIE EN 0
    CLRF contlmin
    CLRF contldecmin
    BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    MOVLW 246		    ;MOVER VALOR PARA DELAY DE 20ms a W
    MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0

LOOP:
    BTFSC DIS, 0
    GOTO DIS0
    BTFSC DIS, 1
    GOTO DIS1
    BTFSC DIS, 2
    GOTO DIS2
    BTFSC DIS, 3
    GOTO DIS3
    
DIS0:
    BSF TRISD, 0
    BCF TRISD, 1
    BCF TRISD, 2
    BCF TRISD, 3
    
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
    
    MOVF contldecmin, W
    PAGESEL tabla
    CALL tabla
    PAGESEL DIS3
    MOVWF PORTC    
    BSF DIS, 0
    BCF DIS, 3
    GOTO VERIFICACION
    
VERIFICACION:
    BTFSS INTCON, 2
    GOTO VERIFICACION
    BCF INTCON, 2
    BANKSEL TMR0	    ;IR AL BANCO DEL TIMER 0
    MOVLW 246		    ;MOVER VALOR PARA DELAY DE 20ms a W
    MOVWF TMR0		    ;PONER EL VALOR PARA DELAY DE 20ms EN EL Timer0
    GOTO LOOP
    
;HORAFECHA:
;    BTFSS estado1, 0
;    GOTO HORA
;    GOTO FECHA
;
;HORA:
;    BTFSS estado2, 0
;    GOTO TIMER
;    GOTO CONFIGH
;
;TIMER:
;    MOVF contlseg, W	    ;MOVER VALOR DE CONTADOR DE UNIDADES DE SEGUNDOS A W
;    CALL tabla		    ;DAR EL NUMERO DE INSTRUCCION A LA TABLA PARA QUE ESTA REGRESE LA INSTRUCCION EN TERMINOS DEL DISPLAY A W
;    MOVWF PORTC		    ;MOVER DE INSTRUCCIóN DE LA TABLA AL PUERTO C (DISPLAY 1)
;    MOVF contldec, W	    ;MOVER VALOR DE CONTADOR DE DECENAS DE SEGUNDOS A W
;    CALL tabla		    ;DAR EL NUMERO DE INSTRUCCION A LA TABLA PARA QUE ESTA REGRESE LA INSTRUCCION EN TERMINOS DEL DISPLAY A W
;    MOVWF PORTC		    ;MOVER DE INSTRUCCIóN DE LA TABLA AL PUERTO A (DISPLAY 2)	    
;    GOTO TIMER
;    
;CONFIGH:
;    
;FECHA:
;    BTFSS estado2, 1
;    GOTO FECHA_MAIN
;    GOTO CONFIGF
;    
;FECHA_MAIN:
;    
;CONFIGF:
;    
;PRTB:
;    BTFSS INTCON, 0	    ;REVISAR EL BIT DE INTERRUPCIONES DEL PUERTO B
;    RETURN		    ;REGRESAR
;    BANKSEL PORTB	    ;IR AL BANCO DONDE SE ENCUENTRA EL REGISTRO DE LOS PUERTOS
;    BTFSC PORTB, 4	    ;REVISAR SI EL BOTóN DE INCREMENTAR FUE PRESIONADO
;    CALL anti1		    ;LLAMAR AL ANTIRREBOTE
;    BTFSS PORTB, 4	    ;REVISAR SI SE DEJO DE PRESIONAR EL BOTON
;    CALL ESTADO0_ISR
;    BTFSC PORTB, 5	    ;REVISAR SI EL BOTóN DE DECREMENTAR FUE PRESIONADO
;    CALL anti2
;    BTFSS PORTB, 5
;    CALL ESTADO1_ISR
;    BTFSC PORTB, 6	    ;REVISAR SI EL BOTóN DE DECREMENTAR FUE PRESIONADO
;    CALL anti3
;    BTFSS PORTB, 6
;    CALL ESTADO2_ISR
;    BCF INTCON, 0	    ;LIMPIAR BIT DE INTERRUPCIóN DEL PUERTO B
;    RETURN		    ;REGRESAR
;
;ESTADO0_ISR:			    ;FUNCION DE INCREMENTAR
;    BTFSS ban, 0
;    RETURN
;    BTFSS estado, 0
;    BSF estado, 0
;    BCF estado, 0
;    CLRF ban
;    RETURN
;
;ESTADO1_ISR:			    ;FUNCION DE INCREMENTAR
;    BTFSS ban, 1
;    RETURN
;    BTFSS estado1, 0
;    BSF estado1, 0
;    BCF estado1, 0
;    CALL ESTADO2_ISR
;    CLRF ban
;    RETURN
;    
;ESTADO2_ISR:			    ;FUNCION DE INCREMENTAR
;    BTFSS ban, 2
;    RETURN
;    BTFSS estado1, 0
;    BSF estado1, 0
;    BCF estado1, 0
;    CLRF ban
;    RETURN
;
;
;dec1:
;    BTFSS ban, 1	    ;FUNCION DE DECREMENTAR
;    RETURN
;    DECF PORTD, F
;    CLRF ban
;    RETURN
;
;anti1:			    ;ANTIRREBOTE 1
;    BSF ban, 0
;    RETURN
;    
;anti2:			    ;ANTIRREBOTE 2
;    BSF ban, 1
;    RETURN
; 
;anti3:
;    BSF ban, 2
;    RETURN
;    
;dec1:
;    BTFSS ban, 1	    ;FUNCION DE DECREMENTAR
;    RETURN
;    DECF PORTD, F
;    CLRF ban
;    RETURN
;
END


