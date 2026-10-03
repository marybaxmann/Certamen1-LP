# Certamen 1 — DSL para Máquina de Turing con Flex y Bison

## Objetivo de este documento

Este README documenta el avance actual del Certamen 1 de Lenguajes de Programación.

La idea es que cualquier integrante del grupo pueda:

- entender qué se está construyendo;
- comprender el rol de Flex y Bison;
- entender lexemas, tokens, terminales, no terminales y GLC;
- saber cómo compilar y probar el proyecto;
- conocer las decisiones de diseño tomadas;
- reconocer errores que ya aparecieron y cómo se corrigieron;
- saber exactamente qué partes faltan.

> **Estado actual:** lexer funcional + integración Flex/Bison + gramática base para una máquina con alfabeto, estados, estado inicial, estados finales y transiciones.

---

# 1. Objetivo general del proyecto

El certamen pide construir un **lenguaje de dominio específico (DSL)** para definir, componer y simular Máquinas de Turing.

El flujo general del proyecto es:

```text
archivo .tm
   ↓
Flex
   ↓
tokens
   ↓
Bison
   ↓
estructura sintáctica válida
   ↓
acciones semánticas
   ↓
representación interna de la máquina
   ↓
intérprete
   ↓
ejecución paso a paso
```

Actualmente hemos implementado principalmente:

```text
Flex
+
Bison
+
gramática base
```

---

# 2. Herramientas utilizadas

Se optó por:

- **Flex** para análisis léxico.
- **Bison** para análisis sintáctico.
- **GCC** para compilar el código C generado.
- **Cygwin** como entorno en Windows.
- **VS Code** para editar los archivos.
- **Git/GitHub** para versionamiento y respaldo.

---

# 3. Análisis léxico: ¿qué hace Flex?

Flex responde:

> **¿Qué es cada fragmento del texto fuente?**

Ejemplo:

```text
maquina Complemento {
```

Flex reconoce:

```text
maquina        → MAQUINA
Complemento    → ID
{              → LLAVE_IZQ
```

---

# 4. Lexema vs token

## Lexema

Es el texto concreto escrito en el programa.

Ejemplos:

```text
maquina
Complemento
q0
'0'
{
```

## Token

Es la categoría asignada al lexema.

Ejemplos:

```text
MAQUINA
ID
ID
SIMBOLO
LLAVE_IZQ
```

Por ejemplo:

```text
Duplicador
Complemento
q0
qA
```

son lexemas distintos, pero pueden pertenecer al mismo token:

```text
ID
```

---

# 5. Token vs terminal

Cuando hablamos de Flex decimos **token**.

Cuando ese mismo token participa en la gramática de Bison, funciona como **símbolo terminal**.

Ejemplo:

```text
"maquina"  → lexema
MAQUINA    → token / terminal
maquina    → no terminal
```

Regla mental:

```text
Flex reconoce TOKENS
        ↓
Bison usa esos TOKENS como TERMINALES
```

---

# 6. ¿Qué es un no terminal?

Los no terminales son categorías sintácticas que definimos nosotros dentro de la gramática.

Ejemplos actuales:

```text
programa
maquina
alfabeto
lista_simbolos
estados
lista_estados
inicial
finales
transiciones
lista_transiciones
transicion
movimiento
```

No vienen desde Flex.

Se construyen mediante reglas de producción.

Ejemplo:

```c
maquina:
    MAQUINA ID LLAVE_IZQ alfabeto estados inicial finales transiciones LLAVE_DER
;
```

Aquí:

```text
MAQUINA, ID, LLAVE_IZQ, LLAVE_DER
```

son terminales.

Mientras:

```text
alfabeto
estados
inicial
finales
transiciones
```

son no terminales.

---

# 7. ¿Qué es una GLC?

GLC significa:

```text
Gramática Libre de Contexto
```

La GLC describe **cómo deben organizarse los tokens para formar estructuras válidas**.

Flex reconoce las piezas.

Bison usa la GLC para verificar cómo se combinan.

Ejemplo:

```c
maquina:
    MAQUINA ID LLAVE_IZQ LLAVE_DER
;
```

significa:

> Una estructura `maquina` puede formarse con los terminales `MAQUINA ID LLAVE_IZQ LLAVE_DER`.

La GLC se escribe principalmente en la sección entre:

```text
%%
...
%%
```

del archivo `turing.y`.

---

# 8. ¿Qué significa `|` en Bison?

El símbolo:

```text
|
```

significa:

```text
o
```

Ejemplo:

```c
movimiento:
    IZQ
    |
    DER
    |
    QUIETO
;
```

significa:

> Un movimiento puede ser `IZQ`, `DER` o `QUIETO`.

---

# 9. Recursividad en la gramática

Una regla es recursiva cuando se refiere a sí misma.

Ejemplo:

```c
lista_simbolos:
    SIMBOLO
    |
    lista_simbolos COMA SIMBOLO
;
```

Esto permite reconocer:

```text
'0'
```

o:

```text
'0', '1'
```

o:

```text
'0', '1', '_'
```

La primera alternativa:

```c
SIMBOLO
```

es el **caso base**.

La segunda:

```c
lista_simbolos COMA SIMBOLO
```

es el **caso recursivo**.

---

# 10. Decisión de diseño: símbolos entre comillas simples

Se decidió escribir los símbolos del alfabeto así:

```text
'0'
'1'
'_'
'a'
'#'
```

Esto permite distinguir:

```text
0      → NUMERO
'0'    → SIMBOLO
```

Patrón en Flex:

```c
\'[^\']\'
```

Esta convención fue elegida para evitar ambigüedad entre enteros y símbolos del alfabeto.

---

# 11. Tokens definidos en Flex

## Palabras reservadas

```text
MAQUINA
ALFABETO
ESTADOS
INICIAL
FINALES
TRANSICIONES
SUBRUTINA
USA
```

## Movimientos

```text
IZQ
DER
QUIETO
```

## Categorías generales

```text
ID
NUMERO
SIMBOLO
```

## Símbolos estructurales

```text
LLAVE_IZQ
LLAVE_DER
DOS_PUNTOS
PUNTO_COMA
COMA
FLECHA
PARENTESIS_IZQ
PARENTESIS_DER
```

---

# 12. Código actual de `turing.l`

```c
%{
#include <stdio.h>
#include "turing.tab.h"
%}

%%

"maquina" { return MAQUINA; }
"alfabeto" { return ALFABETO; }
"estados" { return ESTADOS; }
"inicial" { return INICIAL; }
"finales" { return FINALES; }
"transiciones" { return TRANSICIONES; }

"IZQ" { return IZQ; }
"DER" { return DER; }
"QUIETO" { return QUIETO; }

"subrutina" { return SUBRUTINA; }
"usa" { return USA; }

\'[^\']\' { return SIMBOLO; }

[0-9]+ { return NUMERO; }

[a-zA-Z_][a-zA-Z0-9_]* { return ID; }

"//".* {
    /* ignorar comentario */
}

[ \t\n]+ {
    /* ignorar espacios, tabuladores y saltos de línea */
}

"{" { return LLAVE_IZQ; }
"}" { return LLAVE_DER; }
":" { return DOS_PUNTOS; }
";" { return PUNTO_COMA; }
"," { return COMA; }
"->" { return FLECHA; }
"(" { return PARENTESIS_IZQ; }
")" { return PARENTESIS_DER; }

. {
    printf("ERROR LEXICO: caracter no reconocido: %s\n", yytext);
}

%%

int yywrap() {
    return 1;
}
```

---

# 13. ¿Por qué ya no usamos `printf` para los tokens?

Antes se utilizaba:

```c
printf("TOKEN: MAQUINA\n");
```

Eso servía para probar el lexer de forma aislada.

Ahora Flex debe entregar los tokens a Bison:

```c
return MAQUINA;
```

El flujo actual es:

```text
yyparse()
   ↓
necesita un token
   ↓
yylex()
   ↓
Flex reconoce un lexema
   ↓
return TOKEN
   ↓
Bison recibe el token
```

---

# 14. ¿Qué es `turing.tab.h`?

`turing.tab.h` es generado automáticamente por Bison.

Se crea con:

```bash
bison -d turing.y
```

Bison genera:

```text
turing.tab.c
turing.tab.h
```

El archivo:

```text
turing.tab.h
```

contiene las definiciones de tokens utilizadas por Bison.

Por eso Flex incluye:

```c
#include "turing.tab.h"
```

No se debe editar manualmente.

---

# 15. Archivos del proyecto

Los archivos que nosotros editamos son:

```text
turing.l
turing.y
```

Los archivos generados son:

```text
lex.yy.c
turing.tab.c
turing.tab.h
```

Y el ejecutable final es:

```text
turing
```

No conviene editar manualmente los archivos generados.

---

# 16. Estructura de `turing.y`

Bison tiene tres secciones principales:

```text
declaraciones
%%
gramática
%%
código C
```

---

# 17. Código actual de `turing.y`

```c
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


programa:
    maquina
;

maquina:
    MAQUINA ID LLAVE_IZQ alfabeto estados inicial finales transiciones LLAVE_DER
;

alfabeto:
    ALFABETO LLAVE_IZQ lista_simbolos LLAVE_DER
;

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


void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
}

int main() {
    return yyparse();
}
```

---

# 18. ¿Qué significa `QUIETO`?

`QUIETO` es uno de los movimientos posibles del cabezal de la Máquina de Turing.

```text
IZQ     → mover una celda a la izquierda
DER     → mover una celda a la derecha
QUIETO  → permanecer en la misma celda
```

Ejemplo:

```text
q0, '_' -> qA, '_', QUIETO;
```

---

# 19. Compilación

Dentro de:

```text
~/certamen_turing
```

ejecutar:

```bash
bison -d turing.y
flex turing.l
gcc turing.tab.c lex.yy.c -lfl -o turing
```

Después:

```bash
./turing
```

---

# 20. Orden de generación

El orden importa.

Primero:

```bash
bison -d turing.y
```

porque crea:

```text
turing.tab.h
```

Luego:

```bash
flex turing.l
```

Finalmente:

```bash
gcc turing.tab.c lex.yy.c -lfl -o turing
```

---

# 21. Prueba completa válida

```text
maquina Complemento {
    alfabeto { '0', '1', '_' }
    estados { q0, qA }
    inicial: q0;
    finales: { qA };

    transiciones {
        q0, '0' -> q0, '1', DER;
        q0, '1' -> q0, '0', DER;
        q0, '_' -> qA, '_', QUIETO;
    }
}
```

---

# 22. Pruebas sintácticas inválidas

## Falta una coma

```text
alfabeto { '0' '1' '_' }
```

## Falta `:`

```text
inicial q0;
```

## Falta `;`

```text
inicial: q0
```

## Forma incorrecta de finales

```text
finales: qA;
```

Nuestra gramática espera:

```text
finales: { qA };
```

## Falta flecha

```text
q0, '0' q0, '1', DER;
```

---

# 23. Importante: una estructura aislada no es un programa completo

Actualmente:

```c
programa:
    maquina
;
```

Por eso ejecutar únicamente:

```text
inicial: q0;
```

produce error.

La regla `inicial` puede estar correcta, pero Bison espera un `programa` completo.

---

# 24. Error encontrado: dos funciones `main()`

Al integrar Flex y Bison apareció:

```text
multiple definition of `main'
```

La causa era que existía un `main()` en `turing.l` y otro en `turing.y`.

La solución fue eliminar el `main()` de `turing.l`.

Actualmente solo queda:

```c
int main() {
    return yyparse();
}
```

---

# 25. Error frecuente: escribir DSL cuando ya estamos en Bash

Cuando vuelve a aparecer:

```text
usuario@DESKTOP... $
```

ya estamos nuevamente en Bash.

Si ahí escribimos:

```text
alfabeto { '0', '1', '_' }
```

Bash intentará ejecutar `alfabeto` como un comando.

Esto no es un error de la gramática.

---

# 26. Recomendación: probar usando archivos `.tm`

Crear:

```text
prueba.tm
```

y ejecutar:

```bash
./turing < prueba.tm
```

Esto evita escribir manualmente toda la máquina.

---

# 27. Conflictos `reduce/reduce`

Un conflicto `reduce/reduce` ocurre cuando Bison encuentra dos reducciones posibles para la misma entrada.

Ejemplo conceptual:

```c
estado:
    ID
;

nombre:
    ID
;
```

Si ambas reglas fueran posibles en el mismo punto, Bison podría dudar entre:

```text
ID → estado
```

y:

```text
ID → nombre
```

La versión actual de la gramática debe compilar sin esas advertencias.

---

# 28. Diferencia entre sintaxis y semántica

Ejemplo:

```text
estados { q0, qA }
inicial: q99;
```

Sintácticamente puede ser válido.

Pero `q99` no fue declarado.

Eso será un error **semántico**, no sintáctico.

Otro ejemplo:

```text
alfabeto { '0', '1' }
```

puede ser sintácticamente válido.

Pero la pauta exige que el alfabeto incluya el símbolo blanco `_`.

Eso se verificará semánticamente.

---

# 29. Estado actual respecto a la pauta

## Ya implementado en la parte sintáctica

- nombre de máquina;
- alfabeto;
- lista de símbolos;
- estados;
- lista de estados;
- estado inicial;
- estados finales;
- función de transición;
- lista de transiciones;
- movimientos `IZQ`, `DER`, `QUIETO`;
- lexer con Flex;
- parser inicial con Bison;
- integración Flex/Bison.

---

# 30. PENDIENTES

## 30.1 Permitir una o más máquinas

Actualmente:

```c
programa:
    maquina
;
```

acepta solo una máquina.

La pauta pide permitir **una o más máquinas**.

El siguiente cambio será:

```c
programa:
    maquina
    |
    programa maquina
;
```

---

## 30.2 Subrutinas reutilizables

Falta implementar realmente:

```text
SUBRUTINA
USA
```

Se debe permitir:

- definir subrutinas nombradas;
- invocarlas desde una máquina;
- componer máquinas con ellas;
- generar los estados/transiciones correspondientes.

---

## 30.3 Subrutina parametrizada

Se exige al menos una subrutina parametrizada por entero.

Ejemplos:

```text
escribir_unos(n)
desplazar(n)
```

Los tokens `NUMERO`, `PARENTESIS_IZQ` y `PARENTESIS_DER` ya existen, pero aún no se usan en la gramática.

---

## 30.4 Acciones semánticas

Actualmente Bison verifica estructura.

Falta hacer que, al reconocer construcciones, se almacenen datos reales de la máquina.

---

## 30.5 Tabla de símbolos

Falta almacenar y consultar:

- estados declarados;
- símbolos del alfabeto;
- estado inicial;
- estados finales;
- nombres de máquinas/subrutinas si corresponde.

---

## 30.6 Validaciones semánticas obligatorias

Falta comprobar:

- que `_` pertenezca al alfabeto;
- que el estado inicial exista;
- que los estados finales existan;
- que los estados usados en las transiciones hayan sido declarados;
- que los símbolos leídos/escritos pertenezcan al alfabeto;
- determinismo: no repetir el mismo par `(estado, símbolo leído)`.

---

## 30.7 Representación interna

Después del parsing se debe construir internamente la máquina.

Ejemplo:

```text
inicial = q0
finales = { qA }

(q0, '0') → (q0, '1', DER)
(q0, '1') → (q0, '0', DER)
(q0, '_') → (qA, '_', QUIETO)
```

---

## 30.8 Intérprete

Falta implementar:

- cinta;
- estado actual;
- posición del cabezal;
- lectura;
- escritura;
- movimiento;
- cambio de estado.

---

## 30.9 Manejo de cinta

Hay que decidir y documentar:

- cinta acotada o extensible;
- comportamiento en los extremos;
- símbolo blanco.

---

## 30.10 Traza paso a paso

Debe mostrar:

- paso;
- estado;
- símbolo leído;
- acción;
- cabezal;
- contenido de la cinta.

---

## 30.11 Detención y resultado

Falta manejar:

- llegada a estado final;
- ausencia de transición aplicable;
- aceptación/rechazo/detención;
- contenido final de la cinta.

---

## 30.12 Máquinas de demostración

Preparar al menos dos máquinas distintas en el DSL.

---

## 30.13 Makefile

La entrega debe compilar mediante:

```bash
make
```

Aún falta crear el `Makefile`.

---

## 30.14 Presentación y entrevista

Falta preparar:

- decisiones de diseño;
- supuestos;
- GLC;
- acciones semánticas;
- demostración en vivo;
- dominio del código por todos los integrantes.

---

# 31. Resumen del avance

Actualmente funciona:

```text
CARACTERES
    ↓
LEXEMAS
    ↓
FLEX
    ↓
TOKENS / TERMINALES
    ↓
BISON
    ↓
GLC
    ↓
ESTRUCTURA SINTÁCTICA DE UNA MÁQUINA
```

Lo siguiente será:

```text
múltiples máquinas
    ↓
subrutinas
    ↓
acciones semánticas
    ↓
tabla de símbolos
    ↓
validaciones
    ↓
representación interna
    ↓
intérprete
    ↓
traza
```

---

## Estado actual

**Lexer:** funcional.  
**Flex + Bison:** integrados.  
**Gramática base de máquina:** funcional.  
**Semántica e intérprete:** pendientes.
