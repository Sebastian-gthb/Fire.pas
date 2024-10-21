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

   mov  ax,13h       {SETZE GRAFIKMODUS 13h}
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
   db 66h,0B8h,12h,0CDh,7Ah,2Dh  {mov eax,2D7ACD12h   bel. Zahl}
   db 66h,50h                    {push eax   Zuvallszahl in Stack sichern}

@@010:
   mov  cx,60        {Setze Z„hler auf XXX}
@@011:
   db 66h,58h                        { pop eax           }
   db 66h,89h,0C3h                   { mov ebx,eax       }
   db 66h,0C1h,0E0h,07h              { shl eax,7         }
   db 66h,03h,0C3h                   { add eax,ebx       }
   db 66h,81h,0C0h,0E9h,62h,19h,36h  { add eax,361962E9h }
   db 66h,50h                        { push eax          }

   push cx                   {Sichere Z„hler}

   db 66h,0C1h,0E8h,10h              { shr eax,16        }
   mov  cx,320
   xor  dx,dx
   div  cx
   mov  bx,dx

   mov  di,0
   mov  dx,0FFFFh
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx

   pop  cx      {Lade Z„hler wieder}
   dec  cx
   jnz @@011


   mov  di,1        {Berechne Bild}
   mov  ax,0
   mov  bx,0
   mov  cx,0
   mov  si,31520

@@100:
   mov  ax,Word ptr [ds:di+639]
   mov  bl,ah
 xor  ah,ah
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
   dec  si
   jnz @@100

   in  al,60h
   cmp al,1
   jnz @@010

   pop  bx           {Zuvallszahl aus Stack entfernen}
   pop  ax

   mov  ax,03h           {SETZE ALTEN GRAFIKMODUS}
   int  10h

   mov  ax,ds
   mov  es,ax
   mov  ah,49h
   int  21h
@@999:
   pop  si
   pop  di
   pop  es
   pop  ds
end;
end.