;----------------------------------------------------------------------------
;
;  CosmoX BLENDING Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

extrn BMapActive  : byte
extrn BMapSeg     : word
extrn B$SETM      : far       ; This is the QB function SETMEM

CosmoXBMapFile struc
    BMapFileTitle     db  'CosmoX BMap File    '
    LibVersion        db  'CosmoX Library v2.0 '
CosmoXBMapFile ends

.data

align 2

BMapHeader          CosmoXBMapFile <>            ; BMap File Header
BMapLoad            CosmoXBMapFile <>            ; BMap File Header
BMapID              db  'CosmoX BMap File    '   ; BMap File ID

.code

public  CSCreateBMap, CSSetBMap, CSGetBMap, CSDestroyBMap, xCSSaveBMap,
public  xCSLoadBMap

CSCreateBMap proc
  mov dl, BMapActive
  or  dl, dl
  jnz @@AlreadyUp
  mov eax, -66000
  push eax
  call B$SETM
  mov ah, 48h
  mov bx, 4096
  int 21h
  jc  @@NoMemory
  mov BMapSeg, ax
  mov dl, 1
  mov BMapActive, dl
  xor ecx, ecx
  xor di, di
  mov dx, ds
  mov ds, ax
@@CreateBMap:
  mov [di], ch
  inc ecx
  inc di
  cmp ecx, 65536
  jl  @@CreateBMap
  mov ds, dx
  xor ax, ax
  ret
@@AlreadyUp:
  mov ax, 2
  ret
@@NoMemory:
  mov ax, 1
  ret
CSCreateBMap endp

CSSetBMap proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndSetBMap
  mov ax, BMapSeg
  mov ds, ax
  mov ax, [bp+12]
  mov bx, [bp+10]
  mov bh, al
  mov al, [bp+08]
  mov [bx], al
@@EndSetBMap:
  pop ds
  pop bp
  ret 6
CSSetBMap endp

CSGetBMap proc
  push bp
  push ds
  mov bp, sp
  mov ax, 0ffffh
  mov dl, BMapActive
  or  dl, dl
  JZ  @@EndGetBMap
  mov ax, BMapSeg
  mov ds, ax
  mov ax, [bp+10]
  mov bx, [bp+08]
  mov bh, al
  xor ah, ah
  mov al, [bx]
@@EndGetBMap:
  pop ds
  pop bp
  ret 4
CSGetBMap endp

CSDestroyBMap proc
  mov dl, BMapActive
  or  dl, dl
  jz  @@AlreadyDown
  mov ax, BMapSeg
  mov es, ax
  mov ah, 49h
  int 21h
  mov eax, 66000
  push eax
  call B$SETM
@@AlreadyDown:
  ret
CSDestroyBMap endp

xCSSaveBMap proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@ErrorNoBMap
  mov ds, [bp+10]
  mov dx, [bp+08]
  xor cx, cx
  mov ah, 3ch
  int 21h
  jc  @@ErrorOpenSBMap
  mov bx, ax
  mov ax, seg BMapHeader
  mov ds, ax
  mov dx, offset BMapHeader
  mov cx, 40
  mov ah, 40h
  int 21h
  jc  @@ErrorSaveBMap
  mov ax, BMapSeg
  mov ds, ax
  xor dx, dx
  mov cx, 8000h
  mov ah, 40h
  int 21h
  jc  @@ErrorSaveBMap
  mov dx, 8000h
  mov cx, 8000h
  mov ah, 40h
  int 21h
  jc  @@ErrorSaveBMap
  mov ah, 3eh
  int 21h
  jc  @@ErrorSaveBMap
  xor ax, ax
  JMP @@EndSaveBMap
@@ErrorSaveBMap:
  xor ax, ax
  mov ax, 2
  jmp @@EndSaveBMap
@@ErrorOpenSBMap:
  xor ax, ax
  mov ax, 1
  jmp @@EndSaveBMap
@@ErrorNoBMap:
  mov ax, 3
@@EndSaveBMap:
  pop ds
  pop bp
  ret 4
xCSSaveBMap endp

xCSLoadBMap proc
  push bp
  push ds
  mov bp, sp
  mov dl, BMapActive
  or  dl, dl
  jz  @@EndLoadBMap
  mov ds, [bp+10]
  mov dx, [bp+08]
  xor cx, cx
  mov ah, 3dh
  int 21h
  jc  @@ErrorOpenLBMap
  mov bx, ax
  mov ax, seg BMapLoad
  mov ds, ax
  mov dx, offset BMapLoad
  mov cx, 40
  mov ah, 3fh
  int 21h
  jc  @@ErrorLoadBMap
  mov ax, ds
  mov es, ax
  mov si, offset BMapLoad
  mov di, offset BMapID
  mov cx, 20
  repe cmpsb
  jne @@NoBMapFile
  mov ax, BMapSeg
  mov ds, ax
  xor dx, dx
  mov cx, 8000h
  mov ah, 3fh
  int 21h
  jc  @@ErrorLoadBMap
  mov dx, 8000h
  mov cx, 8000h
  mov ah, 3fh
  int 21h
  JC  @@ErrorLoadBMap
  mov ah, 3eh
  int 21h
  jc  @@ErrorLoadBMap
  xor ax, ax
  jmp @@EndLoadBMap
@@ErrorOpenLBMap:
  mov ax, 1
  jmp @@EndLoadBMap
@@NoBMapFile:
  mov ah, 3eh
  int 21h
  mov ax, 3
  jmp @@EndLoadBMap
@@ErrorLoadBMap:
  mov ah, 3eh
  int 21h
  mov ax, 2
@@EndLoadBMap:
  pop ds
  pop bp
  ret 4
xCSLoadBMap endp

end
