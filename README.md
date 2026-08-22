# Fire.pas
Turbo Pascal assembly: a fire graphic demo on 320x200 256 colors

I wrote this Tubro Pascal programms from September 1997 up to December 1999.
I found the idea in a broken source code without the right colors. After I analysed the code, I write a completly new code in assembly and optimized and speed up to run this slowly on a 80286 at 16Mhz.

## Screenshot

![Fire_Screenshot](https://github.com/user-attachments/assets/58401fc5-1620-48b0-8246-5d4ce171d110)

## Filedescriptions
### fire16xx.pas
These are the 16bit version of the program.

The fire1670.pas is the first version in assembly only.

The versions fire1691.pas are the best version and the other are older versions. This version get his last update on August 2026.

### fire32xx.pas
These are the 32bit versions of the program.

The version fire3205.pas are maybe the best version and the other under construction (i'm not realy sure).

### firev201.pas
This is a 32bit version for the interesting smal assemply operation system calles V2os. You must compile the code only into a file and cut the program code between "start->" and "<-stop" into a file. This program code can run under V2os.

Currently not clear is: In this code i use 32bit assembly commands insted of the opcodes but Turbo Pascal dont support these. I can't remember how i compile this.

More informazion about V2os can you find here: https://v2.nl/works/v2_os
