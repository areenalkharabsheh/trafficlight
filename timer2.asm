;*********************************************************
;this prpgram written by areen alkhrabsheh and ro'oa dofash
;The signal is connected to RB0 
;Timer2 used to get 1 Sec of time to measure the frequency of signal 
;7-Segments is connected to PORTB (We connect RB1 to a, RB2 to b ???.And RB7 to g)
;to return the rang of frequency as a hexadecimal numbers 
;The program uses a PIC16F877A running at crystal oscillator of frequency 4MHz. 
;**********************************************************
 include "p16f877A.inc"
;**********************************************************
; Macro definitions
push	macro

	movwf		WTemp		; WTemp must be reserved in all banks
	swapf		STATUS,W	; store in W without affecting status bits
	banksel		StatusTemp	; select StatusTemp bank
	movwf		StatusTemp	; save STATUS
	endm

pop	macro

	banksel		StatusTemp	; point to StatusTemp bank
	swapf		StatusTemp,W; unswap STATUS nibbles into W	
	movwf		STATUS		; restore STATUS
	swapf		WTemp,F		; unswap W nibbles
	swapf		WTemp,W		; restore W without affecting STATUS
	endm
;**********************************************************
;**********************************************************
; User-defined variables
	
	cblock		0x20		; bank 0 assignnments
			WTemp	    	; WTemp must be reserved in all banks
			StatusTemp
			RB0COUNTS
            RB0INT
			TMR2_Counter
		    R1_Counter
			G1_Counter
			Y1_Counter
		    R2_Counter
			G2_Counter
			Y2_Counter
			Counter5
			check_5
			COUNT5S
	endc

	cblock		0x0A0		; bank 1 assignnments
			WTemp1	    	; bank 1 WTemp
	endc

	cblock		0x120		; bank 2 assignnments
			WTemp2	    	; bank 2 WTemp
	endc

	cblock		0x1A0		; bank 3 assignnments
			WTemp3	    	; bank 3 WTemp
	endc

;**********************************************************
; Start of executable code
	org	0x00		;Reset vector
	nop
	goto    	Main		
	org	0x04	        
	goto		INT_SVC
	;;;;;;; Main program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Main
	call	Initial				;Initialize everything
MainLoop
     goto   Traffic_lights
	goto	MainLoop			;Do it again

;;;;;;;	Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This subroutine performs all initializations of variables and registers.
Initial	
	banksel	TRISB				;Select bank1
	clrf	TRISB				;set all bits of port B to output
	banksel	TRISC				;Select bank1
	clrf	TRISC				;set all bits of port C to output for seven_seg1
	banksel	TRISE				;Select bank1
	clrf	TRISE				;set all bits of port E to output for 7_seg 2
	bsf		TRISB,RB0            ;set bit 0 as input for the signal
    BANKSEL T2CON                ;select bank 0
	movlw	0x7E
	movwf	T2CON			    ;POSTSCALER =(1:16) TMR2
								;Prescaler TMR2 (1:16)
	bsf		INTCON,GIE			;Enable Global Interrupt 
	bsf		INTCON,PEIE			;Enable peripheral interrupts
	bsf		INTCON,INTE			;Enable EXTERNAL INTERRUPT
    banksel PIE1
    bsf     PIE1,TMR2IE         ;TIMER2 INTERRUPT ON

	BANKSEL PR2
	movlw	D'195'				;..
	movwf	PR2  				;SETTING TMR2 TO INTERRUPT EVERY  50ms
			BANKSEL PORTB
	
	movlw	B'00001101' ;tl1 green,tl2 red
	movwf	PORTB			
	clrf	TMR2_Counter
	clrf	RB0COUNTS
    clrf    RB0INT
	clrf 	COUNT5S;
    movlw d'15'
	movwf R1_Counter
	movwf R2_Counter
    movlw d'8'
	movwf G1_Counter
	movwf G2_Counter
    movlw d'4'
	movwf Y1_Counter
	movwf Y2_Counter
    movlw d'6'
	movwf Counter5
	banksel PORTC
    movlw d'8'
	call Seven_segments
	movwf PORTC
	movlw d'0'
	call Seven_segments
	movwf PORTE
	clrf check_5
	Return
;**********************************************************
Seven_segments
addwf PCL
retlw b'00111111';0
retlw b'00000110';1
retlw b'01011011';2
retlw b'01001111';3
retlw b'01100110';4
retlw b'00101101';5
retlw b'01111101';6
retlw b'01000111';7
retlw b'01111111';8
retlw b'01101111';9

;**********************************************************
;;;;;;;	Traffic light subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Traffic_lights
TL1

btfss PORTB,RB1
GOTO   Yellow1
btfss PORTB,RB2
GOTO   Green1
btfss PORTB,RB3
GOTO   Red1
;----------
Green1 ;8s
decf   G1_Counter,f
movf  G1_Counter,w
call Seven_segments
movwf PORTC
movlw d'0'
call Seven_segments
movwf PORTE
movf  G1_Counter,w
btfss	STATUS,Z
GOTO TL2

;--------------
Yellow1 ;4s
movf  Y1_Counter,w
call Seven_segments
movwf PORTC
movlw d'0'
call Seven_segments
movwf PORTE
bcf PORTB,RB1
bsf PORTB,RB2
movf  Y1_Counter,w
addlw d'1'
sublw d'1'
decf   Y1_Counter,f
btfss	STATUS,C
GOTO TL2
;------------
Red1 ;15s
movf check_5
btfsc check_5,0
goto   redcount2
movf  Counter5,w
addlw d'1'
sublw d'1'
decf Counter5
btfsc	STATUS,C
goto   redcount2
movf  Counter5,w
call Seven_segments
movlw d'1'
call Seven_segments
goto colouring
redcount2
movlw 1
movwf check_5
movf  R1_Counter,w
call Seven_segments
movwf PORTC
movlw d'0'
call Seven_segments
movwf PORTE
colouring
bsf PORTB,RB3
movf  R1_Counter,w
addlw d'1'
sublw d'1'
decf   R1_Counter,f
btfss	STATUS,C
goto	TL2
    movlw d'15'
	movwf R1_Counter;
    movlw d'8'
	movwf G1_Counter;
    movlw d'4'
	movwf Y1_Counter;
    movlw d'6'
	movwf Counter5;
	clrf check_5
bsf PORTB,RB1
bcf PORTB,RB2
	banksel PORTC
    movlw d'8'
	call Seven_segments
	movwf PORTC
	movlw d'0'
	call Seven_segments
	movwf PORTE
goto	TL2
;-----------------


TL2
btfss PORTB,RB3
GOTO   Yellow2
btfss PORTB,RB4
GOTO   Green2
GOTO   Red2
Red2 ;15s
bsf PORTB,RB5
decf   R2_Counter,f
movf  R2_Counter,w
btfss	STATUS,Z
GOTO  Continue

Green2 

bsf PORTB,RB3
bcf PORTB,RB4
decf   G2_Counter,f
movf  G2_Counter,w
btfss	STATUS,Z
goto	Continue

Yellow2
bcf PORTB,RB3
bsf PORTB,RB4
decf   Y2_Counter,f
movf  Y2_Counter,w
btfss	STATUS,Z
	goto	Continue	
    movlw d'15'
	movwf R2_Counter;
    movlw d'8'
	movwf G2_Counter;
    movlw d'4'
	movwf Y2_Counter;
goto Red2
goto	Continue
;**********************************************************
; TIMER2 
T2
	
	incf	TMR2_Counter,F
	movf	TMR2_Counter,w
	sublw	D'20'
	btfss	STATUS,Z
	goto	Continue
	clrf	TMR2_Counter
    movfw   COUNT5S ; if the pb is alredy pressed 10 times make
	btfss	STATUS,Z ; the tl1 red for 5 seconds
	goto    redfor5s
    MOVF    RB0INT,W
    SUBLW   D'10'
	BTFSS   STATUS,Z
    goto	Traffic_lights ; continue the lighting
redfor5s
	clrf RB0INT
    bsf  PORTB,RB3
    
    incf COUNT5S ;count for 5 seconds
    movlw COUNT5S
    sublw d'6'
    btfsc STATUS,Z
    clrf  COUNT5S
    Continue
	bcf		PIR1,TMR2IF
	goto	POLL    			;Check for another interrupt
;**********************************************************
;**********************************************************
; EXTERNAL 
EXTERNAL_INTERRUPT
	
	incf	RB0INT,F   ; PUSHBUTTON PRESSES COUNTER
	bcf		INTCON,INTF
	goto	POLL    			;Check for another interrupt
;**********************************************************
INT_SVC
push
POLL
	btfsc	PIR1,TMR2IF			; Check for an TMR2 Interrupt
	goto	T2
    btfsc INTCON,INTF
	goto	EXTERNAL_INTERRUPT	     ; check for an EXTERNAL Interrupt

	pop
	retfie

;**********************************************************
	End