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

MON_OUTSTR  EQU 8526H

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

; IN:       P=7
; OUT:      P=3, RF.1 = received character
; TRASHED:  R8

B96IN_Return
    SEP R3
B96IN
    ; Load the starting point for the LED animation
    LDI HIGH KnightRider
    PHI R8
    LDI LOW KnightRider
    PLO R8

B96StopBitLoop      ; Wait for the stop bit
    B3  B96StopBitLoop

    LDI $FF         ; Initialize input character in RF.1 to $FF
    PHI RF

DrawLights
    LDA R8
    STR R2
    B3  FoundStartBit
    OUT 4
    DEC R2
    GLO R8
    B3  FoundStartBit
    SMI LOW KnightRider+44
    BNZ B96WaitStartBit
    LDI LOW KnightRider
    B3  FoundStartBit
    PLO R8
    LDI HIGH KnightRider
    PHI R8
    B3  FoundStartBit

B96WaitStartBit
    LDI $00         ; animation inner loop counter

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
    LDI  $01        ; Set up D and DF, which takes about a quarter of a bit duration
    SHR
    BR   SkipDelay
    
StartDelay
    LDI $02
B96DelayLoop
    SMI $01
    BNZ B96DelayLoop
    ; When done with delay, D=0 and DF=1
    
SkipDelay           ; read current bit
    B3  B96IN4
    SKP             ; if BIT=0 (EF3 PIN HIGH), leave DF=1
B96IN4
    SHR             ; if BIT=1 (EF3 PIN LOW), set DF=0
    GHI RF          ; load incoming byte
    SHRC            ; shift new bit into MSB, and oldest bit into DF
    PHI RF
    LBDF StartDelay
    
    BR  B96IN_Return

;__________________________________________________________________________________________________
; Customized serial output routine
; 9600 baud, inverted RS232 logic

; IN:       P=7, RF.1 = character to transmit
; OUT:      P=3
; TRASHED:  RF.0, RF.1

B96OUT_Return
    SEP R3
B96OUT
    GHI RF          ; start by setting LEDs to output character
    STR R2
    OUT 4
    DEC R2
    
    LDI 08H         ; RF.0 is data bit counter
    PLO RF

STBIT               ; Send Start Bit (Space)
    SEQ             ;  2
    NOP             ;  5
    NOP             ;  8
    GHI RF          ; 10
    SHRC            ; 12 DF = 1st bit to transmit
    PHI RF          ; 14
    PHI RF          ; 16
    NOP             ; 19 
    BDF STBIT1      ; 21 First bit = 1?
    BR  QHI         ; 23 bit = 0, output Space
STBIT1
    BR  QLO         ; 23 bit = 1, output Mark

QHI1
    DEC RF
    GLO RF
    BZ  DONE96      ;AT 8.5 INSTRUCTIONS EITHER DONE OR REQ

;DELAY
    NOP
    NOP

QHI
    SEQ             ; Q ON
    GHI RF
    SHRC            ; PUT NEXT BIT IN DF
    PHI RF
    LBNF    QHI1    ; 5.5 TURN Q OFF AFTER 6 MORE INSTRUCTION TIMES

QLO1
    DEC RF
    GLO RF
    BZ  DONE96      ; AT 8.5 INSTRUCTIONS EITHER DONE OR SEQ

;DELAY
    NOP
    NOP

QLO
    REQ             ;Q OFF
    GHI RF
    SHRC            ;PUT NEXT BIT IN DF
    PHI RF
    LBDF QLO1       ;5.5 TURN Q ON AFTER 6 MORE INSTRUCTION TIMES

    DEC RF
    GLO RF
    BZ  DONE96      ;AT 8.5 INSTRUCTIONS EITHER DONE OR REQ

;DELAY
    NOP
    LBR QHI

DONE96              ;FINISH LAST BIT TIMING
    NOP
    NOP

DNE961
    REQ             ; Send stop bit: Q=0

    BR B96OUT_Return

;__________________________________________________________________________________________________
; String print routine

; IN:       R8 = pointer to null-terminated string
; OUT:      N/A
; TRASHED:  R7, R8, RF

OutString
    LDI  HIGH B96OUT
    PHI  R7
    LDI  LOW B96OUT
    PLO  R7

OutStrLoop1
    LDA  R8
    BZ   OutStrDone
    PHI  RF
    SEP  R7
    BR   OutStrLoop1

OutStrDone
    SEP  R5

;__________________________________________________________________________________________________
; Clear screen

; IN:       N/A
; OUT:      N/A
; TRASHED:  R7, R8, RF

ClearScreen
    LDI  HIGH ClsMsg
    PHI  R8
    LDI  LOW ClsMsg
    PLO  R8
    
    SEP  R4
    DW   OutString
    SEP  R5

;__________________________________________________________________________________________________
; Main program starting point
    ORG $100    ; fixme remove

START
    ; First, check that the serial port setup is supported
    LDI HIGH BAUD
    PHI R7
    LDI LOW BAUD
    PLO R7
    LDA R7
    PHI RE
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
    DW  MON_OUTSTR

Exit    
    LDI $8B
    PHI R0
    LDI $DF
    PLO R0
    SEX R0
    SEP R0  ;BACK TO THE MONITOR PROGRAM WE GO

SerialOK
    ; clear screen
    SEP  R4
    DW   ClearScreen

    ; Print initial message
    LDI  HIGH StartingMsg
    PHI  R8
    LDI  LOW StartingMsg
    PLO  R8
    SEP  R4
    DW   OutString

MainLoop
    ; Get one input character from serial port in RF.1
    LDI HIGH B96IN
    PHI R7
    LDI LOW B96IN
    PLO R7
    SEP R7

    ; Exit back to monitor when ESCAPE is pressed
    GHI RF
    SMI 1BH
    BZ  Exit

    ; Echo character back
    LDI HIGH B96OUT
    PHI R7
    LDI LOW B96OUT
    PLO R7
    SEP R7

    ; get next keypress
    BR  MainLoop

;__________________________________________________________________________________________________
; Read/Write Data

;__________________________________________________________________________________________________
; Read-only Data

SerialError     BYTE        "Unsupported serial settings. Must be 9600 baud.\r\n"
KnightRider     DB          $00, $00, $80, $80, $C0, $C0, $E0, $60, $70, $30, $38, $18, $1C, $0C, $0E, $06, $07, $03, $03, $01, $01, $00, $00, $01, $01, $03, $03, $07, $06, $0E, $0C, $1C, $18, $38, $30, $70, $60, $E0, $C0, $C0, $80, $80, $00, $00
StartingMsg     BYTE        " W E L C O M E   T O \n A D V E N T U R E - 1+ \r\n\n\n\n\n"
                BYTE        "The object of your adventure is to find treasures and return them\r\n"
                BYTE        "to the proper place for you to accumulate points.  I'm your clone.  Give me\r\n"
                BYTE        "commands that consist of a verb & noun, i.e. GO EAST, TAKE KEY, CLIMB TREE,\r\n"
                BYTE        "SAVE GAME, TAKE INVENTORY, FIND AXE, etc.\r\n\n"
                BYTE        "You'll need some special items to do some things, but I'm sure that you'll be\r\n"
                BYTE        "a good adventurer and figure these things out (which is most of the fun of\r\n"
                BYTE        "this game).\r\n\n"
                BYTE        "Note that going in the opposite direction won't always get you back to where\r\n"
                BYTE        "you were.\r\n\n\n"
                BYTE        "HAPPY ADVENTURING!!!\r\n\n\n\n\n"
                BYTE        "************************** Press any key to continue **************************\r\n", 0
                DB          $00
ClsMsg          DB          $1B, $5B, $32, $4A, $1B, $48, $00

                INCL           "adventureland_data.asm"

                END

