{$M 1024,0,0}
{$G+}
begin
asm
   push ds
   push es
   push di
   push si

      {Benchmark}
      {AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec}
      mov  ah,2Ch
      int 21h
      push dx
      push cx


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
   mov  ax,03F3Fh
   xor  bx,bx
   xor  dx,dx
   xor  di,di
@@002:
   mov  [ds:di],dl      {r 0...63}
   mov  [ds:di+1],bx    {g 0, b 0}
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
   mov  [ds:di],ax      {r 63, g 63}
   mov  [ds:di+2],dl    {b 1..63}
   add  di,3
   inc  dl
   loop @@004
   mov  cx,99           {die uebrigen 66 Farben auf 63,63,63 setzen = 99mal 2Bytes=1Word}
@@005:
   mov  [ds:di],ax
   add  di,2
   loop @@005

   mov  ax,ds        {SETZE PALETTE}
   mov  es,ax
   xor  dx,dx
   mov  ax,1012h
   xor  bx,bx
   mov  cx,100h
   int  10h

   mov  ax,0A000h
   mov  es,ax

   xor  di,di          {LOESCHE SPEICHER}
   xor  dx,dx
   mov  cx,32768
@@006:
   mov  [ds:di],dx
   add  di,2
   loop @@006

   mov  ax,02D7Ah     {bel. Zahl}
   mov  bx,0CD12h
   push ax            {Zuvallszahl in Stack sichern}
   push bx

@@010:                {setze neue weisse Punkte am untern Bildrand}
   mov  cx,60         {Setze Zaehler auf XXX}
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

   push cx      {Sichere Zaehler}

   mov  cx,320
   xor  dx,dx
   div  cx
   mov  bx,dx

   xor  di,di
   mov  dx,0FFFFh
   mov  [ds:di+62080+bx],dl
   mov  [ds:di+62399+bx],dx
   mov  [ds:di+62401+bx],dx
   mov  [ds:di+62720+bx],dx

   pop  cx      {Lade Zaehler wieder}
   loop @@011

   mov  di,1        {Berechne Bild}
   xor  bx,bx
   xor  cx,cx
   mov  si,31520

   mov  dx,Word ptr [ds:di+639]
@@100:
   xor  ah,ah      {ah auf 0 setzen, da es aus dem letzten Lauf noch Werte enthalten kann}
   mov  al,dl      {dx hat noch Wert von di+641 aus letzem Lauf, was jetzt di+639 ist}
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
   mov  dx,Word ptr [ds:di+641]   {dx ist im nachsten Lauf der Wert von ds:di+639 und muss nicht noch mal gelesen werden}
   mov  cl,dl
   add  ax,cx
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
   mov  Word ptr [ds:di],ax      {Schreibe beide Punkte in Puffer}
   {mov  Word ptr [es:di],ax }   {Schreibe beide Punkte in Videospeicher (4B 3T)}
   {add  di,2 }            {4B 3T}
   inc  di        {2x 1B 2T=2B 4T}
   inc  di
   dec  si
   jnz @@100

                  {kopiere Puffer in Videospeicher - ist minimal schneller}
   xor  di,di    
   mov  cx,32000  {fuer alle 64.000 Byte bei 320x200}
   rep  movsw     {1B 5T}

   in  al,60h
   cmp al,1
      {jnz @@010 }    {fuer Benschmark deaktiviert}

      jz @@103               {\             }
      mov ax,1               { |            }
      mov si,65000           { |            }
      sub [ds:si],ax         { | Code fuer  }
      jnz @@010              { | Benschmark }
                             { |            }
@@103:                       {/             }


   pop  bx               {Zuvallszahl aus Stack entfernen}
   pop  ax

   mov  ax,03h           {SETZE ALTEN GRAFIKMODUS}
   int  10h

   mov  ax,ds            {Speicher wieder freigeben}
   mov  es,ax
   mov  ah,49h
   int  21h
@@999:

      pop  bx        {Benchmark: Zeitstempel vom Start zurueckholen}
      call @@1000
      pop  bx
      call @@1000
      {AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec}
      mov  ah,02Ch
      int 21h
      mov  bx,cx
      mov  cx,dx
      call @@1000
      mov  bx,cx
      call @@1000
      jmp  @@1111

@@1000:        {function to split a word in to 4 character calls}
      mov  dl,bh
      shr  dl,4
      call @@1010
      mov  dl,bh
      and  dl,00Fh
      call @@1010
      mov  dl,bl
      shr  dl,4
      call @@1010
      mov  dl,bl
      and  dl,00Fh
      call @@1010
      ret
@@1010:        {function print half byte (dl) as hex}
      add  dl,030h
      cmp  dl,039h
      jna @@1011
      add  dl,7
@@1011:
      mov  ah,02h
      int 21h
      ret
@@1111:


   pop  si
   pop  di
   pop  es
   pop  ds
end;
end.