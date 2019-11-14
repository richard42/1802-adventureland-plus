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

B96StopBitLoop              ; Wait for the stop bit
    B3  B96StopBitLoop

    LDI $FF                 ; Initialize input character in RF.1 to $FF
    PHI RF

DrawLights
    LDA R8                  ; load next bit pattern in LED animation
    STR R2                  ; put it on the stack
    B3  FoundStartBit
    OUT 4                   ; output to LEDs
    DEC R2                  ; restore stack pointer to original value
    GLO R8                  ; load the low byte of the current bit pattern pointer
    SMI LOW KnightRider+44  ; is it at the end of the animation sequence?
    B3  FoundStartBit
    BNZ B96WaitStartBit     ; if not, go burn CPU cycles and wait for the start bit
    
    LDI LOW Rand_VarX       ; we have to reset the pointer, so begin by instead
    PLO R8
    LDI HIGH Rand_VarX      ; loading a pointer to the psuedo-random generator's X value
    B3 FoundStartBit
    PHI R8
    LDN R8
    ADI $01                 ; and incrementing this value in memory, to make the generator's
    STR R8                  ; values non-deterministic
    B3 FoundStartBit
    
    LDI LOW KnightRider     ; now re-load the bit pattern pointer
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

; IN:       P=7, D = character to transmit, R2 is stack pointer
; OUT:      P=3
; TRASHED:  RF

B96OUT_Return
    SEP R3
B96OUT
    PHI RF          ; save output character in RF.1
    STR R2
    SEX R2
    OUT 4           ; set LEDs to output character
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
    SEP  R7
    BR   OutStrLoop1

OutStrDone
    SEP  R5

;__________________________________________________________________________________________________
; Print a 2-digit number

; IN:       D = number to print, R8 = pointer to start of string
; OUT:      N/A
; TRASHED:  D, R7

Print2Digit
    PHI  R7                         ; save number to print
    LDI  $30                        ; ASCII 0
    PLO  R7
    GHI  R7
P2D_Tens
    SMI  10
    BL   P2D_TensDone
    INC  R7
    BR   P2D_Tens
P2D_TensDone
    ADI  10                         ; D is now number of singles
    PHI  R7
    GLO  R7
    STR  R8                         ; set the tens digit
    INC  R8
    LDI  $30                        ; ASCII 0
    PLO  R7
    GHI  R7
P2D_Ones
    SMI  1
    BL   P2D_OnesDone
    INC  R7
    BR   P2D_Ones
P2D_OnesDone
    GLO  R7
    STR  R8
    DEC  R8
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
; Generate a psuedo-random byte

; IN:       N/A
; OUT:      D=psuedo-random number
; TRASHED:  R7

GenRandom
    LDI  LOW Rand_VarX
    PLO  R7
    LDI  HIGH Rand_VarX
    PHI  R7
    SEX  R7

    LDN  R7         ; D = VarX
    ADI  $01
    STR  R7
    INC  R7
    LDA  R7         ; D = VarA
    INC  R7
    XOR             ; D = VarA XOR VarC
    DEC  R7
    DEC  R7
    DEC  R7
    XOR             ; D = VarA XOR VarC XOR VarX
    INC  R7
    STR  R7         ; VarA = D
    INC  R7
    ADD
    STXD
    SHR
    XOR
    INC  R7
    INC  R7
    ADD
    STR  R7

    SEP  R5    

;__________________________________________________________________________________________________
; Restore internal variables to starting state

; IN:       N/A
; OUT:      N/A
; TRASHED:  R7, R8, R9

GameReset
    LDI  LOW Array_I2               ; start by initializing item locations
    PLO  R8
    LDI  HIGH Array_I2
    PHI  R8
    LDI  LOW Array_IA
    PLO  R9
    LDI  HIGH Array_IA
    PHI  R9
    LDI  IL
    PLO  R7
GRLoop1
    LDA  R8
    STR  R9
    INC  R9
    DEC  R7
    GLO  R7
    BNZ  GRLoop1
    INC  R9
    INC  R9
    LDI  $00
    STR  R9                         ; Loadflag = 0
    INC  R9
    STR  R9                         ; Endflag = 0
    INC  R9
    STR  R9                         ; Darkflag = 0
    LDI  AR
    INC  R9
    STR  R9                         ; Room = AR
    LDI  LI
    INC  R9
    STR  R9                         ; lamp_oil = LT
    LDI  $00
    INC  R9
    STR  R9
    INC  R9
    STR  R9                         ; state_flags = 0
    SEP  R5

;__________________________________________________________________________________________________
; Main program starting point

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
    SEP R0                          ; BACK TO THE MONITOR PROGRAM WE GO

SerialOK
    ; beginning of main() function
    ; clear screen
    SEP  R4
    DW   ClearScreen

    ; Print welcome message
    LDI  HIGH StartingMsg
    PHI  R8
    LDI  LOW StartingMsg
    PLO  R8
    SEP  R4
    DW   OutString

    ; wait for key press
    LDI HIGH B96IN
    PHI R7
    LDI LOW B96IN
    PLO R7
    SEP R7
    
    ; clear screen
    SEP  R4
    DW   ClearScreen

    ; start of main loop
MainLoad
    ; reset all game state
    SEP  R4
    DW   GameReset
    ; /////////////////////////////
    ; fixme: add state loading code here
    ; /////////////////////////////
    ; clear screen
    SEP  R4
    DW   ClearScreen
    ; look()
    SEP  R4
    DW   Do_Look
    ; NV[0] = 0
    LDI  LOW Array_NV
    PLO  R9
    LDI  HIGH Array_NV
    PHI  R9
    LDI  $00
    STR  R9
    ; turn()
    SEP  R4
    DW   Do_Turn
MainGetInput
    ; get_input()
    SEP  R4
    DW   Do_GetInput
    ; if command parsing failed, try again
    BNZ  MainGetInput
    ; turn()
    SEP  R4
    DW   Do_Turn
    ; reload R9 to point to Endflag
    LDI  LOW Endflag
    PLO  R9
    LDI  HIGH Endflag
    PHI  R9
    LDN  R9
    BNZ  Exit                       ; quit if endflag != 0
    DEC  R9
    LDN  R9
    BNZ  MainLoad                   ; loop back and re-load if loadflag != 0
    ; deal with lamp oil
    LDI  LOW (Array_IA+9)
    PLO  RA
    LDI  HIGH (Array_IA+9)
    PHI  RA
    LDN  RA
    SMI  $FF
    BNZ  MainNoLamp
    LDI  LOW LampOil
    PLO  R9
    LDI  HIGH LampOil
    PHI  R9
    LDN  R9
    SMI  $01
    STR  R9                         ; lamp_oil--
    BPZ  LampNotEmpty
    LDI  HIGH LampEmptyMsg          ; print Lamp is Empty message
    PHI  R8
    LDI  LOW LampEmptyMsg
    PLO  R8
    SEP  R4
    DW   OutString
    LDI  $00
    STR  RA                         ; IA[9] = 0
    BR   MainNoLamp
LampNotEmpty
    SMI  25                         ; is our oil level < 25?
    BPZ  MainNoLamp
    LDI  HIGH LampLow1Msg           ; print Lamp is low message
    PHI  R8
    LDI  LOW LampLow1Msg
    PLO  R8
    SEP  R4
    DW   OutString
    LDI  HIGH PrintNumber
    PHI  R8
    LDI  LOW PrintNumber
    PLO  R8
    LDN  R9                         ; D = lamp_oil
    SEP  R4
    DW   Print2Digit
    SEP  R4
    DW   OutString
    LDI  HIGH LampLow2Msg
    PHI  R8
    LDI  LOW LampLow2Msg
    PLO  R8
    SEP  R4
    DW   OutString
MainNoLamp
    ; NV[0] = 0
    LDI  LOW Array_NV
    PLO  R9
    LDI  HIGH Array_NV
    PHI  R9
    LDI  $00
    STR  R9
    ; turn()
    SEP  R4
    DW   Do_Turn
MainLoopTail
    ; reload R9 to point to Endflag
    LDI  LOW Endflag
    PLO  R9
    LDI  HIGH Endflag
    PHI  R9
    LDN  R9
    LBNZ  Exit                      ; if endflag != 0, quit
    DEC  R9
    LDN  R9
    LBNZ  MainLoad                  ; if loadflag != 0, loop back and re-load
    LBR   MainGetInput              ; otherwise, get next command

;__________________________________________________________________________________________________
; Adventure get_input() function

; IN:       N/A
; OUT:      D = return value (1 if failed, 0 if command OK)
; TRASHED:  R7, R8, R9, RA, RB, RC, RD, RF

Do_GetInput
    ; print input prompt
    LDI  HIGH InputPromptMsg
    PHI  R8
    LDI  LOW InputPromptMsg
    PLO  R8
    SEP  R4
    DW   OutString
    ; now we are in the gets() function. set up loop variables
    LDI  $00
    PLO  RA                         ; RA.0 is character counter; only 79 are allowed
    LDI  HIGH Array_TPS
    PHI  R9
    LDI  LOW Array_TPS
    PLO  R9                         ; R9 is pointer to input line
GILoop1
    ; wait for key press
    LDI  HIGH B96IN
    PHI  R7
    LDI  LOW B96IN
    PLO  R7
    SEP  R7
    ; load R7 to point to serial output routine in case I need to print. this saves code space
    LDI  HIGH B96OUT
    PHI  R7
    LDI  LOW B96OUT
    PLO  R7
    ; handle backspace
    GHI  RF
    SMI  $8
    BZ   GIBackspace
    GHI  RF
    SMI  $7F
    BNZ  GILoop1N1
GIBackspace
    GLO  RA                         ; if line length is 0
    BZ   GILoop1                    ; then just go back for another input character
    LDI  $08                        ; otherwise, erase last character
    SEP  R7
    LDI  $20                        ; ' '
    SEP  R7
    LDI  $08                        ; '\b'
    SEP  R7
    DEC  RA                         ; decrement character count
    DEC  R9                         ; decrement input line pointer
    BR   GILoop1                    ; and then go back for another input character
GILoop1N1
    ; handle enter or return
    GHI  RF
    SMI  $0A
    BZ   GIEnter
    GHI  RF
    SMI  $0D
    BNZ  GILoop1N2
GIEnter
    LDI  '\r'                       ; '\n'
    SEP  R7
    LDI  '\n'                       ; '\n'
    SEP  R7
    BR   GIgetsDone
GILoop1N2
    ; ensure that input character is valid
    GHI  RF
    SMI  $20
    BZ   GICharOk
    GHI  RF
    SMI  $41
    BL   GILoop1
    GHI  RF
    SMI  $5B
    BL   GICharOk
    GHI  RF
    SMI  $61
    BL   GILoop1
    GHI  RF
    SMI  $7B
    BGE  GILoop1
GICharOk
    GHI  RF
    STR  R9                         ; add input character to our string
    INC  R9
    INC  RA                         ; increment string length counter
    SEP  R7                         ; echo character to serial output
    GLO  RA                         ; how long is the input line?
    SMI  79
    BL   GILoop1                    ; if < 79 characters, go get another
GIgetsDone
    LDI  $00                        ; null-terminate input string
    STR  R9
    LDI  HIGH Array_TPS
    PHI  R9
    LDI  LOW Array_TPS
    PLO  R9                         ; reload R9 to point to beginning of input string
    ; now we are back in the get_input() function.
    ; If the line is empty, go prompt for another command
    LDN  R9
    BZ   Do_GetInput
    ; otherwise, start parsing. begin by skipping any leading spaces
GIParseLoop1
    LDA  R9
    BZ   GIParseLoop1Done
    SMI  $20                        ; ' '
    BZ   GIParseLoop1
GIParseLoop1Done
    DEC  R9
    ; store pointer to first word in RA
    GLO  R9
    PLO  RA
    GHI  R9
    PHI  RA
    ; convert entire string to uppercase
GIParseLoop2
    LDA  R9
    BZ   GIParseLoop2Done
    SMI  $61
    BL   GIParseLoop2
    ADI  $41
    DEC  R9
    STR  R9
    INC  R9
    BR   GIParseLoop2
GIParseLoop2Done
    ; reload pointer to start of first word, and find the end (the next space)
    GLO  RA
    PLO  R9
    GHI  RA
    PHI  R9
GIParseLoop3
    LDA  R9
    BZ   GIParseLoop3Done
    SMI  $20                        ; ' '
    BNZ  GIParseLoop3
GIParseLoop3Done
    ; if we found a space, NULL-terminate the first word
    DEC  R9
    LDN  R9
    BZ   GIParseLoop4
    LDI  $00
    STR  R9
    INC  R9
    ; skip any additional spaces in between words
GIParseLoop4
    LDA  R9
    SMI  $20                        ; ' '
    BZ   GIParseLoop4
    DEC  R9
    ; store pointer to second word in RB
    GLO  R9
    PLO  RB
    GHI  R9
    PHI  RB
    ; find matches for both words
    LDI  LOW Array_NV               ; RC = pointer to NV[2]
    PLO  RC
    LDI  HIGH Array_NV
    PHI  RC
    LDI  LOW Array_NVS              ; RD = pointer to NVS[2][NL][4], NL=60
    PLO  RD
    LDI  HIGH Array_NVS
    PHI  RD
    LDI  $00
    PHI  RF                         ; RF.1 = i, for (i = 0; i < 2; i++)
    GLO  RA                         ; load pointer to first word in R9
    PLO  R9
    GHI  RA
    PHI  R9
GIParseLoop5
    LDI  $00
    STR  RC                         ; NV[i] = 0
    LDN  R9
    LBZ  GIParseLoop5Tail
    LDI  $00
    PLO  RF                         ; RF.0 = j, for (j = 0; j < NL; j++)
GIParseLoop5_1
    GLO  RD
    PLO  R8
    GHI  RD
    PHI  R8                         ; R8 = s = NVS[i][j]
    LDN  R8
    SMI  '*'                        ; if first character of word is '*'
    LBNZ GIParseLoop5_1Next1
    INC  R8                         ; then skip it
    LBR  GIParseLoop5_1Next1        ; fixme remove
    ORG $300                        ; fixme remove
GIParseLoop5_1Next1
    ; comparestring()
    SEX  R8
    LDA  R9                         ; Load 1st character in input word
    BZ   GIParseLoop5_1WordEnd
    SM                              ; compare to 1st character in table word
    BNZ  GIParseLoop5_1NoMatch
    INC  R8
    LDA  R9                         ; Load 2nd character in input word
    BZ   GIParseLoop5_1WordEnd
    SM                              ; compare to 2nd character in table word
    BNZ  GIParseLoop5_1NoMatch
    INC  R8
    LDA  R9                         ; Load 3rd character in input word
    BZ   GIParseLoop5_1WordEnd
    SM                              ; compare to 3rd character in table word
    BNZ  GIParseLoop5_1NoMatch
    SKP                             ; fall through to GIParseLoop5_1Match
GIParseLoop5_1WordEnd
    LDN  R8
    BNZ  GIParseLoop5_1NoMatch
GIParseLoop5_1Match
    GLO  RF
    STR  RC                         ; NV[i] = j
    GLO  RD
    PLO  R8
    GHI  RD
    PHI  R8                         ; R8 = NVS[i][j]
GIParseLoop5_1_1                    ; while (NVS[i][NV[i]][0] == '*') NV[i]--;
    LDN  R8
    SMI  '*'
    BNZ  GIParseLoop5Tail
    LDN  RC
    SMI  $01
    STR  RC                         ; NV[i]--
    DEC  R8
    DEC  R8
    DEC  R8
    DEC  R8
    BR   GIParseLoop5_1_1
GIParseLoop5_1NoMatch
    SEX  R2
    INC  RD
    INC  RD
    INC  RD
    INC  RD                         ; move word table pointer to next word
    GHI  RF                         ; test i variable
    BNZ  GIParseLoop5_1Next2
    GLO  RA                         ; reload pointer to first word in R9
    PLO  R9
    GHI  RA
    PHI  R9
    BR   GIParseLoop5_1Next3
GIParseLoop5_1Next2
    GLO  RB                         ; reload pointer to second word in R9
    PLO  R9
    GHI  RB
    PHI  R9
GIParseLoop5_1Next3
    INC  RF
    GLO  RF
    SMI  NL                         ; NL = 60
    LBNF  GIParseLoop5_1            ; go check the next word in the table
GIParseLoop5Tail
    INC  RC                         ; point to next element in NV array
    GLO  RB                         ; load pointer to second word in R9
    PLO  R9
    GHI  RB
    PHI  R9
    LDI  LOW (Array_NVS+NL*4)       ; RD = pointer to second half of NVS[2][NL][4], NL=60
    PLO  RD
    LDI  HIGH (Array_NVS+NL*4)
    PHI  RD
    GHI  RF
    ADI  $1                         ; i++
    PHI  RF
    SMI  $2
    LBNF GIParseLoop5               ; branch if less
    ; validate first word (verb)
    DEC  RC
    DEC  RC
    LDA  RC
    BNZ  GIParseVerbOk
    LDI  HIGH InputError1Msg
    PHI  R8
    LDI  LOW InputError1Msg
    PLO  R8
    SEP  R4
    DW   OutString                  ; print "I don't know how to "
    GLO  RA
    PLO  R8
    GHI  RA
    PHI  R8
    SEP  R4
    DW   OutString                  ; print first word
    LDI  '!'
    SEP  R7
    LDI  $0D
    SEP  R7
    LDI  $0A
    SEP  R7                         ; print '!\r\n'
    LDI  $01
    SEP  R5                         ; return 1
GIParseVerbOk
    ; validate second word (noun)
    LDN  RB                         ; D is word[0][0]
    BZ   GIParseAllGood
    LDN  RC                         ; D is NV[1]
    BNZ  GIParseAllGood
    LDI  HIGH InputError2Msg
    PHI  R8
    LDI  LOW InputError2Msg
    PLO  R8
    SEP  R4
    DW   OutString                  ; print "I don't know what a "
    GLO  RB
    PLO  R8
    GHI  RB
    PHI  R8
    SEP  R4
    DW   OutString                  ; print second word
    LDI  HIGH InputError3Msg
    PHI  R8
    LDI  LOW InputError3Msg
    PLO  R8
    SEP  R4
    DW   OutString                  ; print " is!\n"
    LDI  $01
    SEP  R5                         ; return 1
GIParseAllGood
    LDI  $00
    SEP  R5                         ; return 0

;__________________________________________________________________________________________________
; Adventure look() function

; IN:       N/A
; OUT:      N/A
; TRASHED:  R7, R8, R9, RA, RB, RC, RF

Do_Look
    LDI  LOW Darkflag
    PLO  R9
    LDI  HIGH Darkflag
    PHI  R9
    LDA  R9                         ; D == is_dark
    BZ   LKNotDark
    SEX  R9                         ; R9 is pointing to 'room'
    LDI  LOW (Array_IA+9)
    PLO  RA
    LDI  HIGH (Array_IA+9)
    PHI  RA
    LDN  RA
    SHL
    BDF  LKNotDark
    SHR
    SM
    BZ   LKNotDark
    ; it's dark. print a message and return
    LDI  HIGH Look1Msg
    PHI  R8
    LDI  LOW Look1Msg
    PLO  R8
    SEP  R4
    DW   OutString
    SEP  R5
LKNotDark
    LDN  R9
    SHL                             ; D = room * 2
    ADI  LOW Table_RSS
    PLO  RA
    LDI  HIGH Table_RSS
    ADCI $00
    PHI  RA
    LDA  RA
    PHI  RB
    LDA  RA
    PLO  RB                         ; RB = RSS[room]
    LDA  RB
    SMI  '*'
    BZ   LKPrintRoom1
    DEC  RB
    LDI  HIGH Look2Msg              ; print "I'm in a " prefix
    PHI  R8
    LDI  LOW Look2Msg
    PLO  R8
    SEP  R4
    DW   OutString
LKPrintRoom1
    GLO  RB
    PLO  R8
    GHI  RB
    PHI  R8
    SEP  R4
    DW   OutString                  ; print the room description
    LDI  $00
    PLO  RB                         ; RB.0 is item counter 'i' for loop
    PHI  RB                         ; RB.1 is flag which specifies whether item list prefix has been printed
    LDI  LOW Array_IA
    PLO  RA
    LDI  HIGH Array_IA
    PHI  RA                         ; RA is pointer to start of IA[]
LKLoop1
    SEX  R9                         ; R9 is pointing to 'room'
    LDA  RA
    SM
    LBNZ LKLoop1Tail
    ; we have found an item in this room.  start by printing the item list header if necessary
    GHI  RB
    LBNZ LKLoop1Next1
    LDI  $01
    PHI  RB
    LDI  HIGH Look3Msg
    PHI  R8
    LDI  LOW Look3Msg
    PLO  R8
    SEP  R4
    DW   OutString                  ; print: "Visible Items Here:"
LKLoop1Next1
    ; print item description
    GLO  RB                         ; D = item number (i)
    SHL
    ADI  LOW Table_IAS
    PLO  R8
    LDI  HIGH Table_IAS
    ADCI $00
    PHI  R8
    LDA  R8
    PHI  RC
    LDA  R8
    PLO  RC                         ; RC = pointer to item description
    LDI  ' '
    SEP  R7
    LDI  ' '
    SEP  R7
    LDI  ' '
    SEP  R7
LKLoop1_1
    LDN  RC
    BZ   LKLoop1_1Tail
    SMI  '/'
    BZ   LKLoop1_1Tail
    LDA  RC
    SEP  R7
    BR   LKLoop1_1
LKLoop1_1Tail
    LDI  '\r'
    SEP  R7
    LDI  '\n'
    SEP  R7
LKLoop1Tail
    INC  RB
    GLO  RB
    SMI  IL
    LBNF LKLoop1
    ; now print room exits
    SEX  R9
    LDN  R9                         ; D = room
    ADD
    ADD
    SHL                             ; D = room * 6
    ADI  LOW Array_RM
    PLO  R9
    LDI  HIGH Array_RM
    ADCI $00
    PHI  R9                         ; R9 is pointer to RM[room][0]
    LDI  $00
    PLO  RB                         ; RB.0 is direction counter 'i' for loop
    PHI  RB                         ; RB.1 is flag which specifies whether exit list header has been printed
LKLoop2
    LDA  R9
    BZ  LKLoop2Tail
    ; we have found an exit from this room.  start by printing the exit list header if necessary
    GHI  RB
    BNZ  LKLoop2Next1
    LDI  $01
    PHI  RB
    LDI  HIGH Look4Msg
    PHI  R8
    LDI  LOW Look4Msg
    PLO  R8
    SEP  R4
    DW   OutString
LKLoop2Next1
    GLO  RB
    SHL
    SHL
    SHL
    ADI  LOW Array_DIR
    PLO  R8
    LDI  HIGH Array_DIR
    ADCI $00
    PHI  R8
    SEP  R4
    DW   OutString                  ; print direction
    LDI  ' '
    SEP  R7
LKLoop2Tail
    INC  RB
    GLO  RB
    SMI  6
    BL   LKLoop2
    LDI  '\r'
    SEP  R7
    LDI  '\n'
    SEP  R7
    LDI  '\n'
    SEP  R7
    SEP  R5

;__________________________________________________________________________________________________
; Adventure turn() function

; IN:       N/A
; OUT:      N/A
; TRASHED:  R7, R8, R9, RA, RB, RF

Do_Turn
    LDI  $00
    PLO  R9                         ; R9.0 = i ((is_dark) && (IA[9] != room) && (IA[9] != -1))
    PHI  R9                         ; R9.1 = go_direction
    LDI  LOW Array_NV
    PLO  R7
    LDI  HIGH Array_NV
    PHI  R7
    LDA  R7                         ; D = NV[0]
    SMI  $01
    BNZ  TUNoGo
    LDN  R7
    BNZ  TUHaveNoun
    LDI  HIGH Turn1Msg
    PHI  R8
    LDI  LOW Turn1Msg
    PLO  R8
    SEP  R4
    DW   OutString                  ; print "Where do you want me to go? Give me a direction too.\n"
    SEP  R5                         ; return
TUHaveNoun
    SMI  $07
    LBDF TUNoDirection              ; BGE
    LDN  R7
    PHI  R9                         ; go_direction = NV[1]
    BR   TUHaveDirection
TUNoGo
    DEC  R7
    LDN  R7                         ; D = NV[0]
    SMI  54
    LBNF TUNoDirection              ; BL
    SMI  6
    LBDF TUNoDirection              ; BGE
    ADI  7
    PHI  R9                         ; go_direction = NV[0] - 53
TUHaveDirection
    LDI  LOW Darkflag
    PLO  RA
    LDI  HIGH Darkflag
    PHI  RA
    LDA  RA                         ; D == is_dark
    SEX  RA                         ; RA is pointing to 'room'
    BZ   TUNotDark
    LDI  LOW (Array_IA+9)
    PLO  RB
    LDI  HIGH (Array_IA+9)
    PHI  RB                         ; RB is pointer to IA[9]
    LDN  RB
    SHL
    BDF  TUNotDark
    SHR
    SM
    BZ   TUNotDark
    ; it's dark. print a message
    INC  R9                         ; i = 1
    LDI  HIGH Turn2Msg
    PHI  R8
    LDI  LOW Turn2Msg
    PLO  R8
    SEP  R4                         ; print: "Warning: it's dangerous to move in the dark!\n"
    DW   OutString
    SEX  RA
TUNotDark
    GHI  R9
    STR  R2                         ; put go_direction on top of stack
    LDX                             ; D = room
    ADD
    ADD
    SHL                             ; D = room * 6
    SEX  R2
    ADD                             ; D = room * 6 + go_direction
    ADI  LOW (Array_RM-1)
    PLO  RB
    LDI  HIGH (Array_RM-1)
    ADCI $00
    PHI  RB                         ; RB is pointer to RM[room][go_direction-1]
    LDN  RB
    PHI  R9                         ; R9.1 = j
    LBNZ TUExitNotBlocked
    GLO  R9
    BNZ  TUBlockedAndDark
    LDI  HIGH Turn3Msg
    PHI  R8
    LDI  LOW Turn3Msg
    PLO  R8
    SEP  R4                         ; print: "I can't go in that direction.\n"
    DW   OutString
    SEP  R5                         ; return
TUBlockedAndDark
    LDI  HIGH Turn4Msg
    PHI  R8
    LDI  LOW Turn4Msg
    PLO  R8
    SEP  R4                         ; print: "I fell down and broke my neck.\n"
    DW   OutString
    LDI  RL-1
    PHI  R9                         ; j = RL-1
    DEC  RA
    LDI  $00
    STR  RA                         ; is_dark = false
    INC  RA
    BR   TUSetRoom
TUExitNotBlocked
    SEP  R4
    DW   ClearScreen
TUSetRoom
    GHI  R9
    STR  RA                         ; room = j
    SEP  R4
    DW   Do_Look                    ; look()
    SEP  R5                         ; return
TUNoDirection
    LDI  $00
    PHI  R9                         ; R9.1 = command_found = false
    PLO  R9
    INC  R9                         ; R9.0 = command_allowed = true
    LDI  LOW Array_C
    PLO  RA
    LDI  HIGH Array_C
    PHI  RA                         ; RA = C[cmd]
TULoop1
    LDI  LOW Array_NV
    PLO  R7
    LDI  HIGH Array_NV
    PHI  R7                         ; R7 = NV
    LDN  RA
    PLO  R8                         ; R8.0 = i = C[cmd][0]
    BZ   TULoop1Next1
    LDN  R7
    LBZ  TULoop1Done                ; if (NV[0] == 0 && i != 0) break;
    GLO  R8
TULoop1Next1
    SEX  R7
    SM
    BNZ  TULoop1Tail
    INC  RA
    LDN  RA
    DEC  RA
    PLO  R8                         ; R8.0 = i = C[cmd][1]
    BZ   TULoop1CheckCommand
    INC  R7
    SM                              ; D = i - NV[1]
    DEC  R7
    BZ   TULoop1CheckCommand
    LDN  R7                         ; D = NV[0]
    BNZ  TULoop1Tail
TULoop1GetChances                   ; get random number between 1 and 100
    SEP  R4
    DW   GenRandom                  ; R7 is trashed
    SHR
    SMI  100
    BGE  TULoop1GetChances
    ADI  101
    STR  R2
    GLO  R8                         ; D = i
    SM
    BL   TULoop1Tail
TULoop1CheckCommand
    LDI  $01
    PHI  R9                         ; R9.1 = command_found = true
    SEP  R4
    DW   Do_CheckLogics
    PLO  R9                         ; R9.0 = command_allowed = check_logics(cmd)
    BZ   TULoop1Tail
    GLO  RA                         ; pre-increment C[cmd] pointer to use as an end-of-loop marker
    PLO  RE                         ; and store original value in RE
    ADI  $10
    PLO  RA
    PLO  RB
    GHI  RA
    PHI  RE                         ; RE is pAcVar
    ADCI $00
    PHI  RA
    PHI  RB
    DEC  RB
    DEC  RB
    DEC  RB
    DEC  RB                         ; RB is C[cmd][y]
TULoop1_1
    LDN  RB                         ; D = ac
    BZ   TULoop1_1SkipAction
    SEP  R4
    DW   Do_Action
    BNZ  TULoop1_1Done              ; if (failed) break;
TULoop1_1SkipAction
    LDI  LOW Loadflag
    PLO  R7
    LDI  HIGH Loadflag
    PHI  R7
    LDA  R7
    BNZ  TULoop1Done                ; if (loadflag) break twice
    LDN  R7
    BNZ  TULoop1Done                ; if (endflag) break twice
TULoo1_1Tail
    INC  RB                         ; y++
    GLO  RB
    STR  R2
    GLO  RA
    SM
    BNZ  TULoop1_1                  ; loop if C[cmd][y] != C[cmd+1][0]
TULoop1_1Done
    LDI  LOW Array_NV
    PLO  R7
    LDI  HIGH Array_NV
    PHI  R7                         ; R7 = NV
    LDN  R7
    BNZ  TULoop1Done                ; if (NV[0] != 0) break;
    BR   TULoop1Tail2               ; skip C[cmd] pointer advancement because we already did it
TULoop1Tail
    GLO  RA
    ADI  $10
    PLO  RA
    GHI  RA
    ADCI $00
    PHI  RA                         ; RA = C[cmd+1]
TULoop1Tail2
    LDN  RA
    SMI  $FF
    BNZ  TULoop1
TULoop1Done
    LDI  LOW Array_NV
    PLO  R7
    LDI  HIGH Array_NV
    PHI  R7
    LDN  R7                         ; D = NV[0]
    SMI  10
    BZ   TUCarryDrop
    LDN  R7
    SMI  18
    BNZ  TUNotCarryDrop
TUCarryDrop
    GLO  R9                         ; D = command_allowed
    BZ   TURunCarryDrop
    GHI  R9                         ; D = command_found
    BNZ  TUNotCarryDrop
TURunCarryDrop                      ; if (!command_found || !command_allowed)
    SEP  R4
    DW   Do_CarryDrop               ; carry_drop()
    SEP  R5                         ; return
TUNotCarryDrop
    LDN  R7                         ; D = NV[0]
    BZ   TUDone
    GHI  R9                         ; D = command_found
    BNZ  TUCommandWasFound
    LDI  LOW Turn5Msg
    PLO  R8
    LDI  HIGH Turn5Msg
    PHI  R8
    BR   TUPrintAndReturn           ; print: "I don't understand your command."
TUCommandWasFound
    GLO  R9                         ; D = command_allowed
    BNZ  TUDone
    LDI  LOW Turn6Msg
    PLO  R8
    LDI  HIGH Turn6Msg
    PHI  R8
TUPrintAndReturn
    SEP  R4                         ; print: "I can't do that yet."
    DW   OutString
TUDone
    SEP  R5

;__________________________________________________________________________________________________
; Adventure carry_drop() function

; IN:       N/A
; OUT:      N/A
; TRASHED:  R7, R8, R9, RA, RF

Do_CarryDrop
    LDI  LOW Array_NV
    PLO  R7
    LDI  HIGH Array_NV
    PHI  R7                         ; R7 = NV
    LDA  R7
    PLO  RA                         ; RA.0 = NV[0]
    LDN  R7
    PHI  RA                         ; RA.1 = NV[1]
    BNZ  CDHaveNoun
    LDI  LOW CarryDrop1Msg
    PLO  R8
    LDI  HIGH CarryDrop1Msg
    PHI  R8
    LBR  CDPrintAndReturn           ; print: "What?"
CDHaveNoun
    GLO  RA
    SMI  10
    LBNZ CDNotTake
    ; check to make sure we don't have too many items
    LDI  LOW Array_IA
    PLO  R7
    LDI  HIGH Array_IA
    PHI  R7                         ; R7 points to IA array
    LDI  0
    PLO  RF                         ; RF.0 = number of items in inventory
    LDI  IL
CDLoop1
    PHI  RF                         ; RF.1 = item counter
    LDA  R7
    SMI  $FF
    BNZ  CDLoop1Tail
    INC  RF
CDLoop1Tail
    GHI  RF
    SMI  $01
    LBNZ CDLoop1
    LDI  MX
    STR  R2
    GLO  RF
    SM                              ; DF/D = items - MX
    BL   CDNotTake
    LDI  LOW CarryDrop2Msg
    PLO  R8
    LDI  HIGH CarryDrop2Msg
    PHI  R8
    SEP  R4                         ; print: "I can't. I'm carrying too much!"
    DW   OutString
    SEP  R5                         ; return
CDNotTake
    LDI  IL
    PLO  RF                         ; RF.0 = item counter
    GHI  RA                         ; D = NV[1]
    SHL
    SHL
    ADI  LOW (Array_NVS+240)
    PLO  R9
    LDI  HIGH (Array_NVS+240)
    ADCI $00
    PHI  R9                         ; R9 points to NVS[1][NV[1]], which is a 3-letter uppercase noun given by the user
    LDI  LOW Table_IAS
    PLO  R7
    LDI  HIGH Table_IAS
    PHI  R7                         ; R7 points to IAS table
    SEX  R8
CDLoop2
    LDA  R7
    PHI  R8
    LDA  R7
    PLO  R8                         ; R8 = pointer to IAS[j][0]
CDLoop2_1
    LDA  R8                         ; find end of item description string
    BNZ  CDLoop2_1
    DEC  R8
    DEC  R8
    LDN  R8
    SMI  '/'                        ; if last character is not a slash
    BNZ  CDLoop2Tail                ; then skip this item
CDLoop2_2
    DEC  R8                         ; else find the preceding slash
    LDN  R8
    SMI  '/'
    BNZ  CDLoop2_2
    INC  R8                         ; R8 is first character in short uppercase object name
    ; comparestring()
    LDA  R9                         ; Load 1st character in input noun
    SM                              ; compare to 1st character in object name
    BNZ  CDLoop2_2NoMatch1
    INC  R8
    LDA  R9                         ; Load 2nd character in input noun
    SM                              ; compare to 2nd character in object name
    BNZ  CDLoop2_2NoMatch2
    INC  R8
    LDN  R9                         ; Load 3rd character in input noun
    BZ   CDLoop2_FoundObject
    SM                              ; compare to 3rd character in object name
    BZ   CDLoop2_FoundObject
CDLoop2_2NoMatch2
    DEC  R9
CDLoop2_2NoMatch1
    DEC  R9                         ; restore R9 to point to start of input noun
CDLoop2Tail
    DEC  RF
    GLO  RF
    BNZ  CDLoop2
CDLoop2Done
    LDI  LOW CarryDrop7Msg
    PLO  R8
    LDI  HIGH CarryDrop7Msg
    PHI  R8
    SEP  R4                         ; print: "It's beyond my power to do that."
    DW   OutString
    SEP  R5

CDLoop2_FoundObject
    ; we found the object!
    SEX  R2
    GLO  RF
    STR  R2
    LDI  IL
    SM                              ; D = j (item index)
    ADI  LOW Array_IA
    PLO  R9
    LDI  HIGH Array_IA
    ADCI $00
    PHI  R9                         ; R9 = pointer to IA[j]
    LDI  LOW Room
    PLO  R8
    LDI  HIGH Room
    PHI  R8                         ; R8 = pointer to 'room'
    GLO  RA                         ; D = NV[0]
    SMI  10
    BNZ  CDDropItem
CDTakeItem
    SEX  R8
    LDN  R9
    SM
    BNZ  CDItemNotHere
    LDI  $FF
    STR  R9                         ; IA[j] = -1;
    LDI  LOW CarryDrop3Msg
    PLO  R8
    LDI  HIGH CarryDrop3Msg
    PHI  R8
    BR   CDPrintAndReturn           ; print: "OK, taken."
CDItemNotHere
    LDI  LOW CarryDrop4Msg
    PLO  R8
    LDI  HIGH CarryDrop4Msg
    PHI  R8
    BR   CDPrintAndReturn           ; print: "I don't see it here."
CDDropItem
    LDN  R9
    SMI  $FF
    BNZ  CDItemNotHeld              ; not in my inventory
    LDN  R8
    STR  R9                         ; IA[j] = room;
    LDI  LOW CarryDrop5Msg
    PLO  R8
    LDI  HIGH CarryDrop5Msg
    PHI  R8
    BR   CDPrintAndReturn           ; print: "OK, dropped."
CDItemNotHeld
    LDI  LOW CarryDrop6Msg
    PLO  R8
    LDI  HIGH CarryDrop6Msg
    PHI  R8                         ; print: "I'm not carrying it!"
CDPrintAndReturn
    SEP  R4
    DW   OutString
    SEP  R5

;__________________________________________________________________________________________________
; Adventure check_logics() function

; IN:       RA=C[cmd]
; OUT:      D=1 if command is allowed, 0 otherwise
; TRASHED:  R7, R8, RB, RC

Do_CheckLogics
    GLO  RA
    STXD
    GHI  RA
    STXD                            ; push RA on the stack
    LDI  $05
    PLO  R7                         ; R7.0 = loop counter
    INC  RA
    INC  RA                         ; RA points to C[cmd][2]
    LDI  LOW Room
    PLO  RC
    LDI  HIGH Room
    PHI  RC                         ; RC = pointer to Room
CLLoop1
    INC  RC
    INC  RC                         ; RC = pointer to StateFlags
    LDA  RC
    PHI  RB
    LDN  RC
    PLO  RB                         ; RB = value of StateFlags
    DEC  RC
    DEC  RC
    DEC  RC                         ; RC = pointer to Room
    LDA  RA
    PHI  R7                         ; R7.1 = ll
    PLO  R8
CLLoop1_1
    BZ   CLLoop1_1Done
    GHI  RB
    SHR
    PHI  RB
    GLO  RB
    SHRC
    PLO  RB
    DEC  R8
    GLO  R8
    BR   CLLoop1_1
CLLoop1_1Done
    GLO  RB
    ANI  $01
    PHI  R8                         ; R8.1 = ((state_flags >> ll) && 1)
    GHI  R7                         ; D = ll
    ADI  LOW Array_IA
    PLO  RB
    LDI  HIGH Array_IA
    ADCI $00
    PHI  RB                         ; RB = pointer to IA[ll]
    LDA  RA                         ; D = k
    LBZ  CLLoop1Tail                ; skip this predicate if k == 0
CLLoopCheck1
    SEX  RC                         ; M(R(X)) points to Room
    SMI  $01
    BNZ  CLLoopCheck2
    LDN  RB
    SMI  $FF
    LBZ  CLLoop1Tail                ; if (k == 1) allowed = (IA[ll] == -1);
    LBR  CLReturnFalse
CLLoopCheck2
    SMI  $01
    BNZ  CLLoopCheck3
    LDN  RB
    SM
    LBZ  CLLoop1Tail                ; if (k == 2) allowed = (IA[ll] == room);
    LBR  CLReturnFalse
CLLoopCheck3
    SMI  $01
    LBNZ CLLoopCheck4
    LDN  RB
    SM
    LBZ  CLLoop1Tail
    LDN  RB
    SMI  $FF
    BZ   CLLoop1Tail                ; if (k == 3) allowed = (IA[ll] == room || IA[ll] == -1);
    BR   CLReturnFalse
CLLoopCheck4
    SMI  $01
    BNZ  CLLoopCheck5
    GHI  R7
    SM
    BZ   CLLoop1Tail                ; if (k == 4) allowed = (room == ll);
    BR   CLReturnFalse
CLLoopCheck5
    SMI  $01
    BNZ  CLLoopCheck6
    LDN  RB
    SM
    BNZ  CLLoop1Tail                ; if (k == 5) allowed = (IA[ll] != room);
    BR   CLReturnFalse
CLLoopCheck6
    SMI  $01
    BNZ  CLLoopCheck7
    LDN  RB
    SMI  $FF
    BNZ  CLLoop1Tail                ; if (k == 6) allowed = (IA[ll] != -1);
    BR   CLReturnFalse
CLLoopCheck7
    SMI  $01
    BNZ  CLLoopCheck8
    GHI  R7
    SM
    BNZ  CLLoop1Tail                ; if (k == 7) allowed = (room != ll);
    BR   CLReturnFalse
CLLoopCheck8
    SMI  $01
    BNZ  CLLoopCheck9
    GHI  R8                         ; D = ((state_flags >> ll) && 1)
    BNZ  CLLoop1Tail                ; if (k == 8) allowed = (state_flags & (1 << ll)) != 0;
    BR   CLReturnFalse
CLLoopCheck9
    SMI  $01
    BNZ  CLLoopCheck10
    GHI  R8                         ; D = ((state_flags >> ll) && 1)
    BZ   CLLoop1Tail                ; if (k == 9) allowed = (state_flags & (1 << ll)) == 0;
    BR   CLReturnFalse
CLLoopCheck10
    SMI  $01
    BNZ  CLLoopCheck11
    LDI  LOW Array_IA
    PLO  RB
    LDI  HIGH Array_IA
    PHI  RB                         ; RB = pointer to IA[0]
    LDI  IL
    PLO  R8                         ; R8 = loop counter IL
CLCheck10Loop1
    LDA  RB
    SMI  $FF
    BZ   CLLoop1Tail                ; if (k == 10) for (i=0; i<IL; i++) if (IA[i] == -1) allowed = true;
    DEC  R8
    GLO  R8
    BNZ  CLCheck10Loop1
    BR   CLReturnFalse
CLLoopCheck11
    SMI  $01
    BNZ  CLLoopCheck12
    LDI  LOW Array_IA
    PLO  RB
    LDI  HIGH Array_IA
    PHI  RB                         ; RB = pointer to IA[0]
    LDI  IL
    PLO  R8                         ; R8 = loop counter IL
CLCheck11Loop1
    LDA  RB
    SMI  $FF
    BZ   CLReturnFalse              ; if (k == 11) for (i=0; i<IL; i++) if (IA[i] == -1) allowed = false;
    DEC  R8
    GLO  R8
    BNZ  CLCheck11Loop1
    BR   CLLoop1Tail
CLLoopCheck12
    SMI  $01
    BNZ  CLLoopCheck13
    LDN  RB
    SM
    BZ   CLReturnFalse
    LDN  RB
    SMI  $FF
    BZ   CLReturnFalse              ; if (k == 12) allowed = (IA[ll] != -1 && IA[ll] != room);
    BR   CLLoop1Tail
CLLoopCheck13
    SMI  $01
    BNZ  CLLoopCheck14
    LDN  RB
    BNZ  CLLoop1Tail                ; if (k == 13) allowed = (IA[ll] != 0);
    BR   CLReturnFalse
CLLoopCheck14
    SMI  $01
CLDebug1
    BNZ  CLDebug1                   ; deadlock here if invalid 'k' was found
    LDN  RB
    BNZ  CLReturnFalse              ; if (k == 14) allowed = (IA[ll] == 0);
CLLoop1Tail
    DEC  R7
    GLO  R7
    LBNZ CLLoop1
CLReturnTrue
    SEX  R2
    INC  R2
    LDXA
    PHI  RA
    LDX
    PLO  RA                         ; restore original value of RA
    LDI  $01
    SEP  R5                         ; return false
CLReturnFalse
    SEX  R2
    INC  R2
    LDXA
    PHI  RA
    LDX
    PLO  RA                         ; restore original value of RA
    LDI  $00
    SEP  R5                         ; return false

;__________________________________________________________________________________________________
; Adventure action() function

; IN:       D=ac, RE=pAcVar
; OUT:      D=1 if action failed, 0 otherwise
; TRASHED:  R7, R8, RC, RD, RF

Do_Action
    STR  R2                         ; save 'ac' variable
    SMI  52
    BL   DAPrintMessage
    SMI  50
    BGE  DAPrintMessage
    ADI  50
    BR   DACheck52
DAPrintMessage
    ADI  52                         ; D = message number
    SHL
    ADI  LOW Table_MSS
    PLO  R7
    LDI  HIGH Table_MSS
    ADCI $00
    PHI  R7
    LDA  R7
    PHI  R8
    LDN  R7
    PLO  R8                         ; R8 points to message to print
    SEP  R4
    DW   OutString
    LDI  $0D
    SEP  R7
    LDI  $0A
    SEP  R7                         ; print '\r\n'
    LDI  $00
    SEP  R5                         ; return false (action didn't fail)
DACheck52
    BNZ  DACheck53

DACheck53
    SMI  $01
    BNZ  DACheck54

DACheck54
    LDI  $00
    SEP  R5                         ; return false (action didn't fail)

;    if (ac == 52)
;    {
;        j = 0;
;        for (i=1; i<IL; i++) if (IA[i] == -1) j++;
;        if (j >= MX)
;        {
;            printf("I can't. I'm carrying too much!\n");
;            return true;
;        }
;        else IA[get_action_variable(pAcVar)] = -1;
;    }

;__________________________________________________________________________________________________
; Read-only Data

SerialError     BYTE        "Unsupported serial settings. Must be 9600 baud.\r\n"
KnightRider     DB          $00, $00, $80, $80, $C0, $C0, $E0, $60, $70, $30, $38, $18, $1C, $0C, $0E, $06, $07, $03, $03, $01, $01, $00, $00, $01, $01, $03, $03, $07, $06, $0E, $0C, $1C, $18, $38, $30, $70, $60, $E0, $C0, $C0, $80, $80, $00, $00
ClsMsg          DB          $1B, $5B, $32, $4A, $1B, $48, $00
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
LampEmptyMsg    BYTE        "Your lamp has run out of oil!\r\n", 0
LampLow1Msg     BYTE        "Your lamp will run out of oil in ",0
LampLow2Msg     BYTE        " turns!\r\n",0
InputPromptMsg  BYTE        "\r\nTell me what to do? ",0
InputError1Msg  BYTE        "I don't know how to ",0
InputError2Msg  BYTE        "I don't know what a ", 0
InputError3Msg  BYTE        " is!\r\n", 0
Look1Msg        BYTE        "I can't see.  It's too dark!\r\n", 0
Look2Msg        BYTE        "I'm in a ", 0
Look3Msg        BYTE        "\r\n\nVisible Items Here:\r\n", 0
Look4Msg        BYTE        "\r\nObvious Exits:\r\n   ", 0
Turn1Msg        BYTE        "Where do you want me to go? Give me a direction too.\r\n", 0
Turn2Msg        BYTE        "Warning: it's dangerous to move in the dark!\r\n", 0
Turn3Msg        BYTE        "I can't go in that direction.\r\n", 0
Turn4Msg        BYTE        "I fell down and broke my neck.\r\n", 0
Turn5Msg        BYTE        "I don't understand your command.\r\n", 0
Turn6Msg        BYTE        "I can't do that yet.\r\n", 0
CarryDrop1Msg   BYTE        "What?\r\n", 0
CarryDrop2Msg   BYTE        "I can't. I'm carrying too much!\r\n", 0
CarryDrop3Msg   BYTE        "OK, taken.\r\n", 0
CarryDrop4Msg   BYTE        "I don't see it here.\r\n", 0
CarryDrop5Msg   BYTE        "OK, dropped.\r\n", 0
CarryDrop6Msg   BYTE        "I'm not carrying it!\r\n", 0
CarryDrop7Msg   BYTE        "It's beyond my power to do that.\r\n", 0

                INCL        "adventureland_data.asm"

;__________________________________________________________________________________________________
; Read/Write Data

Array_TPS       BLK         80      ; These data members must all stay in this order
Array_IA        BLK         IL
Array_NV        DB          0, 0
Loadflag        DB          0
Endflag         DB          0
Darkflag        DB          0
Room            DB          0
LampOil         DB          0
StateFlags      DW          0

Rand_VarX       DB          18      ; These data members must all stay in this order
Rand_VarA       DB          166
Rand_VarB       DB          220
Rand_VarC       DB          64

PrintNumber     DB          0,0,0   ; temporary location for storing 2-digit number to print

                END

