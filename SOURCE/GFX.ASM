;----------------------------------------------------------------------------
;
;  CosmoX GFX Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

extrn ClipX1      :  word
extrn ClipX2      :  word
extrn ClipY1      :  word
extrn ClipY2      :  word

.data

align 2

RandSeed            dw 1234h

.code

public  CSFire

CSFire proc
  push bp
  mov bp, sp
  mov ax, [bp+16]
  mov si, [bp+12]
  mov es, ax
  mov bx, si
  shl si, 8
  shl bx, 6
  add si, bx
  add si, [bp+14]
  mov cx, [bp+10]
  mov bx, [bp+08]
@@RandomLineLoop:
  call Random
  and dx, 01h
  imul dx, bx
  mov es:[si], dl
  inc si
  dec cx
  jnz @@RandomLineLoop
  xor edx, edx
  mov dx, [bp+12]
  mov di, [bp+14]
  mov bx, [bp+12]
  mov cx, [bp+14]
  sub bx, [bp+06]
  add di, [bp+10]
  mov bp, bx
@@NextPixel:
  mov si, dx
  mov bx, dx
  shl si, 8
  shl bx, 6
  add si, bx
  add si, cx
  xor ax, ax
  mov al, es:[si]
  add al, es:[si-1]
  adc ah, 0
  add al, es:[si+1]
  adc ah, 0
  add al, es:[si-320]
  adc ah, 0
  shr ax, 2
  jz  @@BlackPixel
  dec ax
@@BlackPixel:
  mov es:[si-320], al
  inc cx
  cmp cx, di
  jng @@NextPixel
  sub cx, di
  dec dx
  cmp dx, bp
  jnl @@NextPixel
  pop bp
  ret 12
CSFire endp

Random proc
  mov ax, [RandSeed]
  mov dx, 8405h
  mul dx
  inc ax
  mov [RandSeed], ax
  ret
Random endp

end
