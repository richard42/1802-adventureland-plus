;__________________________________________________________________________________________________
; Macro definitions

    INCL        "macros.asm"

;__________________________________________________________________________________________________
; Entry point when the game is loaded into RAM by a monitor is 0x0010
; (On entry, R0 is our program counter)

    CPU         1802
    ORG         0010H

    LBR         FakeBootLoader

;__________________________________________________________________________________________________
; Adventureland game code

    ORG         0013H
    INCL        "adventureland.asm"

;__________________________________________________________________________________________________
; The FakeBootLoader is here so that the first LBR instruction at the beginning of the binary
; program will tell the build script the size of the program data to compress. The LBR instruction
; here will tell the build script the address of the game startup routine.

FakeBootLoader
    LBR         GameStart

    END

