;----------------------------------------------------------------------------
;
;  CosmoX DISK Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

DtaStruct struc
  Res       db  21 dup(?)
  Attr      db  ?
  FileTime  dw  ?
  FileData  dw  ?
  FileSize  dd  ?
  FileName  db  13 dup(?)
  Res2      db  85 dup(?)
DtaStruct ends

.data

align 2

DtaSeg              dw  ?               ;  Last Dta Segment
DtaOff              dw  ?               ;  Last Dta offset
OldInt24Off         dw  ?               ;  Original Int 24h offset
OldInt24Seg         dw  ?               ;  Original Int 24h segment
Dta                 DtaStruct <>        ;  DOS Dta structure
ErrorFlag           db  ?

.code

public  xCSDrive, CSTotalDrives, CSFreeDiskSpc, CSTotalDiskSpc, xCSPath
public  xCSFindFile, xCSChdir, xCSSetDrive

xCSDrive proc
  push bp
  mov bp, sp
  mov ax, 1900h
  int 21h
  xor ah, ah
  add al, 41h
  pop bp
  ret
xCSDrive endp

CSTotalDrives proc
  mov ax, 1900h
  int 21h
  xor dh, dh
  mov dl, al
  mov ax, 0e00h
  int 21h
  mov si, ax
  xor cx, cx
@@FindDrives:
  mov ax, 440eh
  mov bx, cx
  inc bx
  int 21h
  jc @@EndFindDrives
  inc cx
  cmp cx, si
  jl  @@FindDrives
@@EndFindDrives:
  mov ax, cx
  ret
CSTotalDrives endp

CSFreeDiskSpc proc
  mov si, bp
  mov bp, sp
  mov dx, [bp+04]
  mov ah, 36h
  int 21h
  cmp ax, 0ffffh
  jne @@GiveFree
  mov dx, ax
  mov bp, si
  ret 2
@@GiveFree:
  mul bx
  mul cx
  mov bp, si
  ret 2
CSFreeDiskSpc endp

CSTotalDiskSpc proc
  mov si, bp
  mov bp, sp
  mov dx, [bp+04]
  mov ah, 36h
  int 21h
  cmp ax, 0ffffh
  jnz @@GiveTotal
  mov dx, ax
  mov bp, si
  ret 2
@@GiveTotal:
  mul dx
  mul cx
  mov bp, si
  ret 2
CSTotalDiskSpc endp

xCSPath proc
  push bp
  push ds
  mov bp, sp
  mov ax, 1900h
  int 21h
  xor dh, dh
  mov dl, al
  inc dl
  mov ds, [bp+10]
  mov si, [bp+08]
  add al, 41h
  mov [si], al
  inc si
  mov al, 3ah
  mov [si], al
  inc si
  mov al, 5ch
  mov [si], al
  inc si
  mov ah, 47h
  int 21h
  mov ds, [bp+10]
  mov si, [bp+08]
@@LookForNull:
  mov al, [si]
  inc si
  or  al, al
  jnz @@LookForNull
  dec si
  mov al, 5ch
  mov [si], al
  pop ds
  pop bp
  ret 4
xCSPath endp

xCSFindFile proc
  push bp
  push ds
  mov bp, sp
  mov ds, [bp+16]
  mov si, [bp+14]
  mov dl, [si]
  or  dl, dl
  jz  @@FindNextFile
  mov ax, seg Dta
  mov ds, ax
  mov dx, offset Dta
  mov ax, 1a00h
  int 21h
  mov ds, [bp+16]
  mov dx, [bp+14]
  mov cx, [bp+12]
  mov ax, 4e00h
  int 21h
  jc  @@FileNotFound
  jmp @@StoreFile
@@FindNextFile:
  mov ax, 4f00h
  int 21h
  jc  @@FileNotFound
@@StoreFile:
  mov ax, seg Dta
  mov ds, ax
  mov si, offset Dta
  add si, 30
  mov es, [bp+10]
  mov di, [bp+08]
  xor cx, cx
@@StoreNextChar:
  mov al, [si]
  or  al, al
  jz  @@EndStoreFile
  mov es:[di], al
  inc di
  inc si
  inc cx
  cmp cx, 13
  jnz @@StoreNextChar
@@EndStoreFile:
  mov ax, seg Dta
  mov es, ax
  mov di, offset Dta
  add di, 30
  mov al, 20h
  mov cx, 13
  rep stosb
  pop ds
  pop bp
  ret 10
@@FileNotFound:
  mov es, [bp+10]
  mov di, [bp+08]
  xor ax, ax
  stosb
  pop ds
  pop bp
  ret 10
xCSFindFile endp

xCSChdir proc
  push bp
  push ds
  mov bp, sp
  mov ax, 3b00h
  mov ds, [bp+10]
  mov dx, [bp+08]
  int 21h
  jc  @@ErrorChdir
  xor ax, ax
  pop ds
  pop bp
  ret 4
@@ErrorChdir:
  mov ax, 0ffffh
  pop ds
  pop bp
  ret 4
xCSChdir endp

xCSSetDrive proc
  push bp
  mov bp, sp
  mov ax, 0e00h
  mov dl, [bp+06]
  int 21h
  pop bp
  ret 2
xCSSetDrive endp

end
