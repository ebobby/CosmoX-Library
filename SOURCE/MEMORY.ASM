;----------------------------------------------------------------------------
;
;  CosmoX MEMORY Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

.code

public  CSPoke, CSPeek, CSPoke16, CSPeek16, CSPoke32, CSPeek32, CSMemCopy
public  CSMemSwap

CSPoke proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+10]
  mov di, [bp+06]
  mov es, ax
  mov ax, [bp+04]
  mov es:[di], al
  mov bp, bx
  ret 8
CSPoke endp

CSPeek proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+08]
  mov es, ax
  mov di, [bp+04]
  mov al, es:[di]
  xor ah, ah
  mov bp, bx
  ret 6
CSPeek endp

CSPoke16 proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+10]
  mov di, [bp+06]
  mov es, ax
  mov ax, [bp+04]
  mov es:[di], ax
  mov bp, bx
  ret 8
CSPoke16 endp

CSPeek16 proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+08]
  mov es, ax
  mov di, [bp+04]
  mov ax, es:[di]
  mov bp, bx
  ret 6
CSPeek16 endp

CSPoke32 proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+12]
  mov es, ax
  mov di, [bp+08]
  mov eax, [bp+04]
  mov es:[di], eax
  mov bp, bx
  ret 10
CSPoke32 endp

CSPeek32 proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+08]
  mov es, ax
  mov di, [bp+04]
  mov ax, es:[di]
  mov dx, es:[di+2]
  mov bp, bx
  ret 6
CSPeek32 endp

CSMemCopy proc
  mov bx, bp
  mov dx, ds
  mov bp, sp
  mov ax, [bp+18]
  mov ds, ax
  mov si, [bp+14]
  mov ax, [bp+12]
  mov es, ax
  mov di, [bp+08]
  mov cx, [bp+04]
  test cx, 3
  jz  @@DWordMemCopy
  test cx, 1
  jz  @@WordMemCopy
  shr cx, 1
  rep movsw
  adc cx, cx
  rep movsb
  jmp @@EndMemCopy
@@DWordMemCopy:
  shr cx, 2
  rep movsd
  jmp @@EndMemCopy
@@WordMemCopy:
  shr cx, 1
  rep movsw
@@EndMemCopy:
  mov ds, dx
  mov bp, bx
  ret 16
CSMemCopy endp

CSMemSwap proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov ds, ax
  mov ax, [bp+16]
  mov es, ax
  mov si, [bp+18]
  mov di, [bp+12]
  mov cx, [bp+08]
  test cx, 3
  jz  @@DWordMemSwap
  test cx, 1
  jz  @@WordMemSwap
@@ByteMemSwap:
  shr cx, 1
  jnc @@ByteMemSwapW
  mov ah, [si]
  mov al, es:[di]
  mov [si], al
  mov es:[di], ah
  inc si
  inc di
@@ByteMemSwapW:
  mov ax, [si]
  mov bx, es:[di]
  mov [si], bx
  mov es:[di], ax
  add si, 2
  add di, 2
  dec cx
  jnz @@ByteMemSwapW
  jmp @@EndMemSwap
@@DWordMemSwap:
  shr cx, 2
@@DWordMemSwapLoop:
  mov eax, [si]
  mov ebx, es:[di]
  mov [si], ebx
  mov es:[di], eax
  add si, 4
  add di, 4
  dec cx
  jnz @@DWordMemSwapLoop
  jmp @@EndMemSwap
@@WordMemSwap:
  shr cx, 1
@@WordMemSwapLoop:
  mov ax, [si]
  mov bx, es:[di]
  mov [si], bx
  mov es:[di], ax
  add si, 2
  add di, 2
  dec cx
  jnz @@WordMemSwapLoop
@@EndMemSwap:
  pop ds
  pop bp
  ret 16
CSMemSwap endp

end
