;__________________________________________________________________________________________________
; Macros for the register names
R0      EQU 0
R1      EQU 1
R2      EQU 2
R3      EQU 3
R4      EQU 4
R5      EQU 5
R6      EQU 6
R7      EQU 7
R8      EQU 8
R9      EQU 9
RA      EQU 10
RB      EQU 11
RC      EQU 12
RD      EQU 13
RE      EQU 14
RF      EQU 15

;__________________________________________________________________________________________________
; Macros for the MCSMP20J monitor program

STACK   EQU 7FBFH
CALL    EQU 8ADBH
RETURN  EQU 8AEDH

;NOTE: REGISTER RE MUST BE LOADED WITH THE BAUD RATE INFO PRIOR TO
;USING ANY INPUT OR OUTPUT CALLS
;BAUD RATE INFO IS STORED AT 7FCD AND 7FCE
;M(7FCD) GOES INTO RE.1
;M(7FCE) GOES INTO RE.0
BAUD    EQU 7FCDH

INPUT   EQU 8005H
OUTPUT  EQU 821DH

OUTCRLF EQU 8513H
HEXCRLF EQU 8519H
OUTSTR  EQU 8526H

;__________________________________________________________________________________________________
; Start of our Boot Loader
; (On entry, R0 is our program counter)

    CPU 1802
    ORG 0010H

    ; SETUP R2 (Stack)
    LDI HIGH STACK
    PHI R2
    LDI LOW STACK
    PLO R2  ;STACK = 7FBFH
    SEX R2  ;X = 2

    ; SETUP R4 (CALL PC)
    LDI HIGH CALL
    PHI R4
    LDI LOW CALL
    PLO R4  ;R4 = PC FOR CALL SUBROUTINE

    ; SETUP R5 (RETURN PC)
    LDI HIGH RETURN
    PHI R5
    LDI LOW RETURN
    PLO R5  ;R5 = PC FOR RETURN SUBROUTINE

    ;SETUP R3 AS OUR NEW PC
    LDI HIGH START
    PHI R3
    LDI LOW START
    PLO R3
    SEP R3  ;CHANGE PC FROM R0 TO R3

; When calling a subroutine:
; - accumulator value D is passed through
; - R6 is preserved but not passed through
; - RF.1 is trashed.
; When in a subroutine, R6=Caller

;__________________________________________________________________________________________________
; Customized serial input routine

; IN:       N/A
; OUT:      RB.0 = received character
; TRASHED:  R7

MY_INPUT
    ; Load the starting point for the LED animation
    LDI HIGH KnightRider
    PHI R7
    LDI LOW KnightRider
    PLO R7

B96IN           ; Wait for the stop bit
	B3	B96IN

	LDI	$FF     ; Initialize input character in RB.0 to $FF
	PLO	RB

DrawLights
    LDA R7
    STR	R2
	B3  FoundStartBit
	OUT 4
	DEC	R2
    GLO R7
	B3  FoundStartBit
    SMI LOW KnightRider+44
    BNZ B96WaitStartBit
    LDI LOW KnightRider
	B3  FoundStartBit
    PLO R7
    LDI HIGH KnightRider
    PHI R7
	B3  FoundStartBit

B96WaitStartBit
    LDI $00     ; animation inner loop counter

B96StartBitLoop
	NOP
	NOP
	B3  FoundStartBit
	SMI $01
	NOP
	NOP
	B3  FoundStartBit
	BNZ B96StartBitLoop
	BR  DrawLights

FoundStartBit
    LDI  $01    ; Set up D and DF, which takes about a quarter of a bit duration
    SHR
    BR   SkipDelay
    
StartDelay
	LDI $02
B96DelayLoop
	SMI	$01
	BNZ	B96DelayLoop
	; When done with delay, D=0 and DF=1
    
SkipDelay       ; read current bit
	B3	B96IN4
	SKP		    ; if BIT=0 (EF3 PIN HIGH), leave DF=1
B96IN4
	SHR		    ; if BIT=1 (EF3 PIN LOW), set DF=0
	GLO	RB	    ; load incoming byte
	SHRC		; shift new bit into MSB, and oldest bit into DF
	PLO	RB
	LBDF StartDelay

	SEP	R5

;__________________________________________________________________________________________________
; Main program starting point
START
    ; First, check that the serial port setup is supported
    LDI HIGH BAUD
    PHI R7
    LDI LOW BAUD
    PLO R7
    LDA R7
	PHI	RE
    LDN R7
    PLO RE
    SMI $02
    BNZ SerialNotSupported
    GHI RE
    SMI $81
    BZ  SerialOK

SerialNotSupported
    LDI HIGH SerialError
    PHI R7
    LDI LOW SerialError
    PLO R7
    SEP R4
    DW  OUTSTR

Exit    
    LDI $8B
    PHI R0
    LDI $DF
    PLO R0
    SEX R0
    SEP R0  ;BACK TO THE MONITOR PROGRAM WE GO

SerialOK
    ; Get one input character from serial port in RB.0
    SEP R4
    DW  MY_INPUT

    ; IF THE USER PRESSED THE ESC KEY, RETURN TO THE MONITOR PROGRAM
    GLO RB
    SMI 1BH
    BZ  Exit    ;ESC PRESSED SO RETURN BACK TO THE MONITOR

;NOW LETS ECHO THE INPUT TO THE OUTPUT
;WHATEVER IS IN RB.0 IS PASSED TO THE OUTPUT ROUTINE
;MAKE SURE REGISTER RE IS LOADED CORRECTLY

    SEP R4
    DW  OUTPUT
    BR  START  ;GET NEXT KEY DEPRESSION


;__________________________________________________________________________________________________
; Read/Write Data

;__________________________________________________________________________________________________
; Read-only Data

SerialError     TEXT        "Unsupported serial settings. Must be 9600 baud inverted.\r\n\000"
KnightRider     DB          $00, $80, $80, $C0, $C0, $E0, $60, $70, $30, $38, $18, $1C, $0C, $0E, $06, $07, $03, $03, $01, $01, $00, $00, $00, $01, $01, $03, $03, $07, $06, $0E, $0C, $1C, $18, $38, $30, $70, $60, $E0, $C0, $C0, $80, $80, $00, $00

    END

