%{
#include <stdio.h>
#include "turing.tab.h" /*Es un archivo generado por Bison que contiene las definiciones de tokens para que Flex y Bison compartan los mismos nombres. */
#include <string.h>
#include <stdlib.h>
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
    yylval.texto = strdup(yytext);
    return SIMBOLO;    
}

[0-9]+ {
    yylval.numero = atoi(yytext);
    return NUMERO;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.texto = strdup(yytext);
    return ID;
}

"//".* {
    /* ignorar comentario */
}

[ \t\r\n]+ {
    /* ignorar espacios, tabuladores, retorno de carro de Windows y saltos de línea */
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