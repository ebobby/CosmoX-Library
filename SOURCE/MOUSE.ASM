;----------------------------------------------------------------------------
;
;  CosmoX MOUSE Handling Module
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

MouseX              dw  0               ;  Current mouse x coordinate
MouseY              dw  0               ;  Current mouse y coordinate
MouseB              db  0               ;  Current mouse buttons status
MouseDetected       db  0               ;  Has the mouse been detected?
MouseOn             db  0               ;  Is the mouse cursor visible?
MouseShape          db  0FFh,03Fh,0FFh,01Fh,0FFh,00Fh,0FFh,007h
                    db  0FFh,003h,0FFh,001h,0FFh,000h,07Fh,000h
                    db  03Fh,000h,07Fh,000h,0FFh,00Fh,0FFh,0BFh
                    db  0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
                    db  000h,000h,000h,040h,000h,060h,000h,070h
                    db  000h,078h,000h,07Ch,000h,07Eh,000h,07Fh
                    db  080h,07Fh,000h,070h,000h,040h,000h,000h
                    db  000h,000h,000h,000h,000h,000h,000h,000h

.code

public  CSDetectMouse, CSMouseX, CSMouseY, CSMouseLB, CSMouseRB, CSMouseOn
public  CSMouseOff, CSSetMouseXY, CSSetMouseRange, CSSetMouseSpeed
public  xCSSetMouseCursor, CSResetMouse, CSMouseClickOn, CSMouseOver

CSDetectMouse proc
  xor ax, ax
  int 33h
  or  ax, ax
  jnz @@InstallMouse
  ret
@@InstallMouse:
  mov ax, seg MouseHandler
  mov es, ax
  mov dx, offset MouseHandler
  mov cx, 31
  mov ax, 0ch
  int 33h
  mov ax, 1
  mov MouseDetected, al
  ret
MouseHandler:
  push ds
  mov ax, @data
  mov ds, ax
  mov MouseX, cx
  mov MouseY, dx
  mov MouseB, bl
  pop ds
  ret
CSDetectMouse endp

CSMouseX proc
  mov ax, MouseX
  shr ax, 1
  ret
CSMouseX endp

CSMouseY proc
  mov ax, MouseY
  ret
CSMouseY endp

CSMouseLB proc
  xor ah, ah
  mov al, MouseB
  and al, 1
  ret
CSMouseLB endp

CSMouseRB proc
  xor ah, ah
  mov al, MouseB
  and al, 2
  shr ax, 1
  ret
CSMouseRB endp

CSMouseOn proc
  mov bl, MouseOn
  or  bl, bl
  jnz @@EndMouseOn
  mov ax, 1
  int 33h
  mov MouseOn, 1
@@EndMouseOn:
  ret
CSMouseOn endp

CSMouseOff proc
  mov bl, MouseOn
  or  bl, bl
  jz  @@EndMouseOff
  mov ax, 2
  int 33h
  mov MouseOn, 0
@@EndMouseOff:
  ret
CSMouseOff endp

CSSetMouseXY proc
  push bp
  mov bp, sp
  mov cx, [bp+08]
  shl cx, 1
  mov MouseX, cx
  mov dx, [bp+06]
  mov MouseY, dx
  mov ax, 4
  int 33h
  pop bp
  ret 4
CSSetMouseXY endp

CSSetMouseRange proc
  push bp
  mov bp, sp
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOff
  mov ax, 2
  int 33h
@@SkipOff:
  mov cx, [bp+12]
  shl cx, 1
  mov dx, [bp+08]
  shl dx, 1
  mov ax, 7
  int 33h
  mov cx, [bp+10]
  mov dx, [bp+06]
  mov ax, 8
  int 33h
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOn
  mov ax, 1
  int 33h
@@SkipOn:
  pop bp
  ret 8
CSSetMouseRange endp

CSSetMouseSpeed proc
  push bp
  mov bp, sp
  mov dx, [bp+06]
  mov cx, [bp+08]
  shl cx, 1
  mov ax, 0fh
  int 33h
  pop bp
  ret 4
CSSetMouseSpeed endp

xCSSetMouseCursor proc
  push bp
  mov bp, sp
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOff1
  mov ax, 2
  int 33h
@@SkipOff1:
  mov bx, [bp+12]
  mov cx, [bp+10]
  mov es, [bp+08]
  mov dx, [bp+06]
  mov ax, 9
  int 33h
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOn1
  mov ax, 1
  int 33h
@@SkipOn1:
  pop bp
  ret 8
xCSSetMouseCursor endp

CSResetMouse proc
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOff2
  mov ax, 2
  int 33h
@@SkipOff2:
  xor cx, cx
  mov dx, 639
  mov ax, 7
  int 33h
  xor cx, cx
  mov dx, 199
  mov ax, 8
  int 33h
  xor cx, cx
  xor bx, bx
  mov ax, seg MouseShape
  mov es, ax
  mov dx, offset MouseShape
  mov ax, 9
  int 33h
  mov cx, 8
  mov dx, 16
  mov ax, 0fh
  int 33h
  mov bl, MouseOn
  or  bl, bl
  jz  @@SkipOn2
  mov ax, 1
  int 33h
@@SkipOn2:
  ret
CSResetMouse endp

CSMouseClickOn proc
  push bp
  mov bp, sp
  xor ax, ax
  mov bx, MouseX
  shr bx, 1
  mov cx, MouseY
  cmp bx, [bp+12]
  jl  @@ClickOut
  cmp cx, [bp+10]
  jl  @@ClickOut
  cmp bx, [bp+08]
  jg  @@ClickOut
  cmp cx, [bp+06]
  jg  @@ClickOut
  mov al, MouseB
@@ClickOut:
  pop bp
  ret 8
CSMouseClickOn endp

CSMouseOver proc
  push bp
  mov bp, sp
  xor ax, ax
  mov bx, MouseX
  shr bx, 1
  mov cx, MouseY
  cmp bx, [bp+12]
  jl  @@MoveOut
  cmp cx, [bp+10]
  jl  @@MoveOut
  cmp bx, [bp+08]
  jg  @@MoveOut
  cmp cx, [bp+06]
  jg  @@MoveOut
  mov ax, 1
@@MoveOut:
  pop bp
  ret 8
CSMouseOver endp

end
