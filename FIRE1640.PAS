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
   add  di,62400
   add  di,ax
   mov  dl,255

   mov  [es:di-320],dl
   mov  [es:di-1],dl
   mov  [es:di],dl
   mov  [es:di+1],dl
   mov  [es:di+2],dl
   mov  [es:di+320],dl
   mov  [es:di+321],dl

   pop  di
   pop  es
end;
procedure rechne(wo:pointer);assembler;
asm
   push es
   push di
   push ds
   push si

   les  di,wo
   inc  di
   mov  ax,0
   mov  bx,0
   mov  cx,0
   mov  dx,0
   mov  si,31520

@@1:
   mov  dx,Word ptr [es:di+639]
   mov  al,dl
   mov  bl,dh
   mov  dx,Word ptr [es:di+319]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [es:di+321]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [es:di+641]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,Word ptr [es:di+959]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,Word ptr [es:di+961]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx

   shr  ax,3
   cmp  ax,0
   jz @@2
   dec  ax
@@2:
   mov  Byte ptr [es:di],al
   shr  bx,3
   cmp  bx,0
   jz @@3
   dec  bx
@@3:
   mov  Byte ptr [es:di+1],bl
   add  di,2
   dec  si
   jnz @@1

   les  di,wo                  {Kopiere Bild in Videospeicher}
   mov  si,0A000h
   mov  ds,si
   mov  si,0
   mov  cx,32000
@@4:
   mov  dx,[es:di]
   add  di,2
   mov  [ds:si],dx
   add  si,2
   dec  cx
   jnz @@4

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