;----------------------------------------------------------------------------
;
;  CosmoX PALETTE Handling Module
;
;  Part of the CosmoX Library v2.0
;  by bobby - CosmoSoft 2000-2001
;
;----------------------------------------------------------------------------

 p386
.model use16 medium, basic
.stack 200h

locals @@

CosmoXPaletteFile struc
    PaletteFileTitle  db  'CosmoX Palette File '
    LibVersion        db  'CosmoX Library v2.0 '
CosmoXPaletteFile ends

.data

align 2

PalLoad             CosmoXPaletteFile <>
PalHeader           CosmoXPaletteFile <>
BlueHues            db  ?               ;  Used by Palette functions
GreenHues           db  ?               ;  Used by Palette functions
RedHues             db  ?               ;  Used by Palette functions

.CODE

public  CSSetCol, CSGetCol, xCSGetPal, xCSSetPal, CSBlackPal, CSNegativePal
public  CSGrayPal, xCSFadeIn, xCSFadeInStep, CSFadeTo, CSFadeToStep, CSFindCol
public  CSRotatePalB, CSRotatePalF, xCSSavePal, xCSLoadPal, CSWaitRetrace

CSSetCol proc
  mov bx, bp
  mov bp, sp
  mov dx, 03c8h
  mov ax, [bp+10]
  out dx, al
  inc dx
  mov al, [bp+08]
  out dx, al
  mov al, [bp+06]
  out dx, al
  mov al, [bp+04]
  out dx, al
  mov bp, bx
  ret 8
CSSetCol endp

CSGetCol proc
  mov di, bp
  mov bp, sp
  mov dx, 03c7h
  mov al, [bp+10]
  out dx, al
  xor ax, ax
  mov dx, 03c9h
  mov bx, [bp+08]
  in  al, dx
  mov [bx], ax
  mov bx, [bp+06]
  in  al, dx
  mov [bx], ax
  mov bx, [bp+04]
  in  al, dx
  mov [bx], ax
  mov bp, di
  ret 8
CSGetCol endp

xCSGetPal proc
  mov bx, bp
  mov bp, sp
  mov ax, [bp+06]
  mov es, ax
  mov di, [bp+04]
  mov dx, 03c7h
  xor ax, ax
  out dx, al
  add dx, 2
  mov cx, 768
@@GetPalLoop:
  insb
  dec cx
  jnz @@GetPalLoop
  mov bp, bx
  ret 4
xCSGetPal endp

xCSSetPal proc
  mov bx, bp
  mov di, ds
  mov bp, sp
  mov ax, [bp+06]
  mov ds, ax
  mov si, [bp+04]
  xor ax, ax
  mov dx, 03c8h
  out dx, al
  inc dx
  mov cx, 768
@@SetPalLoop:
  outsb
  dec cx
  jnz @@SetPalLoop
  mov ds, di
  mov bp, bx
  ret 4
xCSSetPal endp

CSBlackPal proc
  push bp
  mov bp, sp
  mov ax, [bp+12]
  inc ax
  mov [bp+12], ax
  mov ah, [bp+10]
  mov bh, [bp+08]
  mov bl, [bp+06]
  mov cx, [bp+14]
@@BlackPalLoop:
  mov dx, 03c8h
  mov al, cl
  out dx, al
  inc dx
  mov al, ah
  out dx, al
  mov al, bh
  out dx, al
  mov al, bl
  out dx, al
  inc cx
  cmp cx, [bp+12]
  jl  @@BlackPalLoop
  pop bp
  ret 10
CSBlackPal endp

CSNegativePal proc
  push bp
  mov bp, sp
  mov ax, [bp+06]
  inc ax
  mov [bp+06], ax
  mov cx, [bp+08]
@@NegatePalLoop:
  mov dx, 03c7h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ah, al
  mov dx, 03c8h
  mov al, cl
  out dx, al
  mov dl, 63
  sub dl, bh
  mov bh, dl
  mov dl, 63
  sub dl, bl
  mov bl, dl
  mov dl, 63
  sub dl, ah
  mov ah, dl
  mov dx, 03c9h
  mov al, bh
  out dx, al
  mov al, bl
  out dx, al
  mov al, ah
  out dx, al
  inc cx
  cmp cx, [bp+06]
  jl  @@NegatePalLoop
  pop bp
  ret 4
CSNegativePal endp

CSGrayPal proc
  push bp
  mov bp, sp
  mov ax, [bp+06]
  inc ax
  mov [bp+06], ax
  mov cx, [bp+08]
@@GrayPalLoop:
  mov dx, 03c7h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  xor ah, ah
  in  al, dx
  mov bx, ax
  in  al, dx
  mov si, ax
  in  al, dx
  mov di, ax
  mov dx, 03c8h
  mov al, cl
  out dx, al
  mov ax, 11
  mul bx
  mov bx, ax
  mov ax, 59
  mul si
  mov si, ax
  mov ax, 30
  mul di
  add ax, bx
  add ax, si
  mov bx, 100
  div bx
  mov dx, 03c9h
  out dx, al
  out dx, al
  out dx, al
  inc cx
  cmp cx, [bp+06]
  jl  @@GrayPalLoop
  pop bp
  ret 4
CSGrayPal endp

xCSFadeIn proc
  push bp
  mov bp, sp
  mov ax, [bp+08]
  mov es, ax
  mov ax, [bp+10]
  inc ax
  mov [bp+10], ax
  mov cx, [bp+12]
  mov ax, 3
  mul cx
  add [bp+06], ax
  xor si, si
@@FadeToPal:
  call CSWaitRetrace
  mov di, [bp+06]
@@FadeToPalLoop:
  mov dx, 03c7h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ah, al
  mov dx, 03c8h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  mov al, es:[di]
  inc di
  cmp bh, al
  jl  @@IncPalRed
  jg  @@DecPalRed
  out dx, al
@@CheckPalGreen:
  mov al, es:[di]
  inc di
  cmp bl, al
  jl  @@IncPalGreen
  jg  @@DecPalGreen
  out dx, al
@@CheckPalBlue:
  mov al, es:[di]
  inc di
  cmp ah, al
  jl  @@IncPalBlue
  jg  @@DecPalBlue
  out dx, al
  jmp @@CheckPalCounters
@@IncPalRed:
  mov al, bh
  inc al
  out dx, al
  jmp @@CheckPalGreen
@@DecPalRed:
  mov al, bh
  dec al
  out dx, al
  jmp @@CheckPalGreen
@@IncPalGreen:
  mov al, bl
  inc al
  out dx, al
  jmp @@CheckPalBlue
@@DecPalGreen:
  mov al, bl
  dec al
  out dx, al
  jmp @@CheckPalBlue
@@IncPalBlue:
  mov al, ah
  inc al
  out dx, al
  jmp @@CheckPalCounters
@@DecPalBlue:
  mov al, ah
  dec al
  out dx, al
@@CheckPalCounters:
  inc cx
  cmp cx, [bp+10]
  jne @@FadeToPalLoop
  mov cx, [bp+12]
  inc si
  cmp si, 64
  jnz @@FadeToPal
  pop bp
  ret 8
xCSFadeIn endp

xCSFadeInStep proc
  push bp
  mov bp, sp
  mov ax, [bp+08]
  mov es, ax
  mov di, [bp+06]
  mov ax, [bp+10]
  inc ax
  mov [bp+10], ax
  mov cx, [bp+12]
  mov ax, 3
  mul cx
  add di, ax
  call CSWaitRetrace
@@FadeToPalStepLoop:
  mov dx, 03c7h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ah, al
  mov dx, 03c8h
  mov al, cl
  out dx, al
  mov dx, 03c9h
  mov al, es:[di]
  inc di
  cmp bh, al
  jl  @@IncPalStepRed
  jg  @@DecPalStepRed
  out dx, al
@@CheckPalStepGreen:
  mov al, es:[di]
  inc di
  cmp bl, al
  jl  @@IncPalStepGreen
  jg  @@DecPalStepGreen
  out dx, al
@@CheckPalStepBlue:
  mov al, es:[di]
  inc di
  cmp ah, al
  jl  @@IncPalStepBlue
  jg  @@DecPalStepBlue
  out dx, al
  jmp @@CheckPalStepCounters
@@IncPalStepRed:
  inc bh
  mov al, bh
  out dx, al
  jmp @@CheckPalStepGreen
@@DecPalStepRed:
  dec bh
  mov al, bh
  out dx, al
  jmp @@CheckPalStepGreen
@@IncPalStepGreen:
  inc bl
  mov al, bl
  out dx, al
  jmp @@CheckPalStepBlue
@@DecPalStepGreen:
  dec bl
  mov al, bl
  out dx, al
  jmp @@CheckPalStepBlue
@@IncPalStepBlue:
  inc ah
  mov al, ah
  out dx, al
  jmp @@CheckPalStepCounters
@@DecPalStepBlue:
  dec ah
  mov al, ah
  out dx, al
@@CheckPalStepCounters:
  inc cx
  cmp cx, [bp+10]
  jl  @@FadeToPalStepLoop
  pop bp
  ret 8
xCSFadeInStep endp

CSFadeTo proc
  push bp
  mov bp, sp
  mov ax, [bp+12]
  inc ax
  mov [bp+12], ax
  mov di, [bp+14]
  xor si, si
  call CSWaitRetrace
@@FadeToColLoop:
  mov dx, 03c7h
  mov ax, di
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ch, al
  mov dx, 03c8h
  mov ax, di
  out dx, al
  mov dx, 03c9h
  mov ax, [bp+10]
  cmp bh, al
  jl  @@IncColRed
  jg  @@DecColRed
  out dx, al
@@CheckColGreen:
  mov ax, [bp+08]
  cmp bl, al
  jl  @@IncColGreen
  jg  @@DecColGreen
  out dx, al
@@CheckColBlue:
  mov ax, [bp+06]
  cmp ch, al
  jl  @@IncColBlue
  jg  @@DecColBlue
  out dx, al
  jmp @@CheckColCounters
@@IncColRed:
  inc bh
  mov al, bh
  out dx, al
  jmp @@CheckColGreen
@@DecColRed:
  dec bh
  mov al, bh
  out dx, al
  jmp @@CheckColGreen
@@IncColGreen:
  inc bl
  mov al, bl
  out dx, al
  jmp @@CheckColBlue
@@DecColGreen:
  dec bl
  mov al, bl
  out dx, al
  jmp @@CheckColBlue
@@IncColBlue:
  inc ch
  mov al, ch
  out dx, al
  jmp @@CheckColCounters
@@DecColBlue:
  dec ch
  mov al, ch
  out dx, al
@@CheckColCounters:
  inc di
  cmp di, [bp+12]
  jne @@FadeToColLoop
  call CSWaitRetrace
  mov di, [bp+14]
  inc si
  cmp si, 64
  jnz @@FadeToColLoop
  pop bp
  ret 10
CSFadeTo endp

CSFadeToStep proc
  push bp
  mov bp, sp
  mov ax, [bp+12]
  inc ax
  mov [bp+12], ax
  mov di, [bp+14]
  call CSWaitRetrace
@@FadeToColStepLoop:
  mov dx, 03c7h
  mov ax, di
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ch, al
  mov dx, 03c8h
  mov ax, di
  out dx, al
  mov dx, 03c9h
  mov ax, [bp+10]
  cmp bh, al
  jl  @@IncColStepRed
  jg  @@DecColStepRed
  out dx, al
@@CheckColStepGreen:
  mov ax, [bp+08]
  cmp bl, al
  jl  @@IncColStepGreen
  jg  @@DecColStepGreen
  out dx, al
@@CheckColStepBlue:
  mov ax, [bp+06]
  cmp ch, al
  jl  @@IncColStepBlue
  jg  @@DecColStepBlue
  out dx, al
  jmp @@CheckColStepCounters
@@IncColStepRed:
  inc bh
  mov al, bh
  out dx, al
  jmp @@CheckColStepGreen
@@DecColStepRed:
  dec bh
  mov al, bh
  out dx, al
  jmp @@CheckColStepGreen
@@IncColStepGreen:
  inc bl
  mov al, bl
  out dx, al
  jmp @@CheckColStepBlue
@@DecColStepGreen:
  dec bl
  mov al, bl
  out dx, al
  jmp @@CheckColStepBlue
@@IncColStepBlue:
  inc ch
  mov al, ch
  out dx, al
  jmp @@CheckColStepCounters
@@DecColStepBlue:
  dec ch
  mov al, ch
  out dx, al
@@CheckColStepCounters:
  inc di
  cmp di, [bp+12]
  jne @@FadeToColStepLoop
  pop bp
  ret 10
CSFadeToStep endp

CSFindCol proc
  push bp
  mov bp, sp
  xor ax, ax
  mov di, 11907
  xor cx, cx
  mov dx, 3c7h
  out dx, al
  mov dx, 3c9h
@@FindColLoop:
  mov dx, 3c9h
  in  al, dx
  mov RedHues, al
  in  al, dx
  mov GreenHues, al
  in  al, dx
  mov BlueHues, al
  mov ax, [bp+10]
  sub al, RedHues
  mov RedHues, al
  mov bx, [bp+08]
  sub bl, GreenHues
  MOV GreenHues, bl
  mov ax, [bp+06]
  sub al, BlueHues
  mov BlueHues, al
  xor si, si
  xor ax, ax
  mov al, RedHues
  mov bx, ax
  xor dx, dx
  imul bx
  add si, ax
  xor ax, ax
  mov al, GreenHues
  mov bx, ax
  xor dx, dx
  imul bx
  add si, ax
  xor ax, ax
  mov al, BlueHues
  mov bx, ax
  xor dx, dx
  imul bx
  add si, ax
  cmp si, di
  jge @@SecondCheck
  mov di, si
@@SecondCheck:
  cmp si, 0
  je  @@EndFindCol
  xor ax, ax
  mov dx, 3c9h
  inc cx
  cmp cx, 256
  jnz @@FindColLoop
@@EndFindCol:
  cmp cx, 256
  jne @@ColFinded
  mov cx, 0ffffh
@@ColFinded:
  mov ax, cx
  pop bp
  ret 6
CSFindCol endp

CSRotatePalB proc
  push bp
  mov bp, sp
  mov ax, [bp+08]
  mov dx, 03c7h
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov RedHues, al
  in  al, dx
  mov GreenHues, al
  in  al, dx
  mov BlueHues, al
  mov si, [bp+08]
@@RotateBLoop:
  mov ax, si
  inc al
  mov dx, 03c7h
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ch, al
  mov ax, si
  mov dx, 03c8h
  out dx, al
  mov dx, 03c9h
  mov al, bh
  out dx, al
  mov al, bl
  out dx, al
  mov al, ch
  out dx, al
  inc si
  cmp si, [bp+06]
  jl  @@RotateBLoop
  mov ax, [bp+06]
  mov dx, 03c8h
  out dx, al
  mov dx, 03c9h
  mov al, RedHues
  out dx, al
  mov al, GreenHues
  out dx, al
  mov al, BlueHues
  out dx, al
@@EndRotateB:
  pop bp
  ret 4
CSRotatePalB endp

CSRotatePalF proc
  push bp
  mov bp, sp
  mov ax, [bp+06]
  mov dx, 03c7h
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov RedHues, al
  in  al, dx
  mov GreenHues, al
  in  al, dx
  mov BlueHues, al
  mov si, [bp+06]
@@RotateFLoop:
  mov ax, si
  dec al
  mov dx, 03c7h
  out dx, al
  mov dx, 03c9h
  in  al, dx
  mov bh, al
  in  al, dx
  mov bl, al
  in  al, dx
  mov ch, al
  mov ax, si
  mov dx, 03c8h
  out dx, al
  mov dx, 03c9h
  mov al, bh
  out dx, al
  mov al, bl
  out dx, al
  mov al, ch
  out dx, al
  dec si
  cmp si, [bp+08]
  ja  @@RotateFLoop
  mov ax, [bp+08]
  mov dx, 03c8h
  out dx, al
  mov dx, 03c9h
  mov al, RedHues
  out dx, al
  mov al, GreenHues
  out dx, al
  mov al, BlueHues
  out dx, al
@@EndRotateF:
  pop bp
  ret 4
CSRotatePalF endp

xCSSavePal proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+10]
  mov ds, ax
  mov dx, [bp+08]
  xor cx, cx
  mov ah, 3ch
  int 21h
  jc  @@ErrorOpenPal
  mov bx, ax
  mov ax, seg PalHeader
  mov ds, ax
  mov dx, offset PalHeader
  mov cx, 40
  mov ah, 40h
  int 21h
  jc  @@ErrorSavePal
  mov ax, [bp+14]
  mov ds, ax
  mov dx, [bp+12]
  mov cx, 768
  mov ah, 40h
  int 21h
  jc  @@ErrorSavePal
  mov ah, 3eh
  int 21h
  xor ax, ax
  jmp @@EndSavePal
@@ErrorOpenPal:
  mov ax, 1
  jmp @@EndSavePal
@@ErrorSavePal:
  mov ah, 3eh
  int 21h
  mov ax, 2
@@EndSavePal:
  pop ds
  pop bp
  ret 8
xCSSavePal endp

xCSLoadPal proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+10]
  mov ds, ax
  mov dx, [bp+08]
  xor cx, cx
  xor ax, ax
  mov ah, 3dh
  int 21h
  jc  @@ErrorOpenLPal
  mov bx, ax
  mov ax, seg PalLoad
  mov ds, ax
  mov dx, offset PalLoad
  mov cx, 40
  mov ah, 3fh
  int 21h
  jc  @@ErrorLoadPal
  mov ax, ds
  mov es, ax
  mov si, offset PalLoad
  mov di, offset PalHeader
  mov cx, 20
  repe cmpsb
  jne @@ErrorNoPal
  mov ax, [bp+14]
  mov ds, ax
  mov dx, [bp+12]
  mov cx, 768
  mov ah, 3fh
  int 21h
  jc  @@ErrorLoadPal
  mov ah, 3eh
  int 21h
  xor ax, ax
  jmp @@EndLoadPal
@@ErrorOpenLPal:
  mov ax, 1
  jmp @@EndLoadPal
@@ErrorNoPal:
  mov ah, 3eh
  int 21h
  mov ax, 3
  jmp @@EndLoadPal
@@ErrorLoadPal:
  mov ah, 3eh
  int 21h
  mov ax, 2
@@EndLoadPal:
  pop ds
  pop bp
  ret 8
xCSLoadPal endp

CSWaitRetrace proc
  mov dx, 03dah
@@Wait1:
  in  al, dx
  and al, 08h
  jnz @@Wait1
@@Wait2:
  in  al, dx
  and al, 08h
  jz  @@Wait2
  ret
CSWaitRetrace endp

end
