;__________________________________________________________________________________________________
; Macro definitions

    INCL        "macros.asm"

;__________________________________________________________________________________________________
; Entry point when the game is loaded into RAM by a monitor is 0x8010
; (On entry, R0 is our program counter)

    CPU         1802
    ORG         8010H

    LBR         BootLoader

;__________________________________________________________________________________________________
; Adventureland game code

    ORG         8013H
    INCL        "adventureland.asm"

;__________________________________________________________________________________________________
; Setup code to initialize the stack and SCRT registers

BootLoader
    ; SETUP R2 (Stack)
    LDI  HIGH STACK
    PHI  R2
    LDI  LOW STACK
    PLO  R2  ;STACK = 7F6FH
    SEX  R2  ;X = 2

    ; SETUP R4 (CALL PC)
    LDI  HIGH CALL
    PHI  R4
    LDI  LOW CALL
    PLO  R4  ;R4 = PC FOR CALL SUBROUTINE

    ; SETUP R5 (RETURN PC)
    LDI  HIGH RETURN
    PHI  R5
    LDI  LOW RETURN
    PLO  R5  ;R5 = PC FOR RETURN SUBROUTINE

    ;SETUP R3 AS OUR NEW PC
    LDI  HIGH GameStart
    PHI  R3
    LDI  LOW GameStart
    PLO  R3
    SEP  R3  ;CHANGE PC FROM R0 TO R3

; When calling a subroutine:
; - accumulator value D is passed through
; - R6 is preserved but not passed through
; - RF.1 is trashed.
; When in a subroutine, R6=Caller

    END

