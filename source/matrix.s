;----------------------------------------------------------------------------
;
;  CosmoX MATRIX Module
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

Matrix              dd  16 dup(?)       ;  Temporal Matrix
Vertex              dd  3 dup(?)        ;  Temporal Vertex

.code

public  CSCopyMatrix, CSIdentityMatrix, CSInitRotXMatrix, CSInitRotYMatrix
public  CSInitRotZMatrix, CSInitTransMatrix, CSInitScaleMatrix
public  CSMatrixMulMatrix, CSVectorMulMatrix, CSProjectVector, CSPolyFacing
public  CSVectorDot, CSXNormal, CSYNormal, CSZNormal, CSUnitVector

CSCopyMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov bx, [bp+12]
  mov ds, ax
  mov es, bx
  mov si, [bp+14]
  mov di, [bp+08]
  mov cx, 16
  rep movsd
  pop ds
  pop bp
  ret 12
CSCopyMatrix endp

CSIdentityMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+12]
  mov si, [bp+08]
  mov ds, ax
  fldz
  fld1
  fst dword ptr [si]
  fst dword ptr [si+20]
  fst dword ptr [si+40]
  fstp dword ptr [si+60]
  fst dword ptr [si+04]
  fst dword ptr [si+08]
  fst dword ptr [si+12]
  fst dword ptr [si+16]
  fst dword ptr [si+24]
  fst dword ptr [si+28]
  fst dword ptr [si+32]
  fst dword ptr [si+36]
  fst dword ptr [si+44]
  fst dword ptr [si+48]
  fst dword ptr [si+52]
  fstp dword ptr [si+56]
  fwait
  pop ds
  pop bp
  ret 6
CSIdentityMatrix endp

CSInitRotXMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+20]
  mov si, [bp+16]
  mov ds, ax
  fld dword ptr [bp+08]
  fld dword ptr [bp+12]
  fldz
  fld1
  fst dword ptr [si]
  fstp dword ptr [si+60]
  fst dword ptr [si+04]
  fst dword ptr [si+08]
  fst dword ptr [si+12]
  fst dword ptr [si+16]
  fst dword ptr [si+28]
  fst dword ptr [si+32]
  fst dword ptr [si+44]
  fst dword ptr [si+48]
  fst dword ptr [si+52]
  fstp dword ptr [si+56]
  fst dword ptr [si+20]
  fstp dword ptr [si+40]
  fst dword ptr [si+24]
  fchs
  fstp dword ptr [si+36]
  fwait
  pop ds
  pop bp
  ret 14
CSInitRotXMatrix endp

CSInitRotYMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+20]
  mov si, [bp+16]
  mov ds, ax
  fld dword ptr [bp+08]
  fld dword ptr [bp+12]
  fldz
  fld1
  fst dword ptr [si+20]
  fstp dword ptr [si+60]
  fst dword ptr [si+04]
  fst dword ptr [si+12]
  fst dword ptr [si+16]
  fst dword ptr [si+24]
  fst dword ptr [si+28]
  fst dword ptr [si+36]
  fst dword ptr [si+44]
  fst dword ptr [si+48]
  fst dword ptr [si+52]
  fstp dword ptr [si+56]
  fst dword ptr [si]
  fstp dword ptr [si+40]
  fst dword ptr [si+32]
  fchs
  fstp dword ptr [si+08]
  fwait
  pop ds
  pop bp
  ret 14
CSInitRotYMatrix endp

CSInitRotZMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+20]
  mov si, [bp+16]
  mov ds, ax
  fld dword ptr [bp+08]
  fld dword ptr [bp+12]
  fldz
  fld1
  fst dword ptr [si+40]
  fstp dword ptr [si+60]
  fst dword ptr [si+08]
  fst dword ptr [si+12]
  fst dword ptr [si+24]
  fst dword ptr [si+28]
  fst dword ptr [si+32]
  fst dword ptr [si+36]
  fst dword ptr [si+44]
  fst dword ptr [si+48]
  fst dword ptr [si+52]
  fstp dword ptr [si+56]
  fst dword ptr [si]
  fstp dword ptr [si+20]
  fst dword ptr [si+04]
  fchs
  fstp dword ptr [si+16]
  fwait
  pop ds
  pop bp
  ret 14
CSInitRotZMatrix endp

CSInitTransMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+24]
  mov si, [bp+20]
  mov ds, ax
  fldz
  fld1
  fst dword ptr [si]
  fst dword ptr [si+20]
  fst dword ptr [si+40]
  fstp dword ptr [si+60]
  fst dword ptr [si+04]
  fst dword ptr [si+08]
  fst dword ptr [si+12]
  fst dword ptr [si+16]
  fst dword ptr [si+24]
  fst dword ptr [si+28]
  fst dword ptr [si+32]
  fst dword ptr [si+36]
  fstp dword ptr [si+44]
  fld dword ptr [bp+08]
  fld dword ptr [bp+12]
  fld dword ptr [bp+16]
  fstp dword ptr [si+48]
  fstp dword ptr [si+52]
  fstp dword ptr [si+56]
  fwait
  pop ds
  pop bp
  ret 18
CSInitTransMatrix endp

CSInitScaleMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+24]
  mov si, [bp+20]
  mov ds, ax
  fldz
  fld1
  fstp dword ptr [si+60]
  fst dword ptr [si+04]
  fst dword ptr [si+08]
  fst dword ptr [si+12]
  fst dword ptr [si+16]
  fst dword ptr [si+24]
  fst dword ptr [si+28]
  fst dword ptr [si+32]
  fst dword ptr [si+36]
  fst dword ptr [si+44]
  fst dword ptr [si+48]
  fst dword ptr [si+52]
  fstp dword ptr [si+56]
  fld dword ptr [bp+08]
  fld dword ptr [bp+12]
  fld dword ptr [bp+16]
  fstp dword ptr [si]
  fstp dword ptr [si+20]
  fstp dword ptr [si+40]
  fwait
  pop ds
  pop bp
  ret 18
CSInitScaleMatrix endp

CSMatrixMulMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+18]
  mov bx, [bp+12]
  mov cx, seg Matrix
  mov ds, ax
  mov es, bx
  mov fs, cx
  xor si, si
  xor di, di
@@MatrixMul:
  mov ax, si
  mov cx, [bp+14]
  shl ax, 2
  add cx, ax
  mov bx, cx
  fld dword ptr [bx]
  mov ax, di
  mov dx, [bp+08]
  shl ax, 4
  add dx, ax
  mov bx, dx
  fmul dword ptr es:[bx]
  mov bx, cx
  fld dword ptr [bx+16]
  mov bx, dx
  fmul dword ptr es:[bx+4]
  faddp
  mov bx, cx
  fld dword ptr [bx+32]
  mov bx, dx
  fmul dword ptr es:[bx+8]
  faddp
  mov bx, cx
  fld dword ptr [bx+48]
  mov bx, dx
  fmul dword ptr es:[bx+12]
  faddp
  mov ax, si
  mov cx, di
  mov bx, offset Matrix
  shl ax, 2
  shl cx, 4
  add bx, ax
  add bx, cx
  fstp dword ptr fs:[bx]
  inc di
  cmp di, 4
  jl  @@MatrixMul
  xor di, di
  inc si
  cmp si, 4
  jl  @@MatrixMul
  fwait
  mov ax, [bp+18]
  mov bx, seg Matrix
  mov es, ax
  mov ds, bx
  mov si, offset Matrix
  mov di, [bp+14]
  mov cx, 16
  rep movsd
  pop ds
  pop bp
  ret 12
CSMatrixMulMatrix endp

CSVectorMulMatrix proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+24]
  mov bx, [bp+18]
  mov cx, seg Vertex
  mov ds, ax
  mov es, bx
  mov fs, cx
  mov bx, [bp+20]
  mov si, [bp+14]
  mov di, offset Vertex
  fld dword ptr [bx]
  fmul dword ptr es:[si]
  fld dword ptr [bx+04]
  fmul dword ptr es:[si+16]
  faddp
  fld dword ptr [bx+08]
  fmul dword ptr es:[si+32]
  faddp
  fadd dword ptr es:[si+48]
  fstp dword ptr fs:[di]
  fld dword ptr [bx]
  fmul dword ptr es:[si+04]
  fld dword ptr [bx+04]
  fmul dword ptr es:[si+20]
  faddp
  fld dword ptr [bx+08]
  fmul dword ptr es:[si+36]
  faddp
  fadd dword ptr es:[si+52]
  fstp dword ptr fs:[di+4]
  fld dword ptr [bx]
  fmul dword ptr es:[si+08]
  fld dword ptr [bx+04]
  fmul dword ptr es:[si+24]
  faddp
  fld dword ptr [bx+08]
  fmul dword ptr es:[si+40]
  faddp
  fadd dword ptr es:[si+56]
  fstp dword ptr fs:[di+8]
  fwait
  mov ax, [bp+12]
  mov si, [bp+08]
  mov ds, ax
  mov eax, fs:[di]
  mov ebx, fs:[di+04]
  mov ecx, fs:[di+08]
  mov [si], eax
  mov [si+04], ebx
  mov [si+08], ecx
  pop ds
  pop bp
  ret 18
CSVectorMulMatrix endp

CSProjectVector proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+22]
  mov bx, [bp+16]
  mov ds, ax
  mov es, bx
  mov si, [bp+18]
  mov di, [bp+12]
  fld dword ptr [si]
  fld dword ptr [si+8]
  fsubr dword ptr [bp+08]
  fdivr dword ptr [bp+08]
  fmulp
  fistp word ptr es:[di]
  fld dword ptr [si+4]
  fld dword ptr [si+8]
  fsubr dword ptr [bp+08]
  fdivr dword ptr [bp+08]
  fmulp
  fchs
  fistp word ptr es:[di+2]
  fwait
  mov ax, es:[di]
  mov bx, es:[di+2]
  add ax, 160
  add bx, 100
  mov es:[di], ax
  mov es:[di+2], bx
  pop ds
  pop bp
  ret 16
CSProjectVector endp

CSPolyFacing proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+24]
  mov cx, [bp+18]
  mov dx, [bp+12]
  mov si, [bp+20]
  mov di, [bp+14]
  mov bx, [bp+08]
  mov ds, ax
  mov es, cx
  mov gs, dx
  mov ax, es:[di]
  mov dx, [si+02]
  sub ax, [si]
  sub dx, gs:[bx+02]
  imul dx
  mov cx, ax
  mov ax, es:[di+02]
  mov dx, [si]
  sub ax, [si+02]
  sub dx, gs:[bx]
  imul dx
  sub cx, ax
  mov ax, cx
  pop ds
  pop bp
  ret 18
CSPolyFacing endp

CSVectorDot proc
  push bp
  mov bp, sp
  mov ax, [bp+18]
  mov dx, [bp+12]
  mov di, [bp+06]
  mov si, [bp+14]
  mov bx, [bp+08]
  mov es, ax
  mov fs, dx
  fld dword ptr es:[si+08]
  fld dword ptr es:[si+04]
  fld dword ptr es:[si]
  fmul dword ptr fs:[bx]
  fxch st(1)
  fmul dword ptr fs:[bx+04]
  faddp
  fxch st(1)
  fmul dword ptr fs:[bx+08]
  faddp
  fstp dword ptr [di]
  fwait
  mov ax, [bp+06]
  pop bp
  ret 14
CSVectorDot endp

CSXNormal proc
  push bp
  mov bp, sp
  push ds
  mov ax, [bp+24]
  mov cx, [bp+18]
  mov dx, [bp+12]
  mov si, [bp+20]
  mov di, [bp+14]
  mov bx, [bp+08]
  mov ds, ax
  mov es, cx
  mov fs, dx
  fld dword ptr es:[di+08]
  fld dword ptr [si+08]
  fsubp
  fld dword ptr [si+04]
  fld dword ptr fs:[bx+04]
  fsubp
  fmulp
  fld dword ptr es:[di+04]
  fld dword ptr [si+04]
  fsubp
  fld dword ptr [si+08]
  fld dword ptr fs:[bx+08]
  fsubp
  fmulp
  fsubp
  pop ds
  mov ax, [bp+06]
  mov si, ax
  fstp dword ptr [si]
  fwait
  pop bp
  ret 20
CSXNormal endp

CSYNormal proc
  push bp
  mov bp, sp
  push ds
  mov ax, [bp+24]
  mov cx, [bp+18]
  mov dx, [bp+12]
  mov si, [bp+20]
  mov di, [bp+14]
  mov bx, [bp+08]
  mov ds, ax
  mov es, cx
  mov fs, dx
  fld dword ptr es:[di]
  fld dword ptr [si]
  fsubp
  fld dword ptr [si+08]
  fld dword ptr fs:[bx+08]
  fsubp
  fmulp
  fld dword ptr es:[di+08]
  fld dword ptr [si+08]
  fsubp
  fld dword ptr [si]
  fld dword ptr fs:[bx]
  fsubp
  fmulp
  fsubp
  pop ds
  mov ax, [bp+06]
  mov si, ax
  fstp dword ptr [si]
  fwait
  pop bp
  ret 20
CSYNormal endp

CSZNormal proc
  push bp
  mov bp, sp
  push ds
  mov ax, [bp+24]
  mov cx, [bp+18]
  mov dx, [bp+12]
  mov si, [bp+20]
  mov di, [bp+14]
  mov bx, [bp+08]
  mov ds, ax
  mov es, cx
  mov fs, dx
  fld dword ptr es:[di+04]
  fld dword ptr [si+04]
  fsubp
  fld dword ptr [si]
  fld dword ptr fs:[bx]
  fsubp
  fmulp
  fld dword ptr es:[di]
  fld dword ptr [si]
  fsubp
  fld dword ptr [si+04]
  fld dword ptr fs:[bx+04]
  fsubp
  fmulp
  fsubp
  pop ds
  mov ax, [bp+06]
  mov si, ax
  fstp dword ptr [si]
  fwait
  pop bp
  ret 20
CSZNormal endp

CSUnitVector proc
  push bp
  push ds
  mov bp, sp
  mov ax, [bp+14]
  mov dx, [bp+10]
  mov si, [bp+12]
  mov di, [bp+08]
  mov ds, ax
  mov es, dx
  fld dword ptr [si+08]
  fld dword ptr [si+08]
  fmulp
  fld dword ptr [si+04]
  fld dword ptr [si+04]
  fmulp
  fld dword ptr [si]
  fld dword ptr [si]
  fmulp
  faddp
  faddp
  fsqrt
  fld dword ptr [si+08]
  fld dword ptr [si+04]
  fld dword ptr [si]
  fdiv st, st(3)
  fxch st(1)
  fdiv st, st(3)
  fxch st(2)
  fdiv st, st(3)
  fstp dword ptr es:[di+08]
  fstp dword ptr es:[di]
  fstp dword ptr es:[di+04]
  ffree
  fwait
  pop ds
  pop bp
  ret 8
CSUnitVector endp

end
