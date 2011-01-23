;----------------------------------------------------------------------------
;
;  CosmoX IMAGE Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

PCXHeaderType struc
  Man         db  ?
  Ver         db  ?
  Encoding    db  ?
  PCXBPP      db  ?
  XMin        dw  ?
  YMin        dw  ?
  PCXXSize    dw  ?
  PCXYSize    dw  ?
  Hdpi        dw  ?
  Vdpi        dw  ?
  Colormap    db  48 dup(?)
  Unused      db  64 dup(?)
PCXHeaderType ends

BMPHeaderType struc
  BMPID           dw  ?
  FileSize        dd  ?
  Reserved1       dw  ?
  Reserved2       dw  ?
  OffBits         dd  ?
  HSize           dd  ?
  BMPXSize        dd  ?
  BMPYSize        dd  ?
  Planes          dw  ?
  BMPBPP          dw  ?
  Compression     dd  ?
  SizeImage       dd  ?
  XPelsPerMeter   dd  ?
  YPelsPerMeter   dd  ?
  ClrUsed         dd  ?
  ClrImportant    dd  ?
BMPHeaderType ends

.data

align 2

BMPHeader           BMPHeaderType <>
PCXHeader           PCXHeaderType <>
Buffer              db  ?

.code

public xCSLoadPCX, xCSLoadBMP, xCSSaveBMP

xCSLoadPCX proc
  push bp
  push ds
  mov bp, sp
  mov es, [bp+20]
  mov ax, [bp+16]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+18]
  mov ds, [bp+10]
  mov dx, [bp+08]
  xor ax, ax
  mov ah, 3dh
  int 21h
  jc  @@ErrorOpenPCX
  mov bx, ax
  mov ax, seg PCXHeader
  mov ds, ax
  mov dx, offset PCXHeader
  mov cx, size PCXHeader
  mov ah, 3fh
  int 21h
  jc  @@ErrorReadingPCX
  cmp PCXHeader.Ver, 5
  jne @@ErrorBadPCX
  cmp PCXHeader.Encoding, 1
  jne @@ErrorBadPCX
  cmp PCXHeader.PCXBPP, 8
  jne @@ErrorBadPCX
  mov ax, PCXHeader.XMin
  dec ax
  sub PCXHeader.PCXXSize, ax
  mov ax, PCXHeader.YMin
  dec ax
  sub PCXHeader.PCXYSize, ax
  xor dx, dx
  xor ax, ax
  mov si, PCXHeader.PCXYSize
  test PCXHeader.PCXXSize, 1
  jz  @@PCXLoadLoop
  inc PCXHeader.PCXXSize
@@PCXLoadLoop:
  call ReadBuffer
  jc  @@ErrorReadingPCX
  mov al, Buffer
  mov cl, al
  and al, 0c0h
  cmp al, 0c0h
  mov al, cl
  jz  @@DecodePCXRle
  mov es:[di], al
  inc di
  inc dx
  cmp dx, PCXHeader.PCXXSize
  jl  @@PCXNextData
  add di, 320
  sub di, dx
  xor dx, dx
  dec si
  jmp @@PCXNextData
@@DecodePCXRle:
  and al, 3fh
  mov cl, al
  call ReadBuffer
  jc  @@ErrorReadingPCX
  mov al, Buffer
@@DecodePCXRleLoop:
  mov es:[di], al
  inc di
  inc dx
  cmp dx, PCXHeader.PCXXSize
  jl  @@DecodePCX
  add di, 320
  sub di, dx
  xor dx, dx
  dec si
@@DecodePCX:
  dec cl
  jnz @@DecodePCXRleLoop
@@PCXNextData:
  or  si, si
  jnz @@PCXLoadLoop
  call ReadBuffer
  jc  @@ErrorReadingPCX
  mov es, [bp+14]
  mov di, [bp+12]
  mov cx, 768
@@LoadPCXPal:
  call ReadBuffer
  jc  @@ErrorReadingPCX
  mov al, Buffer
  shr al, 2
  stosb
  dec cx
  jnz @@LoadPCXPal
  mov ah, 3eh
  int 21h
  xor ax, ax
  jmp @@EndLoadPCX
@@ErrorOpenPCX:
  mov ax, 1
  jmp @@EndLoadPCX
@@ErrorReadingPCX:
  mov ah, 3eh
  int 21h
  mov ax, 2
  jmp @@EndLoadPCX
@@ErrorBadPCX:
  mov ah, 3eh
  int 21h
  mov ax, 3
@@EndLoadPCX:
  pop ds
  pop bp
  ret 14
xCSLoadPCX endp

xCSLoadBMP proc
  push bp
  push ds
  mov bp, sp
  mov es, [bp+20]
  mov ax, [bp+16]
  mov di, ax
  shl ax, 8
  shl di, 6
  add di, ax
  add di, [bp+18]
  mov ds, [bp+10]
  mov dx, [bp+08]
  xor ax, ax
  mov ah, 3dh
  int 21h
  jc  @@ErrorOpenBMP
  mov bx, ax
  mov ax, seg BMPHeader
  mov ds, ax
  mov dx, offset BMPHeader
  mov cx, size BMPHeader
  mov ah, 3fh
  int 21h
  jc  @@ErrorReadingBMP
  cmp BMPHeader.BMPID, 19778
  jne @@ErrorBadBMP
  cmp BMPHeader.Planes, 1
  jne @@ErrorBadBMP
  cmp BMPHeader.BMPBPP, 8
  jne @@ErrorBadBMP
  cmp BMPHeader.Compression, 0
  jne @@ErrorBadBMP
  mov gs, [bp+14]
  mov si, [bp+12]
  mov cx, 256
@@LoadBMPPal:
  call ReadBuffer
  jc  @@ErrorReadingBMP
  mov al, Buffer
  shr al, 2
  mov gs:[si+2], al
  call ReadBuffer
  jc  @@ErrorReadingBMP
  mov al, Buffer
  shr al, 2
  mov gs:[si+1], al
  call ReadBuffer
  jc  @@ErrorReadingBMP
  mov al, Buffer
  shr al, 2
  mov gs:[si], al
  call ReadBuffer
  jc  @@ErrorReadingBMP
  add si, 3
  dec cx
  jnz @@LoadBMPPal
  mov eax, BMPHeader.BMPXSize
  mov ecx, eax
  and eax, 3
  jz  @@WidthOk
  sub ecx, eax
  add ecx, 4
@@WidthOk:
  mov BMPHeader.BMPXSize, ecx
  mov eax, BMPHeader.BMPYSize
  dec ax
  mov dx, ax
  shl dx, 8
  shl ax, 6
  add ax, dx
  add di, ax
  mov ecx, BMPHeader.BMPYSize
@@LoadBMPLoop:
  push cx
  push ds
  mov ecx, BMPHeader.BMPXSize
  mov ax, es
  mov ds, ax
  mov ah, 03fh
  mov dx, di
  int 21h
  pop ds
  pop cx
  jc  @@ErrorReadingBMP
  sub di, 320
  dec cx
  jnz @@LoadBMPLoop
  mov ah, 3eh
  int 21h
  xor ax, ax
  jmp @@EndLoadBMP
@@ErrorOpenBMP:
  mov ax, 1
  jmp @@EndLoadBMP
@@ErrorReadingBMP:
  mov ah, 3eh
  int 21h
  mov ax, 2
  jmp @@EndLoadBMP
@@ErrorBadBMP:
  mov ah, 3eh
  int 21h
  mov ax, 3
@@EndLoadBMP:
  pop ds
  pop bp
  ret 14
xCSLoadBMP endp

xCSSaveBMP proc
  push bp
  push ds
  mov bp, sp
  mov es, [bp+24]
  mov ds, [bp+10]
  mov dx, [bp+08]
  xor ax, ax
  mov cx, 20h
  mov ah, 3ch
  int 21h
  jc  @@ErrorCreateBMP
  mov bx, ax
  mov BMPHeader.BMPID, 19778
  xor eax, eax
  xor ecx, ecx
  mov ax, [bp+18]
  sub ax, [bp+22]
  inc ax
  mov BMPHeader.BMPXSize, eax
  mov cx, [bp+16]
  sub cx, [bp+20]
  inc cx
  mov BMPHeader.BMPYSize, ecx
  mul cx
  mov BMPHeader.SizeImage, eax
  add ax, 1078
  mov BMPHeader.FileSize, eax
  xor eax, eax
  mov BMPHeader.Reserved1, ax
  mov BMPHeader.Reserved2, ax
  mov BMPHeader.OffBits, 1078
  mov BMPHeader.HSize, 40
  mov BMPHeader.Planes, 1
  mov BMPHeader.BMPBPP, 8
  mov BMPHeader.Compression, eax
  mov BMPHeader.XPelsPerMeter, 3790
  mov BMPHeader.YPelsPerMeter, 3780
  mov BMPHeader.ClrUsed, eax
  mov BMPHeader.ClrImportant, eax
  mov ax, seg BMPHeader
  mov ds, ax
  mov dx, offset BMPHeader
  mov cx, size BMPHeader
  mov ah, 40h
  int 21h
  jc  @@ErrorWritingBMP
  mov gs, [bp+14]
  mov si, [bp+12]
  mov cx, 256
@@SaveBMPPal:
  mov al, gs:[si+2]
  shl al, 2
  mov Buffer, al
  call WriteBuffer
  jc  @@ErrorWritingBMP
  mov al, gs:[si+1]
  shl al, 2
  mov Buffer, al
  call WriteBuffer
  jc  @@ErrorWritingBMP
  mov al, gs:[si]
  shl al, 2
  mov Buffer, al
  call WriteBuffer
  jc  @@ErrorWritingBMP
  mov Buffer, 0
  call WriteBuffer
  jc  @@ErrorWritingBMP
  add si, 3
  dec cx
  jnz @@SaveBMPPal
  mov ecx, BMPHeader.BMPYSize
@@SaveBMPloop:
  mov dx, cx
  add dx, [bp+20]
  dec dx
  mov si, dx
  shl dx, 8
  shl si, 6
  add dx, si
  add dx, [bp+22]
  push cx
  push ds
  mov eax, BMPHeader.BMPXSize
  mov ecx, eax
  and eax, 3
  jz  @@WidthOk
  sub ecx, eax
  add ecx, 4
@@WidthOk:
  mov ax, es
  mov ds, ax
  mov ah, 40h
  int 21h
  pop ds
  pop cx
  jc  @@ErrorWritingBMP
  dec cx
  jnz @@SaveBMPloop
  xor ax, ax
  jmp @@EndSaveBMP
@@ErrorCreateBMP:
  mov ax, 1
  jmp @@EndSaveBMP
@@ErrorWritingBMP:
  mov ah, 3eh
  int 21h
  mov ax, 2
@@EndSaveBMP:
  pop ds
  pop bp
  ret 18
xCSSaveBMP endp

ReadBuffer proc
  push ds
  push ax
  push cx
  push dx
  mov dx, offset Buffer
  mov ax, @data
  mov ds, ax
  mov cx, 1
  mov ah, 3fh
  int 21h
  pop dx
  pop cx
  pop ax
  pop ds
  ret
ReadBuffer endp

WriteBuffer proc
  push ds
  push ax
  push cx
  push dx
  mov dx, offset Buffer
  mov ax, @data
  mov ds, ax
  mov cx, 1
  mov ah, 40h
  int 21h
  pop dx
  pop cx
  pop ax
  pop ds
  ret
WriteBuffer endp

END
