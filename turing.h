#ifndef TURING_H
#define TURING_H

#define MAX_ESTADOS 100
#define MAX_SIMBOLOS 100
#define MAX_TRANSICIONES 100
#define TAM_CINTA 100
#define MAX_FINALES 100

#define MAX_SUBRUTINAS 20
#define MAX_TRANSICIONES_SUBRUTINA 100


typedef enum {
    MOV_IZQ,
    MOV_DER,
    MOV_QUIETO
} TipoMovimiento;


typedef struct {
    char *estado_origen;
    char *simbolo_leido;
    char *estado_destino;
    char *simbolo_escrito;
    TipoMovimiento movimiento;
} Transicion;


/* Representación de una subrutina */


typedef struct {
    char *nombre;
    char *parametro;

    char *estados[MAX_ESTADOS];
    int cantidad_estados;

    char *estado_inicial;

    char *finales[MAX_FINALES];
    int cantidad_finales;

    Transicion transiciones[MAX_TRANSICIONES_SUBRUTINA];
    int cantidad_transiciones;
} Subrutina;

extern char *tabla_estados[MAX_ESTADOS];
extern int cantidad_estados;

extern char *tabla_simbolos[MAX_SIMBOLOS];
extern int cantidad_simbolos;

extern Transicion tabla_transiciones[MAX_TRANSICIONES];
extern int cantidad_transiciones;

extern char *tabla_finales[MAX_FINALES];
extern int cantidad_finales;

extern char *estado_actual;

extern char cinta[TAM_CINTA];
extern int posicion_cabezal;

extern Subrutina tabla_subrutinas[MAX_SUBRUTINAS];
extern int cantidad_subrutinas;

extern Subrutina *subrutina_actual;
extern int dentro_subrutina;
extern int maquina_definida;


void agregar_estado(char *nombre);
int existe_estado(char *nombre);

void agregar_simbolo(char *simbolo);
int existe_simbolo(char *simbolo);

void agregar_transicion(
    char *estado_origen,
    char *simbolo_leido,
    char *estado_destino,
    char *simbolo_escrito,
    TipoMovimiento movimiento
);
int existe_transicion(char *estado, char *simbolo);
Transicion *buscar_transicion(char *estado, char *simbolo);

void agregar_estado_final(char *nombre);
int es_estado_final(char *nombre);

void inicializar_cinta(const char *entrada);
void mostrar_cinta();
void convertir_simbolo(char simbolo, char resultado[4]);
void ejecutar_transicion(Transicion *t);
void ejecutar_maquina();
void agregar_subrutina(char *nombre, char *parametro);
Subrutina *buscar_subrutina(char *nombre);

int validar_alfabeto_subrutina(Subrutina *s);
int expandir_subrutina(Subrutina *s, int repeticiones);

#endif
