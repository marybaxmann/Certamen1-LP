#include <stdio.h>

#include "turing.h"

char cinta[TAM_CINTA];
int posicion_cabezal = 0;

void inicializar_cinta(const char *entrada) {
    /* Primero llenamos toda la cinta con blancos */
    for (int i = 0; i < TAM_CINTA; i++) {
        cinta[i] = '_';
    }

    /* Luego copiamos la entrada al comienzo de la cinta */
    int i = 0;

    while (entrada[i] != '\0' && i < TAM_CINTA) {
        cinta[i] = entrada[i];
        i++;
    }

    /* El cabezal comienza en la primera posición */
    posicion_cabezal = 0;
}

void mostrar_cinta() {
    for (int i = 0; i < 10; i++) {
        if (i == posicion_cabezal) {
            printf("[%c]", cinta[i]);
        } else {
            printf(" %c ", cinta[i]);
        }
    }

    printf("\n");
}

void convertir_simbolo(char simbolo, char resultado[4]) {
    resultado[0] = '\'';
    resultado[1] = simbolo;
    resultado[2] = '\'';
    resultado[3] = '\0';
}

void ejecutar_transicion(Transicion *t) {
    /* 1. Escribir el nuevo símbolo en la cinta */
    cinta[posicion_cabezal] = t->simbolo_escrito[1];

    /* 2. Cambiar al estado destino */
    estado_actual = t->estado_destino;

    /* 3. Mover el cabezal */
    if (t->movimiento == MOV_IZQ) {
        posicion_cabezal--;
    }
    else if (t->movimiento == MOV_DER) {
        posicion_cabezal++;
    }
    else if (t->movimiento == MOV_QUIETO) {
        /* No cambia la posición */
    }
}
void ejecutar_maquina() {
    while (!es_estado_final(estado_actual)) {

        /* Evita leer fuera de los límites de la cinta */
        if (posicion_cabezal < 0 || posicion_cabezal >= TAM_CINTA) {
            printf("ERROR: el cabezal salio de los limites de la cinta.\n");
            return;
        }

        char simbolo_actual[4];

        convertir_simbolo(
            cinta[posicion_cabezal],
            simbolo_actual
        );

        Transicion *t =
            buscar_transicion(estado_actual, simbolo_actual);

        if (t == NULL) {
            printf(
                "Maquina detenida: no existe transicion para (%s, %s).\n",
                estado_actual,
                simbolo_actual
            );

            return;
        }

        printf(
            "\nAplicando: %s, %s -> %s, %s\n",
            t->estado_origen,
            t->simbolo_leido,
            t->estado_destino,
            t->simbolo_escrito
        );

        ejecutar_transicion(t);

        printf("Estado actual: %s\n", estado_actual);
        mostrar_cinta();
    }

    printf(
        "\nMaquina detenida en estado final: %s\n",
        estado_actual
    );
}