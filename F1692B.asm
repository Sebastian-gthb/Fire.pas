; compile with --> nasm F1692B.asm -fbin -o F1692B.com
   org 100h

section .text
   global _start


_start:

   push ds
   push es
   push di
   push si

      ; Benchmark
      ; AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec
      mov  ah,2Ch
      int 21h
      push dx
      push cx

;   mov ah, 4Ah             ; INT 21h, AH=4Ah: Resize Memory Block
;   mov bx, 64              ; Point to the very end of our code/data area 1024byte / 16 = 64
;   int 21h                 ; Call DOS

;   mov  ah,48h       ; Reserviere 64 kB Speicher
;   mov  bx,4096
;   int 21h
;   jnb @@001         ; wenn kein Fehler auftritt springe zu @@001
;   jmp @@999         ; sonst springe zum ENDE
;@@001:
   mov  ax,cs
   add  ax,64         ;wir nutzen bei der .com Datei, das wir ein ganzen 64k Segment fuer uns haben. in den ersten 1024byte ist der code hier und dann nehmen wir uns den Rest als Framebuffer
   mov  ds,ax

   mov  ax,13h       ; SETZE GRAFIKMODUS 13h
   int  10h

   mov  cx,64        ; erzeuge Palette
   mov  ax,03F3Fh
   xor  bx,bx
   xor  dx,dx
   xor  di,di
@@002:
   mov  [ds:di],dl      ; r 0...63
   mov  [ds:di+1],bx    ; g 0, b 0
   add  di,3
   inc  dl
   loop @@002
   mov  cx,63
   mov  dl,1
@@003:
   mov  [ds:di],al      ; r 63
   mov  [ds:di+1],dl    ; g 1..63
   mov  [ds:di+2],dh    ; b 0
   add  di,3
   inc  dl
   loop @@003
   mov  cx,63
   mov  dl,1
@@004:
   mov  [ds:di],ax      ; r 63, g 63
   mov  [ds:di+2],dl    ; b 1..63
   add  di,3
   inc  dl
   loop @@004
   mov  cx,99           ; die uebrigen 66 Farben auf 63,63,63 setzen = 99mal 2Bytes=1Word
@@005:
   mov  [ds:di],ax
   add  di,2
   loop @@005

   mov  ax,ds        ; SETZE PALETTE
   mov  es,ax
   xor  dx,dx
   mov  ax,1012h
   xor  bx,bx
   mov  cx,100h
   int  10h

   mov  ax,0A000h
   mov  es,ax

   xor  di,di          ; LOESCHE SPEICHER
   xor  dx,dx
   mov  cx,32768
@@006:
   mov  [ds:di],dx
   add  di,2
   loop @@006

   mov  ax,02D7Ah     ; bel. Zahl
   push ax            ; Zuvallszahl in Stack sichern

      ; Benchmark
      mov ax,200             ; Benchmark 200=ok
      mov [ds:di+64200],ax   ; setze Zaehler fuer Anzahl durchlaeufe

@@010:                ; setze neue weisse Punkte am untern Bildrand
   mov  cx,60         ; Setze Zaehler auf XXX
@@011:
   pop  ax
   mov  si,ax
   shr  ax,1
   add  ax,si
   add  ax,dx      ; dx hat in jedem Bild einmalig einen Wert aus der letzten Bildberechnung
   push ax

   ; mov  si,cx      ; Sichere Zaehler

   ; mov  cx,320 
   ; xor  dx,dx  
   ; div  cx          ; AX:320 ... Rest in DX
   ; mov  bx,dx  

   xor  bx,bx       ; generate a nuber between 0 and 319
   mov  bl,al       ; use 8bit = 256 from al
   shr  ax,10       ; use 6bit = 64 from the highes bits in ax
   add  bx,ax       ; add 256 + 64 = 320
   dec  bx          ; dec bx for maximum of 319

   mov  di,62080
   add  di,bx
   xor  dx,dx
   dec  dx       ; dx=0FFFFh
   mov  [ds:di],dl
   mov  [ds:di+318],dx
   mov  [ds:di+320],dx
   ; mov  cx,si      ; Lade Zaehler zurueck in cx fuer loop
   mov  [ds:di+638],dx
   loop @@011

   mov  di,1        ; Berechne Bild
   xor  bx,bx
   xor  cx,cx
   mov  si,31520
   nop

   mov  dx,[ds:di+639]
@@100:
   xor  ah,ah      ; ah auf 0 setzen, da es aus dem letzten Lauf noch Werte enthalten kann
   mov  al,dl      ; dx hat noch Wert von di+641 aus letzem Lauf, was jetzt di+639 ist
   mov  bl,dh
   mov  dx,[ds:di+319]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,[ds:di+321]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,[ds:di+959]
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,[ds:di+961]
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,[ds:di+641]   ; dx ist im nachsten Lauf der Wert von ds:di+639 und muss nicht noch mal gelesen werden
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  bx,cx

   shr  ax,3         ; Teile ersten Punkt durch 8 ; wenn schon 0...
   jz @@101          ; ...dann springe zu @@101...
   dec  ax           ; ...sonst ziehe 1 ab
@@101:
   shr  bx,3         ; Teile zweiten Punkt durch 8 ; wenn schon 0...
   jz @@102          ; ...dann springe zu @@102...
   dec  bx           ; ...sonst ziehe 1 ab
@@102:
   mov  ah,bl
   mov  [ds:di],ax    ; Schreibe beide Punkte in Puffer
   ; mov  [es:di],ax    ; Schreibe beide Punkte in Videospeicher (4B 3T)
   ; add  di,2             ; 4B 3T
   inc  di        ; 2x 1B 2T=2B 4T
   inc  di
   dec  si
   jnz @@100

                  ; kopiere Puffer in Videospeicher - ist minimal schneller
   xor  di,di    
   mov  cx,32000  ; fuer alle 64.000 Byte bei 320x200
   rep  movsw     ; 1B 5T

   in  al,60h
   cmp al,1
      ; jnz @@010     ; fuer Benschmark deaktiviert

      jz @@103               ; \             
      mov ax,1               ;  |            
      mov si,64200           ;  |            
      sub [ds:si],ax         ;  | Code fuer  
      jnz @@010              ;  | Benchmark 
                             ;  |            
@@103:                       ; /             


   pop  ax               ; Zuvallszahl aus Stack entfernen

   mov  ax,03h           ; SETZE ALTEN GRAFIKMODUS
   int  10h

;   mov  ax,ds            ; Speicher wieder freigeben
;   mov  es,ax
;   mov  ah,49h
;   int  21h
@@999:

      pop  bx        ; Benchmark: Zeitstempel vom Start zurueckholen
      call @@1000
      pop  bx
      call @@1000
      ; AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec
      mov  ah,02Ch
      int 21h
      mov  bx,cx
      mov  cx,dx
      call @@1000
      mov  bx,cx
      call @@1000
      jmp  @@1111

@@1000:                ; function to split a word in to 4 character calls
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
@@1010:                 ; function print half byte (dl) as hex
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

   mov  ax,04C00h    ;exit .com file
   int 21h

section .data

section .bss