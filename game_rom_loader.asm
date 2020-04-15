;__________________________________________________________________________________________________
; Macro definitions

    INCL        "macros.asm"

;__________________________________________________________________________________________________
; The game loader starts at address D000 in the ROM image
; (On entry, R0 is our program counter)

    CPU         1802
    ORG         $D000

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

;__________________________________________________________________________________________________
; Decompressor code

    INCL        "decompress.asm"

;__________________________________________________________________________________________________
; Main logic for game loader

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

    ; decompress Splash screen into RAM
    LDI  $CA
    PHI  R7
    LDI  $00
    PLO  R7                         ; R7 points to the size of the compressed block
    LDA  R7
    PHI  R8
    LDA  R7                         ; now R7 points to the size of the uncompressed text
    ADI  $04
    PLO  R8
    GHI  R8
    ADCI $CA
    PHI  R8                         ; R8 points to one byte past the end of the compressed data
    LDI  $00                        ; decompressed data should be stored at $0013
    PHI  R9
    LDI  $13
    PLO  R9
    LDA  R7
    ADI  $13
    PLO  RA
    LDA  R7                         ; now R7 points to the start of the compressed data
    ADCI $00
    PHI  RA
    SEP  R4
    DW   Do_ULZ_Decompress          ; defined in decompress.asm

    ; check for errors
    BZ   SplashOkay
    LBR  DecompressFailed

SplashOkay
    ; null-terminate the splash screen string
    STR  R9
    
    ; print the splash screen
    LDI  $00
    PHI  R7
    LDI  $13
    PLO  R7
    SEP  R4
    DW   MON_OUTSTR
    
    ; find the end of the first block of text
FindTextEnd
    INC  R7
    LDN  R7
    BNZ  FindTextEnd
    ; did we just print everything that was decompressed?
    LDI  $01
    PLO  RA                         ; RA is our "print again" flag
    GHI  R9
    STR  R2
    GHI  R7
    SM
    BNZ  KeyWait
    GLO  R9
    STR  R2
    GLO  R7
    SM
    BNZ  KeyWait
    DEC  RA                         ; we already printed everything

KeyWait
    ; wait for a keypress
    SEP  R4
    DW   MON_INPUT
    ; should we print another message?
    GLO  RA
    BZ   PrintDecompressing
    ; Yes, print the instructions (following the splash screen) now
    INC  R7
    SEP  R4
    DW   MON_OUTSTR

PrintDecompressing
    ; print Decompressing message
    LDI  HIGH StartingMsg
    PHI  R7
    LDI  LOW StartingMsg
    PLO  R7
    SEP  R4
    DW   MON_OUTSTR
    
    ; decompress Adventureland program into RAM
    LDI  HIGH CompressedSize
    PHI  R7
    LDI  LOW CompressedSize
    PLO  R7                         ; R7 points to the size of the compressed block
    LDA  R7
    PHI  R8
    LDA  R7                         ; now R7 points to the size of the uncompressed game data, little endian
    PLO  R8                         ; R8 holds the compressed data size
    ADI  LOW (CompressedSize+4)
    PLO  R8
    GHI  R8
    ADCI HIGH (CompressedSize+4)
    PHI  R8                         ; R8 points to one byte past the end of the compressed data
    LDI  $00
    PHI  R9
    LDI  $13
    PLO  R9                         ; R9 decompressed data should be stored at $0013
    LDA  R7
    ADI  $13
    PLO  RA
    LDA  R7                         ; now R7 points to the start of the compressed data
    ADCI $00
    PHI  RA
    SEP  R4
    DW   Do_ULZ_Decompress          ; defined in decompress.asm

    ; check for errors
    BZ   DecompressOkay
    
    ; not okay
DecompressFailed
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
    LDI  HIGH GameStartAddr         ; starting address of the game in RAM is stored here by build_rom.py
    PHI  R7
    LDI  LOW GameStartAddr
    PLO  R7                         ; R7 points to the size of the starting address of the game
    LDI  $00
    PHI  R8
    LDI  $10
    PLO  R8
    LDI  $C0
    STR  R8
    INC  R8
    LDA  R7                         ; high byte of game start addresss
    STR  R8
    INC  R8
    LDA  R7                         ; low byte of game start address
    STR  R8

    ; Jump to start the game
    LBR  $0010

;__________________________________________________________________________________________________
; Read-only Data

StartingMsg     BYTE        "\r\n\nDecompressing...", 0
ErrorMsg        BYTE        "\r\n\nDecompress failed.\r\n", 0

; These 3 fields must be at the end of the file
; They will get replaced with the correct values by the build script
GameStartAddr   DW          0
CompressedSize  DW          0
GameRamSize     DW          0

    END

