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

    SEX  R2
    SEP  R5    

;__________________________________________________________________________________________________
; Restore internal variables to starting state

; IN:       N/A
; OUT:      
; TRASHED:  

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
    LDI  LOW Array_IA+9
    PLO  RA
    LDI  HIGH Array_IA+9
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
    LBNZ  GIParseLoop5_1NoMatch
    INC  R8
    LDA  R9                         ; Load 2nd character in input word
    BZ   GIParseLoop5_1WordEnd
    SM                              ; compare to 2nd character in table word
    LBNZ  GIParseLoop5_1NoMatch
    INC  R8
    LDA  R9                         ; Load 3rd character in input word
    BZ   GIParseLoop5_1WordEnd
    SM                              ; compare to 3rd character in table word
    LBNZ  GIParseLoop5_1NoMatch
    SKP                             ; fall through to GIParseLoop5_1Match
GIParseLoop5_1WordEnd
    LDN  R8
    LBNZ  GIParseLoop5_1NoMatch
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
    LDI  LOW Array_NVS+NL*4         ; RD = pointer to second half of NVS[2][NL][4], NL=60
    PLO  RD
    LDI  HIGH Array_NVS+NL*4
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
; TRASHED:  N/A

Do_Look
    SEP  R5

;__________________________________________________________________________________________________
; Adventure turn() function

; IN:       N/A
; OUT:      N/A
; TRASHED:  N/A

Do_Turn
    SEP  R5

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
LampEmptyMsg    BYTE        "Your lamp has run out of oil!\r\n", 0
LampLow1Msg     BYTE        "Your lamp will run out of oil in ",0
LampLow2Msg     BYTE        " turns!\r\n",0
InputPromptMsg  BYTE        "\r\nTell me what to do? ",0
InputError1Msg  BYTE        "I don't know how to ",0        ; append with "!\n"
InputError2Msg  BYTE        "I don't know what a ", 0
InputError3Msg  BYTE        " is!\r\n", 0
ClsMsg          DB          $1B, $5B, $32, $4A, $1B, $48, $00

                INCL           "adventureland_data.asm"

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

