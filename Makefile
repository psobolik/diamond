EXE = diamond
ASMFLAGS = --64 --gdwarf-2 -mintel64 -mmnemonic=intel -msyntax=intel -mnaked-reg
SOURCES = $(EXE).s get_size.s
OBJECTS = $(SOURCES:.s=.o)
LDFLAGS = -e main

all: $(EXE)

$(EXE): $(OBJECTS)
	ld $(LDFLAGS) $^ -o $@

%.o:%.s
	as $(ASMFLAGS) $^ -o $@

run: $(EXE)
	./$(EXE)

clean:
	rm $(EXE) $(OBJECTS)

