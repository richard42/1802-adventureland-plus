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
;
; When the game is launched from ROM, after decompressing the game data into RAM at address 0013H,
; the LBR instruction at 0010 will be over-written by code in game_rom_loader.asm to instead jump
; to the game's starting address in RAM.

FakeBootLoader
    LBR         GameStart

    END

