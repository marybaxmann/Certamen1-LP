%{
#include <stdio.h>
#include "turing.tab.h" /*Es un archivo generado por Bison que contiene las definiciones de tokens para que Flex y Bison compartan los mismos nombres. */
%}

%%

"maquina" {
    return MAQUINA;
}

"alfabeto" {
    return ALFABETO;
}

"estados" {
    return ESTADOS;
}

"inicial" {
    return INICIAL;
}

"finales" {
    return FINALES;
}

"transiciones" {
    return TRANSICIONES;
}

"IZQ" {
    return IZQ;
}

"DER" {
    return DER;
}

"QUIETO" {
    return QUIETO;
}

"subrutina" {
    return SUBRUTINA;
}

"usa" {
    return USA;
}

\'[^\']\' {
    return SIMBOLO;
}

[0-9]+ {
    return NUMERO;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    return ID;
}

"//".* {
    /* ignorar comentario */
}

[ \t\n]+ {
    /* ignorar espacios, tabuladores y saltos de línea */
}

"{" {
    return LLAVE_IZQ;
}

"}" {
    return LLAVE_DER;
}

":" {
    return DOS_PUNTOS;
}

";" {
    return PUNTO_COMA;
}

"," {
    return COMA;
}

"->" {
    return FLECHA;
}

"(" {
    return PARENTESIS_IZQ;
}

")" {
    return PARENTESIS_DER;
}

. {
    printf("ERROR LEXICO: caracter no reconocido: %s\n", yytext);
}

%%

int yywrap() {
    return 1;
}