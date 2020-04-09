;__________________________________________________________________________________________________
; Customized ULZ decompression routine

; IN:       R7 = pointer to ULZ-compressed data
;           R8 = R7 + size of compressed data
;           R9 = pointer to output buffer where decompressed data will be stored
;           RA = R9 + size of output buffer
; OUT:      D = return value (1 - 4 if failed, 0 if command OK)
; TRASHED:  R0.0, R1, R7, R8, R9, RA, RB, RC, RD, RF

Do_ULZ_Decompress
    ; save the pointer to the start of the output buffer in RF
    GLO  R9
    PLO  RF
    GHI  R9
    PHI  RF
    ; use R1 to point to our KnightRider LED animation
    LDI  HIGH KnightRider
    PHI  R1
    LDI  LOW KnightRider
    PLO  R1
    ; R0.0 holds our animation loop counter
    LDI  30
    PLO  R0
    ; set the first value to the LEDs
    LDA  R1
    STR  R2
    OUT  4
    DEC  R2
    
UDLoop1
    ; start by checking if the input pointer has reached the end of the compressed data
    GHI  R7
    STR  R2
    GHI  R8
    SM
    BNZ  UDLoop1Go
    GLO  R7
    STR  R2
    GLO  R8
    SM
    BNZ  UDLoop1Go
    
    ; we have reached the exact end, so decompression was successful
UDLoop1End
    LDI  $00
    SEP  R5                         ; return 0

UDLoop1Go
    ; check if we need to advance the animation frame
    DEC  R0
    GLO  R0
    BNZ  UDLoop1ReadToken
    LDI  30
    PLO  R0                         ; reset loop counter
    LDI  LOW KnightRiderEnd
    STR  R2
    GLO  R1
    SM
    BZ   UDLoop1ReadToken           ; don't advance animation if we are already at the end
    LDA  R1                         ; get next byte in animation sequence
    STR  R2
    OUT  4                          ; put byte on LEDs
    DEC  R2

UDLoop1ReadToken
    LDI  $00
    PHI  RB                         ; RB.1 = 0
    LDA  R7                         ; token = *ip++;
    PLO  RD                         ; RD.0 = token
    
    ANI  $F0
    BZ   UDLoop1SkipCopy
    SHR
    SHR
    SHR
    SHR
    PLO  RB                         ; RB.0 = run = token>>4;
    SMI  $0F
    BNZ  UDLoop1CheckCopy
    SEP  R4
    DW   Do_DecodeMod               ; RB = DecodeMod(ip)
    GLO  RB
    ADI  15
    PLO  RB
    GHI  RB
    ADCI $00
    PHI  RB                         ; run = 15 + DecodeMod(ip)
    
UDLoop1CheckCopy
    ; RB is the length of data to copy from the compressed byte stream
    SEP  R4
    DW   Do_CheckInput
    SEP  R4
    DW   Do_CheckOutput
    ; Pointers are good, do the copy
UDLoop1_1
    LDA  R7
    STR  R9
    INC  R9
    DEC  RB
    GHI  RB
    BNZ  UDLoop1_1
    GLO  RB
    BNZ  UDLoop1_1

UDLoop1SkipCopy
    ; check if the output pointer has reached the expected end of the uncompressed data
    GHI  R9
    STR  R2
    GHI  RA
    SM
    BNZ  UDLoop1StartMatch
    GLO  R9
    STR  R2
    GLO  RA
    SM
    BNZ  UDLoop1StartMatch
    BR   UDLoop1End

UDLoop1StartMatch
    ; calculate how much data to copy from the uncompressed (output) buffer
    LDI  $00
    PHI  RB                         ; RB.1 = 0
    GLO  RD
    ANI  $0F                        ; D = token & 15
    ADI  4
    PLO  RB                         ; RB = len
    SMI  19
    BNZ  UDLoop1CheckMatch1
    SEP  R4
    DW   Do_DecodeMod               ; RB = DecodeMod(ip)
    GLO  RB
    ADI  19
    PLO  RB
    GHI  RB
    ADCI $00
    PHI  RB                         ; len = 19 + DecodeMod(ip)

UDLoop1CheckMatch1
    ; RB is the length of the match, copied from the uncompressed (output) buffer
    SEP  R4
    DW   Do_CheckOutput
    GHI  RB
    PHI  RD
    GLO  RB
    PLO  RD                         ; RD = len
    SEP  R4
    DW   Do_DecodeMod               ; RB = dist = DecodeMod(ip)

    ; calculate RC = CopyStart = op - dist
    GLO  R9
    STR  R2
    GLO  RB
    SD
    PLO  RC
    GHI  R9
    STR  R2
    GHI  RB
    SDB
    PHI  RC
    
    ; validate that RC falls within the range of bytes already written to output buffer
    GHI  RC
    STR  R2
    GHI  RF
    SM
    BL   UDLoop2MatchStartNoError
    BNZ  UDLoop1MatchStartError
    GLO  RC
    STR  R2
    GLO  RF
    SM
    BL   UDLoop2MatchStartNoError
    BZ   UDLoop2MatchStartNoError
UDLoop1MatchStartError
    LDI  $01
    SEP  R5
UDLoop2MatchStartNoError
UDLoop1MatchStartOk
    GHI  RC
    STR  R2
    GHI  R9
    SM
    BL   UDLoop1MatchEndError
    BNZ  UDLoop1MatchEndOk
    GLO  RC
    STR  R2
    GLO  R9
    SM
    BL   UDLoop1MatchEndError
    BNZ  UDLoop1MatchEndOk
UDLoop1MatchEndError
    LDI  $02
    SEP  R5

UDLoop1MatchEndOk

    ; Pointers are good, copy the matched data
UDLoop1_2
    LDA  RC
    STR  R9
    INC  R9
    DEC  RD
    GHI  RD
    BNZ  UDLoop1_2
    GLO  RD
    BNZ  UDLoop1_2
    
    ; Go back and check if we're finished, or get the next token
    BR   UDLoop1

;__________________________________________________________________________________________________
; CheckInput routine
; IN:       R7 = current pointer in ULZ-compressed data
;           R8 = pointer to byte after the last byte in compressed buffer
;           RB = Size of compressed data to read
; OUT:      returns from Do_ULZDecompress with D=3 if R7 + RB >= R8
; TRASHED:  D, RC

Do_CheckInput
    ; calculate RC = R7 + RB
    GLO  RB
    STR  R2
    GLO  R7
    ADD
    PLO  RC
    GHI  RB
    STR  R2
    GHI  R7
    ADC
    PHI  RC
    ; compare RC to R8
    STR  R2
    GHI  R8
    SD
    BL   CheckInOkay
    BNZ  CheckInInvalid
    GLO  RC
    STR  R2
    GLO  R8
    SD
    BL   CheckInOkay
    BNZ  CheckInInvalid

CheckInOkay
    SEP  R5                         ; return to Do_ULZ_Decompress

CheckInInvalid:
    INC  R2
    LDA  R2
    PHI  R6
    LDN  R2
    PLO  R6                         ; replace the return address to Do_ULZ_Decompress with prior return address on stack
    LDI  $03
    SEP  R5                         ; return to caller of Do_ULZ_Decompress

;__________________________________________________________________________________________________
; CheckOutput routine
; IN:       R9 = current pointer to output buffer where uncompressed data is being written
;           RA = pointer to byte after last byte in output buffer
;           RB = Size of uncompressed data to be written
; OUT:      returns from Do_ULZDecompress with D=4 if R9 + RB >= RA
; TRASHED:  D, RC

Do_CheckOutput
    ; calculate RC = R9 + RB
    GLO  RB
    STR  R2
    GLO  R9
    ADD
    PLO  RC
    GHI  RB
    STR  R2
    GHI  R9
    ADC
    PHI  RC
    ; compare RC to RA
    STR  R2
    GHI  RA
    SD
    BL   CheckOutOkay
    BNZ  CheckOutInvalid
    GLO  RC
    STR  R2
    GLO  RA
    SD
    BL   CheckOutOkay
    BNZ  CheckOutInvalid

CheckOutOkay
    SEP  R5                         ; return to Do_ULZ_Decompress

CheckOutInvalid:
    INC  R2
    LDA  R2
    PHI  R6
    LDN  R2
    PLO  R6                         ; replace the return address to Do_ULZ_Decompress with prior return address on stack
    LDI  $04
    SEP  R5                         ; return to caller of Do_ULZ_Decompress

;__________________________________________________________________________________________________
; Do_DecodeMod routine
; IN:       R7 = current pointer in ULZ-compressed data
; OUT:      RB = variable-length integer value read from compressed stream
; TRASHED:  D

Do_DecodeMod
    LDI  $00
    PHI  RB
    LDN  R7
    ANI  $7F
    PLO  RB
    LDN  R7
    ANI  $80
    BZ   DMDone
DMLoad2
    INC  R7
    LDN  R7
    SHR
    PHI  RB
    LDN  R7
    ANI  $01
    BZ   DMLoad2Done
    GLO  RB
    ORI  $80
    PLO  RB
DMLoad2Done
    LDN  R7
    ANI  $80
    BZ   DMDone
DMLoad3
    INC  R7
    LDN  R7
    SHL
    SHL
    SHL
    SHL
    SHL
    SHL
    STR  R2
    GHI  RB
    OR
    PHI  RB
DMDone
    INC  R7
    SEP  R5                         ; return

;__________________________________________________________________________________________________
; Read-only Data

KnightRider     DB          $00, $80, $40, $20, $10, $08, $04, $02, $01
                DB          $01, $81, $41, $21, $11, $09, $05, $03
                DB          $03, $83, $43, $23, $13, $0B, $07
                DB          $07, $87, $47, $27, $17, $0F
                DB          $0F, $8F, $4F, $2F, $1F
                DB          $1F, $9F, $5F, $3F
                DB          $3F, $BF, $7F
                DB          $7F, $FF
                DB          $FF
KnightRiderEnd

