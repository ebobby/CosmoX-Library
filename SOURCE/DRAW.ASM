;----------------------------------------------------------------------------
;
;  CosmoX DRAW Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

extrn BMapActive    :  byte
extrn BMapSeg       :  word
extrn ClipX1        :  word
extrn ClipX2        :  word
extrn ClipY1        :  word
extrn ClipY2        :  word

.data

align 2

Xerr                dw  0             ; \
Yerr                dw  0             ;   |
DeltaX              dw  0             ;   |
DeltaY              dw  0             ;   | Bresenham's line algorithm
XInc                dw  0             ;   |
YInc                dw  0             ;   |
Distance            dw  0             ;  /
Point               dw  0             ;  Just some variables to help me
WindowHeight        dw  0             ;  Used by CSWindow to speed things up
WindowPos1          dw  0             ;  Used by CSWindow to speed things up
WindowPos2          dw  0             ;  Used by CSWindow to speed things up
WindowWidth         dw  0             ;  Used by CSWindow to speed things up

.code

public  CSPset, CSPoint, CSBox, CSBoxF, CSLine, CSCircle, CSCircleF, CSEllipse
public  CSEllipseF, CSScroll, CSScrollArea, CSPcopy, CSPcopyT, CSPcopyB
public  CSPcopyC, CSClear, CSWin, CSAntiAliase, CSTri, CSCopyBlock, CSPsetB
public  CSBoxFB

PUTPIXEL macro
local @@NoPut
  cmp dx, ClipX1
  jl  @@NoPut
  cmp dx, ClipX2
  jg  @@NoPut
  cmp bx, ClipY1
  jl  @@NoPut
  cmp bx, ClipY2
  jg  @@NoPut
  mov di, bx
  shl bx, 8
  shl di, 6
  add di, bx
  add di, dx
  mov es:[di], al
@@NoPut:
endm

HLINE macro
local @@NoLineH, @@NoClipX1, @@NoClipX2, @@NoOddPixel
  cmp dx, ClipX1
  jge @@NoClipX1
  mov dx, ClipX1
@@NoClipX1:
  cmp dx, ClipX2
  jg  @@NoLineH
  cmp cx, ClipX1
  jl  @@NoLineH
  cmp cx, ClipX2
  jle @@NoClipX2
  mov cx, ClipX2
@@NoClipX2:
  cmp bx, ClipY1
  jl  @@NoLineH
  cmp bx, ClipY2
  jg  @@NoLineH
  sub cx, dx
  mov di, bx
  shl bx, 8
  shl di, 6
  add di, bx
  add di, dx
  test di, 1
  jz  @@NoOddPixel
  mov es:[di], al
  inc di
  dec cx
  jle @@NoLineH
@@NoOddPixel:
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
@@NoLineH:
endm

CSPset proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+10]
  mov dx, [bp+06]
  mov cx, [bp+08]
  mov es, ax
  cmp dx, ClipY1
  jl  @@NoPutPixel
  cmp dx, ClipY2
  jg  @@NoPutPixel
  cmp cx, ClipX1
  jl  @@NoPutPixel
  cmp cx, ClipX2
  jg  @@NoPutPixel
  mov di, dx
  shl dx, 6
  shl di, 8
  mov al, [bp+04]
  add di, dx
  add di, cx
  mov es:[di], al
@@NoPutPixel:
  mov bp, bx
  ret 8
CSPset endp

CSPoint proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+08]
  mov cx, [bp+04]
  mov dx, [bp+06]
  mov es, ax
  mov di, cx
  shl cx, 8
  shl di, 6
  add di, cx
  add di, dx
  xor ah, ah
  mov al, es:[di]
  mov bp, bx
  ret 6
CSPoint endp

CSPsetB proc
  push bp
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndPsetB
  mov bx, BMapSeg
  mov ax, [bp+12]
  mov dx, [bp+08]
  mov cx, [bp+10]
  mov es, ax
  mov gs, bx
  cmp dx, ClipY1
  jl  @@EndPsetB
  cmp dx, ClipY2
  jg  @@EndPsetB
  cmp cx, ClipX1
  jl  @@EndPsetB
  cmp cx, ClipX2
  jg  @@EndPsetB
  mov di, dx
  shl dx, 6
  shl di, 8
  mov bh, [bp+06]
  add di, dx
  add di, cx
  mov bl, es:[di]
  mov al, gs:[bx]
  mov es:[di], al
@@EndPsetB:
  pop bp
  ret 8
CSPsetB endp

CSBox proc
  push bp
  mov bp, sp
  mov dx, [bp+16]
  mov es, dx
  mov ax, [bp+14]
  mov dx, [bp+10]
  cmp ax, dx
  jle @@NoSwap1
  xchg ax, dx
  mov [bp+14], ax
  mov [bp+10], dx
@@NoSwap1:
  mov ax, [bp+12]
  mov dx, [bp+08]
  cmp ax, dx
  jle @@NoSwap2
  xchg ax, dx
  mov [bp+12], ax
  mov [bp+08], dx
@@NoSwap2:
  mov cx, [bp+10]
  mov dx, [bp+12]
  sub cx, [bp+14]
  mov bx, [bp+08]
  mov si, dx
  shl dx, 8
  mov di, bx
  shl bx, 8
  shl si, 6
  mov ax, [bp+06]
  shl di, 6
  mov ah, al
  add si, dx
  add di, bx
  add si, [bp+14]
  mov bx, ax
  add di, [bp+14]
  shl eax, 16
  mov ax, bx
  mov bx, si
@@FixAddressLoopB:
  test di, 3
  JZ  @@NoOddPixelsB
  mov es:[di], al
  mov es:[si], al
  inc di
  inc si
  dec cx
  jg  @@FixAddressLoopB
@@NoOddPixelsB:
  or  cx, cx
  jle @@EndDrawHLines
  mov dx, cx
  shr cx, 2
  rep stosd
  mov cx, dx
  and cx, 3
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
  mov di, si
  mov cx, dx
  shr cx, 2
  rep stosd
  mov cx, dx
  and cx, 3
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
@@EndDrawHLines:
  mov si, di
  mov di, bx
  mov cx, [bp+08]
  sub cx, [bp+12]
  inc cx
@@VLineLoopB:
  mov es:[si], al
  mov es:[di], al
  add si, 320
  add di, 320
  dec cx
  jnz @@VLineLoopB
@@EndDrawBox:
  pop bp
  ret 12
CSBox endp

CSBoxF proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+14]
  mov es, ax
  mov ax, [bp+12]
  mov dx, [bp+08]
  cmp ax, dx
  jle @@NoSwap3
  xchg ax, dx
  mov [bp+12], ax
  mov [bp+08], dx
@@NoSwap3:
  mov ax, [bp+10]
  mov dx, [bp+06]
  cmp ax, dx
  jle @@NoSwap4
  xchg ax, dx
  mov [bp+10], ax
  mov [bp+06], dx
@@NoSwap4:
  mov cx, [bp+08]
  sub cx, [bp+12]
  inc cx
  mov si, cx
  mov dx, [bp+06]
  sub dx, [bp+10]
  inc dx
  mov ax, [bp+10]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+12]
  mov al, [bp+04]
  mov ah, al
@@NextFillLine:
  test di, 1
  jz  @@NoOddPixelsBF
  mov es:[di], al
  inc di
  dec cx
  jle @@FinishLine
@@NoOddPixelsBF:
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
@@FinishLine:
  mov cx, si
  sub di, si
  add di, 320
  dec dx
  jnz @@NextFillLine
  mov bp, bx
  ret 12
CSBoxF endp

CSBoxFB proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndBoxFB
  mov ax, BMapSeg
  mov gs, ax
  mov ax, [bp+16]
  mov dx, [bp+12]
  cmp ax, dx
  jle @@NoSwap5
  xchg ax, dx
  mov [bp+16], ax
  mov [bp+12], dx
@@NoSwap5:
  mov ax, [bp+14]
  mov dx, [bp+10]
  cmp ax, dx
  jle @@NoSwap6
  xchg ax, dx
  mov [bp+14], ax
  mov [bp+10], dx
@@NoSwap6:
  mov ax, [bp+16]
  mov dx, [bp+14]
  cmp ax, ClipX2
  jg  @@EndBoxFB
  cmp ax, ClipX1
  jge @@X1Ok
  mov ax, ClipX1
@@X1Ok:
  cmp dx, ClipY2
  jg  @@EndBoxFB
  cmp dx, ClipY1
  jge @@Y1Ok
  mov dx, ClipY1
@@Y1Ok:
  mov [bp+16], ax
  mov [bp+14], dx
  mov ax, [bp+12]
  mov dx, [bp+10]
  cmp ax, ClipX1
  jl  @@EndBoxFB
  cmp ax, ClipX2
  jle @@X2Ok
  mov ax, ClipX2
@@X2Ok:
  cmp dx, ClipY1
  jl  @@EndBoxFB
  cmp dx, ClipY2
  jle @@Y2Ok
  mov dx, ClipY2
@@Y2Ok:
  mov cx, ax
  sub cx, [bp+16]
  mov di, dx
  sub di, [bp+14]
  inc cx
  inc di
  mov dx, [bp+18]
  mov ds, dx
  mov ax, [bp+14]
  mov si, ax
  shl ax, 8
  shl si, 6
  add si, ax
  add si, [bp+16]
  mov dx, cx
  mov bh, [bp+08]
@@FillBlend:
  mov bl, [si]
  mov al, gs:[bx]
  mov [si], al
  inc si
  dec cx
  jnz @@FillBlend
  add si, 320
  sub si, dx
  mov cx, dx
  dec di
  jnz @@FillBlend
@@EndBoxFB:
  pop ds
  pop bp
  ret 12
CSBoxFB endp

CSLine proc
  push bp
  mov bp, sp
  xor ax, ax
  mov bx, [bp+16]
  mov Xerr, AX
  mov Yerr, AX
  mov es, bx
  mov ax, [bp+10]
  mov dx, [bp+08]
  sub ax, [bp+14]
  sub dx, [bp+12]
  mov bx, 1
  xor cx, cx
  or  ax, ax
  jz  @@ZeroXInc
  jg  @@PosXInc
  neg ax
  not cx
  mov XInc, cx
  mov DeltaX, ax
  neg ax
  not cx
  jmp @@OkXInc
@@PosXInc:
  mov XInc,  bx
  mov DeltaX, ax
  jmp @@OkXInc
@@ZeroXInc:
  mov XInc, cx
  mov DeltaX, ax
@@OkXInc:
  or  dx, dx
  je  @@ZeroYInc
  jg  @@PosYInc
  neg dx
  not cx
  mov YInc, cx
  mov DeltaY, dx
  neg dx
  not cx
  jmp @@OkYInc
@@PosYInc:
  mov YInc, bx
  mov DeltaY, dx
  jmp @@OkYInc
@@ZeroYInc:
  MOV YInc, cx
  MOV DeltaY, dx
@@OkYInc:
  mov ax, DeltaX
  mov dx, DeltaY
  cmp ax, dx
  jng @@DistanceY
  mov Distance, ax
  jmp @@DistanceOk
@@DistanceY:
  mov Distance, dx
@@DistanceOk:
  mov cx, -1
  mov dx, [bp+14]
  mov bx, [bp+12]
@@DrawLoopLine:
  cmp dx, ClipX1
  jl  @@SkipPixelLine
  cmp bx, ClipY1
  jl  @@SkipPixelLine
  cmp dx, ClipX2
  jg  @@SkipPixelLine
  cmp bx, ClipY2
  jg  @@SkipPixelLine
  mov ax, bx
  mov si, bx
  shl ax, 8
  shl si, 6
  add si, ax
  add si, dx
  mov al, [bp+06]
  mov es:[si], al
@@SkipPixelLine:
  mov ax, Xerr
  mov di, Yerr
  add ax, DeltaX
  add di, DeltaY
  mov Xerr, ax
  mov Yerr, di
  cmp ax, Distance
  jng @@NoRollOverX
  sub ax, Distance
  add dx, XInc
  mov Xerr, ax
@@NoRollOverX:
  cmp di, Distance
  jng @@UpdateCounterLine
  sub di, Distance
  add bx, YInc
  mov Yerr, di
@@UpdateCounterLine:
  inc cx
  cmp cx, Distance
  jle @@DrawLoopLine
  pop bp
  ret 12
CSLine endp

CSCircle proc
  push bp
  mov bp, sp
  mov ax, [bp+14]
  mov dx, [bp+12]
  mov bx, [bp+10]
  mov cx, [bp+08]
  mov si, [bp+06]
  push ax
  push dx
  push bx
  push cx
  push cx
  push si
  call CSEllipse
  pop bp
  ret 10
CSCircle endp

CSCircleF proc
  push bp
  mov bp, sp
  mov ax, [bp+14]
  mov dx, [bp+12]
  mov bx, [bp+10]
  mov cx, [bp+08]
  mov si, [bp+06]
  push ax
  push dx
  push bx
  push cx
  push cx
  push si
  call CSEllipseF
  pop bp
  ret 10
CSCircleF endp

CSEllipse proc
  push bp
  sub sp, 12
  mov bp, sp
  mov ax, [bp+28]
  mov es, ax
  mov dx, [bp+22]
  cmp dx, 0
  jne @@NotVLine
  mov dx, [bp+24]
  sub dx, [bp+20]
  mov cx, [bp+24]
  add cx, [bp+20]
  cmp dx, ClipY1
  jge @@NoClipY1
  mov dx, ClipY1
@@NoClipY1:
  cmp dx, ClipY2
  jg  @@EndEllipse
  cmp cx, ClipY1
  jl  @@EndEllipse
  cmp cx, ClipY2
  jle @@NoClipY2
  mov cx, ClipY2
@@NoClipY2:
  mov ax, [bp+26]
  cmp ax, ClipX1
  jl  @@EndEllipse
  cmp ax, ClipX2
  jg  @@EndEllipse
  sub cx, dx
  inc cx
  mov di, dx
  shl dx, 8
  shl di, 6
  add di, dx
  add di, ax
  mov ax, [bp+18]
@@VLineLoop:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@VLineLoop
  jmp @@EndEllipse
@@NotVLine:
  mov dx, [bp+20]
  cmp dx, 0
  jne @@NotHLine
  mov dx, [bp+26]
  sub dx, [bp+22]
  mov cx, [bp+26]
  add cx, [bp+22]
  cmp dx, ClipX1
  jge @@NoClipX1
  mov dx, ClipX1
@@NoClipX1:
  cmp dx, ClipX2
  jg  @@EndEllipse
  cmp cx, ClipX1
  jl  @@EndEllipse
  cmp cx, ClipX2
  jle @@NoClipX2
  mov cx, ClipX2
@@NoClipX2:
  mov ax, [bp+24]
  cmp ax, ClipY1
  jl  @@EndEllipse
  cmp ax, ClipY2
  jg  @@EndEllipse
  sub cx, dx
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, dx
  mov ax, [bp+18]
  mov ah, al
  shr cx, 1
  rep stosw
  adc cx, 1
  rep stosb
  jmp @@EndEllipse
@@NotHLine:
  mov ax, [bp+20]
  cmp ax, [bp+22]
  jg  @@OtherAxis
  xor dx, dx
  mov [bp+10], dx
  mov [bp+06], dx
  mov ax, [bp+22]
  mov bx, ax
  mul bx
  mov [bp+04], ax
  push ax
  shr ax, 1
  neg ax
  mov [bp], ax
  mov bx, [bp+20]
  mov [bp+08], bx
  pop ax
  xor dx, dx
  div bx
  mov [bp+02], ax
  mov ax, [bp+18]
@@AxisLoopX:
  mov dx, [bp]
  cmp dx, 0
  jg  @@OnlyFourPixelsX
@@FourPixelsLoopX:
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+10]
  add bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+10]
  sub bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  sub bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+10]
  inc dx
  mov [bp+10], dx
  mov bx, [bp+06]
  add bx, [bp+20]
  mov [bp+06], bx
  mov dx, [bp]
  add dx, bx
  mov [bp], dx
  cmp dx, 0
  jle @@FourPixelsLoopX
  jmp @@UpdateCountersX
@@OnlyFourPixelsX:
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+10]
  add bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+10]
  sub bx, [bp+08]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  sub bx, [bp+08]
  PUTPIXEL
@@UpdateCountersX:
  mov dx, [bp+04]
  sub dx, [bp+02]
  mov [bp+04], dx
  mov bx, [bp]
  sub bx, dx
  mov [bp], bx
  mov dx, [bp+08]
  dec dx
  mov [bp+08], dx
  cmp dx, 0
  jne @@AxisLoopX
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  PUTPIXEL
  jmp @@EndEllipse
@@OtherAxis:
  xor dx, dx
  mov [bp+10], dx
  mov [bp+06], dx
  mov ax, [bp+20]
  mov bx, ax
  mul bx
  mov [bp+04], ax
  push ax
  shr ax, 1
  neg ax
  mov [bp], ax
  mov bx, [bp+22]
  mov [bp+08], bx
  pop ax
  xor dx, dx
  div bx
  mov [bp+02], ax
  mov ax, [bp+18]
@@AxisLoopY:
  mov dx, [bp]
  cmp dx, 0
  jg  @@OnlyFourPixelsY
@@FourPixelsLoopY:
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+08]
  add bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  add bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+08]
  sub bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  sub bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+10]
  inc dx
  mov [bp+10], dx
  mov bx, [bp+06]
  add bx, [bp+22]
  mov [bp+06], bx
  mov dx, [bp]
  add dx, bx
  mov [bp], dx
  cmp dx, 0
  jle @@FourPixelsLoopY
  jmp @@UpdateCountersY
@@OnlyFourPixelsY:
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+08]
  add bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  add bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  add dx, [bp+08]
  sub bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  sub bx, [bp+10]
  PUTPIXEL
@@UpdateCountersY:
  mov dx, [bp+04]
  sub dx, [bp+02]
  mov [bp+04], dx
  mov bx, [bp]
  sub bx, dx
  mov [bp], bx
  mov dx, [bp+08]
  dec dx
  mov [bp+08], dx
  cmp dx, 0
  jne @@AxisLoopY
  mov dx, [bp+26]
  mov bx, [bp+24]
  add bx, [bp+10]
  PUTPIXEL
  mov dx, [bp+26]
  mov bx, [bp+24]
  sub bx, [bp+10]
  PUTPIXEL
@@EndEllipse:
  add sp, 12
  pop bp
  ret 12
CSEllipse endp

CSEllipseF proc
  push bp
  sub sp, 12
  mov bp, sp
  mov ax, [bp+28]
  mov es, ax
  mov dx, [bp+22]
  cmp dx, 0
  jne @@NotVLineF
  mov dx, [bp+24]
  sub dx, [bp+20]
  mov cx, [bp+24]
  add cx, [bp+20]
  cmp dx, ClipY1
  jge @@NoClipY1F
  mov dx, ClipY1
@@NoClipY1F:
  cmp dx, ClipY2
  jg  @@EndEllipseF
  cmp cx, ClipY1
  jl  @@EndEllipseF
  cmp cx, ClipY2
  jle @@NoClipY2F
  mov cx, ClipY2
@@NoClipY2F:
  mov ax, [bp+26]
  cmp ax, ClipX1
  jl  @@EndEllipseF
  cmp ax, ClipX2
  jg  @@EndEllipseF
  sub cx, dx
  inc cx
  mov di, dx
  shl dx, 8
  shl di, 6
  add di, dx
  add di, ax
  mov ax, [bp+18]
@@VLineLoopF:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@VLineLoopF
  jmp @@EndEllipseF
@@NotVLineF:
  mov dx, [bp+20]
  cmp dx, 0
  jne @@NotHLineF
  mov dx, [bp+26]
  sub dx, [bp+22]
  mov cx, [bp+26]
  add cx, [bp+22]
  cmp dx, ClipX1
  jge @@NoClipX1F
  mov dx, ClipX1
@@NoClipX1F:
  cmp dx, ClipX2
  jg  @@EndEllipseF
  cmp cx, ClipX1
  jl  @@EndEllipseF
  cmp cx, ClipX2
  jle @@NoClipX2F
  mov cx, ClipX2
@@NoClipX2F:
  mov ax, [bp+24]
  cmp ax, ClipY1
  jl  @@EndEllipseF
  cmp ax, ClipY2
  jg  @@EndEllipseF
  sub cx, dx
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, dx
  mov ax, [bp+18]
  mov ah, al
  shr cx, 1
  rep stosw
  adc cx, 1
  rep stosb
  jmp @@EndEllipseF
@@NotHLineF:
  mov ax, [bp+20]
  cmp ax, [bp+22]
  jg  @@OtherAxisF
  xor dx, dx
  mov [bp+10], dx
  mov [bp+06], dx
  mov ax, [bp+22]
  mov bx, ax
  mul bx
  mov [bp+04], ax
  push ax
  shr ax, 1
  neg ax
  mov [bp], ax
  mov bx, [bp+20]
  mov [bp+08], bx
  pop ax
  xor dx, dx
  div bx
  mov [bp+02], ax
  mov ax, [bp+18]
  mov ah, al
@@AxisLoopXF:
  mov dx, [bp]
  cmp dx, 0
  jg  @@OnlyFourPixelsXF
@@FourPixelsLoopXF:
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add cx, [bp+10]
  add bx, [bp+08]
  HLINE
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add cx, [bp+10]
  sub bx, [bp+08]
  HLINE
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add cx, [bp+10]
  HLINE
  mov dx, [bp+10]
  inc dx
  mov [bp+10], dx
  mov bx, [bp+06]
  add bx, [bp+20]
  mov [bp+06], bx
  mov dx, [bp]
  add dx, bx
  mov [bp], dx
  cmp dx, 0
  jle @@FourPixelsLoopXF
  jmp @@UpdateCountersXF
@@OnlyFourPixelsXF:
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add cx, [bp+10]
  add bx, [bp+08]
  HLINE
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+10]
  add cx, [bp+10]
  sub bx, [bp+08]
  HLINE
@@UpdateCountersXF:
  mov dx, [bp+04]
  sub dx, [bp+02]
  mov [bp+04], dx
  mov bx, [bp]
  sub bx, dx
  mov [bp], bx
  mov dx, [bp+08]
  dec dx
  mov [bp+08], dx
  cmp dx, 0
  jne @@AxisLoopXF
  jmp @@EndEllipseF
@@OtherAxisF:
  xor dx, dx
  mov [bp+10], dx
  mov [bp+06], dx
  mov ax, [bp+20]
  mov bx, ax
  mul bx
  mov [bp+04], ax
  push ax
  shr ax, 1
  neg ax
  mov [bp], ax
  mov bx, [bp+22]
  mov [bp+08], bx
  pop ax
  xor dx, dx
  div bx
  mov [bp+02], ax
  mov ax, [bp+18]
  mov ah, al
@@AxisLoopYF:
  mov dx, [bp]
  cmp dx, 0
  jg  @@UpdateCountersYF
@@FourPixelsLoopYF:
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  add cx, [bp+08]
  add bx, [bp+10]
  HLINE
  mov dx, [bp+26]
  mov cx, [bp+26]
  mov bx, [bp+24]
  sub dx, [bp+08]
  add cx, [bp+08]
  sub bx, [bp+10]
  HLINE
  mov dx, [bp+10]
  inc dx
  mov [bp+10], dx
  mov bx, [bp+06]
  add bx, [bp+22]
  mov [bp+06], bx
  mov dx, [bp]
  add dx, bx
  mov [bp], dx
  cmp dx, 0
  jle @@FourPixelsLoopYF
@@UpdateCountersYF:
  mov dx, [bp+04]
  sub dx, [bp+02]
  mov [bp+04], dx
  mov bx, [bp]
  sub bx, dx
  mov [bp], bx
  mov dx, [bp+08]
  dec dx
  mov [bp+08], dx
  cmp dx, 0
  jne @@AxisLoopYF
@@EndEllipseF:
  add sp, 12
  pop bp
  ret 12
CSEllipseF endp

CSScroll proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+12]
  mov ds, ax
  mov es, ax
  mov al, [bp+08]
  cmp al, 3
  je  @@ScrollRight
  cmp al, 2
  je  @@ScrollLeft
  cmp al, 1
  je  @@ScrollDown
  mov ax, [bp+10]
  mov si, ax
  shl ax, 8
  shl si, 6
  add si, ax
  xor di, di
  mov cx, 16000
  rep movsd
  pop ds
  pop bp
  ret 6
@@ScrollDown:
  mov ax, [bp+10]
  mov bx, ax
  shl ax, 8
  shl bx, 6
  add ax, bx
  mov cx, 63996
  mov di, cx
  mov si, di
  sub si, ax
  sub cx, ax
  shr cx, 2
  std
  rep movsd
  cld
  pop ds
  pop bp
  ret 6
@@ScrollLeft:
  xor di, di
  mov si, [bp+10]
  mov cx, 64000
  sub cx, [bp+10]
  shr cx, 2
  rep movsd
  pop ds
  pop bp
  ret 6
@@ScrollRight:
  mov cx, 63996
  mov di, cx
  sub cx, [bp+10]
  mov si, cx
  shr cx, 2
  std
  rep movsd
  cld
  pop ds
  pop bp
  ret 6
CSScroll endp

CSScrollArea proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov ds, ax
  mov es, ax
  mov al, [bp+08]
  cmp al, 3
  je  @@AScrollRight
  cmp al, 2
  je  @@AScrollLeft
  cmp al, 1
  je  @@AScrollDown
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov si, di
  add si, 320
  mov dx, [bp+12]
  sub dx, [bp+16]
  inc dx
  mov cx, dx
  mov bx, [bp+14]
  inc bx
@@AScrollLoopU:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  sub si, dx
  mov di, si
  add si, 320
  mov cx, dx
  inc bx
  cmp bx, [bp+10]
  jl  @@AScrollLoopU
  pop ds
  pop bp
  ret 12
@@AScrollDown:
  mov ax, [bp+10]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov si, di
  sub si, 320
  mov dx, [bp+12]
  sub dx, [bp+16]
  inc dx
  mov cx, dx
  mov bx, [bp+14]
  inc bx
@@AScrollLoopD:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  sub si, dx
  mov di, si
  sub si, 320
  mov cx, dx
  inc bx
  cmp bx, [bp+10]
  jl  @@AScrollLoopD
  pop ds
  pop bp
  ret 12
@@AScrollLeft:
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov si, di
  inc si
  mov dx, [bp+12]
  sub dx, [bp+16]
  mov cx, dx
  mov bx, [bp+14]
@@AScrollLoopL:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  sub si, dx
  add si, 320
  mov di, si
  dec di
  mov cx, dx
  inc bx
  cmp bx, [bp+10]
  jle @@AScrollLoopL
  pop ds
  pop bp
  ret 12
@@AScrollRight:
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+12]
  mov si, di
  dec si
  mov dx, [bp+12]
  sub dx, [bp+16]
  mov cx, dx
  mov bx, [bp+14]
  std
@@AScrollLoopR:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  add di, 320
  add di, dx
  mov si, di
  dec si
  mov cx, dx
  inc bx
  cmp bx, [bp+10]
  jle @@AScrollLoopR
  cld
  pop ds
  pop bp
  ret 12
CSScrollArea endp

CSClear proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov es, ax
  xor di, di
  mov al, [bp+04]
  mov ah, al
  mov dx, ax
  shl eax, 16
  mov ax, dx
  mov cx, 16000
  rep stosd
  mov bp, bx
  ret 4
CSClear endp

CSPcopy proc
  mov bx, bp
  mov dx, ds
  mov bp, sp
  mov ax, [bp+06]
  mov ds, ax
  mov ax, [bp+04]
  mov es, ax
  xor si, si
  xor di, di
  mov cx, 16000
  rep movsd
  mov ds, dx
  mov bp, bx
  ret 4
CSPcopy endp

CSPcopyT proc
  mov bx, bp
  mov dx, ds
  mov bp, sp
  mov ax, [bp+06]
  mov ds, ax
  mov ax, [bp+04]
  mov es, ax
  xor si, si
  xor di, di
  xor cx, cx
@@PcopyTLoop:
  mov al, [si]
  or  al, al
  jz  @@SkipPcopyTPixel
  mov es:[di], al
@@SkipPcopyTPixel:
  inc si
  inc di
  inc cx
  cmp cx, 64000
  jnz @@PcopyTLoop
  mov ds, dx
  mov bp, bx
  ret 4
CSPcopyT endp

CSPcopyB proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndPcopyB
  mov ax, BMapSeg
  mov gs, ax
  mov ax, [bp+06]
  mov ds, ax
  mov ax, [bp+04]
  mov es, ax
  xor si, si
  xor di, di
  xor cx, cx
@@PcopyBLoop:
  mov al, [si]
  or  al, al
  jz  @@SkipPcopyBPixel
  mov bl, es:[di]
  mov bh, al
  mov al, gs:[bx]
  mov es:[di], al
@@SkipPcopyBPixel:
  inc si
  inc di
  inc cx
  cmp cx, 64000
  jnz @@PcopyBLoop
@@EndPcopyB:
  pop ds
  pop bp
  ret 4
CSPcopyB endp

CSPcopyC proc
  push bp
  mov dx, ds
  mov bp, sp
  mov ax, [bp+10]
  mov ds, ax
  mov ax, [bp+08]
  mov es, ax
  mov bx, [bp+06]
  xor si, si
  xor di, di
  xor cx, cx
@@PcopyCLoop:
  mov al, [si]
  or  al, al
  jz  @@SkipPcopyCPixel
  mov ax, bx
  mov es:[di], al
@@SkipPcopyCPixel:
  inc si
  inc di
  inc cx
  cmp cx, 64000
  jnz @@PcopyCLoop
  mov ds, dx
  pop bp
  ret 6
CSPcopyC endp

CSWin proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+18]
  mov es, ax
  mov cx, [bp+12]
  sub cx, [bp+16]
  inc cx
  mov WindowWidth, cx
  mov si, cx
  mov dx, [bp+10]
  sub dx, [bp+14]
  inc dx
  mov WindowHeight, dx
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov WindowPos1, di
  mov al, [bp+08]
  mov ah, al
@@NextWindowLine:
  test di, 1
  jz  @@NoOddPixelWL
  mov es:[di], al
  inc di
  dec cx
  jle @@SkipWindowLine
@@NoOddPixelWL:
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
@@SkipWindowLine:
  mov cx, si
  sub di, si
  add di, 320
  dec dx
  jnz @@NextWindowLine
  mov cx, WindowWidth
  mov di, WindowPos1
  mov al, [bp+04]
  mov ah, al
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
  mov cx, WindowHeight
  mov di, WindowPos1
  mov al, [bp+06]
@@NextWindowPixel:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@NextWindowPixel
  mov cx, WindowHeight
  dec cx
  mov di, WindowPos1
  inc di
  mov al, [bp+06]
@@NextWindowPixel2:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@NextWindowPixel2
  mov cx, WindowWidth
  mov ax, [BP+10]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+16]
  mov al, [bp+06]
  mov ah, al
  shr cx, 1
  rep stosw
  adc cx, cx
  rep stosb
  mov cx, WindowHeight
  mov ax, [bp+14]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+12]
  mov WindowPos2, di
  mov al, [bp+04]
@@NextWindowPixel3:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@NextWindowPixel3
  mov cx, WindowHeight
  mov di, WindowPos2
  dec di
  mov al, [bp+04]
@@NextWindowPixel4:
  mov es:[di], al
  add di, 320
  dec cx
  jnz @@NextWindowPixel4
  mov bp, bx
  ret 16
CSWin endp

CSAntiAliase proc
  push bp
  push ds
  mov bp, sp
  mov dx, [bp+08]
  mov cx, 63360
  mov ds, dx
  mov si, 320
@@AntiAliaseLoop:
  xor ax, ax
  xor bx, bx
  xor dx, dx
  mov al, [si-1]
  mov dl, [si+1]
  add bx, ax
  mov al, [si-320]
  add bx, dx
  mov dl, [si+1]
  add bx, ax
  mov al, [si]
  add bx, dx
  shr bx, 2
  add bx, ax
  shr bx, 1
  mov [si], bl
  inc si
  dec cx
  jnz @@AntiAliaseLoop
  pop ds
  pop bp
  ret 2
CSAntiAliase endp

CSTri proc
  push bp
  mov bp, sp
  mov ax, [bp+20]
  mov bx, [bp+18]
  mov cx, [bp+16]
  mov dx, [bp+14]
  mov si, [bp+12]
  mov di, [bp+06]
  push ax
  push bx
  push cx
  push dx
  push si
  push di
  call CSLine
  mov ax, [bp+20]
  mov bx, [bp+14]
  mov cx, [bp+12]
  mov dx, [bp+10]
  mov si, [bp+08]
  mov di, [bp+06]
  push ax
  push bx
  push cx
  push dx
  push si
  push di
  call CSLine
  mov ax, [bp+20]
  mov bx, [bp+10]
  mov cx, [bp+08]
  mov dx, [bp+18]
  mov si, [bp+16]
  mov di, [bp+06]
  push ax
  push bx
  push cx
  push dx
  push si
  push di
  call CSLine
  pop bp
  ret 16
CSTri endp

CSCopyBlock proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov bx, [bp+16]
  mov ds, ax
  mov es, bx
  mov cx, [bp+10]
  sub cx, [bp+14]
  mov dx, [bp+12]
  mov bx, [bp+08]
  mov ax, dx
  mov si, dx
  shl ax, 8
  shl si, 6
  add si, ax
  add si, [bp+14]
  mov di, si
  inc cx
  inc bx
  mov ax, cx
@@CopyBlockLoop:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  mov cx, ax
  add si, 320
  add di, 320
  sub si, ax
  sub di, ax
  inc dx
  cmp dx, bx
  jne @@CopyBlockLoop
  pop ds
  pop bp
  ret 12
CSCopyBlock endp

end
