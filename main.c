#include <stdio.h>
#include "turing.h"

int yyparse();

int main() {
    int resultado = yyparse();

    if (resultado == 0 && maquina_definida) {
    inicializar_cinta("000");

    printf("\nCinta inicial:\n");
    mostrar_cinta();

    ejecutar_maquina();
}

    return resultado;
}