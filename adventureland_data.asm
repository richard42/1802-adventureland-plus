CL  EQU 148
NL  EQU 60
RL  EQU 34
ML  EQU 79
IL  EQU 61
MX  EQU 5
AR  EQU 11
TT  EQU 13
LN  EQU 3
LI  EQU 125
TR  EQU 3
MAXLINE  EQU 79

; Array C has dimensions 148 x 16
Array_C     DB  $00, $4B, $08, $01, $13, $06, $08, $00, $0A, $00, $00, $00, $75, $3E, $00, $00
            DB  $00, $0A, $14, $01, $15, $00, $14, $00, $07, $06, $00, $00, $0C, $34, $3B, $00
            DB  $00, $08, $15, $01, $00, $00, $00, $00, $00, $00, $00, $00, $0D, $3D, $00, $00
            DB  $00, $08, $1A, $01, $1A, $00, $0D, $00, $00, $00, $00, $00, $11, $3B, $34, $00
            DB  $00, $64, $05, $08, $26, $00, $29, $00, $15, $00, $05, $00, $37, $3E, $3C, $40
            DB  $00, $64, $18, $04, $00, $00, $00, $00, $00, $00, $00, $00, $25, $3F, $00, $00
            DB  $00, $05, $07, $01, $07, $00, $01, $00, $0C, $06, $00, $00, $28, $3E, $00, $00
            DB  $00, $05, $14, $06, $15, $06, $14, $00, $16, $02, $07, $06, $34, $2D, $00, $00
            DB  $00, $08, $18, $02, $07, $0C, $00, $00, $00, $00, $00, $00, $0F, $3D, $00, $00
            DB  $00, $64, $05, $04, $00, $00, $00, $00, $00, $00, $00, $00, $39, $00, $00, $00
            DB  $00, $32, $08, $01, $0C, $06, $08, $00, $37, $00, $00, $00, $30, $3B, $34, $00
            DB  $00, $64, $07, $08, $07, $00, $2F, $00, $19, $00, $00, $00, $3C, $3E, $42, $00
            DB  $00, $1E, $2A, $01, $15, $06, $14, $06, $14, $00, $00, $00, $34, $2D, $00, $00
            DB  $00, $32, $1B, $02, $07, $01, $00, $00, $00, $00, $00, $00, $46, $04, $3D, $00
            DB  $00, $64, $0C, $08, $20, $02, $24, $00, $20, $00, $23, $00, $35, $37, $35, $00
            DB  $00, $64, $0C, $08, $1B, $02, $34, $00, $1B, $00, $00, $00, $35, $37, $00, $00
            DB  $00, $64, $01, $08, $02, $09, $01, $00, $02, $00, $00, $00, $2A, $3C, $3A, $00
            DB  $00, $64, $0E, $08, $0D, $00, $0E, $00, $00, $00, $00, $00, $34, $3C, $3D, $00
            DB  $00, $64, $0C, $08, $0C, $00, $00, $00, $00, $00, $00, $00, $40, $3C, $00, $00
            DB  $00, $64, $0D, $09, $0D, $00, $00, $00, $00, $00, $00, $00, $6E, $3A, $73, $6B
            DB  $00, $64, $01, $08, $02, $08, $01, $00, $02, $00, $00, $00, $1B, $3C, $3C, $00
            DB  $1D, $10, $01, $02, $00, $00, $00, $00, $00, $00, $00, $00, $2E, $00, $00, $00
            DB  $1D, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $00, $00, $00
            DB  $1D, $36, $22, $02, $00, $00, $00, $00, $00, $00, $00, $00, $2E, $00, $00, $00
            DB  $1D, $39, $04, $02, $00, $00, $00, $00, $00, $00, $00, $00, $2E, $00, $00, $00
            DB  $0A, $15, $07, $02, $15, $01, $15, $00, $07, $00, $00, $00, $3B, $34, $76, $00
            DB  $0A, $2A, $17, $02, $07, $06, $18, $02, $00, $00, $00, $00, $0F, $3D, $00, $00
            DB  $0A, $15, $07, $02, $14, $01, $14, $00, $07, $00, $00, $00, $3B, $34, $76, $00
            DB  $12, $2A, $17, $01, $17, $00, $19, $02, $27, $00, $19, $00, $3B, $0E, $35, $37
            DB  $0A, $17, $18, $02, $07, $06, $00, $00, $00, $00, $00, $00, $0F, $3D, $00, $00
            DB  $0A, $17, $18, $02, $07, $01, $0D, $06, $00, $00, $00, $00, $10, $00, $00, $00
            DB  $0A, $17, $18, $02, $07, $01, $0D, $01, $0D, $00, $1A, $00, $3B, $34, $80, $00
            DB  $0A, $21, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $42, $00, $00, $00
            DB  $1D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $46, $40, $00, $00
            DB  $22, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $42, $00, $00, $00
            DB  $17, $00, $1D, $01, $11, $04, $17, $00, $00, $00, $00, $00, $36, $7A, $39, $40
            DB  $0E, $19, $1F, $03, $1C, $06, $00, $00, $00, $00, $00, $00, $13, $00, $00, $00
            DB  $0E, $19, $1F, $01, $1C, $01, $1F, $00, $00, $00, $00, $00, $15, $3D, $3B, $00
            DB  $2D, $2C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $72, $00, $00, $00
            DB  $0E, $19, $1F, $02, $1C, $01, $1F, $00, $0C, $00, $00, $00, $46, $37, $3A, $14
            DB  $01, $22, $14, $04, $23, $02, $13, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $0A, $19, $01, $04, $28, $06, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00
            DB  $0A, $19, $01, $04, $28, $01, $28, $00, $1F, $00, $00, $00, $3B, $34, $7F, $00
            DB  $12, $19, $1F, $01, $1F, $00, $28, $00, $00, $00, $00, $00, $3B, $34, $17, $00
            DB  $0E, $19, $12, $02, $1C, $01, $00, $00, $00, $00, $00, $00, $16, $00, $00, $00
            DB  $2D, $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $72, $00, $00, $00
            DB  $01, $23, $13, $04, $00, $00, $00, $00, $00, $00, $00, $00, $19, $00, $00, $00
            DB  $12, $0A, $26, $01, $26, $00, $1D, $02, $01, $00, $00, $00, $35, $24, $3A, $00
            DB  $2A, $2B, $2E, $01, $2E, $00, $00, $00, $00, $00, $00, $00, $77, $3B, $00, $00
            DB  $0A, $0D, $06, $02, $0D, $01, $0D, $00, $0C, $00, $00, $00, $3B, $34, $00, $00
            DB  $06, $00, $13, $04, $15, $00, $24, $06, $00, $00, $00, $00, $36, $40, $00, $00
            DB  $06, $00, $15, $04, $13, $00, $00, $00, $00, $00, $00, $00, $36, $40, $00, $00
            DB  $01, $23, $15, $04, $19, $02, $00, $00, $00, $00, $00, $00, $1A, $00, $00, $00
            DB  $01, $23, $15, $04, $19, $05, $16, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $23, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $47, $00, $00, $00
            DB  $01, $36, $22, $02, $00, $00, $00, $00, $00, $00, $00, $00, $7D, $00, $00, $00
            DB  $12, $17, $1A, $01, $19, $02, $1A, $00, $18, $00, $0E, $00, $1C, $3B, $35, $3A
            DB  $0A, $0D, $06, $02, $0D, $06, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00
            DB  $26, $33, $03, $02, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00
            DB  $01, $39, $02, $00, $05, $02, $00, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $12, $0D, $0C, $01, $0C, $00, $0D, $00, $00, $00, $00, $00, $3B, $34, $1D, $00
            DB  $0A, $1C, $16, $02, $16, $00, $0A, $00, $00, $00, $00, $00, $37, $45, $37, $2C
            DB  $08, $39, $05, $00, $05, $02, $0E, $0C, $04, $00, $0B, $01, $37, $35, $08, $07
            DB  $27, $14, $05, $04, $10, $02, $0E, $06, $00, $00, $00, $00, $06, $00, $00, $00
            DB  $25, $14, $05, $04, $10, $02, $0E, $06, $00, $00, $00, $00, $06, $00, $00, $00
            DB  $18, $0B, $0B, $01, $03, $00, $0B, $00, $00, $00, $00, $00, $1E, $3A, $35, $00
            DB  $27, $14, $10, $02, $0E, $01, $10, $00, $11, $00, $00, $00, $37, $35, $40, $00
            DB  $12, $25, $24, $01, $22, $05, $24, $00, $00, $00, $00, $00, $35, $00, $00, $00
            DB  $06, $00, $13, $04, $24, $01, $00, $00, $00, $00, $00, $00, $21, $3D, $00, $00
            DB  $12, $25, $24, $01, $38, $00, $2D, $00, $22, $00, $24, $00, $35, $35, $37, $3B
            DB  $0A, $25, $24, $02, $24, $00, $00, $00, $00, $00, $00, $00, $20, $34, $00, $00
            DB  $16, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $22, $00, $00, $00
            DB  $1A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $3F, $00, $00
            DB  $0A, $0A, $26, $02, $19, $02, $00, $00, $00, $00, $00, $00, $1A, $00, $00, $00
            DB  $12, $0A, $26, $01, $1D, $05, $29, $00, $26, $00, $00, $00, $23, $35, $3B, $00
            DB  $07, $00, $03, $08, $26, $05, $03, $00, $00, $00, $00, $00, $6F, $3C, $00, $00
            DB  $20, $00, $03, $08, $03, $00, $1B, $02, $00, $00, $00, $00, $27, $3C, $00, $00
            DB  $21, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $00, $00, $00
            DB  $2F, $00, $14, $01, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $71, $69, $00
            DB  $2F, $00, $15, $01, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $71, $69, $00
            DB  $01, $22, $12, $04, $00, $00, $00, $00, $00, $00, $00, $00, $66, $00, $00, $00
            DB  $0A, $36, $22, $02, $00, $00, $00, $00, $00, $00, $00, $00, $33, $00, $00, $00
            DB  $33, $00, $19, $02, $2B, $00, $12, $00, $19, $00, $00, $00, $29, $3E, $37, $00
            DB  $12, $17, $1A, $01, $1B, $02, $18, $00, $2C, $00, $1B, $00, $35, $35, $37, $2B
            DB  $31, $00, $03, $08, $03, $00, $00, $00, $00, $00, $00, $00, $3C, $01, $6E, $6B
            DB  $27, $14, $11, $02, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $00, $00
            DB  $01, $10, $23, $02, $13, $00, $00, $00, $00, $00, $00, $00, $46, $36, $40, $00
            DB  $07, $00, $03, $08, $26, $00, $05, $00, $03, $00, $19, $02, $37, $3A, $1F, $3C
            DB  $2D, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $72, $00, $00
            DB  $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $2F, $00, $00
            DB  $01, $39, $04, $02, $03, $00, $00, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $08, $39, $05, $02, $0B, $01, $05, $00, $04, $00, $0E, $01, $37, $35, $08, $00
            DB  $28, $26, $19, $02, $00, $00, $00, $00, $00, $00, $00, $00, $1A, $2F, $00, $00
            DB  $28, $27, $1B, $02, $00, $00, $00, $00, $00, $00, $00, $00, $7C, $2F, $00, $00
            DB  $2A, $0D, $0C, $01, $0C, $00, $0D, $00, $00, $00, $00, $00, $03, $3B, $34, $00
            DB  $2A, $0D, $06, $02, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $00, $00
            DB  $2A, $2A, $17, $01, $17, $00, $00, $00, $00, $00, $00, $00, $77, $3B, $00, $00
            DB  $32, $00, $10, $02, $03, $08, $10, $00, $11, $00, $03, $00, $37, $35, $05, $3C
            DB  $1B, $00, $1A, $04, $00, $0A, $00, $00, $00, $00, $00, $00, $7B, $00, $00, $00
            DB  $1B, $00, $1A, $04, $00, $0B, $0A, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $08, $00, $0B, $06, $00, $00, $00, $00, $00, $00, $00, $00, $26, $00, $00, $00
            DB  $2C, $00, $2F, $03, $0B, $01, $0B, $00, $19, $00, $07, $00, $12, $3E, $3A, $00
            DB  $2C, $00, $0B, $01, $1A, $07, $0B, $00, $19, $00, $00, $00, $12, $3E, $42, $00
            DB  $1C, $11, $09, $03, $00, $00, $00, $00, $00, $00, $00, $00, $33, $00, $00, $00
            DB  $1C, $11, $0A, $03, $08, $09, $30, $00, $08, $00, $00, $00, $31, $35, $3A, $00
            DB  $1C, $11, $0A, $03, $0B, $08, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
            DB  $1C, $11, $0A, $03, $0A, $08, $0B, $00, $21, $00, $30, $00, $32, $3A, $36, $3B
            DB  $1C, $11, $0A, $03, $09, $08, $0A, $00, $21, $00, $31, $00, $32, $3A, $36, $3B
            DB  $1C, $11, $0A, $03, $08, $08, $31, $00, $09, $00, $00, $00, $31, $35, $3A, $00
            DB  $33, $00, $14, $01, $14, $00, $15, $00, $00, $00, $00, $00, $78, $0C, $3B, $34
            DB  $33, $00, $15, $01, $00, $00, $00, $00, $00, $00, $00, $00, $78, $0D, $3D, $00
            DB  $1B, $00, $1A, $07, $00, $00, $00, $00, $00, $00, $00, $00, $7E, $00, $00, $00
            DB  $17, $00, $1D, $06, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
            DB  $2C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
            DB  $0E, $11, $09, $03, $00, $00, $00, $00, $00, $00, $00, $00, $79, $00, $00, $00
            DB  $2D, $39, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $67, $00, $00, $00
            DB  $12, $17, $1A, $01, $18, $00, $1A, $00, $0D, $00, $00, $00, $35, $3B, $34, $00
            DB  $2D, $1E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $67, $00, $00, $00
            DB  $2D, $15, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $67, $00, $00, $00
            DB  $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $00, $00, $00
            DB  $01, $39, $0B, $04, $1C, $00, $00, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $2F, $00, $1A, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $69, $6D, $00
            DB  $2F, $00, $0B, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $69, $00, $00
            DB  $2F, $00, $13, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $69, $00, $00
            DB  $2F, $00, $17, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6A, $00, $00
            DB  $2F, $00, $0D, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6D, $00, $00
            DB  $2F, $00, $11, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6D, $00, $00
            DB  $2F, $00, $0F, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6D, $00, $00
            DB  $2F, $00, $15, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $69, $00, $00
            DB  $2F, $00, $08, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6C, $00, $00
            DB  $25, $14, $0E, $01, $10, $02, $11, $00, $10, $00, $00, $00, $35, $37, $40, $00
            DB  $01, $38, $11, $02, $06, $00, $00, $00, $00, $00, $00, $00, $36, $38, $46, $40
            DB  $0E, $11, $0A, $01, $0A, $00, $09, $00, $00, $00, $00, $00, $3B, $34, $0A, $00
            DB  $0E, $13, $09, $01, $09, $00, $0A, $00, $00, $00, $00, $00, $3B, $34, $09, $00
            DB  $0A, $33, $03, $02, $00, $00, $00, $00, $00, $00, $00, $00, $0B, $3D, $00, $00
            DB  $01, $10, $34, $02, $18, $00, $00, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $0A, $31, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $6F, $00, $00
            DB  $0E, $00, $1C, $01, $12, $05, $00, $00, $00, $00, $00, $00, $18, $00, $00, $00
            DB  $33, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
            DB  $17, $00, $1D, $01, $11, $07, $11, $00, $00, $00, $00, $00, $36, $7A, $38, $40
            DB  $2F, $00, $01, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $69, $00, $00
            DB  $18, $0B, $0B, $06, $00, $00, $00, $00, $00, $00, $00, $00, $26, $00, $00, $00
            DB  $2F, $00, $14, $04, $00, $00, $00, $00, $00, $00, $00, $00, $6E, $74, $67, $00
            DB  $2D, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $41, $00, $00, $00
            DB  $01, $10, $04, $04, $05, $00, $00, $00, $00, $00, $00, $00, $36, $46, $40, $00
            DB  $2F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00
            DB  $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $2F, $00, $00
            DB  $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $70, $00, $00, $00
            DB  $FF

; Array NVS has dimensions 2 x 60
Array_NVS   BYTE    "AUT",0, "GO",0,0, "*ENT", "*RUN", "*WAL", "*CLI", "JUM",0, "BEA",0, "CHO",0, "*CUT"
            BYTE    "TAK",0, "*GET", "*PIC", "*CAT", "LIG",0, "*TUR", "*LAM", "*BUR", "DRO",0, "*REL"
            BYTE    "*SPI", "*LEA", "STO",0, "AWA",0, "THR",0, "TOS",0, "QUI",0, "SWI",0, "RUB",0, "LOO",0
            BYTE    "*SHO", "*SEE", "DRA",0, "SCO",0, "INV",0, "SAV",0, "WAK",0, "UNL",0, "REA",0, "OPE",0
            BYTE    "ATT",0, "*KIL", "DRI",0, "*EAT", "BUN",0, "FIN",0, "*LOC", "HEL",0, "SAY",0, "WIN",0
            BYTE    "DOO",0, "SCR",0, "*YEL", "*HOL", "NORT", "SOUT", "EAST", "WEST", "UP",0,0, "DOWN"
            BYTE    "ANY",0, "NOR",0, "SOU",0, "EAS",0, "WES",0, "UP",0,0, "DOWN", "NET",0, "FIS",0, "AWA",0
            BYTE    "MIR",0, "AXE",0, "AXE",0, "WAT",0, "BOT",0, "GAM",0, "HOL",0, "LAM",0, "*ON",0, "OFF",0
            BYTE    "DOO",0, "MUD",0, "*MED", "BEE",0, "SCO",0, "GAS",0, "FLI",0, "EGG",0, "OIL",0, "*SLI"
            BYTE    "KEY",0, "HEL",0, "BUN",0, "INV",0, "LED",0, "THR",0, "CRO",0, "BRI",0, "BEA",0, "DRA",0
            BYTE    "RUG",0, "RUB",0, "HON",0, "FRU",0, "OX",0,0, "RIN",0, "CHI",0, "*BIT", "BRA",0, "SIG",0
            BYTE    "BLA",0, "WEB",0, "*WRI", "SWA",0, "LAV",0, "ARO",0, "HAL",0, "TRE",0, "*STU", "FIR",0

; Array DIR has dimensions 6 x 8
Array_DIR   BYTE    "North",0,0,0, "South",0,0,0, "East",0,0,0,0, "West",0,0,0,0, "Up",0,0,0,0,0,0, "Down",0

; Array RM has dimensions 34 x 6
Array_RM    DB   0,  7, 10,  1,  0, 24
            DB  23,  1,  1, 25,  0,  0
            DB   0,  0,  0,  0,  0,  1
            DB   1,  1,  1,  1,  1,  4
            DB   0,  0,  0,  0,  3,  5
            DB   0,  0,  0,  0,  4,  0
            DB   0,  0,  0,  0,  5,  7
            DB   8,  9,  0, 27,  6, 12
            DB   0,  7,  0,  0,  0,  0
            DB   7,  0,  0,  0, 20,  0
            DB  11, 10,  0,  1,  0, 26
            DB  11, 11, 23, 11,  0,  0      ; AR = 11
            DB  13, 15, 15,  0,  0, 13
            DB   0,  0,  0, 14, 12,  0
            DB  17, 12, 13, 16, 16, 17
            DB  12,  0, 13, 12, 13,  0
            DB   0, 17,  0,  0, 14, 17
            DB  17, 12, 12, 15, 14, 18
            DB   0,  0,  0,  0, 17,  0
            DB   0,  0,  0, 20,  0,  0
            DB   0,  0,  0,  0,  0,  9
            DB   0,  0,  0,  0,  0,  0
            DB   0,  0,  0, 21,  0,  0
            DB  10,  1, 10, 11,  0,  0      ; 23
            DB   0,  0,  0,  0,  0,  0
            DB  11,  0,  1, 11,  0,  0
            DB   0,  0,  0,  0,  0,  0
            DB   0,  0,  7,  0,  0,  0
            DB   0,  0,  0,  0,  0, 11
            DB   0,  0,  0,  0,  0,  0
            DB   0,  0,  0,  0,  0,  0
            DB   0,  0,  0,  0,  0,  0
            DB   0,  0,  0,  0,  0,  0
            DB   0, 24, 11, 24, 28, 24


; String table RSS has length 34
Table_RSS   DW  RSS00_Msg, RSS01_Msg, RSS02_Msg, RSS03_Msg, RSS04_Msg, RSS05_Msg, RSS06_Msg, RSS07_Msg, RSS08_Msg, RSS09_Msg
            DW  RSS10_Msg, RSS11_Msg, RSS12_Msg, RSS13_Msg, RSS14_Msg, RSS15_Msg, RSS16_Msg, RSS17_Msg, RSS18_Msg, RSS19_Msg
            DW  RSS20_Msg, RSS21_Msg, RSS22_Msg, RSS23_Msg, RSS24_Msg, RSS25_Msg, RSS26_Msg, RSS27_Msg, RSS28_Msg, RSS29_Msg
            DW  RSS30_Msg, RSS31_Msg, RSS32_Msg, RSS33_Msg
RSS00_Msg   BYTE    " ", 0
RSS01_Msg   BYTE    "dismal swamp.", 0
RSS02_Msg   BYTE    "*I'm in the top of a tall cypress tree.", 0
RSS03_Msg   BYTE    "large hollow damp stump in the swamp.", 0
RSS04_Msg   BYTE    "root chamber under the stump.", 0
RSS05_Msg   BYTE    "semi-dark hole by the root chamber.", 0
RSS06_Msg   BYTE    "long down-sloping hall.", 0
RSS07_Msg   BYTE    "large cavern.", 0
RSS08_Msg   BYTE    "large 8-sided room.", 0
RSS09_Msg   BYTE    "royal anteroom.", 0
RSS10_Msg   BYTE    "*I'm on the shore of a lake.", 0
RSS11_Msg   BYTE    "forest.", 0
RSS12_Msg   BYTE    "maze of pits.", 0
RSS13_Msg   BYTE    "maze of pits.", 0
RSS14_Msg   BYTE    "maze of pits.", 0
RSS15_Msg   BYTE    "maze of pits.", 0
RSS16_Msg   BYTE    "maze of pits.", 0
RSS17_Msg   BYTE    "maze of pits.", 0
RSS18_Msg   BYTE    "bottom of a chasm.  Above me there are 2 ledges. One has a bricked up\nwindow.", 0
RSS19_Msg   BYTE    "*I'm on a narrow ledge over a chasm. Across the chasm is a throne room.", 0
RSS20_Msg   BYTE    "royal chamber.", 0
RSS21_Msg   BYTE    "*I'm on a narrow ledge by the throne room.\nAcross the chasm is another ledge.", 0
RSS22_Msg   BYTE    "throne room.", 0
RSS23_Msg   BYTE    "sunny meadow.", 0
RSS24_Msg   BYTE    "*I think I'm in real trouble.  Here's a guy with a pitchfork!", 0
RSS25_Msg   BYTE    "hidden grove.", 0
RSS26_Msg   BYTE    "quick-sand bog.", 0
RSS27_Msg   BYTE    "memory RAM of an IBM-PC.  I took a wrong turn!", 0
RSS28_Msg   BYTE    "branch on the top of an old oak tree.\nTo the east I see a meadow beyond a lake.", 0
RSS29_Msg   BYTE    " ", 0
RSS30_Msg   BYTE    " ", 0
RSS31_Msg   BYTE    " ", 0
RSS32_Msg   BYTE    " ", 0
RSS33_Msg   BYTE    "large misty room with strange letters over the exits.", 0


; String table MSS has length 79
Table_MSS   DW  MSS00_Msg, MSS01_Msg, MSS02_Msg, MSS03_Msg, MSS04_Msg, MSS05_Msg, MSS06_Msg, MSS07_Msg, MSS08_Msg, MSS09_Msg
            DW  MSS10_Msg, MSS11_Msg, MSS12_Msg, MSS13_Msg, MSS14_Msg, MSS15_Msg, MSS16_Msg, MSS17_Msg, MSS18_Msg, MSS19_Msg
            DW  MSS20_Msg, MSS21_Msg, MSS22_Msg, MSS23_Msg, MSS24_Msg, MSS25_Msg, MSS26_Msg, MSS27_Msg, MSS28_Msg, MSS29_Msg
            DW  MSS30_Msg, MSS31_Msg, MSS32_Msg, MSS33_Msg, MSS34_Msg, MSS35_Msg, MSS36_Msg, MSS37_Msg, MSS38_Msg, MSS39_Msg
            DW  MSS40_Msg, MSS41_Msg, MSS42_Msg, MSS43_Msg, MSS44_Msg, MSS45_Msg, MSS46_Msg, MSS47_Msg, MSS48_Msg, MSS49_Msg
            DW  MSS50_Msg, MSS51_Msg, MSS52_Msg, MSS53_Msg, MSS54_Msg, MSS55_Msg, MSS56_Msg, MSS57_Msg, MSS58_Msg, MSS59_Msg
            DW  MSS60_Msg, MSS61_Msg, MSS62_Msg, MSS63_Msg, MSS64_Msg, MSS65_Msg, MSS66_Msg, MSS67_Msg, MSS68_Msg, MSS69_Msg
            DW  MSS70_Msg, MSS71_Msg, MSS72_Msg, MSS73_Msg, MSS74_Msg, MSS75_Msg, MSS76_Msg, MSS77_Msg, MSS78_Msg
MSS00_Msg   BYTE    " ", 0
MSS01_Msg   BYTE    "Nothing happens...", 0
MSS02_Msg   BYTE    "Focusing intently on the intricate patterns of the web, I am surprised to\nsee the words: CHOP IT DOWN!", 0
MSS03_Msg   BYTE    "Gulp gulp gulp. I didn't realize how thirsty I was!", 0
MSS04_Msg   BYTE    "The dragon snorts and rumbles, smelling something offensive. It grimaces and\nopens its eyes, looking straight at me, then charges!", 0
MSS05_Msg   BYTE    "I hurl the axe at the door and the spinning blade crashes into the lock,\nshattering it. The door swings open.", 0
MSS06_Msg   BYTE    "I pull on the handle but it's no use; the door is secured with a padlock.", 0
MSS07_Msg   BYTE    "I saw a flash of light as the treetop crashed to the ground. Something was\nlost in the branches.", 0
MSS08_Msg   BYTE    "I swing the axe over and over. Chop! Chop! Chop! After a few minutes the giant\ntree heaves over. TIMBER...", 0
MSS09_Msg   BYTE    "One quick puff extinguishes the lamp.", 0
MSS10_Msg   BYTE    "The lamp pops on and bathes the room in a soft warm glow.", 0
MSS11_Msg   BYTE    "As I'm gathering up the web, the spider darts over and bites my hand!", 0
MSS12_Msg   BYTE    "My chigger bites are now infected.", 0
MSS13_Msg   BYTE    "The chigger bites have rotted my whole body.", 0
MSS14_Msg   BYTE    "The bear lumbers over to the honey, voraciously slurps it all up,\nthen falls asleep.", 0
MSS15_Msg   BYTE    "The bees buzz loudly and swarm angrily around me, then begin to sting me\nall over...", 0
MSS16_Msg   BYTE    "I don't have any container to put it in!", 0
MSS17_Msg   BYTE    "I just noticed that the buzzing has stopped. The bees have all suffocated\nin the bottle.", 0
MSS18_Msg   BYTE    "I speak the magic word and begin to feel dizzy. The world spins around me\nand I close my eyes. After breathing slowly for a few seconds, I open\nmy eyes to find that I have been transported.", 0
MSS19_Msg   BYTE    "I don't have anything that I can use to light the gas!", 0
MSS20_Msg   BYTE    "The gas bladder explodes with a loud BANG! A cloud of dust slowly settles.", 0
MSS21_Msg   BYTE    "The gas bladder explodes violently in my hands and knocks me backwards. I hit\nmy head on something.", 0
MSS22_Msg   BYTE    "An eerie blue flame glows for a few seconds then goes out. That was neat\nbut didn't help you much.", 0
MSS23_Msg   BYTE    "Fffffffff. The swamp gas all rushes out of the wine bladder.", 0
MSS24_Msg   BYTE    "I don't think that's flammable.", 0
MSS25_Msg   BYTE    "How do you want me to get across the chasm? Jump?!", 0
MSS26_Msg   BYTE    "To be honest, I'm too scared of the bear to do that. I need to get him out of\nhere first.", 0
MSS27_Msg   BYTE    "Don't waste *HONEY*.  Get mad instead.  Dam lava!", 0
MSS28_Msg   BYTE    "The bees escape from the bottle, buzzing loudly. The bear hears them, looks\nangrily at me, and then charges to attack me!", 0
MSS29_Msg   BYTE    "I pour out the bottle, its former contents soaking into the ground.", 0
MSS30_Msg   BYTE    "Using only one word, tell me at what object you would like me to throw the axe.", 0
MSS31_Msg   BYTE    "I send the axe spinning towards the bear, but he dodges to the side, and then\nI hear a CRASH! Oh no, something broke.", 0
MSS32_Msg   BYTE    "I gather up an armload of bricks, straining under the load. They are heavy!", 0
MSS33_Msg   BYTE    "With all my strength, I jump heroically off the ledge, but I'm carrying too\nmuch weight and don't make it across, falling into the chasm.", 0
MSS34_Msg   BYTE    "To exit the game, say -QUIT-", 0
MSS35_Msg   BYTE    "The mirror slips out of my hands, hits the floor, and shatters into a million\npieces.", 0
MSS36_Msg   BYTE    "The mirror slips out of my hands but miraculously lands softly on the rug.\nIt then begins to glow, and a message appears:", 0
MSS37_Msg   BYTE    "You lost *ALL* treasures.", 0
MSS38_Msg   BYTE    "I'm not carrying the axe. Try 'TAKE INVENTORY'!", 0
MSS39_Msg   BYTE    "The axe ricochets wildly off of the dragon's thick hide.\nThe dragon does not even wake up.", 0
MSS40_Msg   BYTE    "The caked-on mud has become dry and fallen off of my arm.", 0
MSS41_Msg   BYTE    "As I scream, the bear turns to look at me with a started expression on its\nface. As the bear twists, it loses its balance and falls off the ledge!", 0
MSS42_Msg   BYTE    "*DRAGON STINGS* The message fades after a few seconds. I don't understand what\nthis means, but I hope you do!", 0
MSS43_Msg   BYTE    "The bees swarm around the dragon, which wakes up to their incessant buzzing,\nand flies away...", 0
MSS44_Msg   BYTE    "The magical oil has attracted a magical lamp, which appears in your hands. The\nlamp is now full of oil and burning with a blue flame.", 0
MSS45_Msg   BYTE    "Argh! I've been bitten by chiggers! I hate these things. This cannot be good.", 0
MSS46_Msg   BYTE    "It looks exactly like I'd expect it to look. Maybe I should go there?", 0
MSS47_Msg   BYTE    "Maybe if I threw something?...", 0
MSS48_Msg   BYTE    "This poor fish is dry with no water around, and has now died. That's a bummer.", 0
MSS49_Msg   BYTE    "A glowing genie appears, drops something shiny, and then vanishes.", 0
MSS50_Msg   BYTE    "A genie appears and says, \"boy, you're selfish!\" He takes something and then\nvanishes!", 0
MSS51_Msg   BYTE    "NO!  It's too hot.", 0
MSS52_Msg   BYTE    "There's no way for me to climb up to the ledges from down here.", 0
MSS53_Msg   BYTE    "Try the swamp.", 0
MSS54_Msg   BYTE    "Don't use the verb 'say'. Just give me one word.", 0
MSS55_Msg   BYTE    "Try:  LOOK,JUMP,SWIM,CLIMB,THROW,FIND,GO,TAKE,INVENTORY,SCORE,HELP.", 0
MSS56_Msg   BYTE    "Only 3 things will wake the dragon. One of them is dangerous!", 0
MSS57_Msg   BYTE    "If you need a hint on something, try 'HELP'.", 0
MSS58_Msg   BYTE    "Read the sign in the meadow!", 0
MSS59_Msg   BYTE    "You may need magic words here.", 0
MSS60_Msg   BYTE    "A loud, low voice rumbles from all around me, saying:", 0
MSS61_Msg   BYTE    "PLEASE LEAVE IT ALONE!", 0
MSS62_Msg   BYTE    "I don't think it's a good idea to throw that.", 0
MSS63_Msg   BYTE    "Medicine is good for bites.", 0
MSS64_Msg   BYTE    "Sorry, but I can't find it anywhere around here.", 0
MSS65_Msg   BYTE    "Treasures have a * in their name.  Say 'SCORE'", 0
MSS66_Msg   BYTE    "BLOW IT UP", 0
MSS67_Msg   BYTE    "The golden fish wriggles out of your hands and slips back into the lake.", 0
MSS68_Msg   BYTE    "Ewww. The smooth goo stinks to high heaven. But rubbing it into the chigger\nbites feels good.", 0
MSS69_Msg   BYTE    "It tastes delicious! Yet I miss it now that it's gone. Maybe that wasn't such\na good idea.", 0
MSS70_Msg   BYTE    "Argh! These chigger bites itch like mad! Scratching them feels good for a few\nseconds, but then they get even worse.", 0
MSS71_Msg   BYTE    "The lamp is already lit.", 0
MSS72_Msg   BYTE    "The thick persian rug unfurls itself and I hop on. Just by thinking the\nmagic word, it lifts me up and flies away...", 0
MSS73_Msg   BYTE    "I swim out into the lake, but I'm carrying too much and begin sinking, so I\nswim back to shore.", 0
MSS74_Msg   BYTE    "I'm not so sure that it's a good idea to attack the dragon.", 0
MSS75_Msg   BYTE    "I'm not going in the lava! You go in the lava! That's way too hot.", 0
MSS76_Msg   BYTE    "I don't see any place to go swimming around here.", 0
MSS77_Msg   BYTE    "I hold the empty bladder near the bubbling swamp and pull it open, sucking\nthe gas into the bladder.", 0
MSS78_Msg   BYTE    "I manage to coax a few of the bees into the empty bottle without getting stung!", 0


; String table IAS has length 61
Table_IAS   DW  IAS00_Msg, IAS01_Msg, IAS02_Msg, IAS03_Msg, IAS04_Msg, IAS05_Msg, IAS06_Msg, IAS07_Msg, IAS08_Msg, IAS09_Msg
            DW  IAS10_Msg, IAS11_Msg, IAS12_Msg, IAS13_Msg, IAS14_Msg, IAS15_Msg, IAS16_Msg, IAS17_Msg, IAS18_Msg, IAS19_Msg
            DW  IAS20_Msg, IAS21_Msg, IAS22_Msg, IAS23_Msg, IAS24_Msg, IAS25_Msg, IAS26_Msg, IAS27_Msg, IAS28_Msg, IAS29_Msg
            DW  IAS30_Msg, IAS31_Msg, IAS32_Msg, IAS33_Msg, IAS34_Msg, IAS35_Msg, IAS36_Msg, IAS37_Msg, IAS38_Msg, IAS39_Msg
            DW  IAS40_Msg, IAS41_Msg, IAS42_Msg, IAS43_Msg, IAS44_Msg, IAS45_Msg, IAS46_Msg, IAS47_Msg, IAS48_Msg, IAS49_Msg
            DW  IAS50_Msg, IAS51_Msg, IAS52_Msg, IAS53_Msg, IAS54_Msg, IAS55_Msg, IAS56_Msg, IAS57_Msg, IAS58_Msg, IAS59_Msg
            DW  IAS60_Msg
IAS00_Msg   BYTE    " ", 0
IAS01_Msg   BYTE    "Dark hole", 0
IAS02_Msg   BYTE    "*POT OF RUBIES*/RUB/", 0
IAS03_Msg   BYTE    "Spider web with writing on it.", 0
IAS04_Msg   BYTE    "Hollow stump and remains of a felled tree.", 0
IAS05_Msg   BYTE    "Cypress tree", 0
IAS06_Msg   BYTE    "Water", 0
IAS07_Msg   BYTE    "Evil smelling mud/MUD/", 0
IAS08_Msg   BYTE    "*GOLDEN FISH*/FIS/", 0
IAS09_Msg   BYTE    "Brass lamp (lit)/LAM/", 0
IAS10_Msg   BYTE    "Old fashoned brass lamp/LAM/", 0
IAS11_Msg   BYTE    "Axe (rusty, with a magic word: BUNYON on it)/AXE/", 0
IAS12_Msg   BYTE    "Bottle (filled with water)/BOT/", 0
IAS13_Msg   BYTE    "Empty bottle/BOT/", 0
IAS14_Msg   BYTE    "Ring of skeleton keys/KEY/", 0
IAS15_Msg   BYTE    "Sign: LEAVE TREASURE HERE (say 'SCORE')", 0
IAS16_Msg   BYTE    "Door (locked)", 0
IAS17_Msg   BYTE    "Door (open, with a hallway beyond)", 0
IAS18_Msg   BYTE    "Swamp gas", 0
IAS19_Msg   BYTE    "*GOLDEN NET*/NET/", 0
IAS20_Msg   BYTE    "Chigger bites", 0
IAS21_Msg   BYTE    "Infected chigger bites", 0
IAS22_Msg   BYTE    "Floating patch of oily slime", 0
IAS23_Msg   BYTE    "*ROYAL HONEY*/HON/", 0
IAS24_Msg   BYTE    "Large african bees", 0
IAS25_Msg   BYTE    "Thin black bear", 0
IAS26_Msg   BYTE    "Bottle (with bees buzzing inside)/BOT/", 0
IAS27_Msg   BYTE    "Large sleeping dragon", 0
IAS28_Msg   BYTE    "Flint and steel/FLI/", 0
IAS29_Msg   BYTE    "*THICK PERSIAN RUG*/RUG/", 0
IAS30_Msg   BYTE    "Sign: MAGIC WORD IS AWAY. LOOK LA -(rest of sign is missing)", 0
IAS31_Msg   BYTE    "Bladder (swollen with swamp gas)/BLA/", 0
IAS32_Msg   BYTE    "Bricked up window", 0
IAS33_Msg   BYTE    "Sign: IN SOME CASES MUD IS GOOD, IN OTHERS...", 0
IAS34_Msg   BYTE    "Stream of lava", 0
IAS35_Msg   BYTE    "Bricked up window with a hole blown out of the center, leading to a narrow\nledge", 0
IAS36_Msg   BYTE    "Loose fire bricks", 0
IAS37_Msg   BYTE    "*GOLD CROWN*/CRO/", 0
IAS38_Msg   BYTE    "*MAGIC MIRROR*/MIR/", 0
IAS39_Msg   BYTE    "Thin black bear (asleep)", 0
IAS40_Msg   BYTE    "Empty wine bladder/BLA/", 0
IAS41_Msg   BYTE    "Shards of broken glass", 0
IAS42_Msg   BYTE    "Chiggers/CHI/", 0
IAS43_Msg   BYTE    "Thin black bear (dead)", 0
IAS44_Msg   BYTE    "*DRAGON EGGS* (very rare)/EGG/", 0
IAS45_Msg   BYTE    "Lava stream stopped up with bricks", 0
IAS46_Msg   BYTE    "*JEWELED FRUIT*/FRU/", 0
IAS47_Msg   BYTE    "*SMALL STATUE OF A BLUE OX*/OX/", 0
IAS48_Msg   BYTE    "*DIAMOND RING*/RIN/", 0
IAS49_Msg   BYTE    "*DIAMOND BRACELET*/BRA/", 0
IAS50_Msg   BYTE    "Elaborate carvings on rock which form the message: ALADDIN WAS HERE", 0
IAS51_Msg   BYTE    "Sign: LIMBO.  FIND RIGHT EXIT AND LIVE AGAIN!", 0
IAS52_Msg   BYTE    "Smoking hole.  Pieces of dragon and gore.", 0
IAS53_Msg   BYTE    "Sign: NO SWIMMING ALLOWED", 0
IAS54_Msg   BYTE    "Arrow (pointing down)", 0
IAS55_Msg   BYTE    "Dead golden fish/FIS/", 0
IAS56_Msg   BYTE    "*FIRESTONE* (cold now)/FIR/", 0
IAS57_Msg   BYTE    "Sign: PAUL'S PLACE", 0
IAS58_Msg   BYTE    "Trees", 0
IAS59_Msg   BYTE    " ", 0
IAS60_Msg   BYTE    " ", 0


; Array I2 has length 61
Array_I2    DB   0,  4,  4,  2,  0,  1, 10,  1, 10,  0
            DB   3, 10,  3,  0,  2,  3,  5,  0,  1, 18
            DB   0,  0,  1,  8,  8, 21,  0, 23, 13, 17
            DB  18,  0, 20, 23, 18,  0,  0, 22, 21,  0
            DB   9,  0,  1,  0,  0,  0, 25, 26,  0,  0
            DB  14, 33,  0, 10, 17,  0,  0, 25, 11,  0
            DB   0


