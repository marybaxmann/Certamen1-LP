#include <stdio.h>
#include "turing.h"

int yyparse();

int main(int argc, char *argv[]) {
    int resultado = yyparse();

    if (resultado == 0 && maquina_definida) {
        const char *entrada = (argc > 1) ? argv[1] : "000";
        inicializar_cinta(entrada);

        printf("\nCinta inicial:\n");
        mostrar_cinta();

        ejecutar_maquina();
    }

    return resultado;
}