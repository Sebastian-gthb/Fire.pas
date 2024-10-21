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

                     {erzeuge Palette}
   mov  cx,64
   mov  al,63
   mov  dx,0
   mov  di,0
@@002:
   mov  [ds:di],dl      {r 0...63}
   mov  [ds:di+1],dh    {g 0}
   mov  [ds:di+2],dh    {b 0}
   add  di,3
   inc  dl
   loop @@002
   mov  cx,63
   mov  dl,1
@@003:
   mov  [ds:di],al      {r 63}
   mov  [ds:di+1],dl    {g 1..63}
   mov  [ds:di+2],dh    {b 0}
   add  di,3
   inc  dl
   loop @@003
   mov  cx,63
   mov  dl,1
@@004:
   mov  [ds:di],al      {r 63}
   mov  [ds:di+1],al    {g 63}
   mov  [ds:di+2],dl    {b 1..63}
   add  di,3
   inc  dl
   loop @@004
   mov  cx,99           {die Åbrigen 66 Farben auf 63,63,63 setzen = 99mal 2Bytes=1Word}
   mov  ax,03F3Fh
@@005:
   mov  [ds:di],ax
   add  di,2
   loop @@005

   mov  ax,ds        {SETZE PALETTE}
   mov  es,ax
   mov  dx,0
   mov  ax,1012h
   mov  bx,0
   mov  cx,100h
   int  10h

   mov  ax,0A000h
   mov  es,ax

   mov  di,0          {LôSCHE SPEICHER}
   mov  dx,0
   mov  cx,32768
@@006:
   mov  [ds:di],dx
   add  di,2
   loop @@006

   mov  ax,02D7Ah     {bel. Zahl}
   mov  bx,0CD12h
   push ax            {Zuvallszahl in Stack sichern}
   push bx

@@010:                {setze neue wei·e Punkte am untern Bildrand}
   mov  cx,60        {Setze ZÑhler auf XXX}
@@011:
   pop  bx
   pop  ax

   mov  si,ax            {\ eax = ax,bx  ebx = si,di }
   mov  di,bx            {/ mov ebx,eax              }

   mov  dl,ah            {\              }
   mov  ah,al            { |             }
   mov  al,bh            { |             }
   mov  bh,bl            { \             }
   xor  bl,bl            { / shl eax,7   }
   rcr  dl,1             { |             }
   rcr  ax,1             { |             }
   rcr  bx,1             {/              }

   add  bx,di            {\             }
   adc  ax,si            {/ add eax,ebx }

  add  bx,62e9h         {\                   }
  adc  ax,3619h         {/ add eax,361962E9h }

   push ax
   push bx

   push cx      {Sichere ZÑhler}

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

   pop  cx      {Lade ZÑhler wieder}
   loop @@011


   mov  di,1        {Berechne Bild}
   xor  ax,ax
   xor  bx,bx
   xor  cx,cx
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
   mov  Word ptr [es:di],ax    {Schreibe beide Punkte in Videospeicher (4B 3T}
   add  di,2
   dec  si
   jnz @@100


                    {kopiere Puffer in Videospeicher}
   {xor  di,di    }
   {mov  cx,32000 } {fÅr alle 64.000 Byte bei 320x200}
   {rep  movsw    } {1B 5T}


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