#include <stdio.h>

int yyparse();

typedef struct {
    char *estado_origen;
    char *simbolo_leido;
    char *estado_destino;
    char *simbolo_escrito;
    int movimiento;
} Transicion;


/* Funciones */
void inicializar_cinta(const char *entrada);
void mostrar_cinta();
void convertir_simbolo(char simbolo, char resultado[4]);
void ejecutar_transicion(Transicion *t);

Transicion *buscar_transicion(char *estado, char *simbolo);


/* Variables que están definidas en turing.y */
extern char *estado_actual;
extern char cinta[];
extern int posicion_cabezal;


int main() {
    int resultado = yyparse();

    if (resultado == 0) {
        inicializar_cinta("01");

        printf("\nCinta inicial:\n");
        mostrar_cinta();

        char simbolo_actual[4];

        convertir_simbolo(
            cinta[posicion_cabezal],
            simbolo_actual
        );

        printf(
            "Estado actual: %s\nSimbolo leido: %s\n",
            estado_actual,
            simbolo_actual
        );

        Transicion *t =
            buscar_transicion(estado_actual, simbolo_actual);

        if (t != NULL) {
            printf(
                "Transicion aplicable: %s, %s -> %s, %s, movimiento=%d\n",
                t->estado_origen,
                t->simbolo_leido,
                t->estado_destino,
                t->simbolo_escrito,
                t->movimiento
            );

            ejecutar_transicion(t);

            printf("\nDespues de ejecutar una transicion:\n");
            printf("Estado actual: %s\n", estado_actual);
            mostrar_cinta();
        }
    }

    return resultado;
}