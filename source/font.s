;----------------------------------------------------------------------------
;
;  CosmoX FONT Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

extrn BMapActive      :  byte
extrn BMapSeg         :  word
extrn ClipX1          :  word
extrn ClipX2          :  word
extrn ClipY1          :  word
extrn ClipY2          :  word

CosmoXFontFile struc
    FontFileTitle     db  'CosmoX Font File    '
    LibVersion        db  'CosmoX Library v2.0 '
CosmoXFontFile ends

.data

align 2

TextX               dw  ?               ;  Current text X
TextY               dw  ?               ;  Current text Y
TexturePos          dw  0               ;  Current position within TextTexture
FontHeader          CosmoXFontFile <>
FontID              db  'CosmoX Font File    '
TextSpacing         db  8               ;  Character spacing in pixels
TextTexture         db  64 dup (15)     ;  Text texture for PrintTextured
INCLUDE FONT.INC                        ;  Font Data

.code

public  xCSLoadFont, xCSPrint, xCSPrintSolid, xCSPrintTextured
public  xCSPrintBlended, xCSPrintReversed, CSTextTexture, CSGetTextSpacing
public  CSSetTextSpacing, CSResetFont, xCSSetFont, xCSGetFont, xCSLen

xCSLoadFont proc
  push bp
  push ds
  mov bp, sp
  mov ds, [bp+10]
  mov dx, [bp+08]
  mov ax, 3d00h
  int 21h
  jc  @@FontError
  mov bx, ax
  mov ax, seg FontHeader
  mov ds, ax
  mov dx, offset FontHeader
  mov cx, 40
  mov ah, 3fh
  int 21h
  jc  @@ReadingFontError
  mov ax, ds
  mov es, ax
  mov di, offset FontID
  mov si, offset FontHeader
  mov cx, 20
  repe cmpsb
  jne @@NoFontError
  mov ax, [bp+14]
  mov ds, ax
  mov dx, [bp+12]
  mov cx, 2048
  mov ah, 3fh
  int 21h
  jc  @@ReadingFontError
  mov ax, 3e00h
  int 21h
  jc  @@FontError
  xor ax, ax
  jmp @@EndLoad
@@ReadingFontError:
  mov ax, 3e00h
  int 21h
  mov ax, 2
  jmp @@EndLoad
@@NoFontError:
  mov ax, 3e00h
  int 21h
  mov ax, 3
  jmp @@EndLoad
@@FontError:
  mov ax, 1
@@EndLoad:
  pop ds
  pop bp
  ret 8
xCSLoadFont endp

xCSPrint proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+16]
  mov fs, ax
  mov bx, [bp+14]
  mov ax, seg FontBuffer
  mov ds, ax
  mov ax, [bp+12]
  mov TextX, ax
  mov ax, [bp+10]
  mov TextY, ax
@@NextChar:
  xor ax, ax
  mov al, fs:[bx]
  or  al, al
  jz  @@EndPrint
  shl ax, 3
  mov si, ax
@@NextY:
  xor dx, dx
  mov ch, 80h
@@NextX:
  mov cl, FontBuffer[si]
  test cl, ch
  jz  @@SkipPixel
  mov ax, TextY
  cmp ax, ClipY1
  jb  @@SkipPixel
  cmp ax, ClipY2
  ja  @@SkipPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipPixel
  cmp ax, ClipX2
  ja  @@SkipPixel
  add di, ax
  mov cl, [bp+8]
  mov es:[di], cl
@@SkipPixel:
  shr cx, 1
  inc dx
  inc TextX
  cmp dx, 8
  jnz @@NextX
  inc si
  mov ax, [bp+12]
  mov TextX, ax
  inc TextY
  mov dx, [bp+10]
  add dx, 8
  cmp dx, TextY
  jnz @@NextY
  mov ax, [bp+10]
  mov TextY, ax
  mov ax, [bp+12]
  xor dx, dx
  mov dl, TextSpacing
  add ax, dx
  mov [bp+12], ax
  mov TextX, ax
  inc bx
  jmp @@NextChar
@@EndPrint:
  xor ax, ax
  mov TextY, ax
  mov TextX, ax
  pop ds
  pop bp
  ret 12
xCSPrint endp

xCSPrintSolid proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+20]
  mov es, ax
  mov ax, [bp+18]
  mov fs, ax
  mov bx, [bp+16]
  mov ax, seg FontBuffer
  mov ds, ax
  mov ax, [bp+14]
  mov TextX, ax
  mov ax, [bp+12]
  mov TextY, ax
@@NextSolidChar:
  xor ax, ax
  mov al, fs:[bx]
  or  al, al
  jz  @@EndPrintSolid
  shl ax, 3
  mov si, ax
@@NextSolidY:
  xor dx, dx
  mov ch, 80h
@@NextSolidX:
  mov cl, FontBuffer[si]
  test cl, ch
  jz  @@BGSolidPixel
  mov ax, TextY
  cmp ax, ClipY1
  jb  @@SkipSolidPixel
  cmp ax, ClipY2
  ja  @@SkipSolidPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipSolidPixel
  cmp ax, ClipX2
  ja  @@SkipSolidPixel
  add di, ax
  mov cl, [bp+10]
  mov es:[di], cl
  jmp @@SkipSolidPixel
@@BGSolidPixel:
  mov ax, TextY
  cmp ax, ClipY1
  jb  @@SkipSolidPixel
  cmp ax, ClipY2
  ja  @@SkipSolidPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipSolidPixel
  cmp ax, ClipX2
  ja  @@SkipSolidPixel
  add di, ax
  mov cl, [bp+08]
  mov es:[di], cl
@@SkipSolidPixel:
  shr cx, 1
  inc dx
  inc TextX
  cmp dx, 8
  jnz @@NextSolidX
  inc si
  mov ax, [bp+14]
  mov TextX, ax
  inc TextY
  mov dx, [bp+12]
  add dx, 8
  cmp dx, TextY
  jnz @@NextSolidY
  mov ax, [bp+12]
  mov TextY, ax
  mov ax, [bp+14]
  add ax, 8
  mov [bp+14], ax
  mov TextX, ax
  inc bx
  jmp @@NextSolidChar
@@EndPrintSolid:
  xor ax, ax
  mov TextY, ax
  mov TextX, ax
  pop ds
  pop bp
  ret 14
xCSPrintSolid endp

xCSPrintTextured proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+16]
  mov es, ax
  mov ax, [bp+14]
  mov fs, ax
  mov bx, [bp+12]
  mov ax, seg FontBuffer
  mov ds, ax
  xor ax, ax
  mov TexturePos, ax
  mov ax, [bp+10]
  mov TextX, AX
  mov ax, [bp+08]
  mov TextY, ax
@@NextTexturedChar:
  xor ax, ax
  mov al, fs:[bx]
  or  al, al
  jz  @@EndPrintTextured
  shl ax, 3
  mov si, ax
@@NextTexturedY:
  xor dx, dx
  mov ch, 80h
@@NextTexturedX:
  mov cl, FontBuffer[si]
  test cl, ch
  jz  @@SkipTexturedPixel
  mov ax, TextY
  cmp ax, ClipY1
  jb  @@SkipTexturedPixel
  cmp ax, ClipY2
  ja  @@SkipTexturedPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipTexturedPixel
  cmp ax, ClipX2
  ja  @@SkipTexturedPixel
  add di, ax
  push si
  mov si, TexturePos
  mov cl, TextTexture[si]
  pop si
  mov es:[di], cl
@@SkipTexturedPixel:
  shr cx, 1
  inc dx
  inc TextX
  inc TexturePos
  cmp dx, 8
  jnz @@NextTexturedX
  inc si
  mov ax, [bp+10]
  mov TextX, ax
  inc TextY
  mov dx, [bp+08]
  add dx, 8
  cmp dx, TextY
  jnz @@NextTexturedY
  mov ax, [bp+08]
  mov TextY, ax
  mov ax, [bp+10]
  xor dx, dx
  mov TexturePos, dx
  mov dl, TextSpacing
  add ax, dx
  mov [bp+10], ax
  mov TextX, ax
  inc bx
  jmp @@NextTexturedChar
@@EndPrintTextured:
  xor ax, ax
  mov TextY, ax
  mov TextX, ax
  mov TexturePos, ax
  pop ds
  pop bp
  ret 10
xCSPrintTextured endp

xCSPrintReversed proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+16]
  mov fs, ax
  mov bx, [bp+14]
  mov ax, seg FontBuffer
  mov ds, ax
  mov ax, [bp+12]
  mov TextX, ax
  mov ax, [bp+10]
  add ax, 8
  mov TextY, ax
@@NextReversedChar:
  xor ax, ax
  mov al, fs:[bx]
  or  al, al
  jz  @@EndReversedPrint
  shl ax, 3
  mov si, ax
@@NextReversedY:
  xor dx, dx
  mov ch, 80h
@@NextReversedX:
  mov cl, FontBuffer[si]
  test cl, ch
  jz  @@SkipReversedPixel
  mov ax, TextY
  cmp ax, ClipY1
  JB  @@SkipReversedPixel
  cmp ax, ClipY2
  ja  @@SkipReversedPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipReversedPixel
  cmp ax, ClipX2
  ja  @@SkipReversedPixel
  add di, ax
  mov cl, [bp+08]
  mov es:[di], cl
@@SkipReversedPixel:
  shr cx, 1
  inc dx
  inc TextX
  cmp dx, 8
  jnz @@NextReversedX
  inc si
  mov ax, [bp+12]
  mov TextX, ax
  dec TextY
  mov dx, [bp+10]
  cmp dx, TextY
  jnz @@NextReversedY
  mov ax, [bp+10]
  add ax, 8
  mov TextY, ax
  mov ax, [bp+12]
  xor dx, dx
  mov dl, TextSpacing
  add ax, dx
  mov [bp+12], ax
  mov TextX, ax
  inc bx
  jmp @@NextReversedChar
@@EndReversedPrint:
  xor ax, ax
  mov TextY, ax
  mov TextX, ax
  pop ds
  pop bp
  ret 12
xCSPrintReversed endp

xCSPrintBlended proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndBPrint
  mov ax, [bp+18]
  mov es, ax
  mov ax, [bp+16]
  mov fs, ax
  mov bx, [bp+14]
  mov ax, seg FontBuffer
  mov ds, ax
  mov ax, BMapSeg
  mov gs, ax
  mov ax, [bp+12]
  MOV TextX, ax
  mov ax, [bp+10]
  mov TextY, ax
@@NextBChar:
  xor ax, ax
  mov al, fs:[bx]
  or  al, al
  jz  @@EndBPrint
  shl ax, 3
  mov si, ax
@@NextBY:
  xor dx, dx
  mov ch, 80h
@@NextBX:
  mov cl, FontBuffer[si]
  test cl, ch
  jz  @@SkipBPixel
  mov ax, TextY
  cmp ax, ClipY1
  jb  @@SkipBPixel
  cmp ax, ClipY2
  ja  @@SkipBPixel
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  mov ax, TextX
  cmp ax, ClipX1
  jb  @@SkipBPixel
  cmp ax, ClipX2
  ja  @@SkipBPixel
  add di, ax
  push bx
  mov bl, es:[di]
  mov cl, [bp+08]
  mov bh, cl
  mov cl, gs:[bx]
  pop bx
  mov es:[di], cl
@@SkipBPixel:
  shr cx, 1
  inc dx
  inc TextX
  cmp dx, 8
  jnz @@NextBX
  inc si
  mov ax, [bp+12]
  mov TextX, ax
  inc TextY
  mov dx, [bp+10]
  add dx, 8
  cmp dx, TextY
  jnz @@NextBY
  mov ax, [bp+10]
  mov TextY, ax
  mov ax, [bp+12]
  xor dx, dx
  mov dl, TextSpacing
  add ax, dx
  mov [bp+12], ax
  mov TextX, ax
  inc bx
  jmp @@NextBChar
@@EndBPrint:
  xor ax, ax
  mov TextY, ax
  mov TextX, ax
  pop ds
  pop bp
  ret 12
xCSPrintBlended endp

CSSetTextSpacing proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+04]
  mov TextSpacing, al
  mov bp, bx
  ret 2
CSSetTextSpacing endp

CSTextTexture proc
  mov bx, bp
  mov dx, ds
  mov bp, sp
  mov ds, [bp+06]
  mov si, [bp+04]
  mov ax, seg TextTexture
  mov es, ax
  mov di, offset TextTexture
  mov cx, 64
  shr cx, 2
  rep movsd
  mov bp, bx
  mov ds, dx
  ret 4
CSTextTexture endp

CSGetTextSpacing proc
  xor ah, ah
  mov al, TextSpacing
  ret
CSGetTextSpacing endp

CSResetFont proc
  push ds
  mov ax, 351fH
  int 21H
  mov ax, es
  mov ds, ax
  mov si, bx
  sub si, 1024
  mov ax, seg FontBuffer
  mov es, ax
  mov di, offset FontBuffer
  mov cx, 512
  rep movsd
  pop ds
  ret
CSResetFont endp

xCSSetFont proc
  mov dx, ds
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov si, [bp+04]
  mov ds, ax
  mov ax, seg FontBuffer
  mov di, offset FontBuffer
  mov es, ax
  mov cx, 512
  rep movsd
  mov ds, dx
  mov bp, bx
  ret 4
xCSSetFont endp

xCSGetFont proc
  mov dx, ds
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov di, [bp+04]
  mov es, ax
  mov ax, seg FontBuffer
  mov si, offset FontBuffer
  mov ds, ax
  mov cx, 512
  rep movsd
  mov ds, dx
  mov bp, bx
  ret 4
xCSGetFont endp

xCSLen proc
  push bp
  mov bp, sp
  mov ax, [bp+08]
  mov di, [bp+06]
  mov es, ax
  xor cx, cx
  xor ax, ax
@@FindLen:
  mov al, es:[di]
  inc di
  or  al, al
  jz  @@EndFindLen
  inc cx
  jmp @@FindLen
@@EndFindLen:
  xor bh, bh
  mov ax, cx
  mov bl, 8
  xor dx, dx
  mul bx
  pop bp
  ret 4
xCSLen endp

end
