;__________________________________________________________________________________________________
; Macro definitions

    INCL        "macros.asm"

;__________________________________________________________________________________________________
; The game loader starts at address D000 in the ROM image
; (On entry, R0 is our program counter)

    CPU         1802
    ;ORG         D000H
    ORG         4300H

    ; Setup code to initialize the stack and SCRT registers
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
    LDI  HIGH LoaderStart
    PHI  R3
    LDI  LOW LoaderStart
    PLO  R3
    SEP  R3  ;CHANGE PC FROM R0 TO R3

; When calling a subroutine:
; - accumulator value D is passed through
; - R6 is preserved but not passed through
; - RF.1 is trashed.
; When in a subroutine, R6=Caller

LoaderStart
    ; set up baud rate register
    LDI  HIGH BAUD
    PHI  R7
    LDI  LOW BAUD
    PLO  R7
    LDA  R7
    PHI  RE
    LDN  R7
    PLO  RE

    ; print Decompressing message
    LDI  HIGH StartingMsg
    PHI  R7
    LDI  LOW StartingMsg
    PLO  R7
    SEP  R4
    DW   MON_OUTSTR
    
    ; decompress Adventureland program into RAM
    LDI  HIGH ULZDATA               ; defined in adv_core_ulz.asm
    PHI  R7
    LDI  LOW ULZDATA
    PLO  R7
    LDI  HIGH ULZDATA+ULZSIZE       ; defined in adv_core_ulz.asm
    PHI  R8
    LDI  LOW ULZDATA+ULZSIZE
    PLO  R8
    LDI  $00                        ; decompressed data should be stored at $0013
    PHI  R9
    LDI  $13
    PLO  R9
    LDI  $43                        ; can't write past $4300
    PHI  RA
    LDI  $00
    PLO  RA
    SEP  R4
    DW   Do_ULZ_Decompress          ; defined in decompress.asm

    ; check for errors
    BZ   DecompressOkay
    
    ; not okay
    PHI  R1                         ; put error code in R1 so developer can see it in the monitor
    LDI  HIGH ErrorMsg
    PHI  R7
    LDI  LOW ErrorMsg
    PLO  R7
    SEP  R4
    DW   MON_OUTSTR
Exit
    LDI  $8B
    PHI  R0
    LDI  $5E
    PLO  R0
    SEX  R0
    SEP  R0                          ; jump back to the monitor program

    ; write LBR instruction at 0010 to jump into the game program
DecompressOkay
    LDI  $00
    PHI  R8
    LDI  $10
    PLO  R8
    LDI  $C0
    STR  R8
    INC  R8
    LDI  HIGH GAMESTART             ; defined in adv_core_ulz.asm
    STR  R8
    INC  R8
    LDI  LOW GAMESTART
    STR  R8

    ; Jump to start the game
    LBR  $0010

;__________________________________________________________________________________________________
; Decompressor code

    INCL        "decompress.asm"

;__________________________________________________________________________________________________
; Read-only Data

StartingMsg     BYTE        "\r\nDecompressing...", 0
ErrorMsg        BYTE        "\r\nDecompression failed, jumping back to monitor.\r\n", 0

;__________________________________________________________________________________________________
; Compressed Adventureland program

    INCL        "adv_core_ulz.asm"

    END

