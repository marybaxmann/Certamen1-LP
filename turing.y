%{
#include <stdio.h>

/* Existe una función llamada yylex() que será generada por Flex
   y que entregará tokens al parser de Bison. */
int yylex();

/* Función que Bison utilizará para reportar errores sintácticos. */
void yyerror(const char *s);
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

%token ID
%token NUMERO
%token SIMBOLO

%token LLAVE_IZQ
%token LLAVE_DER
%token DOS_PUNTOS
%token PUNTO_COMA
%token COMA
%token FLECHA
%token PARENTESIS_IZQ
%token PARENTESIS_DER


%%


/* "programa" es un símbolo no terminal.
   Un programa, por ahora, está compuesto por una sola máquina. */
programa:
    maquina
;


/* "maquina" también es un símbolo no terminal.
   No viene directamente desde Flex: lo definimos nosotros
   mediante una producción de la gramática.

   Para reconocer una maquina, Bison debe recibir la secuencia:

   MAQUINA ID LLAVE_IZQ LLAVE_DER
*/
maquina:
    MAQUINA ID LLAVE_IZQ alfabeto estados inicial finales transiciones LLAVE_DER
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
    ESTADOS LLAVE_IZQ lista_estados LLAVE_DER
;

lista_estados:
    ID
    |
    lista_estados COMA ID
;

inicial:
    INICIAL DOS_PUNTOS ID PUNTO_COMA
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


/* Bison llama a esta función cuando encuentra un error sintáctico. */
void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
}


/* El programa inicia llamando al parser.
   yyparse() pedirá tokens a yylex() cuando los necesite. */
int main() {
    return yyparse();
}