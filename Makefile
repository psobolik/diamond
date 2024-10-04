EXE = diamond
NASMFLAGS = -Wall -felf64 -F dwarf -g
SOURCES = $(EXE).asm get_size.asm
OBJECTS = $(SOURCES:.asm=.o)
LDFLAGS =

all: $(EXE)

$(EXE): $(OBJECTS)
	ld $(LDFLAGS) $^ -o $@

%.o:%.asm
	nasm $(NASMFLAGS) $^ -o $@ -l $(*F).lst

run: $(EXE)
	./$(EXE)

clean:
	rm $(EXE) $(OBJECTS)

