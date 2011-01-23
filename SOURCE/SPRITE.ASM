;----------------------------------------------------------------------------
;
;  CosmoX SPRITE Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

extrn BMapActive  :  byte
extrn BMapSeg     :  word
extrn ClipX1      :  word
extrn ClipX2      :  word
extrn ClipY1      :  word
extrn ClipY2      :  word

.data

align 2

ScaleX              dd  ?               ;  Scaling sprites variable
ScaleY              dd  ?               ;  Scaling sprites variable
ScaleXAdd           dd  ?               ;  Scaling sprites variable
ScaleYAdd           dd  ?               ;  Scaling sprites variable
PointX              dw  ?               ;  Just some variables to help me
PointY              dw  ?               ;  Just some variables to help me
SHeight             dw  ?               ;  Sprite Height
SWidth              dw  ?               ;  Sprite Width

include sincos.inc

.code

public  CSSize, CSGet, CSSprite, CSSpriteC, CSSpriteB, CSSpriteF, CSSpriteO
public  CSSpriteFlipH, CSSpriteFlipV, CSSpriteFlipped, CSSpriteS, CSSpriteR
public  CSSpriteRZ, CSSpriteN, CSCollision, CSCollisionC, CSCollide

CSSize proc
  push bp
  mov bp, sp
  mov ax, [bp+08]
  sub ax, [bp+12]
  inc ax
  mov cx, [bp+06]
  sub cx, [bp+10]
  inc cx
  mul cx
  add ax, 4
  shr ax, 1
  pop bp
  ret 8
CSSize endp

CSGet proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov ds, ax
  mov ax, [bp+12]
  mov es, ax
  mov di, [bp+08]
  mov ax, [bp+18]
  mov si, ax
  shl ax, 8
  shl si, 6
  add si, ax
  add si, [bp+20]
  mov ax, [bp+14]
  sub ax, [bp+18]
  inc ax
  mov dx, ax
  mov ax, [bp+16]
  sub ax, [bp+20]
  inc ax
  shl ax, 3
  mov es:[di], ax
  add di, 2
  shr ax, 3
  mov es:[di], dx
  add di, 2
  mov cx, ax
  test cx, 3
  jz  @@DWordGet
  test cx, 1
  jz  @@WordGet
@@ByteGet:
  mov cx, ax
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  sub si, ax
  add si, 320
  dec dx
  jnz @@ByteGet
  jmp @@EndGet
@@DWordGet:
  mov cx, ax
  shr cx, 2
  rep movsd
  sub si, ax
  add si, 320
  dec dx
  jnz @@DWordGet
  jmp @@EndGet
@@WordGet:
  mov cx, ax
  shr cx, 1
  rep movsw
  sub si, ax
  add si, 320
  dec dx
  jnz @@WordGet
@@EndGet:
  pop ds
  pop bp
  ret 16
CSGet endp

CSSprite proc
  push bp
  xor ax, ax
  push ax
  mov bp, sp
  mov ax, [bp+18]
  mov dx, [bp+12]
  mov es, ax
  mov fs, dx
  mov si, [bp+08]
  mov ax, [bp+14]
  mov cx, fs:[si]
  add si, 2
  shr cx, 3
  mov bx, fs:[si]
  add si, 2
  cmp ax, ClipY2
  jg  @@EndSprite
  cmp ax, ClipY1
  jl  @@TooHigh
@@NotTooHigh:
  mov di, ax
  shl di, 2
  add di, ax
  shl di, 6
  add ax, bx
  cmp ax, ClipY1
  jl  @@EndSprite
  cmp ax, ClipY2
  jg  @@TooLow
@@NotTooLow:
  mov ax, [bp+16]
  cmp ax, ClipX2
  jg  @@EndSprite
  cmp ax, ClipX1
  jl  @@TooLeft
@@NotTooLeft:
  add di, [bp+16]
  add ax, cx
  cmp ax, ClipX1
  jl  @@EndSprite
  cmp ax, ClipX2
  jg  @@TooRight
@@NotTooRight:
  mov dx, cx
  mov bp, [bp]
@@SpriteLoop:
  mov ah, fs:[si]
  inc si
  or  ah, ah
  jz  @@SkipPixel
  mov es:[di], ah
@@SkipPixel:
  inc di
  dec cx
  jnz @@SpriteLoop
  mov cx, dx
  add di, 320
  add si, bp
  sub di, dx
  dec bx
  jnz @@SpriteLoop
@@EndSprite:
  pop ax
  pop bp
  ret 12
@@TooHigh:
  mov dx, ClipY1
  sub dx, ax
  sub bx, dx
  jle @@EndSprite
  add ax, dx
  imul dx, cx
  add si, dx
  jmp @@NotTooHigh
@@TooLow:
  sub ax, ClipY2
  sub bx, ax
  inc bx
  jmp @@NotTooLow
@@TooLeft:
  mov dx, ClipX1
  sub dx, ax
  sub cx, dx
  jle @@EndSprite
  add ax, dx
  add si, dx
  mov [bp+16], ax
  mov [bp], dx
  jmp @@NotTooLeft
@@TooRight:
  sub ax, ClipX2
  dec ax
  add [bp], ax
  sub cx, ax
  jmp @@NotTooRight
CSSprite endp

CSSpriteB proc
  push bp
  xor ax, ax
  push ax
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndSpriteB
  mov ax, BMapSeg
  mov gs, ax
  mov ax, [bp+18]
  mov dx, [bp+12]
  mov es, ax
  mov fs, dx
  mov si, [bp+08]
  mov ax, [bp+14]
  mov cx, fs:[si]
  add si, 2
  shr cx, 3
  mov bx, fs:[si]
  add si, 2
  cmp ax, ClipY2
  jg  @@EndSpriteB
  cmp ax, ClipY1
  jl  @@TooHighB
@@NotTooHighB:
  mov di, ax
  shl di, 2
  add di, ax
  shl di, 6
  add ax, bx
  cmp ax, ClipY1
  jl  @@EndSpriteB
  cmp ax, ClipY2
  jg  @@TooLowB
@@NotTooLowB:
  mov ax, [bp+16]
  cmp ax, ClipX2
  jg  @@EndSpriteB
  cmp ax, ClipX1
  jl  @@TooLeftB
@@NotTooLeftB:
  add di, [bp+16]
  add ax, cx
  cmp ax, ClipX1
  jl  @@EndSpriteB
  cmp ax, ClipX2
  jg  @@TooRightB
@@NotTooRightB:
  mov dx, cx
  mov bp, [bp]
@@SpriteLoopB:
  mov al, fs:[si]
  inc si
  or  al, al
  jz  @@SkipPixelB
  push bx
  mov bl, es:[di]
  mov bh, al
  mov al, gs:[bx]
  pop bx
  mov es:[di], al
@@SkipPixelB:
  inc di
  dec cx
  jnz @@SpriteLoopB
  mov cx, dx
  add di, 320
  add si, bp
  sub di, dx
  dec bx
  jnz @@SpriteLoopB
@@EndSpriteB:
  pop ax
  pop bp
  ret 12
@@TooHighB:
  mov dx, ClipY1
  sub dx, ax
  sub bx, dx
  jle @@EndSpriteB
  add ax, dx
  imul dx, cx
  add si, dx
  jmp @@NotTooHighB
@@TooLowB:
  sub ax, ClipY2
  sub bx, ax
  inc bx
  jmp @@NotTooLowB
@@TooLeftB:
  mov dx, ClipX1
  sub dx, ax
  sub cx, dx
  jle @@EndSpriteB
  add ax, dx
  add si, dx
  mov [bp+16], ax
  mov [bp], dx
  jmp @@NotTooLeftB
@@TooRightB:
  sub ax, ClipX2
  dec ax
  add [bp], ax
  sub cx, ax
  jmp @@NotTooRightB
CSSpriteB endp

CSSpriteC proc
  push bp
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+12]
  mov gs, ax
  mov si, [bp+08]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  xor ax, ax
  MOV PointX, ax
  MOV PointY, ax
  mov dx, [bp+14]
  mov cx, [bp+16]
@@SpriteCLoop:
  mov al, gs:[si]
  inc si
  or  al, al
  jz  @@SkipSpriteCPixel
  cmp cx, ClipX1
  jl  @@SkipSpriteCPixel
  cmp cx, ClipX2
  jg  @@SkipSpriteCPixel
  cmp dx, ClipY1
  jl  @@SkipSpriteCPixel
  cmp dx, ClipY2
  jg  @@SkipSpriteCPixel
  mov al, [bp+06]
  mov es:[di], al
@@SkipSpriteCPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@SpriteCLoop
  mov cx, [bp+16]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@SpriteCLoop
  pop bp
  ret 14
CSSpriteC ENDP

CSSpriteF proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+12]
  mov ds, ax
  mov si, [bp+08]
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov ax, [si]
  add si, 2
  mov dx, ax
  shr dx, 3
  mov bx, 320
  sub bx, dx
  mov ax, [si]
  add si, 2
  mov cx, dx
@@FixAddressSF:
  test di, 3
  jz  @@NoOddPixelsSF
  movsb
  dec cx
  jg  @@FixAddressSF
@@NoOddPixelsSF:
  or  cx, cx
  js  @@SkipScanLine
  mov bp, cx
  shr cx, 2
  rep movsd
  mov cx, bp
  and cx, 3
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
@@SkipScanLine:
  mov cx, dx
  add di, bx
  dec ax
  jnz @@FixAddressSF
@@EndPut:
  pop ds
  pop bp
  ret 12
CSSpriteF endp

CSSpriteO proc
  push bp
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+12]
  mov gs, ax
  mov si, [bp+08]
  xor ax, ax
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  mov dx, [bp+14]
  mov cx, [bp+16]
@@SpriteOLoop:
  mov al, gs:[si]
  inc si
  or  al, al
  jz  @@SkipSpriteOPixel
  cmp cx, ClipX1
  jl  @@SkipSpriteOPixel
  cmp cx, ClipX2
  jg  @@SkipSpriteOPixel
  cmp dx, ClipY1
  jl  @@SkipSpriteOPixel
  cmp dx, ClipY2
  jg  @@SkipSpriteOPixel
  mov ah, 1
  cmp [bp+06], ah
  je  @@AndPixel
  inc ah
  cmp [bp+06], ah
  je  @@OrPixel
  xor es:[di], al
  jmp @@SkipSpriteOPixel
@@AndPixel:
  inc ah
  cmp [bp+06], ah
  je  @@OrPixel
  and es:[di], al
  jmp @@SkipSpriteOPixel
@@OrPixel:
  or  es:[di], al
@@SkipSpriteOPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@SpriteOLoop
  mov cx, [bp+16]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@SpriteOLoop
@@EndSpriteO:
  pop bp
  ret 14
CSSpriteO endp

CSSpriteFlipH proc
  push bp
  mov bp, sp
  mov ax, [bp+16]
  mov es, ax
  mov ax, [bp+10]
  mov gs, ax
  mov si, [bp+06]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+12]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+14]
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  add si, bx
  dec si
  mov dx, [bp+12]
  mov cx, [bp+14]
@@SpriteFlipHLoop:
  mov al, gs:[si]
  dec si
  or  al, al
  jz  @@SkipSpriteFlipHPixel
  cmp cx, ClipX1
  jl  @@SkipSpriteFlipHPixel
  cmp cx, ClipX2
  ja  @@SkipSpriteFlipHPixel
  cmp dx, ClipY1
  jl  @@SkipSpriteFlipHPixel
  cmp dx, ClipY2
  ja  @@SkipSpriteFlipHPixel
  mov es:[di], al
@@SkipSpriteFlipHPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@SpriteFlipHLoop
  add si, bx
  add si, bx
  mov cx, [bp+14]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@SpriteFlipHLoop
  pop bp
  ret 12
CSSpriteFlipH endp

CSSpriteFlipV proc
  push bp
  mov bp, sp
  mov ax, [bp+16]
  mov es, ax
  mov ax, [bp+10]
  mov gs, ax
  mov si, [bp+06]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+12]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+14]
  mov ax, SHeight
  mov cx, bx
  mul cx
  add si, ax
  sub si, bx
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  mov dx, [bp+12]
  MOV CX, [BP+14]
@@SpriteFlipVLoop:
  mov al, gs:[si]
  inc si
  or  al, al
  jz  @@SkipSpriteFlipVPixel
  cmp cx, ClipX1
  jl  @@SkipSpriteFlipVPixel
  cmp cx, ClipX2
  ja  @@SkipSpriteFlipVPixel
  cmp dx, ClipY1
  jl  @@SkipSpriteFlipVPixel
  cmp dx, ClipY2
  ja  @@SkipSpriteFlipVPixel
  mov es:[di], al
@@SkipSpriteFlipVPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@SpriteFlipVLoop
  sub si, bx
  sub si, bx
  mov cx, [bp+14]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@SpriteFlipVLoop
  pop bp
  ret 12
CSSpriteFlipV endp

CSSpriteFlipped proc
  push bp
  mov bp, sp
  mov ax, [bp+16]
  mov es, ax
  mov ax, [bp+10]
  mov gs, ax
  mov si, [bp+06]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+12]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+14]
  mov ax, SHeight
  mov cx, bx
  mul cx
  add si, ax
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  dec si
  mov dx, [bp+12]
  mov cx, [bp+14]
@@SpriteFlippedLoop:
  mov al, gs:[si]
  dec si
  or  al, al
  jz  @@SkipSpriteFlippedPixel
  cmp cx, ClipX1
  jl  @@SkipSpriteFlippedPixel
  cmp cx, ClipX2
  ja  @@SkipSpriteFlippedPixel
  cmp dx, ClipY1
  jl  @@SkipSpriteFlippedPixel
  cmp dx, ClipY2
  ja  @@SkipSpriteFlippedPixel
  mov es:[di], al
@@SkipSpriteFlippedPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@SpriteFlippedLoop
  mov cx, [bp+14]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@SpriteFlippedLoop
  pop bp
  ret 12
CSSpriteFlipped endp

CSSpriteS proc
  push bp
  mov bp, sp
  mov ax, [bp+20]
  mov es, ax
  mov ax, [bp+10]
  mov gs, ax
  mov si, [bp+06]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov SWidth, ax
  xor ebx, ebx
  shl eax, 16
  mov bx, [bp+14]
  mov edx, eax
  sar edx, 31
  div ebx
  mov ScaleX, eax
  mov ax, gs:[si]
  add si, 2
  shl eax, 16
  mov bx, [bp+12]
  mov edx, eax
  sar edx, 31
  div ebx
  mov ScaleY, eax
  xor eax, eax
  mov PointX, ax
  mov PointY, ax
  mov ScaleYAdd, eax
  mov ax, [bp+16]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+18]
  mov dx, [bp+16]
  xor ecx, ecx
@@SpriteSLoop:
  mov ax, PointX
  add ax, [bp+18]
  cmp ax, ClipX1
  jl  @@SkipScalePixel
  cmp ax, ClipX2
  jg  @@SkipScalePixel
  cmp dx, ClipY1
  jl  @@SkipScalePixel
  cmp dx, ClipY2
  jg  @@EndScaleSprite
  mov al, gs:[si+bx]
  or  al, al
  je  @@SkipScalePixel
  mov es:[di], al
@@SkipScalePixel:
  inc di
  add ecx, ScaleX
  mov ebx, ecx
  shr ebx, 16
  inc PointX
  mov ax, PointX
  cmp ax, [bp+14]
  jnz @@SpriteSLoop
  add di, 320
  sub di, PointX
  mov fs, dx
  mov si, [bp+06]
  add si, 4
  mov ecx, ScaleY
  add ScaleYAdd, ecx
  mov eax, ScaleYAdd
  shr eax, 16
  mov bx, SWidth
  xor dx, dx
  mul bx
  add si, ax
  xor ecx, ecx
  mov PointX, cx
  mov dx, fs
  inc dx
  inc PointY
  mov ax, PointY
  cmp ax, [bp+12]
  jnz @@SpriteSLoop
@@EndScaleSprite:
  pop bp
  ret 16
CSSpriteS endp

CSSpriteR proc
  push bp
  push eax
  push eax
  mov bp, sp
  mov ax, [bp+26]
  mov bx, [bp+18]
  mov si, [bp+20]
  mov es, ax
  mov fs, bx
  shl si, 1
  mov ax, Cosine[si]
  mov bx, Sine[si]
  mov [bp+02], ax
  mov [bp], bx
  mov si, [bp+14]
  mov ax, fs:[si]
  mov bx, fs:[si+02]
  shr ax, 3
  add si, 4
  xor cx, cx
  mov SWidth, ax
  mov SHeight, bx
  shr ax, 1
  shr bx, 1
  mov PointX, cx
  mov PointY, cx
  add [bp+24], ax
  add [bp+22], bx
@@LoopSpriteR:
  mov bl, fs:[si]
  inc si
  or  bl, bl
  jz  @@SkipPixelR
  mov bh, bl
  mov gs, bx
  mov ax, PointX
  mov bx, SWidth
  shr bx, 1
  sub ax, bx
  mov dx, PointY
  mov bx, SHeight
  shr bx, 1
  sub dx, bx
  mov bx, [bp+02]
  imul bx, ax
  mov cx, [bp]
  imul cx, dx
  sub bx, cx
  sar bx, 7
  add bx, [bp+24]
  cmp bx, ClipX1
  jl  @@SkipPixelR
  cmp bx, ClipX2
  jge @@SkipPixelR
  mov cx, [bp+02]
  imul cx, dx
  mov dx, [bp]
  imul dx, ax
  add cx, dx
  sar cx, 7
  add cx, [bp+22]
  cmp cx, ClipY1
  jl  @@SkipPixelR
  cmp cx, ClipY2
  jg  @@SkipPixelR
  mov di, cx
  shl di, 8
  shl cx, 6
  add di, cx
  add di, bx
  mov ax, gs
  mov es:[di], ax
@@SkipPixelR:
  mov ax, PointX
  inc ax
  mov PointX, ax
  cmp ax, SWidth
  jl  @@LoopSpriteR
  mov bx, PointY
  inc bx
  cmp bx, SHeight
  jge @@EndSpriteR
  mov PointY, bx
  xor ax, ax
  mov PointX, ax
  jmp @@LoopSpriteR
@@EndSpriteR:
  pop eax
  pop eax
  pop bp
  ret 14
CSSpriteR endp

CSSpriteRZ proc
  push bp
  push eax
  mov bp, sp
  mov ax, [bp+26]
  mov bx, [bp+16]
  mov dx, [bp+14]
  mov si, [bp+10]
  mov es, ax
  mov fs, dx
  shl bx, 1
  mov ax, Cosine[bx]
  mov dx, Sine[bx]
  mov [bp+02], ax
  mov [bp], dx
  mov ax, fs:[si]
  add si, 2
  shr ax, 3
  mov SWidth, ax
  xor ebx, ebx
  mov bx, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  div ebx
  mov ScaleX, eax
  xor ebx, ebx
  mov ax, fs:[si]
  add si, 2
  mov bx, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  div ebx
  mov ScaleY, eax
  mov ax, [bp+20]
  mov dx, [bp+18]
  xor ecx, ecx
  shr ax, 1
  shr dx, 1
  mov ScaleXAdd, ecx
  mov ScaleYAdd, ecx
  mov PointX, cx
  mov PointY, cx
  add [bp+24], ax
  add [bp+22], dx
@@SpriteRZLoop:
  mov ebx, ScaleXAdd
  shr ebx, 16
  mov cl, fs:[si+bx]
  or  cl, cl
  jz  @@SkipPixelRZ
  mov ch, cl
  mov gs, cx
  mov ax, PointX
  mov bx, [bp+20]
  shr bx, 1
  sub ax, bx
  mov dx, PointY
  mov bx, [bp+18]
  shr bx, 1
  sub dx, bx
  mov bx, [bp+02]
  imul bx, ax
  mov cx, [bp]
  imul cx, dx
  sub bx, cx
  sar bx, 7
  add bx, [bp+24]
  cmp bx, ClipX1
  jl  @@SkipPixelRZ
  cmp bx, ClipX2
  jge @@SkipPixelRZ
  mov cx, [bp+02]
  imul cx, dx
  mov dx, [bp]
  imul dx, ax
  add cx, dx
  sar cx, 7
  add cx, [bp+22]
  cmp cx, ClipY1
  jl  @@SkipPixelRZ
  cmp cx, ClipY2
  JG  @@SkipPixelRZ
  mov di, cx
  shl di, 8
  shl cx, 6
  add di, cx
  add di, bx
  mov ax, gs
  mov es:[di], ax
@@SkipPixelRZ:
  mov eax, ScaleXAdd
  add eax, ScaleX
  mov ScaleXAdd, eax
  inc PointX
  mov bx, PointX
  cmp bx, [bp+20]
  jle @@SpriteRZLoop
  mov si, [bp+10]
  xor ecx, ecx
  mov PointX, cx
  mov ScaleXAdd, ecx
  add si, 4
  mov eax, ScaleYAdd
  add eax, ScaleY
  mov ScaleYAdd, eax
  shr eax, 16
  mov bx, SWidth
  xor dx, dx
  mul bx
  add si, ax
  inc PointY
  mov dx, PointY
  cmp dx, [bp+18]
  jl  @@SpriteRZLoop
  pop eax
  pop bp
  ret 18
CSSpriteRZ endp

CSSpriteN proc
  push bp
  xor ax, ax
  push ax
  mov bp, sp
  push ds
  mov ax, [bp+18]
  mov dx, [bp+12]
  mov es, ax
  mov fs, dx
  mov si, [bp+08]
  mov ax, [bp+14]
  mov cx, fs:[si]
  add si, 2
  shr cx, 3
  mov bx, fs:[si]
  add si, 2
  cmp ax, ClipY2
  jg  @@EndSpriteN
  cmp ax, ClipY1
  jl  @@TooHighN
@@NotTooHighN:
  mov di, ax
  shl di, 2
  add di, ax
  shl di, 6
  add ax, bx
  cmp ax, ClipY1
  jl  @@EndSpriteN
  cmp ax, ClipY2
  jg  @@TooLowN
@@NotTooLowN:
  mov ax, [bp+16]
  cmp ax, ClipX2
  jg  @@EndSpriteN
  cmp ax, ClipX1
  jl  @@TooLeftN
@@NotTooLeftN:
  add di, [bp+16]
  add ax, cx
  cmp ax, ClipX1
  jl  @@EndSpriteN
  cmp ax, ClipX2
  jg  @@TooRightN
@@NotTooRightN:
  mov dx, fs
  mov ds, dx
  mov dx, cx
  mov ax, [bp]
@@SpriteLoopN:
  test di, 3
  jz  @@NoOddPixelsN
  movsb
  dec cx
  jg  @@SpriteLoopN
@@NoOddPixelsN:
  or  cx, cx
  js  @@SkipScanLineN
  mov bp, cx
  shr cx, 2
  rep movsd
  mov cx, bp
  and cx, 3
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
@@SkipScanLineN:
  mov cx, dx
  add di, 320
  add si, ax
  sub di, dx
  dec bx
  jnz @@SpriteLoopN
@@EndSpriteN:
  pop ds
  pop ax
  pop bp
  ret 12
@@TooHighN:
  mov dx, ClipY1
  sub dx, ax
  sub bx, dx
  jle @@EndSpriteN
  add ax, dx
  imul dx, cx
  add si, dx
  jmp @@NotTooHighN
@@TooLowN:
  sub ax, ClipY2
  sub bx, ax
  inc bx
  jmp @@NotTooLowN
@@TooLeftN:
  mov dx, ClipX1
  sub dx, ax
  sub cx, dx
  jle @@EndSpriteN
  add ax, dx
  add si, dx
  mov [bp+16], ax
  mov [bp], dx
  jmp @@NotTooLeftN
@@TooRightN:
  sub ax, ClipX2
  dec ax
  add [bp], ax
  sub cx, ax
  jmp @@NotTooRightN
CSSpriteN endp

CSCollision proc
  push bp
  mov bp, sp
  mov ax, [bp+16]
  mov es, ax
  mov ax, [bp+10]
  mov gs, ax
  mov si, [bp+06]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+12]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+14]
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  mov dx, [bp+12]
  mov cx, [bp+14]
@@CollisionLoop:
  mov al, gs:[si]
  inc si
  or  al, al
  jz  @@SkipCollisionPixel
  cmp cx, ClipX1
  jl  @@SkipCollisionPixel
  cmp cx, ClipX2
  ja  @@SkipCollisionPixel
  cmp dx, ClipY1
  jl  @@SkipCollisionPixel
  cmp dx, ClipY2
  ja  @@SkipCollisionPixel
  mov al, es:[di]
  or  al, al
  jne @@EndCollision
@@SkipCollisionPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@CollisionLoop
  mov cx, [bp+14]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@CollisionLoop
  xor ax, ax
@@EndCollision:
  pop bp
  ret 12
CSCollision endp

CSCollisionC proc
  push bp
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+12]
  mov gs, ax
  mov si, [bp+08]
  mov ax, gs:[si]
  add si, 2
  shr ax, 3
  mov bx, ax
  mov ax, gs:[si]
  add si, 2
  mov SHeight, ax
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  xor ax, ax
  mov PointX, ax
  mov PointY, ax
  mov dx, [bp+14]
  mov cx, [bp+16]
@@CollisionCLoop:
  mov al, gs:[si]
  inc si
  or  al, al
  jz  @@SkipCollisionCPixel
  cmp cx, ClipX1
  jl  @@SkipCollisionCPixel
  cmp cx, ClipX2
  ja  @@SkipCollisionCPixel
  cmp dx, ClipY1
  jl  @@SkipCollisionCPixel
  cmp dx, ClipY2
  ja  @@SkipCollisionCPixel
  mov al, es:[di]
  cmp al, [bp+6]
  jz  @@ColisionCTrue
@@SkipCollisionCPixel:
  inc di
  inc cx
  inc PointX
  mov ax, PointX
  cmp ax, bx
  jnz @@CollisionCLoop
  mov cx, [bp+16]
  xor ax, ax
  mov PointX, ax
  add di, 320
  sub di, bx
  inc PointY
  inc dx
  mov ax, PointY
  cmp ax, SHeight
  jnz @@CollisionCLoop
  xor ax, ax
  jmp @@EndCollisionC
@@ColisionCTrue:
  mov ax, 1
@@EndCollisionC:
  pop bp
  ret 14
CSCollisionC endp

CSCollide proc
  push bp
  sub sp, 8
  mov bp, sp
  mov ax, [bp+28]
  mov bx, [bp+18]
  mov es, ax
  mov fs, bx
  mov di, [bp+24]
  mov si, [bp+14]
  mov ax, es:[di]
  mov bx, fs:[si]
  shr ax, 3
  shr bx, 3
  mov [bp+06], ax
  mov [bp+04], bx
  mov ax, es:[di+2]
  mov bx, fs:[si+2]
  mov [bp+02], ax
  mov [bp], bx
  xor ax, ax
  mov bx, [bp+32]
  mov cx, [bp+22]
  add bx, [bp+06]
  cmp bx, cx
  jle @@EndCollide
  mov bx, [bp+22]
  mov cx, [bp+32]
  add bx, [bp+04]
  cmp bx, cx
  jle @@EndCollide
  mov bx, [bp+30]
  mov cx, [bp+20]
  add bx, [bp+02]
  cmp bx, cx
  jle @@EndCollide
  mov bx, [bp+20]
  mov cx, [bp+30]
  add bx, [bp]
  cmp bx, cx
  jle @@EndCollide
  mov ax, 0ffffh
@@EndCollide:
  add sp, 8
  pop bp
  ret 20
CSCollide endp

end
