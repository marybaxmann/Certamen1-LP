%{
#include <stdio.h>

/* Existe una función llamada yylex() que será generada por Flex
   y que entregará tokens al parser de Bison. */
int yylex();

/* Función que Bison utilizará para reportar errores sintácticos. */
void yyerror(const char *s);

#define MAX_ESTADOS 100

char *tabla_estados[MAX_ESTADOS];
int cantidad_estados = 0;

void agregar_estado(char *nombre);
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
; /* Un alfabeto tiene la palabra reservada alfabeto, luego {, una lista de símbolos y }.*/

/* Una lista puede contener un solo símbolo o una lista seguida de coma y otro símbolo. */
lista_simbolos:
    SIMBOLO
    |
    lista_simbolos COMA SIMBOLO
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
    |
    lista_estados COMA ID
;

inicial:
    INICIAL DOS_PUNTOS ID PUNTO_COMA
    {
        printf("Estado inicial recibido: %s\n", $3);
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
;

movimiento:
    IZQ
    |
    DER
    |
    QUIETO
;




%%

void agregar_estado(char *nombre) {
    if (cantidad_estados < MAX_ESTADOS) {
        tabla_estados[cantidad_estados] = nombre;
        cantidad_estados++;

        printf("Estado guardado: %s\n", nombre);
    }
}

/* Bison llama a esta función cuando encuentra un error sintáctico. */
void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
}


/* El programa inicia llamando al parser.
   yyparse() pedirá tokens a yylex() cuando los necesite. */
int main() {
    return yyparse();
}