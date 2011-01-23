;----------------------------------------------------------------------------
;
;  CosmoX XMS Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

XMSMoveStruct struc
  XMSLength   dd  ?
  SHandle     dw  ?
  SOffset     dd  ?
  DHandle     dw  ?
  DOffset     dd  ?
XMSMoveStruct ends

.data

align 2

XMSAPI              dd  ?               ;  XMS Manager Address
XMSMove             XMSMoveStruct <>    ;  XMS Move Struct

.code

public  CSDetectXMS, CSFreeXMS, CSAllocateXMS, CSDeallocateXMS, CSMoveToXMS
public  CSMoveFromXMS, CSTotalXMS, CSResizeXMS, CSXMSHandles, CSMoveXMS
public  xCSGetXMSVer, CSXFreeXMS, CSXTotalXMS, CSXAllocateXMS, CSXResizeXMS

CSDetectXMS proc
  mov ax, 4300h
  int 2fh
  cmp al, 80h
  jne @@NoXMS
  mov ax, 4310h
  int 2fh
  mov word ptr [XMSAPI], bx
  mov word ptr [XMSAPI+2], es
  mov ax, 1
  ret
@@NoXMS:
  xor ax, ax
  ret
CSDetectXMS endp

xCSGetXMSVer proc
  xor ax, ax
  call [XMSAPI]
  ret
xCSGetXMSVer endp

CSFreeXMS proc
  mov ah, 08h
  call [XMSAPI]
  xor dx, dx
  ret
CSFreeXMS endp

CSTotalXMS proc
  mov ah, 08h
  call [XMSAPI]
  mov ax, dx
  xor dx, dx
  ret
CSTotalXMS endp

CSAllocateXMS proc
  push bp
  mov bp, sp
  mov dx, [bp+06]
  mov ah, 09h
  call [XMSAPI]
  or  ax, ax
  jz  @@EndAllocate
  mov ax, dx
@@EndAllocate:
  pop bp
  ret 4
CSAllocateXMS endp

CSDeallocateXMS proc
  push bp
  mov bp, sp
  mov dx, [bp+06]
  mov ah, 0ah
  call [XMSAPI]
  pop bp
  ret 2
CSDeallocateXMS endp

CSResizeXMS proc
  push bp
  mov bp, sp
  mov bx, [bp+06]
  mov dx, [bp+10]
  xor ax, ax
  mov ah, 0fh
  call [XMSAPI]
  pop bp
  ret 6
CSResizeXMS endp

CSXMSHandles proc
  xor cx, cx
  mov ah, 09h
  mov dx, 1
  call [XMSAPI]
  or  ax, ax
  jz  @@EndXMSHandles
  mov si, dx
  mov ah, 0eh
  call [XMSAPI]
  mov dx, si
  or  ax, ax
  jz  @@FreeTempHandle
  mov cl, bl
  inc cl
@@FreeTempHandle:
  mov ah, 0ah
  call [XMSAPI]
@@EndXMSHandles:
  mov ax, cx
  ret
CSXMSHandles endp

CSMoveToXMS proc
  push bp
  mov bp, sp
  mov dx, ds
  xor ax, ax
  mov XMSMove.SHandle, ax
  mov eax, [bp+18]
  mov XMSMove.SOffset, eax
  mov ax, [bp+14]
  mov XMSMove.DHandle, ax
  mov eax, [bp+10]
  mov XMSMove.DOffset, eax
  mov eax, [bp+06]
  and al, 0feh
  mov XMSMove.XMSLength, eax
  mov ax, seg XMSMove
  mov ds, ax
  mov si, offset XMSMove
  xor ax, ax
  mov ah, 0bh
  call [XMSAPI]
  mov ds, dx
  pop bp
  ret 16
CSMoveToXMS endp

CSMoveFromXMS proc
  push bp
  mov bp, sp
  mov dx, ds
  xor ax, ax
  mov XMSMove.DHandle, ax
  mov eax, [bp+18]
  mov XMSMove.DOffset, eax
  mov ax, [bp+14]
  mov XMSMove.SHandle, ax
  mov eax, [bp+10]
  mov XMSMove.SOffset, eax
  mov eax, [bp+06]
  and al, 0feh
  mov XMSMove.XMSLength, eax
  mov ax, seg XMSMove
  mov ds, ax
  mov si, offset XMSMove
  xor ax, ax
  mov ah, 0bh
  call [XMSAPI]
  mov ds, dx
  pop bp
  ret 16
CSMoveFromXMS endp

CSMoveXMS proc
  push bp
  push ds
  mov bp, sp
  mov dx, ds
  mov ax, [bp+22]
  mov XMSMove.SHandle, ax
  mov eax, [bp+18]
  mov XMSMove.SOffset, eax
  mov ax, [bp+16]
  mov XMSMove.DHandle, ax
  mov eax, [bp+12]
  mov XMSMove.DOffset, eax
  mov eax, [bp+08]
  and al, 0feh
  mov XMSMove.XMSLength, eax
  mov ax, seg XMSMove
  mov ds, ax
  mov si, offset XMSMove
  xor ax, ax
  mov ah, 0bh
  call [XMSAPI]
  pop ds
  pop bp
  ret 16
CSMoveXMS endp

CSXFreeXMS proc
  mov ah, 88h
  call [XMSAPI]
  or  bl, bl
  js  @@NoXFreeMemory
  mov edx, eax
  shr edx, 16
  ret
@@NoXFreeMemory:
  mov dx, 0ffffh
  mov ax, 0ffffh
  ret
CSXFreeXMS endp

CSXTotalXMS proc
  mov ah, 88h
  call [XMSAPI]
  or  bl, bl
  js  @@NoXTotalMemory
  mov eax, edx
  shr edx, 16
  ret
@@NoXTotalMemory:
  mov dx, 0ffffh
  mov ax, 0ffffh
  ret
CSXTotalXMS endp

CSXAllocateXMS proc
  push bp
  mov bp, sp
  mov ah, 89h
  mov edx, [bp+06]
  call [XMSAPI]
  or  bl, bl
  js  @@NoXAllocateXMS
  or  ax, ax
  jz  @@NoXAllocateXMS
  mov ax, dx
  pop bp
  ret 4
@@NoXAllocateXMS:
  mov ax, 0ffffh
  pop bp
  ret 4
CSXAllocateXMS endp

CSXResizeXMS proc
  push bp
  mov bp, sp
  mov ah, 8fh
  mov dx, [bp+10]
  mov ebx, [bp+06]
  call [XMSAPI]
  or  bl, bl
  jns @@EndXResizeXMS
  mov ax, 0ffffh
@@EndXResizeXMS:
  pop bp
  ret 6
CSXResizeXMS endp

end
