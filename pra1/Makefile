all: pract1a.exe pract1b.exe pract1c.exe

pract1a.exe: pract1a.obj
	tlink  /v pract1a

pract1a.obj: pract1a.asm
	tasm /zi pract1a.asm,,pract1a.lst
	
pract1b.exe: pract1b.obj
	tlink  /v pract1b

pract1b.obj: pract1b.asm
	tasm /zi pract1b.asm,,pract1b.lst

pract1c.exe: pract1c.obj
	tlink  /v pract1c

pract1c.obj: pract1c.asm
	tasm /zi pract1c.asm,,pract1c.lst
		
clean:
	del pract1a.obj
	del pract1b.obj
	del pract1c.obj
	del pract1a.lst
	del pract1b.lst
	del pract1c.lst
	del pract1a.exe
	del pract1b.exe
	del pract1c.exe
	del pract1a.map
	del pract1b.map
	del pract1c.map