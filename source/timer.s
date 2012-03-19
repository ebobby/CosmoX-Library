;----------------------------------------------------------------------------
;
;  CosmoX TIMER Module
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

TIMERS              equ 16              ; # of timers (modify to change the
                                        ; total number of them (def. 16)

ElapsedTicks        dd  0               ; Used to count the ticks and call BIOS
TimerCount          dd  0174eh          ; Divisor of PIT count (1234DDh / 200)
OldInt8Address      dd  ?               ; BIOS IRQ timer handler address
UserTimerTicks      dd  TIMERS dup(0)   ; User timer elapsed ticks
UserTimer           dd  TIMERS dup(-1)  ; User timers frequency (in mlsecs)
UserTimerCount      dd  TIMERS dup(0)   ; User timers counters
UserTimerFlag       dd  TIMERS dup(0)   ; User timers flags
TimerInstalled      db  0               ; Is the timer installed ?

.code

public  CSInstallTimer, CSRemoveTimer, CSSetTimer, CSTimerFlag, CSElapsedTicks
public  CSResetTicks, CSWaitTimer

CSInstallTimer proc
  mov dl, TimerInstalled
  or  dl, dl
  jnz @@DontInstall
  xor dx, dx
  mov es, dx
  cli
  mov edx, es:[20h]
  mov OldInt8Address, edx
  mov ax, offset TimerISR
  mov dx, seg TimerISR
  mov es:[20h], ax
  mov es:[22h], dx
  sti
  mov al, 1
  mov TimerInstalled, al
  xor ebx, ebx
  mov ElapsedTicks, ebx
  mov edx, TimerCount
  mov al, 034h
  out 043h, al
  mov al, dl
  out 040h, al
  mov al, dh
  out 040h, al
@@DontInstall:
  ret
TimerISR:
  push ds
  pushad
  mov ax, @data
  mov ds, ax
  xor si, si
@@UpdateTimers:
  mov bx, si
  shl bx, 2
  mov edx, UserTimer[bx]
  cmp edx, -1
  je  @@NoUserTimer
  mov eax, UserTimerCount[bx]
  add eax, 5
  mov UserTimerCount[bx], eax
  cmp eax, edx
  jb  @@NoUserTimer
  sub eax, edx
  mov ecx, 1
  mov UserTimerCount[bx], eax
  mov UserTimerFlag[bx], ecx
  inc UserTimerTicks[bx]
@@NoUserTimer:
  inc si
  cmp si, TIMERS
  jne @@UpdateTimers
  mov eax, ElapsedTicks
  add eax, TimerCount
  mov ElapsedTicks, eax
  cmp eax, 10000h
  jl  @@TimerAcknowledge
  sub eax, 10000h
  mov ElapsedTicks, eax
  pushf
  call [OldInt8Address]
  jmp @@TimerFinish
@@TimerAcknowledge:
  mov al, 020h
  out 020h, al
@@TimerFinish:
  popad
  pop ds
  iret
CSInstallTimer endp

CSRemoveTimer proc
  mov al, TimerInstalled
  or  al, al
  jz  @@AlreadyRemoved
  xor dx, dx
  mov es, dx
  cli
  mov eax, OldInt8Address
  mov es:[20h], eax
  sti
  mov al, 034h
  out 043h, al
  xor eax, eax
  out 040h, al
  out 040h, al
  xor eax, eax
  mov TimerInstalled, al
  mov ecx, -1
  xor si, si
@@ResetFlags:
  mov bx, si
  shl bx, 2
  mov UserTimer[bx], ecx
  mov UserTimerFlag[bx], eax
  mov UserTimerTicks[bx], eax
  inc si
  cmp si, TIMERS
  jne @@ResetFlags
@@AlreadyRemoved:
  ret
CSRemoveTimer endp

CSSetTimer proc
  push bp
  mov bp, sp
  mov dl, TimerInstalled
  or  dl, dl
  jz  @@EndSetTimer
  mov bx, [bp+10]
  cmp bx, TIMERS
  jae @@EndSetTimer
  shl bx, 2
  xor eax, eax
  mov edx, [bp+06]
  mov UserTimer[bx], edx
  mov UserTimerCount[bx], eax
  mov UserTimerFlag[bx], eax
  mov UserTimerTicks[bx], eax
@@EndSetTimer:
  pop bp
  ret 6
CSSetTimer endp

CSTimerFlag proc
  push bp
  mov bp, sp
  xor ax, ax
  mov dl, TimerInstalled
  or  dl, dl
  jz  @@EndTimerFlag
  mov bx, [bp+06]
  cmp bx, TIMERS
  jae @@EndTimerFlag
  shl bx, 2
  mov eax, UserTimer[bx]
  cmp eax, -1
  je  @@EndTimerFlag
  mov eax, UserTimerFlag[bx]
  or  eax, eax
  jz  @@EndTimerFlag
  xor edx, edx
  mov UserTimerFlag[bx], edx
  mov ax, 1
@@EndTimerFlag:
  pop bp
  ret 2
CSTimerFlag endp

CSElapsedTicks proc
  push bp
  mov bp, sp
  xor ax, ax
  xor dx, dx
  mov cl, TimerInstalled
  or  cl, cl
  jz  @@EndElapsedTicks
  mov bx, [bp+06]
  cmp bx, TIMERS
  jae @@EndElapsedTicks
  shl bx, 2
  mov eax, UserTimerTicks[bx]
  mov edx, eax
  shr edx, 16
@@EndElapsedTicks:
  pop bp
  ret 2
CSElapsedTicks endp

CSResetTicks proc
  push bp
  mov bp, sp
  mov dl, TimerInstalled
  or  dl, dl
  jz  @@EndResetTicks
  mov bx, [bp+06]
  cmp bx, TIMERS
  jae @@EndResetTicks
  shl bx, 2
  xor eax, eax
  mov UserTimerTicks[bx], eax
@@EndResetTicks:
  pop bp
  ret 2
CSResetTicks endp

CSWaitTimer proc
  push bp
  mov bp, sp
  mov dl, TimerInstalled
  or  dl, dl
  jz  @@EndWait
  mov bx, [bp+06]
  cmp bx, TIMERS
  jae @@EndWait
  shl bx, 2
  mov edx, UserTimer[bx]
  cmp edx, -1
  je  @@EndWait
@@WaitLoop:
  mov eax, UserTimerFlag[bx]
  or  eax, eax
  jz  @@WaitLoop
  xor eax, eax
  mov UserTimerFlag[bx], eax
@@EndWait:
  pop bp
  ret 2
CSWaitTimer endp

end
