begin
asm
db 'start->'

{NICHT STARTEN!!!}

   pushad

   mov  al,0Eh       {Reserviere 64 kB Speicher}
   mov  ebx,10000h
   xor  edx,edx
   int  20h
   mov  ds,cx        {Kopiere Descriptor in DS}

   mov  ax,1016h     {SETZE GRAFIKMODUS 13h}
   mov  dword ptr gs:[62Ch],13h
   int  20h

   mov  dx,3C8h      {erzeuge Palette}
   xor  al,al
   out  dx,al
   inc  edx
   out  dx,al
   out  dx,al
   mov  cx,3F3Fh     {setze cl,ch,ah auf 63}
   mov  ah,cl
   out  dx,al
@@002:
   dec  edx
   mov  al,ch
   out  dx,al
   inc  edx
   mov  al,cl
   out  dx,al
   xor  al,al
   out  dx,al
   out  dx,al

   add  ch,ah         {ch+63}
   dec  edx
   mov  al,ch
   out  dx,al
   inc  edx
   mov  al,ah
   out  dx,al
   mov  al,cl
   out  dx,al
   xor  al,al
   out  dx,al

   add  ch,ah         {ch+63}
   dec  edx
   mov  al,ch
   out  dx,al
   inc  edx
   mov  al,ah
   out  dx,al
   out  dx,al
   mov  al,cl
   out  dx,al

   sub  ch,127
   dec  cl
   jnz @@002

   mov  cx,0BE41h        {ch=190  cl=65}
@@003:
   dec  edx
   mov  al,ch
   out  dx,al
   mov  al,ah
   inc  edx
   out  dx,al
   inc  ch
   out  dx,al
   out  dx,al
   dec  cl
   jnz @@003

   xor  edx,edx          {L™SCHE SPEICHERBEREICH}
   push edi
   mov  cx,16384
@@006:
   mov  ds:[edi],edx
   add  di,4
   dec  cx
   jnz  @@006
   pop  edi

   mov  esi,0A0000h
{  mov  eax,2D7ACD12h   bel. Zahl  Es ist schon eine bel. Zahl in eax! }
   push edi
   push eax                          { Zuvallszahl in Stack sichern }

@@010:
   mov  cl,80                        {Setze Z„hler auf XXX}
@@011:
   pop  eax
   mov  ebx,eax
   shl  eax,7
   add  eax,ebx
   add  eax,361962E9h
   pop  edi
   push edi
   push eax

   mov  bl,cl                  {Sichere Z„hler in BL}

   shr  eax,16
   mov  cx,320
   xor  dx,dx
   div  cx
   mov  cl,bl                  {hohle Z„hler wieder aus BL}
xor  ebx,ebx
   mov  bx,dx

   mov  edx,0FFFFFFFFh                {xor&dec = -1Byte}
   mov  ds:[edi+62080+ebx],dl
   mov  ds:[edi+62399+ebx],edx
   mov  ds:[edi+62720+ebx],dx
   dec  cl
   jnz @@011

                   {Berechne Bild}
   xor  ebx,ebx
   xor  ecx,ecx
   xor  esi,esi
@@100:
   mov  edx,ds:[edi+639]
   xor  ah,ah
   mov  al,dl
   mov  bl,dh
   shr  edx,16
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  bx,cx
   mov  edx,ds:[edi+319]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   shr  edx,16
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  edx,ds:[edi+959]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   shr  edx,16
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
   mov  Word ptr ds:[edi],ax    {Schreibe beide Punkte in Puffer}
   mov  Word ptr gs:[esi+0A0000h],ax    {Schreibe beide Punkte in Videospeicher}
   add  di,2
   inc  esi
   cmp  si,31520
   jnz @@100

   in  al,60h
   cmp al,1
   jnz @@010

   pop  eax             { Zuvallszahl aus Stack entfernen}

   mov  al,18h          { V2_OS look}
   int  20h

   mov  bx,ds           {gib Speicherbereich wieder frei}
   mov  al,0Fh
   int  20h


   popad
db '<-stop'
end;
end.