;----------------------------------------------------------------------------
;
;  CosmoX SOUND BLASTER Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

WAVFileHeader struc
  MMFileID          dd ?
  FileLenght        dd ?
  WavFileID         dd ?
  FormatID          dd ?
  FormatLenght      dd ?
  SoundFormat       dw ?
  NumberOfChannels  dw ?
  SamplesPerSec     dd ?
  AvgBytesPerSec    dd ?
  BlockAlign        dw ?
  BitsPerSample     dw ?
  DataID            dd ?
  DataLenght        dd ?
WAVFileHeader ends

.data

align 2

BaseAddr            dw  ?               ;  Sound Blaster base address
BlasterReset        dw  ?               ;  Sound Blaster reset port
BlasterRead         dw  ?               ;  Sound Blaster read port
BlasterWrite        dw  ?               ;  Sound Blaster write port
BlasterStatus       dw  ?               ;  Sound Blaster write status port
BlasterData         dw  ?               ;  Sound Blaster data ready port
WavHeader           WAVFileHeader <>    ;  .WAV file header Struct
BlasterActive       db  ?               ;  Is the Sound Blaster active ?
SoundFlag           db  ?               ;  Is a sound currently playing ?

.code

public  CSInitBlaster, CSTurnBlasterOn, CSTurnBlasterOff, CSPlaySound
public  xCSLoadRAWSound, xCSLoadWAVSound, CSSoundDone, CSContinueSound
public  CSPauseSound

CSInitBlaster proc
  xor ax, ax
  xor dx, dx
  mov bx, 1
@@InitBlasterLoop:
  mov ax, bx
  shl ax, 4
  mov dx, ax
  add dx, 0206H
  mov BlasterReset, dx
  mov dx, ax
  add dx, 020aH
  mov BlasterRead, DX
  mov dx, ax
  add dx, 020ch
  mov BlasterWrite, dx
  mov BlasterStatus, dx
  mov dx, ax
  add dx, 020eh
  mov BlasterData, dx
  mov cx, 5
  mov dx, BlasterReset
  mov al, 1
  out dx, al
  xor al, al
@@ResetWait1:
  call WaitRetrace
  dec cx
  jnz @@ResetWait1
  mov cx, 5
  out dx, al
@@ResetWait2:
  call WaitRetrace
  dec cx
  jnz @@ResetWait2
  mov dx, BlasterData
  in  al, dx
  and al, 80h
  cmp al, 80h
  jne @@NoBlaster
  mov dx, BlasterRead
  in  al, dx
  cmp al, 0aah
  jne @@NoBlaster
  in  al, 08h
  mov ax, 1
  mov BlasterActive, al
  ret
@@NoBlaster:
  inc bx
  cmp bx, 9
  jne @@InitBlasterLoop
  xor ax, ax
  mov BlasterActive, al
  ret
CSInitBlaster endp

CSTurnBlasterOn proc
  mov al, BlasterActive
  or  al, al
  jz  @@NoTurnOn
  mov ah, 0d1h
  call WriteDSP
@@NoTurnOn:
  ret
CSTurnBlasterOn endp

CSTurnBlasterOff proc
  mov al, BlasterActive
  or  al, al
  jz  @@NoTurnOff
  mov ah, 0d3h
  call WriteDSP
@@NoTurnOff:
  ret
CSTurnBlasterOff endp

CSPauseSound proc
  mov al, BlasterActive
  or  al, al
  jz  @@NoPause
  mov ah, 0d0h
  call WriteDSP
@@NoPause:
  ret
CSPauseSound endp

CSContinueSound proc
  mov al, BlasterActive
  or  al, al
  jz  @@NoContinue
  mov ah, 0d4h
  call WriteDSP
@@NoContinue:
  ret
CSContinueSound ENDP

CSPlaySound proc
  push bp
  mov bp, sp
  mov al, BlasterActive
  or  al, al
  jz  @@EndPlaySound
  mov cx, [bp+18]
  mov bx, [bp+14]
  shl cx, 4
  add cx, bx
  mov bx, [bp+18]
  mov ax, [bp+14]
  shr ax, 4
  add bx, ax
  shr bx, 12
  mov dx, 0ah
  mov al, 05h
  out dx, al
  mov dx, 0ch
  xor al, al
  out dx, al
  mov dx, 0bh
  mov al, 49h
  out dx, al
  mov dx, 02h
  mov ax, cx
  out dx, al
  mov al, ah
  out dx, al
  mov dx, 83h
  mov ax, bx
  out dx, al
  mov dx, 03h
  mov ax, [bp+10]
  dec ax
  out dx, al
  mov al, ah
  out dx, al
  mov dx, 0ah
  mov al, 01h
  out dx, al
  xor ebx, ebx
  mov bx, [bp+06]
  mov eax, 1000000
  xor edx, edx
  div ebx
  mov cx, 256
  sub cx, ax
  mov ah, 40h
  call WriteDSP
  mov ah, cl
  call WriteDSP
  mov cx, [bp+10]
  dec cx
  mov ah, 14h
  call WriteDSP
  mov ah, cl
  call WriteDSP
  mov ah, ch
  call WriteDSP
  mov al, 1
  mov SoundFlag, al
@@EndPlaySound:
  pop bp
  ret 14
CSPlaySound endp

xCSLoadRAWSound proc
  push bp
  push ds
  mov bp, sp
  mov cx, [bp+16]
  mov dx, [bp+14]
  mov ds, cx
  mov ax, 3d00h
  int 21h
  jc  @@ErrorOpeningRaw
  mov bx, ax
  xor cx, cx
  xor dx, dx
  mov ax, 4202h
  int 21h
  push ax
  xor cx, cx
  xor dx, dx
  mov ax, 4200h
  int 21h
  pop cx
  push cx
  mov ax, [bp+12]
  mov dx, [bp+08]
  mov ds, ax
  mov ah, 3fh
  int 21h
  jc  @@ErrorReadRaw
  mov ah, 3eh
  int 21h
  in  al, 08h
  pop ax
  xor dx, dx
  jmp @@EndLoadRaw
@@ErrorOpeningRaw:
  mov ax, 1
  jmp @@EndLoadRaw
@@ErrorReadRaw:
  mov ah, 3eh
  int 21h
  pop cx
  mov ax, 2
@@EndLoadRaw:
  pop ds
  pop bp
  ret 10
xCSLoadRAWSound endp

xCSLoadWAVSound proc
  push bp
  push ds
  mov bp, sp
  mov cx, [bp+16]
  mov dx, [bp+14]
  mov ds, cx
  mov ax, 3d00h
  int 21h
  jc  @@ErrorOpeningWav
  mov bx, ax
  mov cx, 44
  mov ax, seg WavHeader
  mov dx, offset WavHeader
  mov ds, ax
  mov ah, 3fh
  int 21h
  jc  @@ErrorReadingWav
  cmp WavHeader.MMFileID, 'FFIR'
  jne @@ErrorBadWav
  cmp WavHeader.WavFileID, 'EVAW'
  jne @@ErrorBadWav
  cmp WavHeader.SoundFormat, 1
  jne @@ErrorBadWav
  cmp WavHeader.NumberOfChannels, 1
  jne @@ErrorBadWav
  cmp WavHeader.BitsPerSample, 8
  jne @@ErrorBadWav
  mov ecx, WavHeader.DataLenght
  mov ax, [bp+12]
  and ecx, 0ffffh
  mov dx, [bp+08]
  mov ds, ax
  mov ah, 3fh
  int 21h
  jc  @@ErrorReadingWav
  mov ah, 3eh
  int 21h
  mov ax, seg WavHeader
  mov ds, ax
  in  al, 08h
  mov eax, WavHeader.DataLenght
  xor dx, dx
  pop ds
  pop bp
  ret 10
@@ErrorOpeningWav:
  mov ax, 1
  pop ds
  pop bp
  ret 10
@@ErrorReadingWav:
  mov ah, 3eh
  int 21h
  mov ax, 2
  pop ds
  pop bp
  ret 10
@@ErrorBadWav:
  mov ah, 3eh
  int 21h
  mov ax, 3
  pop ds
  pop bp
  ret 10
xCSLoadWAVSound endp

CSSoundDone proc
  mov al, SoundFlag
  or  al, al
  jz  @@NoSoundPlaying
  in  al, 08h
  shr al, 1
  and al, 1
  jnz @@TransferDone
  mov ax, 1
  ret
@@TransferDone:
  xor ax, ax
  mov SoundFlag, al
  ret
@@NoSoundPlaying:
  in  al, 08h
  xor ax, ax
  ret
CSSoundDone endp

WriteDSP PROC far
  push cx
  xor cx, cx
  mov dx, BlasterStatus
@@WaitToWriteDSP:
  dec cx
  jz  @@EndWaitToWrite
  in  al, dx
  or  al, al
  js  @@WaitToWriteDSP
@@EndWaitToWrite:
  mov dx, BlasterWrite
  mov al, ah
  out dx, al
  pop cx
  ret
WriteDSP endp

ReadDSP PROC far
  push cx
  xor cx, cx
  mov dx, BlasterData
@@WaitToReadDSP:
  dec cx
  jz  @@EndWaitToRead
  in  al, dx
  or  al, al
  jns @@WaitToReadDSP
@@EndWaitToRead:
  mov dx, BlasterRead
  in  al, dx
  mov ah, al
  pop cx
  ret
ReadDSP endp

WaitRetrace proc
  push ax
  push dx
  mov dx, 03dah
@@Wait1:
  in  al, dx
  and al, 08h
  jnz @@Wait1
@@Wait2:
  in  al, dx
  and al, 08h
  jz  @@Wait2
  pop dx
  pop ax
  ret
WaitRetrace endp

END
