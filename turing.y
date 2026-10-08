%{
#include <stdio.h>
#include <string.h>

/* Flex genera esta función */
int yylex();

/* Bison usa esta función para reportar errores sintácticos */
void yyerror(const char *s);

#define MAX_ESTADOS 100
#define MAX_SIMBOLOS 100
#define MAX_TRANSICIONES 100

char *tabla_estados[MAX_ESTADOS];
int cantidad_estados = 0;

char *tabla_simbolos[MAX_SIMBOLOS];
int cantidad_simbolos = 0;


/* Funciones para estados */
void agregar_estado(char *nombre);
int existe_estado(char *nombre);


/* Funciones para simbolos */
void agregar_simbolo(char *simbolo);
int existe_simbolo(char *simbolo);


/* Tipos de movimiento */
typedef enum {
    MOV_IZQ,
    MOV_DER,
    MOV_QUIETO
} TipoMovimiento;


/* Representación interna completa de una transición */
typedef struct {
    char *estado_origen;
    char *simbolo_leido;
    char *estado_destino;
    char *simbolo_escrito;
    TipoMovimiento movimiento;
} Transicion;

Transicion tabla_transiciones[MAX_TRANSICIONES];
int cantidad_transiciones = 0;


/* Funciones para transiciones */
int existe_transicion(char *estado, char *simbolo);

void agregar_transicion(
    char *estado_origen,
    char *simbolo_leido,
    char *estado_destino,
    char *simbolo_escrito,
    TipoMovimiento movimiento
);


%}


/* Estos nombres son tokens.
   En la gramática funcionan como símbolos terminales.
   Son los símbolos que pueden llegar desde Flex. */

%token MAQUINA
%token ALFABETO
%token ESTADOS
%token INICIAL
%token FINALES
%token TRANSICIONES

%token IZQ
%token DER
%token QUIETO

%token SUBRUTINA
%token USA


%token LLAVE_IZQ
%token LLAVE_DER
%token DOS_PUNTOS
%token PUNTO_COMA
%token COMA
%token FLECHA
%token PARENTESIS_IZQ
%token PARENTESIS_DER

%union {
    char *texto;
    int numero;
}
%token <texto> ID
%token <texto> SIMBOLO
%token <numero> NUMERO
%type <numero> movimiento
%%


/* Un programa está compuesto por una o más declaraciones.
   Cada declaración puede ser una máquina o una subrutina */
programa:
    declaracion
    |
    programa declaracion
;


/* Una declaración puede corresponder a una máquina o a una subrutina. */
declaracion:
    maquina
    |
    subrutina
;

maquina:
    MAQUINA ID LLAVE_IZQ
    alfabeto
    estados
    inicial
    finales
    usos_opcionales
    transiciones
    LLAVE_DER
;


/* Una subrutina puede definirse sin parámetros o con un parámetro identificado mediante un ID*/
subrutina:
    SUBRUTINA ID LLAVE_IZQ
    estados
    inicial
    finales
    transiciones
    LLAVE_DER
    |
    SUBRUTINA ID PARENTESIS_IZQ ID PARENTESIS_DER
    LLAVE_IZQ
    estados
    inicial
    finales
    transiciones
    LLAVE_DER
;


/* Invocación de una subrutina sin parámetros.
   Ejemplo:
   usa mover;
*/
uso_subrutina:
    USA ID PUNTO_COMA
    |
    USA ID PARENTESIS_IZQ NUMERO PARENTESIS_DER PUNTO_COMA
;


/* Una lista contiene una o más invocaciones de subrutinas. */
lista_usos:
    uso_subrutina
    |
    lista_usos uso_subrutina
;

/* Una máquina puede no utilizar subrutinas,
   o puede contener una lista de invocaciones.
   %empty esta producción también puede no consumir ningún token. */
usos_opcionales:
    %empty
    |
    lista_usos
;

alfabeto:
    ALFABETO LLAVE_IZQ lista_simbolos LLAVE_DER
 {
        if (!existe_simbolo("'_'")) {
            printf("ERROR SEMANTICO: el alfabeto debe incluir el simbolo blanco '_'.\n");
        }
    }
; /* Un alfabeto tiene la palabra reservada alfabeto, luego {, una lista de símbolos y }.*/

/* Una lista puede contener un solo símbolo o una lista seguida de coma y otro símbolo. */
lista_simbolos:
    SIMBOLO
    {
        agregar_simbolo($1);
    }
    |
    lista_simbolos COMA SIMBOLO
    {
        agregar_simbolo($3);
    }
;

estados:
    ESTADOS LLAVE_IZQ lista_estados_declarados  LLAVE_DER
;
lista_estados_declarados:
    ID
    {
        agregar_estado($1);
    }
    |
    lista_estados_declarados COMA ID
    {
        agregar_estado($3);
    }
;

lista_estados:
    ID
    {
        if (existe_estado($1)) {
            printf("Estado final valido: %s\n", $1);
        } else {
            printf("ERROR SEMANTICO: el estado final '%s' no fue declarado.\n", $1);
        }
    }
    |
    lista_estados COMA ID
    {
        if (existe_estado($3)) {
            printf("Estado final valido: %s\n", $3);
        } else {
            printf("ERROR SEMANTICO: el estado final '%s' no fue declarado.\n", $3);
        }
    }
;

inicial:
    INICIAL DOS_PUNTOS ID PUNTO_COMA
    {
        if (existe_estado($3)) {
            printf("Estado inicial valido: %s\n", $3);
        } else {
            printf("ERROR SEMANTICO: el estado inicial '%s' no fue declarado.\n", $3);
        }
    }
;

finales:
    FINALES DOS_PUNTOS LLAVE_IZQ lista_estados LLAVE_DER PUNTO_COMA
;

transiciones:
    TRANSICIONES LLAVE_IZQ lista_transiciones LLAVE_DER
;

lista_transiciones:
    transicion
    |
    lista_transiciones transicion
;

transicion:
    ID COMA SIMBOLO FLECHA ID COMA SIMBOLO COMA movimiento PUNTO_COMA
    {
        if (!existe_estado($1)) {
            printf("ERROR SEMANTICO: el estado origen '%s' no fue declarado.\n", $1);
        }

        if (!existe_estado($5)) {
            printf("ERROR SEMANTICO: el estado destino '%s' no fue declarado.\n", $5);
        }

        if (!existe_simbolo($3)) {
            printf("ERROR SEMANTICO: el simbolo leido %s no pertenece al alfabeto.\n", $3);
        }

        if (!existe_simbolo($7)) {
            printf("ERROR SEMANTICO: el simbolo escrito %s no pertenece al alfabeto.\n", $7);
        }

        if (existe_transicion($1, $3)) {
            printf(
                "ERROR SEMANTICO: ya existe una transicion para (%s, %s).\n",
                $1,
                $3
            );
        } else {
            agregar_transicion($1, $3, $5, $7, $9);
        }
    }
;



movimiento:
    IZQ
    {
        $$ = MOV_IZQ;
    }
    |
    DER
    {
        $$ = MOV_DER;
    }
    |
    QUIETO
    {
        $$ = MOV_QUIETO;
    }
;




%%

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

/* Bison llama a esta función cuando encuentra un error sintáctico. */
void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
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



/* El programa inicia llamando al parser.
   yyparse() pedirá tokens a yylex() cuando los necesite. */
int main() {
    return yyparse();
}