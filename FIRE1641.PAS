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
   push ds
   push di
   lds  di,wo
   add  di,x
   mov  dx,0FFFFh
   mov  [ds:di+62080],dl
   mov  [ds:di+62399],dx
   mov  [ds:di+62401],dx
   mov  [ds:di+62720],dx
   pop  di
   pop  ds
end;
procedure rechne(wo:pointer);assembler;
asm
   push es
   push di
   push ds
   push si

   mov  si,0A000h
   mov  es,si
   lds  si,wo
   inc  si
   mov  ax,0
   mov  bx,0
   mov  cx,0
   mov  di,31519

@@1:
   mov  dx,Word ptr [ds:si+639]
   mov  al,dl
   mov  bl,dh
   mov  dx,Word ptr [ds:si+319]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [ds:si+321]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [ds:si+641]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [ds:si+959]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [ds:si+961]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx

   shr  ax,3         {Teile ersten Punkt durch 8}
   cmp  ax,0         {wenn schon 0...}
   jz @@2            {...dann springe zu @@2...}
   dec  ax           {...sonst ziehe 1 ab}
@@2:
   shr  bx,3         {Teile zweiten Punkt durch 8}
   cmp  bx,0         {wenn schon 0...}
   jz @@3            {...dann springe zu @@2...}
   dec  bx           {...sonst ziehe 1 ab}
@@3:
   mov  dl,al
   mov  dh,bl
   mov  Word ptr [ds:si],dx    {Schreibe beide Punkte in Puffer}
   mov  Word ptr [es:si],dx    {Schreibe beide Punkte in Videospeicher}
   add  si,2
   dec  di
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
randomize;
for a:= 0 to 80 do hotspot(random(319),A_Bildschirm);
rechne(A_Bildschirm);
until Keypressed;

setgmode(oldmode);
Dispose(A_Bildschirm);
Dispose(rgbpalette);
end.