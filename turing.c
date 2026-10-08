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

int maquina_definida = 0;

void agregar_estado(char *nombre) {
    if (dentro_subrutina && subrutina_actual != NULL) {
        if (subrutina_actual->cantidad_estados < MAX_ESTADOS) {
            subrutina_actual->estados[subrutina_actual->cantidad_estados] = nombre;
            subrutina_actual->cantidad_estados++;

            printf("Estado de subrutina guardado: %s\n", nombre);
        }

        return;
    }

    if (cantidad_estados < MAX_ESTADOS) {
        tabla_estados[cantidad_estados] = nombre;
        cantidad_estados++;

        printf("Estado guardado: %s\n", nombre);
    }
}

int existe_estado(char *nombre) {
    if (dentro_subrutina && subrutina_actual != NULL) {
        for (int i = 0; i < subrutina_actual->cantidad_estados; i++) {
            if (strcmp(subrutina_actual->estados[i], nombre) == 0) {
                return 1;
            }
        }

        return 0;
    }

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
    if (dentro_subrutina && subrutina_actual != NULL) {

        if (
            subrutina_actual->cantidad_transiciones
            < MAX_TRANSICIONES_SUBRUTINA
        ) {
            int i = subrutina_actual->cantidad_transiciones;

            subrutina_actual->transiciones[i].estado_origen = estado_origen;
            subrutina_actual->transiciones[i].simbolo_leido = simbolo_leido;
            subrutina_actual->transiciones[i].estado_destino = estado_destino;
            subrutina_actual->transiciones[i].simbolo_escrito = simbolo_escrito;
            subrutina_actual->transiciones[i].movimiento = movimiento;

            subrutina_actual->cantidad_transiciones++;

            printf(
                "Transicion de subrutina guardada: "
                "%s, %s -> %s, %s, movimiento=%d\n",
                estado_origen,
                simbolo_leido,
                estado_destino,
                simbolo_escrito,
                movimiento
            );
        }

        return;
    }

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
    if (dentro_subrutina && subrutina_actual != NULL) {

        for (
            int i = 0;
            i < subrutina_actual->cantidad_transiciones;
            i++
        ) {
            if (
                strcmp(
                    subrutina_actual->transiciones[i].estado_origen,
                    estado
                ) == 0
                &&
                strcmp(
                    subrutina_actual->transiciones[i].simbolo_leido,
                    simbolo
                ) == 0
            ) {
                return 1;
            }
        }

        return 0;
    }

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
    if (dentro_subrutina && subrutina_actual != NULL) {
        if (subrutina_actual->cantidad_finales < MAX_FINALES) {
            subrutina_actual->finales[
                subrutina_actual->cantidad_finales
            ] = nombre;

            subrutina_actual->cantidad_finales++;

            printf(
                "Estado final de subrutina guardado: %s\n",
                nombre
            );
        }

        return;
    }

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
Subrutina tabla_subrutinas[MAX_SUBRUTINAS];
int cantidad_subrutinas = 0;

void agregar_subrutina(char *nombre, char *parametro) {
    if (cantidad_subrutinas < MAX_SUBRUTINAS) {
        tabla_subrutinas[cantidad_subrutinas].nombre = nombre;
        tabla_subrutinas[cantidad_subrutinas].parametro = parametro;

        tabla_subrutinas[cantidad_subrutinas].cantidad_estados = 0;
        tabla_subrutinas[cantidad_subrutinas].estado_inicial = NULL;
        tabla_subrutinas[cantidad_subrutinas].cantidad_finales = 0;
        tabla_subrutinas[cantidad_subrutinas].cantidad_transiciones = 0;

        printf("Subrutina guardada: %s\n", nombre);

        cantidad_subrutinas++;
    }
}
Subrutina *buscar_subrutina(char *nombre) {
    for (int i = 0; i < cantidad_subrutinas; i++) {
        if (strcmp(tabla_subrutinas[i].nombre, nombre) == 0) {
            return &tabla_subrutinas[i];
        }
    }

    return NULL;
}

Subrutina *subrutina_actual = NULL;
int dentro_subrutina = 0;
int validar_alfabeto_subrutina(Subrutina *s) {
    int valida = 1;

    for (int i = 0; i < s->cantidad_transiciones; i++) {
        Transicion *t = &s->transiciones[i];

        if (!existe_simbolo(t->simbolo_leido)) {
            printf(
                "ERROR SEMANTICO: la subrutina '%s' usa el simbolo leido %s, "
                "que no pertenece al alfabeto de la maquina.\n",
                s->nombre,
                t->simbolo_leido
            );

            valida = 0;
        }

        if (!existe_simbolo(t->simbolo_escrito)) {
            printf(
                "ERROR SEMANTICO: la subrutina '%s' usa el simbolo escrito %s, "
                "que no pertenece al alfabeto de la maquina.\n",
                s->nombre,
                t->simbolo_escrito
            );

            valida = 0;
        }
    }

    return valida;
}
int expandir_subrutina(Subrutina *s, int repeticiones) {
    if (repeticiones <= 0) {
        printf(
            "ERROR SEMANTICO: la cantidad de repeticiones debe ser mayor que 0.\n"
        );
        return 0;
    }

    char *inicio_maquina = estado_actual;

    for (int r = 1; r <= repeticiones; r++) {

        printf(
            "Expansion %d de la subrutina %s:\n",
            r,
            s->nombre
        );

        /* 1. Crear los estados de esta copia */
        for (int i = 0; i < s->cantidad_estados; i++) {
            char nombre_nuevo[200];

            snprintf(
                nombre_nuevo,
                sizeof(nombre_nuevo),
                "%s_%d_%s",
                s->nombre,
                r,
                s->estados[i]
            );

            char *estado_generado = strdup(nombre_nuevo);

            agregar_estado(estado_generado);

            printf(
                "  Estado generado: %s\n",
                estado_generado
            );
        }

        /* 2. Copiar las transiciones usando los nuevos nombres */
        for (int i = 0; i < s->cantidad_transiciones; i++) {
            Transicion *original = &s->transiciones[i];

            char origen_nuevo[200];
            char destino_nuevo[200];

            snprintf(
                origen_nuevo,
                sizeof(origen_nuevo),
                "%s_%d_%s",
                s->nombre,
                r,
                original->estado_origen
            );

            snprintf(
                destino_nuevo,
                sizeof(destino_nuevo),
                "%s_%d_%s",
                s->nombre,
                r,
                original->estado_destino
            );

            char *origen = strdup(origen_nuevo);
            char *destino = strdup(destino_nuevo);

            if (!existe_transicion(origen, original->simbolo_leido)) {
                agregar_transicion(
                    origen,
                    original->simbolo_leido,
                    destino,
                    original->simbolo_escrito,
                    original->movimiento
                );
            } else {
                printf(
                    "ERROR SEMANTICO: colision al expandir (%s, %s).\n",
                    origen,
                    original->simbolo_leido
                );
                return 0;
            }
        }
    }

    /* 3. Conectar una copia con la siguiente */
    for (int r = 1; r < repeticiones; r++) {

        for (int f = 0; f < s->cantidad_finales; f++) {

            char final_actual[200];
            char inicial_siguiente[200];

            snprintf(
                final_actual,
                sizeof(final_actual),
                "%s_%d_%s",
                s->nombre,
                r,
                s->finales[f]
            );

            snprintf(
                inicial_siguiente,
                sizeof(inicial_siguiente),
                "%s_%d_%s",
                s->nombre,
                r + 1,
                s->estado_inicial
            );

            for (int j = 0; j < cantidad_simbolos; j++) {

                char *simbolo = tabla_simbolos[j];

                if (existe_transicion(final_actual, simbolo)) {
                    printf(
                        "ERROR SEMANTICO: no se puede conectar (%s, %s) "
                        "porque ya existe una transicion.\n",
                        final_actual,
                        simbolo
                    );

                    return 0;
                }

                agregar_transicion(
                    strdup(final_actual),
                    simbolo,
                    strdup(inicial_siguiente),
                    simbolo,
                    MOV_QUIETO
                );
            }
        }
    }

    /* 4. Conectar la ultima copia con el inicio original de la maquina */
    for (int f = 0; f < s->cantidad_finales; f++) {

        char ultimo_final[200];

        snprintf(
            ultimo_final,
            sizeof(ultimo_final),
            "%s_%d_%s",
            s->nombre,
            repeticiones,
            s->finales[f]
        );

        for (int j = 0; j < cantidad_simbolos; j++) {

            char *simbolo = tabla_simbolos[j];

            if (existe_transicion(ultimo_final, simbolo)) {
                printf(
                    "ERROR SEMANTICO: no se puede conectar (%s, %s) "
                    "con la maquina porque ya existe una transicion.\n",
                    ultimo_final,
                    simbolo
                );

                return 0;
            }

            agregar_transicion(
                strdup(ultimo_final),
                simbolo,
                inicio_maquina,
                simbolo,
                MOV_QUIETO
            );
        }
    }

    /* 5. Hacer que la ejecucion comience en la primera copia */
    char primer_inicio[200];

    snprintf(
        primer_inicio,
        sizeof(primer_inicio),
        "%s_1_%s",
        s->nombre,
        s->estado_inicial
    );

    estado_actual = strdup(primer_inicio);

    printf(
        "Nuevo estado inicial por composicion: %s\n",
        estado_actual
    );

    return 1;
}