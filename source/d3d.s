;----------------------------------------------------------------------------
;
;  CosmoX 3D Module
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

EndU                dw  200 dup(?)      ;  Used by Gouraud and Texture
EndV                dw  200 dup(?)      ;  Used by Gouraud and Texture
EndX                dw  200 dup(?)      ;  Last X in scanline
StartU              dw  200 dup(?)      ;  Used by Goraud and Texture
StartV              dw  200 dup(?)      ;  Used by Goraud and Texture
StartX              dw  200 dup(?)      ;  First X in scanline
FirstY              dw  ?               ;  First ScanLine
LastY               dw  ?               ;  Last ScanLine
TextureWrap         dw  63              ;  Used to wrap the texture
TextureAdd          dw  4               ;  Used to skip GET-PUT header
Counter             dw  ?               ;  Used in texture-mapping subs
TextureSize         db  6               ;  Texture size (in bits to shift)

.code

public  CSTriF, CSTriFB, CSTriG, CSTriGB, CSTriT, CSTriTB, CSTextureWidth
public  CSTriTF

CSTriF proc
  push bp
  mov bp, sp
  mov ax, [bp+20]
  mov es, ax
  mov ax, [bp+16]
  mov bx, [bp+12]
  cmp ax, bx
  jle @@Swap12
  mov [bp+16], bx
  mov [bp+12], ax
  mov bx, [bp+14]
  mov ax, [bp+18]
  mov [bp+18], bx
  mov [bp+14], ax
@@Swap12:
  mov ax, [bp+16]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@Swap13
  mov [bp+16], bx
  mov [bp+08], ax
  mov bx, [bp+10]
  mov ax, [bp+18]
  mov [bp+18], bx
  mov [bp+10], ax
@@Swap13:
  mov ax, [bp+12]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@EndSwaps1
  mov [bp+12], bx
  mov [bp+08], ax
  mov bx, [bp+10]
  mov ax, [bp+14]
  mov [bp+14], bx
  mov [bp+10], ax
@@EndSwaps1:
  mov ax, 8000h
  xor si, si
@@InitTriFX:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@InitTriFX
  mov ax, ClipY1
  mov FirstY, ax
  mov bx, [bp+16]
  cmp bx, ClipY2
  jg  @@EndDrawTriF
  cmp bx, ax
  jl  @@ClipFY
  mov FirstY, bx
@@ClipFY:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+08]
  cmp bx, ClipY1
  jl  @@EndDrawTriF
  cmp bx, ax
  jg  @@ClipLY
  mov LastY, bx
@@ClipLY:
  xor ecx, ecx
  mov bx, [bp+16]
  mov cx, [bp+12]
  sub cx, bx
  jnz @@Connect11
  cmp bx, ClipY1
  jl  @@End11
  cmp bx, ClipY2
  jg  @@End11
  shl bx, 1
  mov ax, [bp+18]
  mov StartX[bx], ax
  jmp @@End11
@@Connect11:
  mov ax, [bp+14]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+16]
@@Next11:
  cmp bx, ClipY1
  jl  @@Skip11
  cmp bx, ClipY2
  jg  @@Skip11
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@Skip11:
  add edx, eax
  inc bx
  cmp bx, [bp+12]
  jle @@Next11
@@End11:
  xor ecx, ecx
  mov bx, [bp+12]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@Connect12
  cmp bx, ClipY1
  jl  @@End12
  cmp bx, ClipY2
  jg  @@End12
  shl bx, 1
  mov ax, [bp+14]
  mov StartX[bx], ax
  jmp @@End12
@@Connect12:
  mov ax, [bp+10]
  sub ax, [bp+14]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+14]
  shl edx, 16
  mov bx, [bp+12]
@@Next12:
  cmp bx, ClipY1
  jl  @@Skip12
  cmp bx, ClipY2
  jg  @@Skip12
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@Skip12:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Next12
@@End12:
  xor ecx, ecx
  mov bx, [bp+16]
  mov cx, [bp+08]
  sub cx, bx
  JNZ @@Connect13
  cmp bx, ClipY1
  jl  @@End13
  cmp bx, ClipY2
  jg  @@End13
  shl bx, 1
  mov ax, [bp+18]
  mov EndX[bx], ax
  mov dx, StartX[bx]
  cmp dx, ax
  jl  @@End13
  mov StartX[bx], ax
  mov EndX[bx], dx
  jmp @@End13
@@Connect13:
  mov ax, [bp+10]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+16]
@@Next13:
  cmp bx, ClipY1
  jl  @@Skip13
  cmp bx, ClipY2
  jg  @@Skip13
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@Skip13
  mov StartX[si], cx
  mov EndX[si], di
@@Skip13:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Next13
@@End13:
  mov cx, FirstY
  mov ax, [bp+06]
  mov ah, al
  mov bx, ax
  shl eax, 16
  mov ax, bx
  mov di, cx
  mov bx, di
  shl bx, 8
  shl di, 6
  add di, bx
@@DrawTriF:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@SkipTriFLine
@@DrawTriFLine:
  push cx
  push di
  mov cx, EndX[si]
  cmp bx, ClipX1
  jge @@SkipClipX1
  mov bx, ClipX1
@@SkipClipX1:
  cmp bx, ClipX2
  jg  @@SkipTriFLinePop
  cmp cx, ClipX1
  jl  @@SkipTriFLinePop
  cmp cx, ClipX2
  jle @@SkipClipX2
  mov cx, ClipX2
@@SkipClipX2:
  sub cx, bx
  add di, bx
  inc cx
@@FixAddressLoopF:
  test di, 3
  jz  @@NoOddPixelsF
  mov es:[di], al
  inc di
  dec cx
  jg  @@FixAddressLoopF
  jmp @@SkipTriFLinePop
@@NoOddPixelsF:
  mov bx, cx
  shr cx, 2
  rep stosd
  mov cx, bx
  and cx, 3
  rep stosb
@@SkipTriFLinePop:
  pop di
  pop cx
@@SkipTriFLine:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@DrawTriF
@@EndDrawTriF:
  pop bp
  ret 16
CSTriF endp

CSTriFB proc
  push bp
  mov bp, sp
  mov dl, BMapActive
  or  dl,  dl
  je  @@EndTriFB
  mov ax, [bp+20]
  mov es, ax
  mov ax, [bp+16]
  mov bx, [bp+12]
  cmp ax, bx
  jle @@BSwap12
  mov [bp+16], bx
  mov [bp+12], ax
  mov bx, [bp+14]
  mov ax, [bp+18]
  mov [bp+18], bx
  mov [bp+14], ax
@@BSwap12:
  mov ax, [bp+16]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@BSwap13
  mov [bp+16], bx
  mov [bp+08], ax
  mov bx, [bp+10]
  mov ax, [bp+18]
  mov [bp+18], bx
  mov [bp+10], ax
@@BSwap13:
  mov ax, [bp+12]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@BEndSwaps1
  mov [bp+12], bx
  mov [bp+08], ax
  mov bx, [bp+10]
  mov ax, [bp+14]
  mov [bp+14], bx
  mov [bp+10], ax
@@BEndSwaps1:
  mov ax, 8000H
  xor si, si
@@BInitTriFX:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@BInitTriFX
  mov ax, ClipY1
  mov FirstY, ax
  mov bx, [bp+16]
  cmp bx, ClipY2
  jg  @@EndTriFB
  cmp bx, ax
  jl  @@BClipFY
  mov FirstY, bx
@@BClipFY:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+08]
  cmp bx, ClipY1
  jl  @@EndTriFB
  cmp bx, ax
  jg  @@BClipLY
  mov LastY, bx
@@BClipLY:
  xor ecx, ecx
  mov bx, [bp+16]
  mov cx, [bp+12]
  sub cx, bx
  jnz @@BConnect11
  cmp bx, ClipY1
  jl  @@BEnd11
  cmp bx, ClipY2
  jg  @@BEnd11
  shl bx, 1
  mov ax, [bp+18]
  mov StartX[bx], ax
  jmp @@BEnd11
@@BConnect11:
  mov ax, [bp+14]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+16]
@@BNext11:
  cmp bx, ClipY1
  jl  @@BSkip11
  cmp bx, ClipY2
  jg  @@BSkip11
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@BSkip11:
  add edx, eax
  inc bx
  cmp bx, [bp+12]
  jle @@BNext11
@@BEnd11:
  xor ecx, ecx
  mov bx, [bp+12]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@BConnect12
  cmp bx, ClipY1
  jl  @@BEnd12
  cmp bx, ClipY2
  JG  @@BEnd12
  shl bx, 1
  mov ax, [bp+14]
  mov StartX[bx], ax
  jmp @@BEnd12
@@BConnect12:
  mov ax, [bp+10]
  sub ax, [bp+14]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+14]
  shl edx, 16
  mov bx, [bp+12]
@@BNext12:
  cmp bx, ClipY1
  jl  @@BSkip12
  cmp bx, ClipY2
  jg  @@BSkip12
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@BSkip12:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BNext12
@@BEnd12:
  xor ecx, ecx
  mov bx, [bp+16]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@BConnect13
  cmp bx, ClipY1
  jl  @@BEnd13
  cmp bx, ClipY2
  jg  @@BEnd13
  shl bx, 1
  mov ax, [bp+18]
  mov EndX[bx], ax
  mov dx, StartX[bx]
  cmp dx, ax
  jl  @@BEnd13
  mov StartX[bx], ax
  mov EndX[bx], ax
  jmp @@BEnd13
@@BConnect13:
  mov ax, [bp+10]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+16]
@@BNext13:
  cmp bx, ClipY1
  jl  @@BSkip13
  cmp bx, ClipY2
  jg  @@BSkip13
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@BSkip13
  mov StartX[si], cx
  mov EndX[si], di
@@BSkip13:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BNext13
@@BEnd13:
  mov ax, BMapSeg
  mov fs, ax
  mov cx, FirstY
  mov ax, [bp+6]
  mov dh, al
  mov di, cx
  mov bx, di
  shl bx, 8
  shl di, 6
  add di, bx
@@BDrawTriF:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@BSkipTriFLine
@@BDrawTriFLine:
  cmp bx, ClipX1
  jl  @@BSkipTriFPixel
  cmp bx, ClipX2
  jg  @@BSkipTriFPixel
  mov dl, es:[di+bx]
  mov bp, bx
  mov bx, dx
  mov al, fs:[bx]
  mov bx, bp
  mov es:[di+bx], al
@@BSkipTriFPixel:
  inc bx
  cmp bx, EndX[si]
  jle @@BDrawTriFLine
@@BSkipTriFLine:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@BDrawTriF
@@EndTriFB:
  pop bp
  ret 16
CSTriFB endp

CSTriG proc
  push bp
  mov bp, sp
  mov ax, [bp+24]
  mov es, ax
  mov ax, [bp+20]
  mov bx, [bp+14]
  cmp ax, bx
  jle @@NoSwap12G
  mov [bp+14], ax
  mov [bp+20], bx
  mov ax, [bp+22]
  mov bx, [bp+16]
  mov [bp+16], ax
  mov [bp+22], bx
  mov ax, [bp+18]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+18], bx
@@NoSwap12G:
  mov ax, [bp+20]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@NoSwap13G
  mov [bp+08], ax
  mov [bp+20], bx
  mov ax, [bp+22]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+22], bx
  mov ax, [bp+18]
  mov bx, [bp+06]
  mov [bp+06], ax
  mov [bp+18], bx
@@NoSwap13G:
  mov ax, [bp+14]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@EndSwapsG
  mov [bp+08], ax
  mov [bp+14], bx
  mov ax, [bp+16]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+16], bx
  mov ax, [bp+12]
  mov bx, [bp+6]
  mov [bp+06], ax
  mov [bp+12], bx
@@EndSwapsG:
  mov ax, 8000H
  xor si, si
@@InitTriGX:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@InitTriGX
  mov ax, ClipY1
  mov FirstY, ax
  MOV bx, [bp+20]
  cmp bx, ClipY2
  jg  @@EndDrawTriG
  CMP bx, ax
  jl  @@ClipFYG
  mov FirstY, bx
@@ClipFYG:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [BP+08]
  cmp bx, ClipY1
  jl  @@EndDrawTriG
  cmp bx, ax
  jg  @@ClipLYG
  mov LastY, bx
@@ClipLYG:
  xor ecx, ecx
  mov bx, [bp+20]
  mov cx, [bp+14]
  sub cx, bx
  jnz @@Connect11G
  cmp bx, ClipY1
  jl  @@End11G
  cmp bx, ClipY2
  jg  @@End11G
  shl bx, 1
  mov ax, [bp+22]
  mov StartX[bx], ax
  mov ax, [BP+18]
  mov StartU[bx], ax
  jmp @@End11G
@@Connect11G:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+20]
@@Col1Step1G:
  cmp bx, 0
  jl  @@Col1Next1G
  cmp bx, 199
  jg  @@Col1Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartU[si], cx
@@Col1Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+14]
  jle @@Col1Step1G
  pop ecx
  mov ax, [bp+16]
  sub ax, [bp+22]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+22]
  shl edx, 16
  mov bx, [bp+20]
@@Col1Step2G:
  cmp bx, ClipY1
  jl  @@Col1Next2G
  cmp bx, ClipY2
  jg  @@Col1Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@Col1Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+14]
  jle @@Col1Step2G
@@End11G:
  xor ecx, ecx
  mov bx, [bp+14]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@Connect12G
  cmp bx, ClipY1
  jl  @@End12G
  cmp bx, ClipY2
  jg  @@End12G
  shl bx, 1
  mov ax, [bp+16]
  mov StartX[bx], ax
  mov ax, [bp+12]
  mov StartU[bx], ax
  jmp @@End12G
@@Connect12G:
  push ecx
  mov ax, [bp+06]
  sub ax, [bp+12]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+12]
  shl edx, 16
  mov bx, [bp+14]
@@Col2Step1G:
  cmp bx, 0
  jl  @@Col2Next1G
  cmp bx, 199
  jg  @@Col2Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartU[si], cx
@@Col2Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Col2Step1G
  pop ecx
  mov ax, [bp+10]
  sub ax, [bp+16]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+16]
  shl edx, 16
  mov bx, [bp+14]
@@Col2Step2G:
  cmp bx, ClipY1
  jl  @@Col2Next2G
  cmp bx, ClipY2
  jg  @@Col2Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@Col2Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Col2Step2G
@@End12G:
  xor ecx, ecx
  mov bx, [bp+20]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@Connect13G
  cmp bx, ClipY1
  jl  @@End13G
  cmp bx, ClipY2
  jg  @@End13G
  shl bx, 1
  mov ax, [bp+18]
  mov EndU[bx], ax
  mov ax, [BP+22]
  mov EndX[bx], ax
  mov di, StartX[bx]
  cmp di, AX
  jl  @@End13G
  mov EndX[bx], di
  mov StartX[bx], ax
  mov di, StartU[bx]
  mov ax, EndU[bx]
  mov StartU[bx], ax
  mov EndU[bx], di
  jmp @@End13G
@@Connect13G:
  push ecx
  mov ax, [bp+06]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+20]
@@Col3Step1G:
  cmp bx, 0
  jl  @@Col3Next1G
  cmp bx, 199
  jg  @@Col3Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndU[si], cx
@@Col3Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Col3Step1G
  pop ecx
  mov ax, [bp+10]
  sub ax, [bp+22]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+22]
  shl edx, 16
  mov bx, [bp+20]
@@Col3Step2G:
  cmp bx, ClipY1
  JL  @@Col3Next2G
  cmp bx, ClipY2
  JG  @@Col3Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@Col3Next2G
  mov StartX[si], cx
  mov EndX[si], di
  mov cx, StartU[si]
  mov di, EndU[si]
  mov StartU[si], di
  mov EndU[si], cx
@@Col3Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@Col3Step2G
@@End13G:
  mov cx, FirstY
  mov di, cx
  mov bx, di
  shl bx, 8
  shl di, 6
  add di, bx
@@DrawGTri:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@SkipTriGLine
  push di
  push cx
  xor ecx, ecx
  mov cx, EndX[si]
  sub cx, StartX[si]
  inc cx
  mov ax, EndU[si]
  sub ax, StartU[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, StartU[si]
  shl edx, 16
@@DrawTriGLine:
  mov bx, StartX[si]
  mov bp, EndX[si]
  cmp bp, ClipX1
  JL  @@SkipTriGLinePop
  CMP bp, ClipX2
  JLE @@NoClipX2G
  MOV bp, ClipX2
@@NoClipX2G:
  cmp bx, ClipX2
  jg  @@SkipTriGLinePop
  cmp bx, ClipX1
  jge @@NoClipX1G
@@ClipX1LoopG:
  inc bx
  add edx, eax
  cmp bx, ClipX1
  jl  @@ClipX1LoopG
@@NoClipX1G:
  add di, bx
  sub bp, bx
  jz  @@SkipTriGLinePop
  mov bx, bp
@@FixAddressLoopG:
  test di, 3
  jz  @@NoOddPixelsG
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov es:[di], cl
  inc di
  dec bp
  jg  @@FixAddressLoopG
@@NoOddPixelsG:
  mov bx, bp
  shr bp, 2
  jz  @@DrawLeftPixelsG
  push bx
@@Draw4PixelsLoopG:
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov bl, cl
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov bh, cl
  shl ebx, 16
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov bl, cl
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov bh, cl
  rol ebx, 16
  mov es:[di], ebx
  add di, 4
  dec bp
  jnz @@Draw4PixelsLoopG
  pop bx
@@DrawLeftPixelsG:
  mov bp, bx
  and bp, 3
  jz  @@SkipTriGLinePop
@@LeftPixelsLoopG:
  mov ecx, edx
  shr ecx, 16
  add edx, eax
  mov es:[di], cl
  inc di
  dec bp
  jnz @@LeftPixelsLoopG
@@SkipTriGLinePop:
  pop cx
  pop di
@@SkipTriGLine:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@DrawGTri
@@EndDrawTriG:
  pop bp
  ret 20
CSTriG endp

CSTriGB proc
  push bp
  mov bp, sp
  push ax
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndTriGB
  mov ax, [bp+24]
  mov es, ax
  mov ax, [bp+20]
  mov bx, [bp+14]
  cmp ax, bx
  jle @@BNoSwap12G
  mov [bp+14], ax
  mov [bp+20], bx
  mov ax, [bp+22]
  mov bx, [bp+16]
  mov [bp+16], ax
  mov [bp+22], bx
  mov ax, [bp+18]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+18], bx
@@BNoSwap12G:
  mov ax, [bp+20]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@BNoSwap13G
  mov [bp+08], ax
  mov [bp+20], bx
  mov ax, [bp+22]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+22], bx
  mov ax, [bp+18]
  mov bx, [bp+06]
  mov [bp+06], ax
  mov [bp+18], bx
@@BNoSwap13G:
  mov ax, [bp+14]
  mov bx, [bp+08]
  cmp ax, bx
  jle @@BEndSwapsG
  mov [bp+08], ax
  mov [bp+14], bx
  mov ax, [bp+16]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+16], bx
  mov ax, [bp+12]
  mov bx, [bp+06]
  mov [bp+06], ax
  mov [bp+12], bx
@@BEndSwapsG:
  mov ax, 8000h
  xor si, si
@@BInitTriGX:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@BInitTriGX
  mov ax, ClipY1
  mov FirstY, ax
  mov bx, [bp+20]
  cmp bx, ClipY2
  jg  @@EndTriGB
  cmp bx, ax
  jl  @@BClipFYG
  mov FirstY, bx
@@BClipFYG:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+08]
  cmp bx, ClipY1
  jl  @@EndTriGB
  cmp bx, ax
  jg  @@BClipLYG
  mov LastY, bx
@@BClipLYG:
  xor ecx, ecx
  mov bx, [bp+20]
  mov cx, [bp+14]
  sub cx, bx
  jnz @@BConnect11G
  cmp bx, ClipY1
  jl  @@BEnd11G
  cmp bx, ClipY2
  jg  @@BEnd11G
  shl bx, 1
  mov ax, [bp+22]
  mov StartX[bx], ax
  mov ax, [bp+18]
  mov StartU[bx], ax
  jmp @@BEnd11G
@@BConnect11G:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+20]
@@BCol1Step1G:
  cmp bx, 0
  jl  @@BCol1Next1G
  cmp bx, 199
  jg  @@BCol1Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartU[si], cx
@@BCol1Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+14]
  jle @@BCol1Step1G
  pop ecx
  mov ax, [bp+16]
  sub ax, [bp+22]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+22]
  shl edx, 16
  mov bx, [bp+20]
@@BCol1Step2G:
  cmp bx, ClipY1
  jl  @@BCol1Next2G
  cmp bx, ClipY2
  jg  @@BCol1Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@BCol1Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+14]
  jle @@BCol1Step2G
@@BEnd11G:
  xor ecx, ecx
  mov bx, [bp+14]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@BConnect12G
  cmp bx, ClipY1
  jl  @@BEnd12G
  cmp bx, ClipY2
  jg  @@BEnd12G
  shl bx, 1
  mov ax, [bp+16]
  mov StartX[bx], ax
  mov ax, [bp+12]
  mov StartU[bx], ax
  jmp @@BEnd12G
@@BConnect12G:
  push ecx
  mov ax, [bp+06]
  sub ax, [bp+12]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+12]
  shl edx, 16
  mov bx, [bp+14]
@@BCol2Step1G:
  cmp bx, 0
  jl  @@BCol2Next1G
  cmp bx, 199
  jg  @@BCol2Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartU[si], cx
@@BCol2Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BCol2Step1G
  pop ecx
  mov ax, [bp+10]
  sub ax, [bp+16]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+16]
  shl edx, 16
  mov bx, [bp+14]
@@BCol2Step2G:
  cmp bx, ClipY1
  jl  @@BCol2Next2G
  cmp bx, ClipY2
  jg  @@BCol2Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@BCol2Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BCol2Step2G
@@BEnd12G:
  xor ecx, ecx
  mov bx, [bp+20]
  mov cx, [bp+08]
  sub cx, bx
  jnz @@BConnect13G
  cmp bx, ClipY1
  jl  @@BEnd13G
  cmp bx, ClipY2
  jg  @@BEnd13G
  shl bx, 1
  mov ax, [bp+18]
  mov EndU[bx], ax
  mov ax, [bp+22]
  mov EndX[bx], ax
  mov di, StartX[bx]
  cmp di, ax
  jl  @@BEnd13G
  mov EndX[bx], di
  mov StartX[bx], ax
  mov di, StartU[bx]
  mov ax, EndU[bx]
  mov StartU[bx], ax
  mov EndU[bx], di
  jmp @@BEnd13G
@@BConnect13G:
  push ecx
  mov ax, [bp+06]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+18]
  shl edx, 16
  mov bx, [bp+20]
@@BCol3Step1G:
  cmp bx, 0
  jl  @@BCol3Next1G
  cmp bx, 199
  jg  @@BCol3Next1G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndU[si], cx
@@BCol3Next1G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BCol3Step1G
  pop ecx
  mov ax, [bp+10]
  sub ax, [bp+22]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+22]
  shl edx, 16
  mov bx, [bp+20]
@@BCol3Step2G:
  cmp bx, ClipY1
  jl  @@BCol3Next2G
  cmp bx, ClipY2
  jg  @@BCol3Next2G
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@BCol3Next2G
  mov StartX[si], cx
  mov EndX[si], di
  mov cx, StartU[si]
  mov di, EndU[si]
  mov StartU[si], di
  mov EndU[si], cx
@@BCol3Next2G:
  add edx, eax
  inc bx
  cmp bx, [bp+08]
  jle @@BCol3Step2G
@@BEnd13G:
  mov ax, BMapSeg
  mov gs, ax
  mov cx, FirstY
  mov di, cx
  mov bx, di
  shl bx, 8
  shl di, 6
  add di, bx
@@BDrawGTri:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@BSkipTriGLine
  mov fs, cx
  xor ecx, ecx
  mov cx, EndX[si]
  sub cx, StartX[si]
  inc cx
  mov ax, EndU[si]
  sub ax, StartU[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, StartU[si]
  shl edx, 16
@@BDrawTriGLine:
  cmp bx, ClipX1
  jl  @@BSkipTriGPixel
  cmp bx, ClipX2
  jg  @@BSkipTriGPixel
  mov ecx, edx
  shr ecx, 16
  mov ch, es:[di+bx]
  mov [bp-02], bx
  mov bh, cl
  mov bl, ch
  mov cl, gs:[bx]
  mov bx, [bp-02]
  mov es:[di+bx], cl
@@BSkipTriGPixel:
  add edx, eax
  inc bx
  cmp bx, EndX[si]
  jle @@BDrawTriGLine
  mov cx, fs
@@BSkipTriGLine:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@BDrawGTri
@@EndTriGB:
  pop ax
  pop bp
  ret 20
CSTriGB endp

CSTriT proc
  push bp
  mov bp, sp
  mov ax, [bp+34]
  mov es, ax
  mov ax, [bp+30]
  mov bx, [bp+26]
  cmp ax, bx
  jle @@SwapT1
  mov [bp+26], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+28]
  mov [bp+28], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+16]
  mov [bp+16], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+14]
  mov [bp+14], ax
  mov [bp+18], bx
@@SwapT1:
  mov ax, [bp+30]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@SwapT2
  mov [bp+22], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+18], bx
@@SwapT2:
  mov ax, [bp+26]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@EndSwapsT
  mov [bp+22], ax
  mov [bp+26], bx
  mov ax, [bp+28]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+28], bx
  mov ax, [bp+16]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+16], bx
  mov ax, [bp+14]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+14], bx
@@EndSwapsT:
  xor si, si
  mov ax, 8000h
@@InitTriTX:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@InitTriTX
  mov ax, ClipY1
  mov FirstY, AX
  mov bx, [bp+30]
  cmp bx, ClipY2
  jg  @@EndDrawTriT
  cmp bx, ax
  jl  @@ClipFYT
  mov FirstY, bx
@@ClipFYT:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+22]
  cmp bx, ClipY1
  jl  @@EndDrawTriT
  cmp bx, ax
  jg  @@ClipLYT
  mov LastY, bx
@@ClipLYT:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+26]
  sub cx, bx
  jnz @@ConnectT1
  cmp bx, ClipY1
  jl  @@EndT1
  cmp bx, ClipY2
  jg  @@EndT1
  shl bx, 1
  mov ax, [bp+32]
  mov StartX[bx], ax
  mov ax, [bp+20]
  mov StartU[bx], ax
  mov ax, [bp+18]
  mov StartV[bx], ax
  jmp @@EndT1
@@ConnectT1:
  push ecx
  mov ax, [bp+16]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+14]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT11:
  cmp si, 0
  jl  @@NextT11
  cmp si, 199
  jg  @@NextT11
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT11:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+26]
  jle @@StepT11
  pop ecx
  mov ax, [bp+28]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT12:
  cmp bx, ClipY1
  JL  @@NextT12
  cmp bx, ClipY2
  JG  @@NextT12
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT12:
  add edx, eax
  inc bx
  cmp bx, [bp+26]
  jle @@StepT12
@@EndT1:
  xor ecx, ecx
  mov bx, [bp+26]
  mov cx, [bp+22]
  sub cx, bx
  jnz @@ConnectT2
  cmp bx, ClipY1
  jl  @@EndT2
  cmp BX, ClipY2
  jg  @@EndT2
  shl bx, 1
  mov ax, [bp+28]
  mov StartX[bx], ax
  mov ax, [bp+16]
  mov StartU[bx], ax
  mov ax, [bp+14]
  mov StartV[bx], ax
  jmp @@EndT2
@@ConnectT2:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+16]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+14]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+16]
  shl edx, 16
  mov cx, [bp+14]
  shl ecx, 16
  mov si, [bp+26]
@@StepT21:
  cmp si, 0
  jl  @@NextT21
  cmp si, 199
  jg  @@NextT21
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT21:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT21
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+28]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+28]
  shl edx, 16
  mov bx, [bp+26]
@@StepT22:
  cmp bx, ClipY1
  jl  @@NextT22
  cmp bx, ClipY2
  jg  @@NextT22
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT22:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT22
@@EndT2:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+22]
  sub cx, bx
  jnz @@ConnectT3
  cmp bx, ClipY1
  jl  @@EndT3
  cmp bx, ClipY2
  jg  @@EndT3
  shl bx, 1
  mov ax, [bp+20]
  mov EndU[bx], ax
  mov ax, [bp+18]
  mov EndV[bx], ax
  mov ax, [bp+32]
  mov EndX[bx], ax
  mov dx, StartX[bx]
  cmp dx, ax
  jl  @@EndT3
  mov StartX[bx], ax
  mov EndX[bx], dx
  mov ax, StartU[bx]
  mov dx, EndU[bx]
  mov StartU[bx], dx
  mov EndU[bx], ax
  mov ax, StartV[bx]
  mov dx, EndV[bx]
  mov StartV[bx], dx
  mov EndV[bx], ax
  jmp @@EndT3
@@ConnectT3:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT31:
  cmp si, 0
  jl  @@NextT31
  cmp si, 199
  jg  @@NextT31
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov EndU[si], di
  mov edi, ecx
  shr edi, 16
  mov EndV[si], di
  shr si, 1
@@NextT31:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT31
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT32:
  cmp bx, ClipY1
  jl  @@NextT32
  cmp bx, ClipY2
  jg  @@NextT32
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@NextT32
  mov StartX[si], cx
  mov EndX[si], di
  mov cx, StartU[si]
  mov di, EndU[si]
  mov StartU[si], di
  mov EndU[si], cx
  mov cx, StartV[si]
  mov di, EndV[si]
  mov StartV[si], di
  mov EndV[si], cx
@@NextT32:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT32
@@EndT3:
  mov ax, [bp+08]
  mov gs, ax
  mov cx, FirstY
  mov di, cx
  mov si, cx
  shl di, 8
  shl si, 6
  add di, si
@@DrawTriT:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@SkipTriLineT
  push cx
  push di
  xor ecx, ecx
  mov cx, EndX[si]
  sub cx, bx
  inc cx
  mov ax, EndU[si]
  sub ax, StartU[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  mov ax, EndV[si]
  sub ax, StartV[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  push ax
  mov bp, sp
  mov dx, StartU[si]
  mov ax, StartV[si]
  shl edx, 16
  shl eax, 16
@@DrawTriLineT:
  mov bx, StartX[si]
  mov cx, EndX[si]
  cmp cx, ClipX1
  JL  @@SkipTriLineTPop
  cmp cx, ClipX2
  jle @@NoClipX2T
  mov cx, ClipX2
@@NoClipX2T:
  cmp bx, ClipX2
  jg  @@SkipTriLineTPop
  cmp bx, ClipX1
  jge @@NoClipX1T
@@ClipX1LoopT:
  inc bx
  add edx, [bp+06]
  add eax, [bp+02]
  cmp bx, ClipX1
  jl  @@ClipX1LoopT
@@NoClipX1T:
  add di, bx
  sub cx, bx
  jz  @@SkipTriLineTPop
  mov bx, cx
  mov [bp], bx
@@FixAddressLoopT:
  test di, 3
  jz  @@NoOddPixelsT
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov cl, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  mov es:[di], cl
  inc di
  dec bx
  jg  @@FixAddressLoopT
@@NoOddPixelsT:
  mov [bp], bx
  shr bx, 2
  jz  @@DrawLeftPixelsT
  mov Counter, bx
@@Draw4PixelsLoopT:
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov bl, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov bh, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  shl ebx, 16
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov bl, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov bh, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  rol ebx, 16
  mov es:[di], ebx
  add di, 4
  dec Counter
  jnz @@Draw4PixelsLoopT
@@DrawLeftPixelsT:
  mov bx, [bp]
  and bx, 3
  jz  @@SkipTriLineTPop
@@LeftPixelsLoopT:
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+20]
  mov cl, gs:[si]
  add edx, [bp+06]
  add eax, [bp+02]
  mov es:[di], cl
  inc di
  dec bx
  jnz @@LeftPixelsLoopT
@@SkipTriLineTPop:
  pop ax
  pop eax
  pop eax
  pop di
  pop cx
@@SkipTriLineT:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@DrawTriT
@@EndDrawTriT:
  pop bp
  ret 30
CSTriT endp

CSTriTB proc
  push bp
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndTriTB
  mov ax, [bp+34]
  mov es, ax
  mov ax, [bp+30]
  mov bx, [bp+26]
  cmp ax, bx
  jle @@SwapT1B
  mov [bp+26], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+28]
  mov [bp+28], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+16]
  mov [bp+16], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+14]
  mov [bp+14], ax
  mov [bp+18], bx
@@SwapT1B:
  mov ax, [bp+30]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@SwapT2B
  mov [bp+22], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+18], bx
@@SwapT2B:
  mov ax, [bp+26]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@EndSwapsTB
  mov [bp+22], ax
  mov [bp+26], bx
  mov ax, [bp+28]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+28], bx
  mov ax, [bp+16]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+16], bx
  mov ax, [bp+14]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+14], bx
@@EndSwapsTB:
  xor si, si
  mov ax, 8000H
@@InitTriTXB:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@InitTriTXB
  mov ax, ClipY1
  mov FirstY, ax
  mov bx, [bp+30]
  cmp bx, ClipY2
  jg  @@EndTriTB
  CMP bx, ax
  jl  @@ClipFYTB
  mov FirstY, bx
@@ClipFYTB:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+22]
  cmp bx, ClipY1
  jl  @@EndTriTB
  cmp bx, ax
  jg  @@ClipLYTB
  mov LastY, bx
@@ClipLYTB:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+26]
  sub cx, bx
  jnz @@ConnectT1B
  cmp bx, ClipY1
  jl  @@EndT1B
  cmp bx, ClipY2
  jg  @@EndT1B
  shl bx, 1
  mov ax, [bp+32]
  mov StartX[bx], ax
  mov ax, [bp+20]
  mov StartU[bx], ax
  mov ax, [bp+18]
  mov StartV[bx], ax
  jmp @@EndT1B
@@ConnectT1B:
  push ecx
  mov ax, [bp+16]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+14]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT11B:
  cmp si, 0
  jl  @@NextT11B
  cmp si, 199
  jg  @@NextT11B
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT11B:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+26]
  jle @@StepT11B
  pop ecx
  mov ax, [bp+28]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT12B:
  cmp bx, ClipY1
  jl  @@NextT12B
  cmp bx, ClipY2
  jg  @@NextT12B
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT12B:
  add edx, eax
  inc bx
  cmp bx, [bp+26]
  jle @@StepT12B
@@EndT1B:
  xor ecx, ecx
  mov bx, [bp+26]
  mov cx, [bp+22]
  sub cx, bx
  jnz @@ConnectT2B
  cmp bx, ClipY1
  jl  @@EndT2B
  cmp bx, ClipY2
  jg  @@EndT2B
  shl bx, 1
  mov ax, [bp+28]
  mov StartX[bx], ax
  mov ax, [bp+16]
  mov StartU[bx], ax
  mov ax, [bp+14]
  mov StartV[bx], ax
  jmp @@EndT2B
@@ConnectT2B:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+16]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+14]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+16]
  shl edx, 16
  mov cx, [bp+14]
  shl ecx, 16
  mov si, [bp+26]
@@StepT21B:
  cmp si, 0
  jl  @@NextT21B
  cmp si, 199
  jg  @@NextT21B
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT21B:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT21B
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+28]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+28]
  shl edx, 16
  mov bx, [bp+26]
@@StepT22B:
  cmp bx, ClipY1
  jl  @@NextT22B
  cmp bx, ClipY2
  jg  @@NextT22B
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT22B:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT22B
@@EndT2B:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+22]
  sub cx, bx
  JNZ @@ConnectT3B
  cmp bx, ClipY1
  jl  @@EndT3B
  cmp bx, ClipY2
  jg  @@EndT3B
  shl bx, 1
  mov ax, [bp+20]
  mov EndU[bx], ax
  mov ax, [bp+18]
  mov EndV[bx], ax
  mov ax, [bp+32]
  mov EndX[bx], ax
  mov dx, StartX[bx]
  cmp dx, ax
  jl  @@EndT3B
  mov StartX[bx], ax
  mov EndX[bx], dx
  mov ax, StartU[bx]
  mov dx, EndU[bx]
  mov StartU[bx], dx
  mov EndU[bx], ax
  mov ax, StartV[bx]
  mov dx, EndV[bx]
  mov StartV[bx], dx
  mov EndV[bx], ax
  jmp @@EndT3B
@@ConnectT3B:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT31B:
  cmp si, 0
  jl  @@NextT31B
  cmp si, 199
  jg  @@NextT31B
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov EndU[si], di
  mov edi, ecx
  shr edi, 16
  mov EndV[si], di
  shr si, 1
@@NextT31B:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT31B
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT32B:
  cmp bx, ClipY1
  jl  @@NextT32B
  cmp bx, ClipY2
  jg  @@NextT32B
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@NextT32B
  mov StartX[si], cx
  mov EndX[si], di
  mov cx, StartU[si]
  mov di, EndU[si]
  mov StartU[si], di
  mov EndU[si], cx
  mov cx, StartV[si]
  mov di, EndV[si]
  mov StartV[si], di
  mov EndV[si], cx
@@NextT32B:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT32B
@@EndT3B:
  mov ax, [bp+08]
  mov gs, ax
  mov ax, BMapSeg
  mov fs, ax
  mov cx, FirstY
  mov di, cx
  mov si, cx
  shl di, 8
  shl si, 6
  add di, si
@@DrawTriTB:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@SkipTriLineTB
  push cx
  xor ecx, ecx
  mov cx, EndX[si]
  sub cx, bx
  inc cx
  mov ax, EndU[si]
  sub ax, StartU[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  mov ax, EndV[si]
  sub ax, StartV[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  push ax
  mov bp, sp
  mov ax, EndX[si]
  mov [bp], ax
  mov dx, StartU[si]
  mov ax, StartV[si]
  shl edx, 16
  shl eax, 16
@@DrawTriLineTB:
  cmp bx, ClipX1
  jl  @@SkipTriPixelTB
  cmp bx, ClipX2
  jg  @@SkipTriPixelTB
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+18]
  mov cl, es:[di+bx]
  mov ch, gs:[si]
  or  ch, ch
  jz  @@SkipTriPixelTB
  push bx
  mov bx, cx
  mov cl, fs:[bx]
  pop bx
  mov es:[di+bx], cl
@@SkipTriPixelTB:
  add edx, [bp+06]
  add eax, [bp+02]
  inc bx
  cmp bx, [bp]
  jle @@DrawTriLineTB
  pop ax
  pop eax
  pop eax
  pop cx
@@SkipTriLineTB:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@DrawTriTB
@@EndTriTB:
  pop bp
  ret 30
CSTriTB endp

CSTriTF proc
  push bp
  mov bp, sp
  mov ax, [bp+34]
  mov es, ax
  mov ax, [bp+30]
  mov bx, [bp+26]
  cmp ax, bx
  jle @@SwapT1F
  mov [bp+26], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+28]
  mov [bp+28], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+16]
  mov [bp+16], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+14]
  mov [bp+14], ax
  mov [bp+18], bx
@@SwapT1F:
  mov ax, [bp+30]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@SwapT2F
  mov [bp+22], ax
  mov [bp+30], bx
  mov ax, [bp+32]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+32], bx
  mov ax, [bp+20]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+20], bx
  mov ax, [bp+18]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+18], bx
@@SwapT2F:
  mov ax, [bp+26]
  mov bx, [bp+22]
  cmp ax, bx
  jle @@EndSwapsTF
  mov [bp+22], ax
  mov [bp+26], bx
  mov ax, [bp+28]
  mov bx, [bp+24]
  mov [bp+24], ax
  mov [bp+28], bx
  mov ax, [bp+16]
  mov bx, [bp+12]
  mov [bp+12], ax
  mov [bp+16], bx
  mov ax, [bp+14]
  mov bx, [bp+10]
  mov [bp+10], ax
  mov [bp+14], bx
@@EndSwapsTF:
  xor si, si
  mov ax, 8000h
@@InitTriTXF:
  mov StartX[si], ax
  add si, 2
  cmp si, 400
  jl  @@InitTriTXF
  mov ax, ClipY1
  mov FirstY, ax
  mov bx, [bp+30]
  cmp bx, ClipY2
  jg  @@EndDrawTriTF
  cmp bx, ax
  jl  @@ClipFYTF
  mov FirstY, bx
@@ClipFYTF:
  mov ax, ClipY2
  mov LastY, ax
  mov bx, [bp+22]
  cmp bx, ClipY1
  jl  @@EndDrawTriTF
  cmp bx, ax
  jg  @@ClipLYTF
  mov LastY, bx
@@ClipLYTF:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+26]
  sub cx, bx
  jnz @@ConnectT1F
  cmp bx, ClipY1
  jl  @@EndT1F
  cmp bx, ClipY2
  jg  @@EndT1F
  shl bx, 1
  mov ax, [bp+32]
  mov StartX[bx], ax
  mov ax, [bp+20]
  mov StartU[bx], ax
  mov ax, [bp+18]
  mov StartV[bx], ax
  jmp @@EndT1F
@@ConnectT1F:
  push ecx
  mov ax, [bp+16]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+14]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT11F:
  cmp si, 0
  jl  @@NextT11F
  cmp si, 199
  jg  @@NextT11F
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT11F:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+26]
  jle @@StepT11F
  pop ecx
  mov ax, [bp+28]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT12F:
  cmp bx, ClipY1
  jl  @@NextT12F
  cmp bx, ClipY2
  jg  @@NextT12F
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT12F:
  add edx, eax
  inc bx
  cmp bx, [bp+26]
  jle @@StepT12F
@@EndT1F:
  xor ecx, ecx
  mov bx, [bp+26]
  mov cx, [bp+22]
  sub cx, bx
  jnz @@ConnectT2F
  cmp bx, ClipY1
  jl  @@EndT2F
  cmp bx, ClipY2
  jg  @@EndT2F
  shl bx, 1
  mov ax, [bp+28]
  mov StartX[bx], ax
  mov ax, [bp+16]
  mov StartU[bx], ax
  mov ax, [bp+14]
  mov StartV[bx], ax
  jmp @@EndT2F
@@ConnectT2F:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+16]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+14]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+16]
  shl edx, 16
  mov cx, [bp+14]
  shl ecx, 16
  mov si, [bp+26]
@@StepT21F:
  cmp si, 0
  jl  @@NextT21F
  cmp si, 199
  jg  @@NextT21F
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov StartU[si], di
  mov edi, ecx
  shr edi, 16
  mov StartV[si], di
  shr si, 1
@@NextT21F:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT21F
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+28]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+28]
  shl edx, 16
  mov bx, [bp+26]
@@StepT22F:
  cmp bx, ClipY1
  jl  @@NextT22F
  cmp bx, ClipY2
  jg  @@NextT22F
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov StartX[si], cx
@@NextT22F:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT22F
@@EndT2F:
  xor ecx, ecx
  mov bx, [bp+30]
  mov cx, [bp+22]
  sub cx, bx
  jnz @@ConnectT3F
  cmp bx, ClipY1
  jl  @@EndT3F
  cmp bx, ClipY2
  jg  @@EndT3F
  shl bx, 1
  mov ax, [bp+20]
  mov EndU[bx], ax
  mov ax, [bp+18]
  mov EndV[bx], ax
  mov ax, [bp+32]
  mov EndX[bx], ax
  mov dx, StartX[bx]
  cmp dx, ax
  jl  @@EndT3F
  mov StartX[bx], ax
  mov EndX[bx], dx
  mov ax, StartU[bx]
  mov dx, EndU[bx]
  mov StartU[bx], dx
  mov EndU[bx], ax
  mov ax, StartV[bx]
  mov dx, EndV[bx]
  mov StartV[bx], dx
  mov EndV[bx], ax
  jmp @@EndT3F
@@ConnectT3F:
  push ecx
  mov ax, [bp+12]
  sub ax, [bp+20]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov ebx, eax
  mov ax, [bp+10]
  sub ax, [bp+18]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+20]
  shl edx, 16
  mov cx, [bp+18]
  shl ecx, 16
  mov si, [bp+30]
@@StepT31F:
  cmp si, 0
  jl  @@NextT31F
  cmp si, 199
  jg  @@NextT31F
  shl si, 1
  mov edi, edx
  shr edi, 16
  mov EndU[si], di
  mov edi, ecx
  shr edi, 16
  mov EndV[si], di
  shr si, 1
@@NextT31F:
  add edx, ebx
  add ecx, eax
  inc si
  cmp si, [bp+22]
  jle @@StepT31F
  pop ecx
  mov ax, [bp+24]
  sub ax, [bp+32]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  mov dx, [bp+32]
  shl edx, 16
  mov bx, [bp+30]
@@StepT32F:
  cmp bx, ClipY1
  jl  @@NextT32F
  cmp bx, ClipY2
  jg  @@NextT32F
  mov si, bx
  shl si, 1
  mov ecx, edx
  shr ecx, 16
  mov EndX[si], cx
  mov di, StartX[si]
  cmp di, cx
  jl  @@NextT32F
  mov StartX[si], cx
  mov EndX[si], di
  mov cx, StartU[si]
  mov di, EndU[si]
  mov StartU[si], di
  mov EndU[si], cx
  mov cx, StartV[si]
  mov di, EndV[si]
  mov StartV[si], di
  mov EndV[si], cx
@@NextT32F:
  add edx, eax
  inc bx
  cmp bx, [bp+22]
  jle @@StepT32F
@@EndT3F:
  mov ax, [bp+08]
  mov gs, ax
  mov cx, FirstY
  mov di, cx
  mov si, cx
  shl di, 8
  shl si, 6
  add di, si
@@DrawTriTF:
  mov si, cx
  shl si, 1
  mov bx, StartX[si]
  cmp bx, 8000h
  je  @@SkipTriLineTF
  push cx
  xor ecx, ecx
  mov cx, EndX[si]
  sub cx, bx
  inc cx
  mov ax, EndU[si]
  sub ax, StartU[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  mov ax, EndV[si]
  sub ax, StartV[si]
  shl eax, 16
  mov edx, eax
  sar edx, 31
  idiv ecx
  push eax
  push ax
  mov bp, sp
  mov ax, EndX[si]
  mov [bp], ax
  mov dx, StartU[si]
  mov ax, StartV[si]
  shl edx, 16
  shl eax, 16
@@DrawTriLineTF:
  cmp bx, ClipX1
  jl  @@SkipTriPixelTF
  cmp bx, ClipX2
  jg  @@SkipTriPixelTF
  mov esi, eax
  shr esi, 16
  and si, TextureWrap
  mov cl, TextureSize
  shl si, cl
  mov ecx, edx
  shr ecx, 16
  add si, cx
  add si, TextureAdd
  add si, [bp+18]
  push bx
  push ax
  xor cx, cx
  xor ax, ax
  mov bx, si
  mov si, TextureWrap
  inc si
  mov cl, gs:[bx-1]
  add ax, cx
  mov cl, gs:[bx]
  add ax, cx
  mov cl, gs:[bx+1]
  add ax, cx
  mov cl, gs:[bx-si]
  add ax, cx
  shr ax, 2
  mov cl, gs:[bx+si]
  add ax, cx
  shr ax, 1
  mov cl, al
  pop ax
  pop bx
  or  cl, cl
  jz  @@SkipTriPixelTF
  mov es:[di+bx], cl
@@SkipTriPixelTF:
  add edx, [bp+06]
  add eax, [bp+02]
  inc bx
  cmp bx, [bp]
  jle @@DrawTriLineTF
  pop ax
  pop eax
  pop eax
  pop cx
@@SkipTriLineTF:
  add di, 320
  inc cx
  cmp cx, LastY
  jle @@DrawTriTF
@@EndDrawTriTF:
  pop bp
  ret 30
CSTriTF endp

CSTextureWidth proc
  push bp
  mov bp, sp
  mov bx, [bp+06]
  cmp bx, 100h
  jb  @@No256
  mov TextureSize, 8h
  mov TextureWrap, 0ffh
  mov TextureAdd, 0h
  pop bp
  ret 2
@@No256:
  mov ax, 128
  mov cx, 8
@@FindWidth:
  test bl, al
  jnz @@WidthFound
  shr ax, 1
  dec cx
  jnz @@FindWidth
@@WidthFound:
  dec ax
  mov TextureWrap, ax
  dec cl
  mov TextureSize, cl
  mov TextureAdd, 4h
  pop bp
  ret 2
CSTextureWidth endp

end
