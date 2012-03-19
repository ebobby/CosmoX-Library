;----------------------------------------------------------------------------
;
;  CosmoX EMS Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

EMSMoveStruct struc
  EMSLength   dd  ?
  SType       db  ?
  SHandle     dw  ?
  SOffset     dw  ?
  SSegment    dw  ?
  DType       db  ?
  DHandle     dw  ?
  DOffset     dw  ?
  DSegment    dw  ?
EMSMoveStruct ends

.data

align 2

EMMID               db  'EMMXXXX0'      ;  Expanded Memory manager ID
EMSMove             EMSMoveStruct <>    ;  EMS Move Struct

.CODE

public  CSDetectEMS, CSGetEMSFrame, CSFreeEMSPages, CSTotalEMSPages, CSFreeEMS
public  CSTotalEMS, CSAllocateEMS, CSDeallocateEMS, CSMapEMS, CSEMSHandles
public  CSMapEMSLayer, CSResizeEMS, CSMoveToEMS, CSMoveFromEMS, CSMoveEMS
public  xCSGetEMSVer, CSScrollHEMS, CSScrollVEMS

CSDetectEMS proc
  push ds
  mov ax, @data
  mov ds, ax
  mov si, offset EMMID
  mov di, 000ah
  mov ax, 3567h
  int 21h
  xor ax, ax
  mov cx, 8
  repe cmpsb
  sete al
  pop ds
  ret
CSDetectEMS endp

xCSGetEMSVer proc
  mov ax, 4600h
  int 67h
  or  ah, ah
  jz  @@EMSVersion
  xor ax, ax
@@EMSVersion:
  ret
xCSGetEMSVer endp

CSGetEMSFrame proc
  xor ax, ax
  xor bx, bx
  mov ah, 41h
  int 67h
  mov ax, bx
  ret
CSGetEMSFrame endp

CSFreeEMSPages proc
  xor ax, ax
  mov ah, 42h
  xor bx, bx
  int 67h
  mov ax, bx
  ret
CSFreeEMSPages endp

CSTotalEMSPages proc
  xor ax, ax
  mov ah, 42h
  xor dx, dx
  int 67h
  mov ax, dx
  ret
CSTotalEMSPages endp

CSFreeEMS proc
  xor ax, ax
  mov ah, 42h
  xor bx, bx
  int 67h
  mov ax, bx
  xor dx, dx
  shl ax, 4
  ret
CSFreeEMS endp

CSTotalEMS proc
  xor ax, ax
  mov ah, 42h
  xor dx, dx
  int 67h
  mov ax, dx
  xor dx, dx
  shl ax, 4
  ret
CSTotalEMS endp

CSEMSHandles proc
  xor ax, ax
  mov ah, 4bh
  xor bx, bx
  int 67h
  mov ax, bx
  ret
CSEMSHandles endp

CSAllocateEMS proc
  push bp
  mov bp, sp
  xor ax, ax
  xor dx, dx
  mov bx, [bp+06]
  mov ah, 43h
  int 67h
  or  ah, ah
  jnz @@NoEMSMemory
  mov ax, dx
  pop bp
  ret 2
@@NoEMSMemory:
  xor ax, ax
  pop bp
  ret 2
CSAllocateEMS endp

CSDeallocateEMS proc
  push bp
  mov bp, sp
  xor ax, ax
  mov dx, [bp+06]
  mov ah, 45h
  int 67h
  pop bp
  ret 2
CSDeallocateEMS endp

CSMapEMS proc
  push bp
  mov bp, sp
  xor ax, ax
  mov dx, [bp+10]
  mov al, [bp+08]
  and al, 03h
  mov bx, [bp+06]
  mov ah, 44h
  int 67h
  pop bp
  ret 6
CSMapEMS endp

CSMapEMSLayer proc
  push bp
  mov bp, sp
  xor ax, ax
  mov dx, [bp+08]
  mov bx, [bp+06]
@@MapEMSLayer:
  mov ah, 44h
  int 67h
  inc bx
  inc al
  cmp al, 4
  jnz @@MapEMSLayer
  pop bp
  ret 4
CSMapEMSLayer endp

CSResizeEMS proc
  push bp
  mov bp, sp
  xor ax, ax
  xor bx, bx
  mov dx, [bp+08]
  mov bx, [bp+06]
  mov ah, 51h
  int 67h
  mov ax, bx
  pop bp
  ret 4
CSResizeEMS endp

CSMoveToEMS proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov EMSMove.SSegment, ax
  mov ax, [bp+18]
  mov EMSMove.SOffset, ax
  mov ax, [bp+16]
  mov EMSMove.DHandle, ax
  mov ax, [bp+14]
  mov EMSMove.DSegment, ax
  mov ax, [bp+12]
  mov EMSMove.DOffset, ax
  mov eax, [bp+08]
  mov EMSMove.EMSLength, eax
  xor ax, ax
  mov EMSMove.SType, al
  mov EMSMove.SHandle, ax
  mov al, 1
  mov EMSMove.DType, al
  mov ax, seg EMSMove
  mov ds, ax
  mov si, offset EMSMove
  xor ax, ax
  mov ah, 57h
  int 67h
  pop ds
  pop bp
  ret 16
CSMoveToEMS ENDP

CSMoveFromEMS proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov EMSMove.DSegment, ax
  mov ax, [bp+18]
  mov EMSMove.DOffset, ax
  mov ax, [bp+16]
  mov EMSMove.SHandle, ax
  mov ax, [bp+14]
  mov EMSMove.SSegment, ax
  mov ax, [bp+12]
  mov EMSMove.SOffset, ax
  mov eax, [bp+08]
  mov EMSMove.EMSLength, eax
  xor ax, ax
  mov EMSMove.DType, al
  mov EMSMove.DHandle, ax
  mov al, 1
  mov EMSMove.SType, AL
  mov ax, seg EMSMove
  mov ds, ax
  mov si, offset EMSMove
  xor ax, ax
  mov ah, 57h
  int 67h
  pop ds
  pop bp
  ret 16
CSMoveFromEMS endp

CSMoveEMS proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov EMSMove.SHandle, ax
  mov ax, [bp+20]
  mov EMSMove.SSegment, ax
  mov ax, [bp+18]
  mov EMSMove.SOffset, ax
  mov ax, [bp+16]
  mov EMSMove.DHandle, ax
  mov ax, [bp+14]
  mov EMSMove.DSegment, ax
  mov ax, [bp+12]
  mov EMSMove.DOffset, ax
  mov eax, [bp+08]
  mov EMSMove.EMSLength, eax
  mov al, 1
  mov EMSMove.SType, al
  mov EMSMove.DType, al
  mov ax, seg EMSMove
  mov ds, ax
  mov si, offset EMSMove
  xor ax, ax
  mov ah, 57h
  int 67h
  pop ds
  pop bp
  ret 16
CSMoveEMS endp

CSScrollHEMS proc
  push bp
  push ds
  mov bp, sp
  mov ah, 41h
  int 67h
  mov ax, [bp+18]
  mov ds, bx
  mov es, ax
  mov dx, [bp+14]
  mov ax, 4700h
  int 67h
  mov bx, [bp+12]
  mov ax, 4400h
  int 67h
  mov ax, 4401h
  inc bx
  int 67h
  mov ax, 4402h
  inc bx
  int 67h
  mov ax, 4403h
  inc bx
  int 67h
  mov ax, [bp+16]
  xor si, si
  xor di, di
  or  ax, ax
  jnz @@NotSimpleCopy
  mov cx, 16000
  rep movsd
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
@@NotSimpleCopy:
  cmp ax, 320
  ja  @@SkipFirstBG
  mov dx, 320
  mov si, ax
  sub dx, ax
  mov cx, dx
  mov bx, 200
@@NextLine1:
  shr cx, 2
  rep movsd
  mov cx, dx
  and cx, 3
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  mov cx, dx
  add si, ax
  add di, ax
  dec bx
  jnz @@NextLine1
@@SkipFirstBG:
  mov dx, [bp+10]
  mov bx, [bp+08]
  mov ax, 4400h
  int 67h
  mov ax, 4401h
  inc bx
  int 67h
  mov ax, 4402h
  inc bx
  int 67h
  mov ax, 4403h
  inc bx
  int 67h
  mov ax, [bp+16]
  xor si, si
  xor di, di
  cmp ax, 320
  jna @@NotSimpleCopy2
  mov cx, 16000
  rep movsd
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
@@NotSimpleCopy2:
  mov dx, 320
  sub dx, ax
  mov di, dx
  mov cx, ax
  mov bx, 200
@@NextLine2:
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  mov cx, ax
  add si, dx
  add di, dx
  dec bx
  jnz @@NextLine2
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
CSScrollHEMS endp

CSScrollVEMS proc
  push bp
  push ds
  mov bp, sp
  mov ah, 41h
  int 67h
  mov ax, [bp+18]
  mov ds, bx
  mov es, ax
  mov dx, [bp+14]
  mov ax, 4700h
  int 67h
  mov bx, [bp+12]
  mov ax, 4400h
  int 67h
  mov ax, 4401h
  inc bx
  int 67h
  mov ax, 4402h
  inc bx
  int 67h
  mov ax, 4403h
  inc bx
  int 67h
  mov ax, [bp+16]
  xor si, si
  xor di, di
  or  ax, ax
  jnz @@NotSimpleCopy3
  mov cx, 16000
  rep movsd
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
@@NotSimpleCopy3:
  cmp ax, 200
  ja  @@SkipFirstBG2
  mov cx, 200
  mov si, ax
  sub cx, ax
  shl si, 8
  shl ax, 6
  mov dx, cx
  add si, ax
  shl cx, 8
  shl dx, 6
  add cx, dx
  shr cx, 2
  rep movsd
@@SkipFirstBG2:
  mov dx, [bp+10]
  mov bx, [bp+08]
  mov ax, 4400h
  int 67h
  mov ax, 4401h
  inc bx
  int 67h
  mov ax, 4402h
  inc bx
  int 67h
  mov ax, 4403h
  inc bx
  int 67h
  mov ax, [bp+16]
  xor si, si
  xor di, di
  cmp ax, 200
  jna @@NotSimpleCopy4
  mov cx, 16000
  rep movsd
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
@@NotSimpleCopy4:
  mov dx, 200
  mov cx, ax
  sub dx, ax
  mov di, dx
  shl di, 8
  shl dx, 6
  add di, dx
  shl cx, 8
  shl ax, 6
  add cx, ax
  shr cx, 2
  rep movsd
  mov dx, [bp+14]
  mov ax, 4800h
  int 67h
  pop ds
  pop bp
  ret 12
CSScrollVEMS endp

end
