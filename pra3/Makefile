all: pract3.exe prueba.exe

prueba.exe: prueba.obj
	tlink /v prueba

prueba.obj: prueba.asm
	tasm /zi prueba.asm,,prueba.lst

pract3.exe: pract3.obj pract3a.obj pract3b.obj
	tcc -v -ml -Lc:\compila\tc\lib pract3.obj pract3a.obj pract3b.obj
pract3.obj: pract3.c
	tcc -c -v -ml -Ic:\compila\tc\include pract3.c
pract3a.obj: pract3a.asm
	tasm /zi /ml pract3a,,pract3a
pract3b.obj: pract3b.asm
	tasm /zi /ml pract3b,,pract3b

clean:
	del *.obj
	del *.exe
	del *.lst
