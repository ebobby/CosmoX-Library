;----------------------------------------------------------------------------
;
;  CosmoX BIT Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

BASIC_StrDescriptor struc
  StrLenght   dw  ?
  StrOffset   dw  ?
BASIC_StrDescriptor ends

.data

align 2

BinString           db  16 dup(0)
BinDescriptor       BASIC_StrDescriptor <16, offset BinString>

.code

public  CSShiftL, CSShiftR, CSSetBit, CSClearBit, CSToggleBit, CSReadBit
public  CSRotateL, CSRotateR, CSBin, CSBinToDec

CSShiftL proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov cx, [bp+04]
  shl ax, cl
  mov bp, bx
  ret 4
CSShiftL endp

CSShiftR proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov cx, [bp+04]
  shr ax, cl
  mov bp, bx
  ret 4
CSShiftR endp

CSRotateL proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov cx, [bp+04]
  rol ax, cl
  mov bp, bx
  ret 4
CSRotateL endp

CSRotateR proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov cx, [bp+04]
  ror ax, cl
  mov bp, bx
  ret 4
CSRotateR endp

CSSetBit proc
  mov di, bp
  mov bp, sp
  mov cx, [bp+04]
  mov bx, 1
  mov ax, [bp+06]
  or  cx, cx
  jz  @@SkipSetShift
@@SetShift:
  shl bx, 1
  dec cx
  jnz @@SetShift
@@SkipSetShift:
  or  ax, bx
  mov bp, di
  ret 4
CSSetBit endp

CSClearBit proc
  mov di, bp
  mov bp, sp
  mov cx, [bp+04]
  mov bx, 1
  mov ax, [bp+06]
  or  cx, cx
  jz  @@SkipClearShift
@@ClearShift:
  shl bx, 1
  dec cx
  jnz @@ClearShift
@@SkipClearShift:
  not bx
  and ax, bx
  mov bp, di
  ret 4
CSClearBit endp

CSToggleBit proc
  mov di, bp
  mov bp, sp
  mov cx, [bp+04]
  mov bx, 1
  mov ax, [bp+06]
  or  cx, cx
  je  @@SkipToggleShift
@@ToggleShift:
  shl bx, 1
  dec cx
  jnz @@ToggleShift
@@SkipToggleShift:
  test ax, bx
  jnz @@ToggleOff
  or  ax, bx
  mov bp, di
  ret 4
@@ToggleOff:
  not bx
  and ax, bx
  mov bp, di
  ret 4
CSToggleBit endp

CSReadBit proc
  mov di, bp
  mov bp, sp
  mov cx, [bp+04]
  mov bx, 1
  mov dx, [bp+06]
  or  cx, cx
  je  @@SkipReadShift
@@ReadShift:
  shl bx, 1
  dec cx
  jnz @@ReadShift
@@SkipReadShift:
  xor ax, ax
  test dx, bx
  setnz al
  mov bp, di
  ret 4
CSReadBit endp

CSBin proc
  push bp
  mov bp, sp
  mov bx, [bp+06]
  mov si, offset BinString
  mov cx, 16
  mov dx, 8000h
  mov ax, '01'
@@FillString:
  test bx, dx
  jz  @@ItsAZero
  mov [si], al
  jmp @@KeepCounters
@@ItsAZero:
  mov [si], ah
@@KeepCounters:
  inc si
  shr dx, 1
  dec cx
  jnz @@FillString
  mov ax, offset BinDescriptor
  pop bp
  ret 2
CSBin endp

CSBinToDec proc
  push bp
  mov bp, sp
  mov bx, [bp+06]
  mov di, [bx+02]
  mov cx, 16
  xor ax, ax
  mov dx, 8000h
@@ProcessString:
  mov bl, [di]
  cmp bl, '0'
  jnz @@ItsAOne
  jmp @@UpdateCounters
@@ItsAOne:
  or  ax, dx
@@UpdateCounters:
  inc di
  shr dx, 1
  dec cx
  jnz @@ProcessString
  pop bp
  ret 2
CSBinToDec endp

end
