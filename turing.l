%{
#include <stdio.h>
%}

%%

"maquina" {
    printf("TOKEN: MAQUINA\n");
}

"alfabeto" {
    printf("TOKEN: ALFABETO\n");
}

"estados" {
    printf("TOKEN: ESTADOS\n");
}

"inicial" {
    printf("TOKEN: INICIAL\n");
}

"finales" {
    printf("TOKEN: FINALES\n");
}

"transiciones" {
    printf("TOKEN: TRANSICIONES\n");
}
"IZQ" {
    printf("TOKEN: IZQ\n");
}

"DER" {
    printf("TOKEN: DER\n");
}

"QUIETO" {
    printf("TOKEN: QUIETO\n");
}
"subrutina" {
    printf("TOKEN: SUBRUTINA\n");
}

"usa" {
    printf("TOKEN: USA\n");
}

\'[^\']\' {
    printf("TOKEN: SIMBOLO, lexema: %s\n", yytext);
}

[a-zA-Z_][a-zA-Z0-9_]* {
    printf("TOKEN: ID, lexema: %s\n", yytext);
    
}
[0-9]+ {
    printf("TOKEN: NUMERO, lexema: %s\n", yytext);
}
[ \t\n] {
    /* ignorar espacios, tabuladores y saltos de línea */
}

"{" {
    printf("TOKEN: LLAVE_IZQ\n");
}

"}" {
    printf("TOKEN: LLAVE_DER\n");
}

":" {
    printf("TOKEN: DOS_PUNTOS\n");
}

";" {
    printf("TOKEN: PUNTO_COMA\n");
}

"," {
    printf("TOKEN: COMA\n");
}

"->" {
    printf("TOKEN: FLECHA\n");
}

"(" {
    printf("TOKEN: PARENTESIS_IZQ\n");
}

")" {
    printf("TOKEN: PARENTESIS_DER\n");
}


%%




int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}