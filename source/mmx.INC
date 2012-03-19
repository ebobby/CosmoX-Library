;----------------------------------------------------------------------------
;
;  CosmoX MMX INSTRUCTION OPCODES Include file
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

MMX_MOVQ_REG_DSDI macro MMXREG:req
  db  03eh
  dw  06f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_DSDI_REG macro MMXREG:req
  db  03eh
  dw  07f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_REG_DSSI macro MMXREG:req
  db  03eh
  dw  06f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_DSSI_REG macro MMXREG:req
  db  03eh
  dw  07f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_REG_ESDI macro MMXREG:req
  db  026h
  dw  06f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_ESDI_REG macro MMXREG:req
  db  026h
  dw  07f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_REG_ESSI macro MMXREG:req
  db  026h
  dw  06f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_ESSI_REG macro MMXREG:req
  db  026h
  dw  07f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_REG_GSDI macro MMXREG:req
  db  065h
  dw  06f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_GSDI_REG macro MMXREG:req
  db  065h
  dw  07f0fh
  db  (MMXREG * 08h) + 05h
endm

MMX_MOVQ_REG_GSSI macro MMXREG:req
  db  065h
  dw  06f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_GSSI_REG macro MMXREG:req
  db  065h
  dw  07f0fh
  db  (MMXREG * 08h) + 04h
endm

MMX_MOVQ_REG_REG macro MMXDST:req, MMXSRC:req
  dw  06f0fh
  db  (MMXDST * 08h) + 0c0h + MMXSRC
endm

MMX_EMMS macro
  dw  0770fh
endm

MM0                 equ  0        ; MMX registers
MM1                 equ  1
MM2                 equ  2
MM3                 equ  3
MM4                 equ  4
MM5                 equ  5
MM6                 equ  6
MM7                 equ  7
