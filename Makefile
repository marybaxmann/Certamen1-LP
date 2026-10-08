CC = gcc
CFLAGS = -Wall -Wextra
LEX = flex
YACC = bison

# Desactivar reglas implicitas de make que intentan generar *.c a partir de *.y o *.l
.SUFFIXES:
%.c: %.y
%.c: %.l

TARGET = turing

SOURCES = main.c turing.c interprete.c turing.tab.c lex.yy.c

all: $(TARGET)

$(TARGET): turing.tab.c lex.yy.c main.c turing.c interprete.c turing.h
	$(CC) $(CFLAGS) $(SOURCES) -lfl -o $(TARGET)

turing.tab.c turing.tab.h: turing.y
	$(YACC) -d turing.y

lex.yy.c: turing.l turing.tab.h
	$(LEX) turing.l

run: $(TARGET)
	./$(TARGET) < prueba.tm

run-subrutina: $(TARGET)
	./$(TARGET) < uso_subrutina.tm

run-incrementador: $(TARGET)
	./$(TARGET) 1011 < incrementador.tm

run-sumador: $(TARGET)
	./$(TARGET) "11+111" < sumador_unario.tm

clean:
	rm -f $(TARGET) turing.exe turing.tab.c turing.tab.h lex.yy.c *.o

.PHONY: all run run-subrutina run-incrementador run-sumador clean