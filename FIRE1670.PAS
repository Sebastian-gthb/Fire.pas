{$M 1024,0,0}
{$G+}
begin
asm
   push ds
   push es
   push di
   push si

   mov  ah,48h       {Reserviere 64 kB Speicher}
   mov  bx,4096
   int 21h
   jnb @@001         {wenn kein Fehler auftritt springe zu @@001}
   jmp @@999         {sonst springe zum ENDE}
@@001:
   mov  ds,ax

   mov  di,40h       {SPEICHERE ALTEN GRAFIKMODUS}
   mov  es,di
   mov  di,49h
   mov  dl,Byte ptr[es:di]
   mov  dh,0
   push dx
   mov  ax,13h       {SETZE MODUS 13h}
   int  10h

   mov  cx,64        {erzeuge Palette}
   mov  al,63
   mov  dx,0
   mov  di,0
@@002:
   mov  [ds:di],dl
   mov  [ds:di+1],dh
   mov  [ds:di+2],dh
   add  di,3
   inc  dl
   dec  cx
   jnz @@002
   mov  cx,63
   mov  dl,1
@@003:
   mov  [ds:di],al
   mov  [ds:di+1],dl
   mov  [ds:di+2],dh
   add  di,3
   inc  dl
   dec  cx
   jnz @@003
   mov  cx,63
   mov  dl,1
@@004:
   mov  [ds:di],al
   mov  [ds:di+1],al
   mov  [ds:di+2],dl
   add  di,3
   inc  dl
   dec  cx
   jnz @@004
   mov  cx,66
@@005:
   mov  [ds:di],al
   mov  [ds:di+1],al
   mov  [ds:di+2],al
   add  di,3
   dec  cx
   jnz @@005

   mov  ax,ds        {SETZE PALETTE}
   mov  es,ax
   mov  dx,0
   mov  ax,1012h
   mov  bx,0
   mov  cx,100h
   int  10h

   mov  ax,0A000h
   mov  es,ax

   mov  di,0          {L™SCHE SPEICHER}
   mov  dx,0
   mov  cx,32768
@@006:
   mov  [ds:di],dx
   add  di,2
   dec  cx
   jnz  @@006

@@010:
   mov  al,6          {Timer auslesen}
   out  43h,al
   mov  ax,0
   in   al,40h
   mov  cl,al
   in   al,40h
   mov  ch,al
   mov  ax,2          {Punkte Zeichen mit niedrigem Bit beginnen}
   mov  bx,0
   mov  di,0
   mov  dx,0FFFFh
@@011:
   test cx,ax
   jnz @@012
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx
@@012:
   add  bx,8
   add  ax,ax
   jnz @@011

   mov  al,6          {Timer auslesen}
   out  43h,al
   mov  ax,0
   in   al,40h
   mov  cl,al
   in   al,40h
   mov  ch,al
   mov  ax,80h        {Punkte Zeichnen mit hohem Bit beginnen}
   mov  bx,4
{   mov  di,0
   mov  dx,0FFFFh}
@@013:
   test cx,ax
   jnz @@014
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx
@@014:
   add  bx,8
   shr  ax,1
   cmp  ax,1
   jnz @@013

   mov  al,6          {Timer auslesen}
   out  43h,al
   mov  ax,0
   in   al,40h
   mov  cl,al
   in   al,40h
   mov  ch,al
   mov  ax,2          {Punkte Zeichnen mit niedrigem Bit beginnen}
   mov  bx,60
{   mov  di,0
   mov  dx,0FFFFh}
@@015:
   test cx,ax
   jnz @@016
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx
@@016:
   add  bx,8
   add  ax,ax
   jnz @@015

   mov  al,6          {Timer auslesen}
   out  43h,al
   mov  ax,0
   in   al,40h
   mov  cl,al
   in   al,40h
   mov  ch,al
   mov  ax,8000h        {Punkte Zeichnen mit hohem Bit beginnen}
   mov  bx,120
{   mov  di,0}
{   mov  dx,0FFFFh}
@@017:
   test cx,ax
   jnz @@018
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx
@@018:
   add  bx,8
   shr  ax,1
   cmp  ax,1
   jnz @@017





   mov  di,1        {Berechne Bild}
   mov  ax,0
   mov  bx,0
   mov  cx,0
   mov  si,31520

@@100:
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
   jz @@101          {...dann springe zu @@101...}
   dec  ax           {...sonst ziehe 1 ab}
@@101:
   shr  bx,3         {Teile zweiten Punkt durch 8 ; wenn schon 0...}
   jz @@102          {...dann springe zu @@102...}
   dec  bx           {...sonst ziehe 1 ab}
@@102:
   mov  ah,bl
   mov  Word ptr [ds:di],ax    {Schreibe beide Punkte in Puffer}
   mov  Word ptr [es:di],ax    {Schreibe beide Punkte in Videospeicher}
   add  di,2
   xor  ax,ax
   dec  si
   jnz @@100

   in  al,60h
   cmp al,1
   jnz @@010

   pop  ax           {SETZE ALTEN GRAFIKMODUS}
   int  10h

   mov  ax,ds
   mov  es,ax
   mov  ah,49h
   int  21h
@@999:
end;
end.