;----------------------------------------------------------------------------
;
;  CosmoX MAIN Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p586
.model use16 medium, basic
.stack 200h

locals @@

extrn CSDestroyBMap     : far
extrn CSRemoveKeyBoard  : far
extrn CSRemoveTimer     : far

BASIC_StrDescriptor struc
  StrLenght   dw  ?
  StrOffset   dw  ?
BASIC_StrDescriptor ends

.data

public  BMapSeg, BMapActive, ClipX1, ClipX2, ClipY1, ClipY2

align 2

BMapSeg             dw  0               ;  Blender map segment
ClipX1              dw  0               ;  Clipping Box
ClipX2              dw  319             ;  Clipping Box
ClipY1              dw  0               ;  Clipping Box
ClipY2              dw  199             ;  Clipping Box
CpuType             dw  ?               ;  Cpu type
LibVersion          dw  0200h           ;  Library Version
BMapActive          db  0               ;  Is the blender map active?
CpuIDString         db  12 dup(?)       ;  CPU ID string buffer
CpuIDDescriptor     BASIC_StrDescriptor <12, offset CpuIDString>
LibIDString         db  'CosmoX v2.0 by bobby, CosmoSoft 2001    '
LibIDDescriptor     BASIC_StrDescriptor <40, offset LibIDString>
CPU386              db  '80386                '
CPU486              db  '80486                '
CPU586              db  'Pentium              '
CPU686              db  'Pentium II, or higher'
CPUDescriptor       BASIC_StrDescriptor <21, ?>
OldInt3DAddress     dd  ?
FfixInstalled       db  ?

.code

public  CSVer, CSDetectCPU, CSInitVGA, CSInitText, CSDelay, CSTimerTicks
public  CSSort, xCSGetCard, CSSetClipBox, CSGetClipBox, CSId, CSCpuID
public  CSProcessor, CSClose, CSFfix, CSRemoveFfix

CSVer proc
  mov ax, LibVersion
  ret
CSVer endp

CSInitVGA proc
  mov ax, 0013h
  int 10h
  ret
CSInitVGA endp

CSInitText proc
  mov ax, 0003h
  int 10h
  ret
CSInitText endp

CSTimerTicks proc
  mov ax, 40h
  mov es, ax
  mov di, 6ch
  mov ax, es:[di]
  mov dx, es:[di+2]
  ret
CSTimerTicks endp

CSDelay proc
  mov bx, bp
  mov bp, sp
  mov cx, [bp+04]
@@DelayLoop:
  mov dx, 03dah
@@Delay1:
  in  al, dx
  and al, 08h
  jnz @@Delay1
@@Delay2:
  in  al, dx
  and al, 08h
  jz  @@Delay2
  dec cx
  jnz @@DelayLoop
  mov bp, bx
  ret 2
CSDelay endp

CSSort proc
  push bp
  mov bp, sp
  mov ax, [bp+14]
  mov es, ax
@@SortLoop:
  mov si, [bp+12]
  add si, [bp+06]
  mov di, si
  add di, [bp+08]
  mov cx, [bp+10]
  dec cx
  xor dx, dx
@@SortLoop2:
  mov ax, es:[si]
  mov bx, es:[di]
  cmp ax, bx
  jle @@NoSwap
  mov fs, si
  mov gs, di
  mov bx, [bp+08]
  shr bx, 1
  sub si, [bp+06]
  sub di, [bp+06]
@@SwapLoop:
  mov ax, es:[si]
  mov dx, es:[di]
  mov es:[si], dx
  mov es:[di], ax
  add si, 2
  add di, 2
  dec bx
  jnz @@SwapLoop
  mov di, gs
  mov si, fs
  mov dx, 1
@@NoSwap:
  mov si, di
  add di, [bp+08]
  dec cx
  jnz @@SortLoop2
  or  dx, dx
  jnz @@SortLoop
  pop bp
  ret 10
CSSort endp

xCSGetCard proc
  push bp
  sub sp, 256
  mov bp, sp
  mov ax, ss
  mov es, ax
  mov di, bp
  mov ax, 4f00h
  int 10h
  mov fs, [bp+08]
  mov si, [bp+06]
  add sp, 256
  mov bp, sp
  mov es, [bp+08]
  mov di, [bp+06]
  mov bx, 256
  cmp al, 4fh
  jne @@EndCard
  or  ah, ah
  jnz @@EndCard
@@StoreCard:
  mov al, fs:[si]
  inc si
  or  al, al
  jz  @@EndCard
  mov es:[di], al
  inc di
  dec bx
  jnz @@StoreCard
@@EndCard:
  pop bp
  ret 4
xCSGetCard endp

CSDetectCPU proc
  mov CpuType, 286
  pushf
  mov ax, 7000h
  push ax
  popf
  pushf
  pop ax
  and ax, 7000h
  popf
  or  ax, ax
  jz  @@EndDetectCPU
  mov CpuType, 386
  pushfd
  pushfd
  pop eax
  or  eax, 00040000h
  push eax
  popfd
  pushfd
  pop eax
  popfd
  and eax, 00040000h
  or  eax, eax
  jz  @@EndDetectCPU
  mov CpuType, 486
  pushfd
  pushfd
  pop eax
  or  eax, 00200000h
  push eax
  popfd
  pushfd
  pop eax
  popfd
  and eax, 00200000h
  or  eax, eax
  jz  @@EndDetectCPU
  mov eax, 1
  cpuid
  shr eax, 8
  and ax, 0fh
  cmp ax, 4
  je  @@EndDetectCPU
  cmp ax, 5
  je  @@ItsAPentium
  cmp ax, 6
  je  @@ItsAPentiumPro
  mov CpuType, 786
  jmp @@EndDetectCPU
@@ItsAPentium:
  mov CpuType, 586
  jmp @@EndDetectCPU
@@ItsAPentiumPro:
  mov CpuType, 686
@@EndDetectCPU:
  mov ax, CpuType
  ret
CSDetectCPU endp

CSSetClipBox proc
  push bp
  mov bp, sp
  mov ax, [bp+12]
  mov bx, [bp+08]
  cmp ax, bx
  je  @@BadClipping
  jl  @@NoSwap1
  mov ClipX1, bx
  mov ClipX2, ax
  jmp @@SetYS
@@NoSwap1:
  mov ClipX2, bx
  mov ClipX1, ax
@@SetYS:
  mov ax, [bp+10]
  mov bx, [bp+06]
  cmp ax, bx
  je  @@BadClipping
  jl  @@NoSwap2
  mov ClipY1, bx
  mov ClipY2, ax
  jmp @@EndClip
@@NoSwap2:
  mov ClipY2, bx
  mov ClipY1, ax
@@EndClip:
  pop bp
  ret 8
@@BadClipping:
  xor ax, ax
  mov ClipX1, ax
  mov ClipY1, ax
  mov ax, 199
  mov ClipY2, ax
  mov ax, 319
  mov ClipX2, ax
  pop bp
  ret 8
CSSetClipBox endp

CSGetClipBox proc
  push bp
  mov bp, sp
  mov bx, [bp+12]
  mov ax, ClipX1
  mov [bx], ax
  mov bx, [bp+10]
  mov ax, ClipY1
  mov [bx], ax
  mov bx, [bp+08]
  mov ax, ClipX2
  mov [bx], ax
  mov bx, [bp+06]
  mov ax, ClipY2
  mov [bx], ax
  pop bp
  ret 8
CSGetClipBox endp

CSId proc
  mov ax, offset LibIDDescriptor
  ret
CSId endp

CSCpuID proc
  pushfd
  pushfd
  pop eax
  or  eax, 00200000h
  push eax
  popfd
  pushfd
  pop eax
  popfd
  and eax, 00200000h
  or  eax, eax
  jz  @@NoCpuID
  xor eax, eax
  cpuid
  mov si, offset CpuIDString
  mov [si], ebx
  mov [si+4], edx
  mov [si+8], ecx
@@NoCpuID:
  mov ax, offset CpuIDDescriptor
  ret
CSCpuID endp

CSProcessor proc
  call CSDetectCPU
  cmp ax, 386
  jne @@Not386
  mov dx, offset CPU386
  mov CPUDescriptor.StrOffset, dx
  mov ax, offset CPUDescriptor
  ret
@@Not386:
  cmp ax, 486
  jne @@Not486
  mov dx, offset CPU486
  mov CPUDescriptor.StrOffset, dx
  mov ax, offset CPUDescriptor
  ret
@@Not486:
  cmp ax, 586
  jne @@Not586
  mov dx, offset CPU586
  mov CPUDescriptor.StrOffset, dx
  mov ax, offset CPUDescriptor
  ret
@@Not586:
  mov dx, offset CPU686
  mov CPUDescriptor.StrOffset, dx
  mov ax, offset CPUDescriptor
  ret
CSProcessor endp

CSFfix proc
  mov dl, FfixInstalled
  or  dl, dl
  jnz @@EndFFix
  cli
  xor cx, cx
  mov es, cx
  mov eax, es:[0f4h]
  mov OldInt3DAddress, eax
  mov ax, seg FixISR
  mov bx, offset FixISR
  mov es:[0f4h], bx
  mov es:[0f6h], ax
  sti
  mov FfixInstalled, 1
@@EndFFix:
  ret
FixISR:
  push bp
  mov bp, sp
  push ds
  lds bp, [bp+02]
  mov word ptr ds:[bp-2], 909bh
  pop ds
  pop bp
  iret
CSFfix endp

CSRemoveFfix proc
  mov dl, FfixInstalled
  or  dl, dl
  jz  @@RemoveEndFFix
  cli
  xor cx, cx
  mov es, cx
  mov eax, OldInt3DAddress
  mov es:[0f4h], eax
  sti
  mov FfixInstalled, 0
@@RemoveEndFFix:
  ret
CSRemoveFfix endp

CSClose proc
  call CSDestroyBMap
  call CSRemoveKeyBoard
  call CSRemoveTimer
  call CSRemoveFfix
  call CSInitText
  ret
CSClose endp

end
