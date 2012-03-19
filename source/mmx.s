;----------------------------------------------------------------------------
;
;  CosmoX MMX ROUTINES Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p586
.model use16 medium, basic
.stack 200h

locals @@

include mmx.inc

.data

align 2

MMXDetected         dw  0               ;  Does the CPU support MMX ?

.code

public  CSDetectMMX, CSClearMMX, CSPcopyMMX, CSMemCopyMMX, CSMemSwapMMX

CSDetectMMX proc
  pushfd
  pushfd
  pop eax
  or  eax, 00200000h
  push eax
  popfd
  pushfd
  pop eax
  popfd
  and eax, 00200000h
  or  eax, eax
  jz  @@NoMMX
  mov eax, 01h
  cpuid
  and edx, 00800000h
  or  edx, edx
  jz  @@NoMMX
  mov ax, 1
  MOV MMXDetected, ax
  ret
@@NoMMX:
  xor ax, ax
  mov MMXDetected, ax
  ret
CSDetectMMX endp

CSClearMMX proc
  push bp
  mov bp, sp
  mov dx, MMXDetected
  or  dx, dx
  jz  @@NoMMXClear
  mov bx, [bp+08]
  mov ax, [bp+06]
  mov es, bx
  mov ah, al
  mov bx, ax
  shl eax, 16
  xor di, di
  mov ax, bx
  mov cx, 2000
  mov es:[di], eax
  mov es:[di+4], eax
  MMX_MOVQ_REG_ESDI MM0
@@ClearMMXLoop:
  MMX_MOVQ_ESDI_REG MM0
  add di, 8
  MMX_MOVQ_ESDI_REG MM0
  add di, 8
  MMX_MOVQ_ESDI_REG MM0
  add di, 8
  MMX_MOVQ_ESDI_REG MM0
  add di, 8
  dec cx
  jnz @@ClearMMXLoop
  MMX_EMMS
  pop bp
  ret 4
@@NoMMXClear:
  mov bx, [bp+08]
  mov ax, [bp+06]
  mov es, bx
  mov ah, al
  mov bx, ax
  shl eax, 16
  xor di, di
  mov ax, bx
  mov cx, 16000
  rep stosd
  pop bp
  ret 4
CSClearMMX endp

CSPcopyMMX proc
  push bp
  mov bp, sp
  mov dx, MMXDetected
  or  dx, dx
  jz  @@NoMMXPcopy
  mov ax, [bp+08]
  mov bx, [bp+06]
  mov es, ax
  mov gs, bx
  xor di, di
  mov cx, 2000
@@PcopyMMXLoop:
  MMX_MOVQ_REG_ESDI MM0
  MMX_MOVQ_GSDI_REG MM0
  add di, 8
  MMX_MOVQ_REG_ESDI MM0
  MMX_MOVQ_GSDI_REG MM0
  add di, 8
  MMX_MOVQ_REG_ESDI MM0
  MMX_MOVQ_GSDI_REG MM0
  add di, 8
  MMX_MOVQ_REG_ESDI MM0
  MMX_MOVQ_GSDI_REG MM0
  add di, 8
  dec cx
  jnz @@PcopyMMXLoop
  MMX_EMMS
  pop bp
  ret 4
@@NoMMXPcopy:
  mov dx, ds
  mov ax, [bp+08]
  mov bx, [bp+06]
  mov ds, ax
  mov es, bx
  mov cx, 16000
  xor di, di
  xor si, si
  rep movsd
  mov ds, dx
  pop bp
  ret 4
CSPcopyMMX endp

CSMemCopyMMX proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov bx, [bp+16]
  mov cx, [bp+08]
  mov si, [bp+18]
  mov di, [bp+12]
  mov dx, MMXDetected
  mov ds, ax
  mov es, bx
  and cx, 7
  rep movsb
  or  dx, dx
  jz  @@NoMMXMemCopy
  mov cx, [bp+08]
  shr cx, 3
@@MMXMemCopyLoop:
  MMX_MOVQ_REG_DSSI MM0
  MMX_MOVQ_ESDI_REG MM0
  add si, 8
  add di, 8
  dec cx
  jnz @@MMXMemCopyLoop
  MMX_EMMS
  pop ds
  pop bp
  ret 16
@@NoMMXMemCopy:
  mov cx, [bp+08]
  and cx, 0fff8h
  shr cx, 2
  rep movsd
  pop ds
  pop bp
  ret 16
CSMemCopyMMX endp

CSMemSwapMMX proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov bx, [bp+16]
  mov cx, [bp+08]
  mov si, [bp+18]
  mov di, [bp+12]
  mov dx, MMXDetected
  mov ds, ax
  mov es, bx
  and cx, 7
  jz  @@MMXMemSwapSkip
@@MMXMemSwapLoop1:
  mov ah, [si]
  mov al, es:[di]
  mov [si], al
  mov es:[di], ah
  inc si
  inc di
  dec cx
  jnz @@MMXMemSwapLoop1
@@MMXMemSwapSkip:
  or  dx, dx
  jz  @@NoMMXMemSwap
  mov cx, [bp+08]
  shr cx, 3
@@MMXMemSwapLoop:
  MMX_MOVQ_REG_DSSI MM0
  MMX_MOVQ_REG_ESDI MM1
  MMX_MOVQ_ESDI_REG MM0
  MMX_MOVQ_DSSI_REG MM1
  add si, 8
  add di, 8
  dec cx
  jnz @@MMXMemSwapLoop
  MMX_EMMS
  pop ds
  pop bp
  ret 16
@@NoMMXMemSwap:
  mov cx, [bp+08]
  and cx, 0fff8h
  shr cx, 2
@@MMXMemSwapLoop2:
  mov eax, [si]
  mov ebx, es:[di]
  mov es:[di], eax
  mov [si], ebx
  add si, 4
  add di, 4
  dec cx
  jnz @@MMXMemSwapLoop2
  pop ds
  pop bp
  ret 16
CSMemSwapMMX endp

end
