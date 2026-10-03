; compile with --> nasm F1692B.asm -fbin -o F1692B.com
;   bits 16
   cpu 286
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
      mov byte[cs:start_ms],dl     ; Start ms
      mov byte[cs:start_s],dh      ; Start sek
      mov byte[cs:start_m],cl      ; Start min
      mov byte[cs:start_h],ch      ; Start h


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
   mov  [di],dl      ; r 0...63
   mov  [di+1],bx    ; g 0, b 0
   add  di,3
   inc  dl
   loop @@002
   mov  cx,63
   mov  dl,1
@@003:
   mov  [di],al      ; r 63
   mov  [di+1],dl    ; g 1..63
   mov  [di+2],dh    ; b 0
   add  di,3
   inc  dl
   loop @@003
   mov  cx,63
   mov  dl,1
@@004:
   mov  [di],ax      ; r 63, g 63
   mov  [di+2],dl    ; b 1..63
   add  di,3
   inc  dl
   loop @@004
   mov  cx,99           ; die uebrigen 66 Farben auf 63,63,63 setzen = 99mal 2Bytes=1Word
@@005:
   mov  [di],ax
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
   mov  cx,32000       ; bei .com Datei keine 64kB loeschen, sondern nur 32000w = 64000byte, sonst wird der Stack ueberschrieben... der liegt scheinbar im naechsten Segment
@@006:
   mov  [di],dx
   add  di,2
   loop @@006

   mov  ax,02D7Ah     ; bel. Zahl
   push ax            ; Zuvallszahl in Stack sichern

      ; Benchmark      --> nicht mehr notwendig, da wir mit dem .data section arbeiten und dort die Variable bereits auf 200 gesetzt ist
      ;mov  di,64200
      ;mov  ax,200             ; Benchmark 200=ok
      ;mov  [di],ax   ; setze Zaehler fuer Anzahl durchlaeufe    Hinweis: [ds:di+64200] = di-0x538h, da das Vorzeichen beruecksichtigt wird!!!!

   align 2
@@010:                ; setze neue weisse Punkte am untern Bildrand
   mov  cx,60         ; Setze Zaehler auf XXX
   align 2
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
   mov  [di],dl           ;[ds:di]
   mov  [di+318],dx       ;[ds:di+xxx]
   mov  [di+320],dx       ;[ds:di+xxx]
   ; mov  cx,si      ; Lade Zaehler zurueck in cx fuer loop
   mov  [di+638],dx       ;[ds:di+xxx]
   loop @@011

   mov  di,1        ; Berechne Bild    <-- vielleicht mal auf 0 setzen?
   xor  bx,bx
   xor  cx,cx
   mov  si,31520      ;warum eigentlich 31520? vergessen...

   mov  dx,[di+639]
   align 2
@@100:
   xor  ah,ah      ; ah auf 0 setzen, da es aus dem letzten Lauf noch Werte enthalten kann
   mov  al,dl      ; dx hat noch Wert von di+641 aus letzem Lauf, was jetzt di+639 ist
   mov  bl,dh
   mov  dx,[di+319]     ;ds:di+xxx
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,[di+321]     ;ds:di+xxx
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,[di+959]     ;ds:di+xxx
   mov  cl,dl
   add  ax,cx
   mov  cl,dh
   add  ax,cx
   add  bx,cx
   mov  dx,[di+961]     ;ds:di+xxx
   mov  cl,dl
   add  ax,cx
   add  bx,cx
   mov  cl,dh
   add  bx,cx
   mov  dx,[di+641]   ; dx ist im nachsten Lauf der Wert von ds:di+639 und muss nicht noch mal gelesen werden
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
   mov  [di],ax    ; Schreibe beide Punkte in Puffer
   ;mov  [es:di],ax    ; Schreibe beide Punkte in Videospeicher (4B 3T)
   ;add  di,2             ; 4B 3T
   inc  di        ; 2x 1B 2T=2B 4T
   inc  di
   dec  si
   jnz @@100

                  ; kopiere Puffer in Videospeicher - ist minimal schneller
   xor  di,di    
   mov  cx,32000  ; fuer alle 64.000 Byte bei 320x200
   rep  movsw     ; 1B 5T        mov [es:di],[ds:si]

   in  al,60h
   cmp al,1
   ;jnz @@010      ; fuer Benschmark deaktiviert

      jz @@103               ; \             
      ;mov ax,1               ;  |            
      ;mov si,64200           ;  |            
      ;sub [si],ax         ;  | Code fuer
      sub word[cs:count],1
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

;      pop  bx        ; Benchmark: Zeitstempel vom Start zurueckholen
;      call @@print_BX_hex
;      pop  bx
;      call @@print_BX_hex
;      ; AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec
;      mov  ah,02Ch
;      int 21h
;      mov  bx,cx
;      mov  cx,dx
;      call @@print_BX_hex
;      mov  bx,cx
;      call @@print_BX_hex
;      jmp  @@exit


      mov  ah,02Ch     ; AH=2Ch get system time  CH=hour, CL=minute, DH=second, DL=1/100sec
      int 21h
                       ; lege die Werte in der Verarbeitungsreihenfolge im Stack ab
      mov byte[cs:stop_ms],dl      ; Stopp ms
      mov byte[cs:stop_s],dh       ; Stopp sek 
      mov byte[cs:stop_m],cl       ; Stopp min
      mov byte[cs:stop_h],ch       ; Stopp h

      xor  ax,ax       ; Arbeitsregister auf 0 setzen
      xor  bx,bx
      xor  cx,cx
                    ; Step 1: Stunden
      mov  bl,[cs:start_h]          ; lade Start h in bx
      mov  al,[cs:stop_h]          ; lade Stopp h in ax
      sub  ax,bx
      jnc @@kein_Tagesueberlauf
      mov  ax,1
@@kein_Tagesueberlauf:
      mul  word[cs:sec_per_h]           ; mul ax * 3600 -> Ergebnis in ax+dx (dx = higher bits)
      mov  cx,ax       ; Egebnis in CX kopieren... hier sammeln wir das Ergebnis
      xor  ax,ax       ; ax wieder auf 0 setzen um es wieder zu verwednen

                    ; Step 2: Minuten
      mov  bl,[cs:start_m]          ; lade Start min in bx
      mov  al,[cs:stop_m]          ; lade Stopp min in ax
      sub  al,bl
      imul byte[cs:sec_per_min]           ; vorzeichen mul al * 60 -> Ergebnis in ax
      add  cx,ax
      xor  ax,ax

                    ; Step 3: Sekunden
      mov  bl,[cs:start_s]          ; lade Start sek in bx
      mov  al,[cs:stop_s]          ; lade Stopp sek in ax
      sub  ax,bx
      add  cx,ax
      xor  ax,ax

                    ; Step 4: Millisekunden
      mov  bl,[cs:start_ms]          ; lade Start ms in bx
      mov  al,[cs:stop_ms]          ; lade Stopp ms in ax
      sub  al,bl
      jnc @@kein_Millisekueberlauf
      dec  cx
      add  al,100
@@kein_Millisekueberlauf:

         ; CX = Differenz zwischen Start und Stopp in Sekunden
         ; AL = den zusaetzlichen Millisekundenwert der Differenz

      push ax
      mov  bx,cx
      call @@print_BX_hex
      xor  bx,bx
      pop  ax
      mov  bl,al                  ;lade gesicherten AL Wert in BL
      call @@print_BX_hex

      jmp @@exit

@@print_BX_hex:                ; function to split a word in to 4 character calls
      mov  dl,bh
      shr  dl,4
      call @@print_one_hex_char
      mov  dl,bh
      and  dl,00Fh
      call @@print_one_hex_char
      mov  dl,bl
      shr  dl,4
      call @@print_one_hex_char
      mov  dl,bl
      and  dl,00Fh
      call @@print_one_hex_char
      ret
@@print_one_hex_char:                 ; function print half byte (dl) as hex
      add  dl,030h
      cmp  dl,039h
      jna @@1011
      add  dl,7
@@1011:
      mov  ah,02h
      int 21h
      ret


@@exit:

   pop  si
   pop  di
   pop  es
   pop  ds

   mov  ax,04C00h    ;exit .com file
   int 21h

section .data
align 2
count        dw  200    ; Anzahl zu berechnender Bilder fuer Benchmark
stop_ms      db  0      ; Stopp ms
start_ms     db  0      ; Start ms
stop_s       db  0      ; Stopp sek 
start_s      db  0      ; Start sek
stop_m       db  0      ; Stopp min
start_m      db  0      ; Start min
stop_h       db  0      ; Stopp h
start_h      db  0      ; Start h
sec_per_h    dw  3600   ; Sekunden pro Stunde fuer Multiplikation
sec_per_min  db  60     ; Sekunden pro Minute fuer Multipliktion

section .bss