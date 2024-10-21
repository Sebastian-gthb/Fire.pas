{$G+}
USES Crt;
TYPE vgapalette = ARRAY[0..767] of Byte;
TYPE Schirm = ARRAY[0..63999] of Byte;
VAR rgbpalette   : ^vgapalette;
    A_Bildschirm : ^Schirm;
    oldmode      : Byte;
    a            : Byte;

procedure setgmode(mode: Byte); assembler;
asm
   mov  al,mode
   mov  ah,0
   int  10h
end;
procedure setpalette(palette:Pointer);assembler;
asm
   push es
   push di
   les  di,palette
   mov  cx,64
   mov  al,63
   mov  dl,0
   mov  dh,0

@@1:
   mov  [es:di],dl
   mov  [es:di+1],dh
   mov  [es:di+2],dh
   add  di,3
   inc  dl
   dec  cx
   jnz @@1

   mov  cx,63
   mov  dl,1
@@2:
   mov  [es:di],al
   mov  [es:di+1],dl
   mov  [es:di+2],dh
   add  di,3
   inc  dl
   dec  cx
   jnz @@2

   mov  cx,63
   mov  dl,1
@@3:
   mov  [es:di],al
   mov  [es:di+1],al
   mov  [es:di+2],dl
   add  di,3
   inc  dl
   dec  cx
   jnz @@3

   mov  cx,66
@@4:
   mov  [es:di],al
   mov  [es:di+1],al
   mov  [es:di+2],al
   add  di,3
   dec  cx
   jnz @@4

   les  dx,palette
   mov  ax,1012h
   mov  bx,0
   mov  cx,100h
   int  10h

   pop  di
   pop  es
end;
procedure clearpuffer(wo:Pointer);assembler;
asm
   push es
   push di
   les  di,wo
   mov  cx,32000
   mov  ax,0
@@1:
   mov  [es:di],ax
   add  di,2
   dec  cx
   jnz @@1

   pop  di
   pop  es
end;
procedure hotspot(x:Word;wo:pointer);assembler;
asm
   push es
   push di
   mov  ax,x
   les  di,wo
   add  di,ax
   mov  dl,255

   mov  [es:di+62080],dl
   mov  [es:di+62399],dl
   mov  [es:di+62400],dl
   mov  [es:di+62401],dl
   mov  [es:di+62402],dl
   mov  [es:di+62720],dl
   mov  [es:di+62721],dl

   pop  di
   pop  es
end;
procedure rechne(wo:pointer);assembler;
asm
   push es
   push di
   push ds
   push si

   mov  si,0A000h
   mov  es,si
   lds  di,wo
   mov  cx,40
   mov  dl,255
@@10:
   mov  al,6
   out  43h,al
   mov  ax,0
   mov  bx,0
   in   al,40h
   mov  bl,al
   in   al,40h
   and  ax,63
   add  bx,ax

  mov  ax,0
  test bx,1
  jnz @@11
  add  ax,256
@@11:
  test bx,2
  jnz @@12
  add  ax,128
@@12:
  test bx,4
  jnz @@13
  add  ax,64
@@13:
  test bx,8
  jnz @@14
  add  ax,32
@@14:
  test bx,16
  jnz @@15
  add  ax,16
@@15:
  test bx,32
  jnz @@16
  add  ax,8
@@16:
  test bx,64
  jnz @@17
  add  ax,4
@@17:
  test bx,128
  jnz @@18
  add  ax,2
@@18:
  test bx,256
  jnz @@19
  add  ax,1
@@19:
  mov  bx,ax
  cmp  bx,320
  jb @@20
  sub  bx,230
@@20:
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dl
   mov  [ds:di+62400+bx],dl
   mov  [ds:di+62401+bx],dl
   mov  [ds:di+62402+bx],dl
   mov  [ds:di+62720+bx],dl
   mov  [ds:di+62721+bx],dl
   dec  cx
   jnz @@10

   inc  di
   mov  ax,0
   mov  bx,0
   mov  cx,0
   mov  dx,0
   mov  si,31520

@@1:
   mov  dx,Word ptr [ds:di+639]
   mov  al,dl
   mov  bl,dh
   mov  dx,Word ptr [ds:di+319]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [ds:di+321]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [ds:di+641]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [ds:di+959]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [ds:di+961]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx

   shr  ax,3         {Teile ersten Punkt durch 8 ; wenn schon 0...}
   jz @@2            {...dann springe zu @@2...}
   dec  ax           {...sonst ziehe 1 ab}
@@2:
   shr  bx,3         {Teile zweiten Punkt durch 8 ; wenn schon 0...}
   jz @@3            {...dann springe zu @@2...}
   dec  bx           {...sonst ziehe 1 ab}
@@3:
   mov  ah,bl
   mov  Word ptr [ds:di],ax    {Schreibe beide Punkte in Puffer}
   mov  Word ptr [es:di],ax    {Schreibe beide Punkte in Videospeicher}
   add  di,2
   mov  ax,0
   dec  si
   jnz @@1

   pop  si
   pop  ds
   pop  di
   pop  es
end;


begin
New(rgbpalette);
New(A_Bildschirm);
oldmode := MEM[$40:$49];
setgmode(19);
setpalette(rgbpalette);
clearpuffer(A_Bildschirm);

repeat
rechne(A_Bildschirm);
until Keypressed;

setgmode(oldmode);
Dispose(A_Bildschirm);
Dispose(rgbpalette);
end.