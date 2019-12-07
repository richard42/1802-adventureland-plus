;__________________________________________________________________________________________________
; Customized ULZ decompression routine

; IN:       R7 = pointer to ULZ-compressed data
;           R8 = R7 + size of compressed data
;           R9 = pointer to output buffer where decompressed data will be stored
;           RA = R9 + size of output buffer
; OUT:      D = return value (1 if failed, 0 if command OK)
; TRASHED:  R7, R8, R9, RA, RB, RC, RD, RF

Do_ULZ_Decompress

    ; fixme: not yet implemented
    LDI  $01

    SEP  R5                         ; return

;__________________________________________________________________________________________________
; Read-only Data

KnightRider     DB          $00, $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF, $FF, $7F, $3F, $1F, $0F, $07, $03, $01, $00

