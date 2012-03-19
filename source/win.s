;----------------------------------------------------------------------------
;
;  CosmoX WIN Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

WinFindData struc
  Attrib        dd  0
  CreationTime  dq  0
  LastAccess    dq  0
  LastMod       dq  0
  FileSizeH     dd  0
  FileSizeL     dd  0
  Reserved      db  8 dup(0)
  FileName      db  260 dup(0)
  ShortFileName db  14 dup(0)
WinFindData ends

.data

WinSupported        dw  0               ;  Are we running on Windows?
FindData            WinFindData <>      ;  Used by for searching calls
FindHandle          dw  0               ;  Used by for searching calls

.code

public  CSDetectWIN, xCSWinMakeDir, xCSWinRemoveDir, xCSWinChdir, xCSWinDelFile
public  xCSWinPath, CSWinGetVMID, xCSWinAppSetTitle, xCSWinVMSetTitle
public  xCSWinVMGetTitle, xCSWinAppGetTitle, CSWinOpenClipB, CSWinCloseClipB
public  CSWinEmptyClipB, CSWinGetClipBDataType, CSWinGetClipBDataSize
public  CSWinGetClipBData, CSWinSetClipBData, CSWinFindClose, xCSWinFindFile
public  xCSWinFindNext


CSDetectWIN proc
  mov ax, 3306h
  int 21h
  cmp bl, 07h
  jne @@NoWIN
  mov ax, 1
  mov WinSupported, ax
  ret
@@NoWIN:
  xor ax, ax
  mov WinSupported, ax
  ret
CSDetectWIN endp

xCSWinMakeDir proc
  push bp
  push ds
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ds, [bp+10]
  mov dx, [bp+08]
  mov ax, 7139h
  int 21h
  jc  @@Error
  xor ax, ax
  pop ds
  pop bp
  ret 4
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinMakeDir endp

xCSWinRemoveDir proc
  push bp
  push ds
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ds, [bp+10]
  mov dx, [bp+08]
  mov ax, 713ah
  int 21h
  jc  @@Error
  xor ax, ax
  pop ds
  pop bp
  ret 4
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinRemoveDir endp

xCSWinChdir proc
  push bp
  push ds
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ds, [bp+10]
  mov dx, [bp+08]
  mov ax, 713bh
  int 21h
  jc  @@Error
  xor ax, ax
  pop ds
  pop bp
  ret 4
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinChdir endp

xCSWinDelFile proc
  push bp
  push ds
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ds, [bp+10]
  mov dx, [bp+08]
  mov si, 1
  xor cx, cx
  mov ax, 7141h
  int 21h
  jc  @@Error
  xor ax, ax
  pop ds
  pop bp
  ret 6
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinDelFile endp

xCSWinPath proc
  push bp
  push ds
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ax, 1900h
  int 21h
  xor dx, dx
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
  mov ax, 7147h
  int 21h
  jc  @@Error
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
  xor ax, ax
  pop ds
  pop bp
  ret 4
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinPath endp

CSWinGetVMID proc
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  xor bx, bx
  mov ax, 1683h
  int 2fh
  mov ax, bx
@@Error:
  ret
CSWinGetVMID endp

xCSWinAppSetTitle proc
  push bp
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov es, [bp+08]
  mov di, [bp+06]
  xor dx, dx
  mov ax, 168eh
  int 2fh
@@Error:
  pop bp
  ret 4
xCSWinAppSetTitle endp

xCSWinVMSetTitle proc
  push bp
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov es, [bp+08]
  mov di, [bp+06]
  mov dx, 1
  mov ax, 168eh
  int 2fh
@@Error:
  pop bp
  ret 4
xCSWinVMSetTitle endp

xCSWinAppGetTitle proc
  push bp
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov es, [bp+08]
  mov di, [bp+06]
  mov cx, 256
  mov dx, 2
  mov ax, 168eh
  int 2fh
@@Error:
  pop bp
  ret 4
xCSWinAppGetTitle endp

xCSWinVMGetTitle proc
  push bp
  mov bp, sp
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov es, [bp+08]
  mov di, [bp+06]
  mov cx, 256
  mov dx, 3
  mov ax, 168eh
  int 2fh
@@Error:
  pop bp
  ret 4
xCSWinVMGetTitle endp

CSWinOpenClipB proc
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ax, 1701h
  int 2fh
@@Error:
  ret
CSWinOpenClipB endp

CSWinCloseClipB proc
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ax, 1708h
  int 2fh
@@Error:
  ret
CSWinCloseClipB endp

CSWinEmptyClipB proc
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ax, 1702h
  int 2fh
@@Error:
  ret
CSWinEmptyClipB endp

CSWinGetClipBDataType proc
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov cx, 1
@@Loop:
  mov ax, 1704h
  mov dx, cx
  int 2fh
  inc cx
  cmp cx, 83h
  je  @@NoData
  mov bx, ax
  mov ax, dx
  shl eax, 16
  mov ax, bx
  or  eax, eax
  jz  @@Loop
  mov ax, cx
  dec ax
  ret
@@NoData:
@@Error:
  xor ax, ax
  ret
CSWinGetClipBDataType endp

CSWinGetClipBDataSize proc
  mov ax, -1
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov cx, 1
@@Loop:
  mov ax, 1704h
  mov dx, cx
  int 2fh
  inc cx
  cmp cx, 83h
  je  @@NoData
  mov bx, ax
  mov ax, dx
  shl eax, 16
  mov ax, bx
  or  eax, eax
  jz  @@Loop
  mov edx, eax
  shr edx, 16
  ret
@@NoData:
@@Error:
  xor ax, ax
  xor dx, dx
  ret
CSWinGetClipBDataSize endp

CSWinGetClipBData proc
  push bp
  mov bp, sp
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov es, [bp+12]
  mov bx, [bp+08]
  mov dx, [bp+06]
  mov ax, 1705h
  int 2fh
@@Error:
  pop bp
  ret 8
CSWinGetClipBData endp

CSWinSetClipBData proc
  push bp
  mov bp, sp
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov cx, [bp+06]
  mov si, [bp+08]
  mov dx, [bp+10]
  mov bx, [bp+12]
  mov es, [bp+16]
  mov ax, 1703h
  int 2fh
@@Error:
  pop bp
  ret 12
CSWinSetClipBData endp


xCSWinFindFile proc
  push bp
  push ds
  mov bp, sp
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov bx, FindHandle
  or  bx, bx
  jz  @@HandleClosed
  call CSWinFindClose
@@HandleClosed:
  mov ch, [bp+08]
  mov cl, ch
  mov ax, seg FindData
  mov di, offset FindData
  mov es, ax
  mov ds, [bp+12]
  mov dx, [bp+10]
  xor si, si
  mov ax, 714eh
  int 21h
  jc  @@Error
  mov bx, @data
  mov ds, bx
  mov FindHandle, ax
  mov ax, seg FindData.FileName
  mov si, offset FindData.FileName
  mov ds, ax
  mov es, [bp+16]
  mov di, [bp+14]
@@Loop:
  mov al, [si]
  or  al, al
  jz  @@Done
  mov es:[di], al
  inc si
  inc di
  jmp @@Loop
@@Done:
@@Error:
  pop ds
  pop bp
  ret 10
xCSWinFindFile endp

CSWinFindClose proc
  mov bx, FindHandle
  mov ax, 71a1h
  int 21h
  xor ax, ax
  mov FindHandle, ax
  ret
CSWinFindClose endp

xCSWinFindNext proc
  push bp
  push ds
  mov bp, sp
  mov dx, WinSupported
  or  dx, dx
  je  @@Error
  mov ax, seg FindData
  mov di, offset FindData
  mov es, ax
  xor si, si
  mov bx, FindHandle
  mov ax, 714fh
  int 21h
  jc  @@Error
  mov ax, seg FindData.FileName
  mov si, offset FindData.FileName
  mov ds, ax
  mov es, [bp+10]
  mov di, [bp+08]
@@Loop:
  mov al, [si]
  or  al, al
  jz  @@Done
  mov es:[di], al
  inc si
  inc di
  jmp @@Loop
@@Done:
@@Error:
  pop ds
  pop bp
  ret 4
xCSWinFindNext endp

end

