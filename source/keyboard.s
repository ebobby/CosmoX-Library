;----------------------------------------------------------------------------
;
;  CosmoX KEYBOARD Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

.data

align 2

KeyBuffer           db  128 dup (0)     ;  Key Status
OldInt9Address      dd  ?               ;  BIOS IRQ keyboard handler address
KeyActive           db  0               ;  It's the keyboard handler active?

KeyMap      db 01Bh,031h,032h,033h,034h,035h,036h,037h,038h,039h,030h,02Dh,03Dh,008h,008h,071h,077h,065h,072h,074h,079h,075h,069h,06Fh,070h,05Bh,05Dh,00Dh,000h,061h,073h,064h
            db 066h,067h,068h,06Ah,06Bh,06Ch,03Bh,027h,060h,000h,05Ch,07Ah,078h,063h,076h,062h,06Eh,06Dh,02Ch,02Eh,02Fh,000h,02Ah,000h,020h,000h,000h,000h,000h,000h,000h,000h
            db 000h,000h,000h,000h,000h,000h,037h,038h,039h,02Dh,034h,035h,036h,02Bh,031h,032h,033h,030h,02Eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
            db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
            db 01Bh,021h,040h,023h,024h,025h,05Eh,026h,02Ah,028h,029h,05Fh,03Dh,008h,008h,051h,057h,045h,052h,054h,059h,055h,049h,04Fh,050h,07Bh,07Dh,00Dh,000h,041h,053h,044h
            db 046h,047h,048h,04Ah,04Bh,04Ch,03Ah,063h,07Eh,000h,07Ch,05Ah,058h,043h,056h,042h,04Eh,04Dh,03Ch,03Eh,03Fh,000h,000h,000h,020h,000h,000h,000h,000h,000h,000h,000h
            db 000h,000h,000h,000h,000h,000h,000h,000h,000h,02Dh,000h,035h,000h,02Bh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
            db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

.code

public  CSInstallKeyBoard, CSKey, CSRemoveKeyboard, CSWaitKey, CSReadKey
public  CSLockKeys, CSAsc, CSCheckKeys

CSInstallKeyBoard PROC
  mov dl, KeyActive
  or  dl, dl
  jnz @@EndKeyInstall
  xor dx, dx
  mov es, dx
  cli
  mov eax, es:[24h]
  mov OldInt9Address, eax
  mov ax, offset KeyBoardHandler
  mov dx, seg KeyBoardHandler
  mov es:[24h], ax
  mov es:[26h], dx
  sti
  mov KeyActive, 1
@@EndKeyInstall:
  ret
KeyBoardHandler:
  push ax
  push cx
  push ds
  push si
  mov cl, 1
  in  al, 60h
  test al, 80h
  jz  @@StoreKey
  and al, 7fh
  xor cl, cl
@@StoreKey:
  xor ah, ah
  mov si, ax
  mov ax, @data
  mov ds, ax
  mov KeyBuffer[si], cl
  in  al, 61h
  or  al, 80h
  out 61h, al
  mov al, 20h
  out 20h, al
  pop si
  pop ds
  pop cx
  pop ax
  iret
CSInstallKeyBoard endp

CSRemoveKeyboard proc
  mov dl, KeyActive
  or  dl, dl
  jz  @@AlreadyRemoved
  xor dx, dx
  mov es, dx
  cli
  mov eax, OldInt9Address
  mov es:[24h], eax
  sti
  xor si, si
  xor ax, ax
@@EmptyKeyBuffer:
  mov KeyBuffer[si], al
  inc si
  cmp si, 128
  jl  @@EmptyKeyBuffer
  mov KeyActive, al
@@AlreadyRemoved:
  ret
CSRemoveKeyboard endp

CSKey proc
  mov bx, bp
  mov bp, sp
  mov dl, KeyActive
  or  dl, dl
  jz  @@NoKeyBoard
  xor ah, ah
  mov si, [bp+04]
  mov al, KeyBuffer[SI]
  mov bp, bx
  ret 2
@@NoKeyBoard:
  mov ax, 0ffffh
  mov bp, bx
  ret 2
CSKey endp

CSWaitKey proc
  mov bx, bp
  mov bp, sp
  mov ax, 0ffffh
  mov dl, KeyActive
  or  dl, dl
  jz  @@NoWait
  mov si, [bp+04]
  cmp si, 0ffffh
  je  @@WaitAnyKey
@@WaitKey:
  cmp KeyBuffer[si], 1
  je  @@KeyFound
  jmp @@WaitKey
@@WaitAnyKey:
  xor si, si
@@WaitAnyKeyLoop:
  cmp KeyBuffer[si], 1
  je  @@KeyFound
  inc si
  cmp si, 129
  jnz @@WaitAnyKeyLoop
  jmp @@WaitAnyKey
@@KeyFound:
  cmp KeyBuffer[si], 1
  je  @@KeyFound
@@NoWait:
  mov bp, bx
  ret 2
CSWaitKey endp

CSReadKey proc
  mov ax, 0ffffh
  mov dl, KeyActive
  or  dl, dl
  jz  @@NoKeyRead
@@ReadKey:
  xor si, si
@@ReadKeyLoop:
  cmp KeyBuffer[si], 1
  je  @@ReadKeyFound
  inc si
  cmp si, 129
  jnz @@ReadKeyLoop
  jmp @@ReadKey
@@ReadKeyFound:
  cmp KeyBuffer[si], 1
  je  @@ReadKeyFound
  mov ax, si
@@NoKeyRead:
  ret
CSReadKey endp

CSCheckKeys proc
  mov ax, 0ffffh
  mov dl, KeyActive
  or  dl, dl
  jz  @@NoKeyCheck
  xor si, si
@@CheckKeyLoop:
  cmp KeyBuffer[si], 1
  je  @@CheckKeyFound
  inc si
  cmp si, 129
  jnz @@CheckKeyLoop
  xor ax, ax
  jmp @@NoKeyCheck
@@CheckKeyFound:
  cmp KeyBuffer[si], 1
  je  @@CheckKeyFound
  mov ax, si
@@NoKeyCheck:
  ret
CSCheckKeys endp

CSLockKeys proc
  push bp
  mov bp, sp
  mov ax, 0040h
  mov es, ax
  mov di, 0017h
  mov al, [bp+08]
  cmp al, 2
  je  @@ScrollKey
  cmp al, 1
  je  @@CapsKey
  mov al, [bp+06]
  and al, 01h
  cmp al, 0
  je  @@TurnOffNum
  mov al, 20h
  or  es:[di], al
  jmp @@EndLockKeys
@@TurnOffNum:
  mov al, 20h
  xor al, 0ffh
  and es:[di], al
  jmp @@EndLockKeys
@@CapsKey:
  mov al, [bp+06]
  and al, 01h
  cmp al, 0
  je  @@TurnOffCaps
  mov al, 40h
  or  es:[di], al
  jmp @@EndLockKeys
@@TurnOffCaps:
  mov al, 40h
  xor al, 0ffh
  and es:[di], al
  jmp @@EndLockKeys
@@ScrollKey:
  mov al, [bp+06]
  and al, 01h
  cmp al, 0
  je  @@TurnOffScroll
  mov al, 10h
  or  es:[di], al
  jmp @@EndLockKeys
@@TurnOffScroll:
  mov al, 10h
  xor al, 0ffh
  and es:[di], al
@@EndLockKeys:
  pop bp
  ret 4
CSLockKeys endp

CSAsc proc
  push bp
  mov bp, sp
  xor si, si
  mov bx, [bp+08]
  mov ax, [bp+06]
  and ax, 1
  or  ax, ax
  jz  @@NotShift
  mov si, 128
@@NotShift:
  xor ah, ah
  dec bx
  add si, bx
  mov al, KeyMap[SI]
  pop bp
  ret 4
CSAsc endp

end
