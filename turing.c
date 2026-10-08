#include <stdio.h>
#include <string.h>

#include "turing.h"

char *tabla_estados[MAX_ESTADOS];
int cantidad_estados = 0;

char *tabla_simbolos[MAX_SIMBOLOS];
int cantidad_simbolos = 0;

Transicion tabla_transiciones[MAX_TRANSICIONES];
int cantidad_transiciones = 0;

char *tabla_finales[MAX_FINALES];
int cantidad_finales = 0;

char *estado_actual = NULL;

void agregar_estado(char *nombre) {
    if (cantidad_estados < MAX_ESTADOS) {
        tabla_estados[cantidad_estados] = nombre;
        cantidad_estados++;

        printf("Estado guardado: %s\n", nombre);
    }
}

int existe_estado(char *nombre) {
    for (int i = 0; i < cantidad_estados; i++) {
        if (strcmp(tabla_estados[i], nombre) == 0) {
            return 1;
        }
    }

    return 0;
}

void agregar_simbolo(char *simbolo) {
    if (cantidad_simbolos < MAX_SIMBOLOS) {
        tabla_simbolos[cantidad_simbolos] = simbolo;
        cantidad_simbolos++;

        printf("Simbolo guardado: %s\n", simbolo);
    }
}

int existe_simbolo(char *simbolo) {
    for (int i = 0; i < cantidad_simbolos; i++) {
        if (strcmp(tabla_simbolos[i], simbolo) == 0) {
            return 1;
        }
    }

    return 0;
}

void agregar_transicion(
    char *estado_origen,
    char *simbolo_leido,
    char *estado_destino,
    char *simbolo_escrito,
    TipoMovimiento movimiento
) {
    if (cantidad_transiciones < MAX_TRANSICIONES) {
        tabla_transiciones[cantidad_transiciones].estado_origen = estado_origen;
        tabla_transiciones[cantidad_transiciones].simbolo_leido = simbolo_leido;
        tabla_transiciones[cantidad_transiciones].estado_destino = estado_destino;
        tabla_transiciones[cantidad_transiciones].simbolo_escrito = simbolo_escrito;
        tabla_transiciones[cantidad_transiciones].movimiento = movimiento;

        printf(
            "Transicion guardada: %s, %s -> %s, %s, movimiento=%d\n",
            estado_origen,
            simbolo_leido,
            estado_destino,
            simbolo_escrito,
            movimiento
        );

        cantidad_transiciones++;
    }
}

int existe_transicion(char *estado, char *simbolo) {
    for (int i = 0; i < cantidad_transiciones; i++) {
        if (
            strcmp(tabla_transiciones[i].estado_origen, estado) == 0 &&
            strcmp(tabla_transiciones[i].simbolo_leido, simbolo) == 0
        ) {
            return 1;
        }
    }

    return 0;
}

Transicion *buscar_transicion(char *estado, char *simbolo) {
    for (int i = 0; i < cantidad_transiciones; i++) {
        if (
            strcmp(tabla_transiciones[i].estado_origen, estado) == 0 &&
            strcmp(tabla_transiciones[i].simbolo_leido, simbolo) == 0
        ) {
            return &tabla_transiciones[i];
        }
    }

    return NULL;
}

void agregar_estado_final(char *nombre) {
    if (cantidad_finales < MAX_FINALES) {
        tabla_finales[cantidad_finales] = nombre;
        cantidad_finales++;
    }
}

int es_estado_final(char *nombre) {
    for (int i = 0; i < cantidad_finales; i++) {
        if (strcmp(tabla_finales[i], nombre) == 0) {
            return 1;
        }
    }

    return 0;
}
