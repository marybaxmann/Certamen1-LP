# Certamen 1 — Lexer del DSL para Máquina de Turing

## Objetivo de este documento

Este README documenta el proceso seguido para construir **desde cero el analizador léxico (lexer)** del Certamen 1 de Lenguajes de Programación II.

La idea es que cualquier integrante del grupo pueda:

- entender qué se está construyendo;
- comprender por qué existen los tokens definidos;
- saber qué decisiones de diseño se tomaron;
- ejecutar y probar el lexer;
- reconocer errores frecuentes;
- continuar después con Bison sin perder el hilo del proyecto.

> **Estado actual:** el lexer básico ya está construido y probado.  
> **Aún no se ha implementado la gramática en Bison, las acciones semánticas, la tabla de símbolos, el intérprete ni las subrutinas funcionales.**

---

# 1. ¿Qué pide el certamen?

El certamen solicita implementar un **lenguaje de dominio específico (DSL)** para definir, componer y simular Máquinas de Turing.

El flujo general esperado es:

```text
archivo .tm
   ↓
Lexer / Flex
   ↓
tokens
   ↓
Parser / Bison
   ↓
acciones semánticas
   ↓
representación interna
   ↓
intérprete
   ↓
ejecución paso a paso
```

En esta etapa solo hemos trabajado la primera parte:

```text
código fuente
   ↓
FLEX
   ↓
LEXEMAS
   ↓
TOKENS
```

---

# 2. Concepto clave: léxico vs sintaxis

## 2.1 Léxico

El análisis léxico responde:

> **¿Qué es cada fragmento del código?**

Ejemplo:

```text
maquina Complemento {
```

El lexer puede reconocer:

```text
maquina        → MAQUINA
Complemento    → ID
{              → LLAVE_IZQ
```

`maquina`, `Complemento` y `{` son **lexemas**.

`MAQUINA`, `ID` y `LLAVE_IZQ` son **tokens**.

---

## 2.2 Sintaxis / gramática

La gramática responderá después:

> **¿Los tokens están en un orden válido?**

Por ejemplo, una futura regla podría decir:

```text
definicion_maquina:
    MAQUINA ID LLAVE_IZQ ... LLAVE_DER
;
```

Entonces:

```text
maquina Complemento {
```

podría ser sintácticamente válido.

Pero:

```text
Complemento maquina {
```

aunque contiene lexemas válidos, tendría el orden incorrecto para esa producción.

---

# 3. Lexema vs token

Esta diferencia generó una de las primeras preguntas importantes del desarrollo.

Ejemplo:

```text
maquina Duplicador
```

Los lexemas son:

```text
maquina
Duplicador
```

Los tokens son:

```text
MAQUINA
ID
```

`Duplicador` **no** se transforma en un token llamado `DUPLICADOR`.

¿Por qué?

Porque `Duplicador` es solo un nombre elegido por quien escribe el programa.

También podrían existir:

```text
Complemento
Incrementador
q0
qA
mover
escribir_unos
```

Todos son lexemas distintos, pero pertenecen a la categoría general:

```text
ID
```

En cambio:

```text
maquina
alfabeto
estados
inicial
finales
```

sí tienen significado especial en el lenguaje, por lo que se tratan como **palabras reservadas**.

---

# 4. Herramientas utilizadas

Se optó por:

- **Flex** para análisis léxico.
- **Bison** para análisis sintáctico, que se implementará después.
- **GCC** para compilar el código C generado.
- **Cygwin** como entorno de trabajo en Windows.
- **VS Code** para editar los archivos.

---

# 5. Instalación en Windows

El curso trabaja con Flex/Bison y en Windows se utilizó Cygwin.

Durante la instalación de Cygwin se deben agregar, como mínimo:

```text
flex
bison
gcc-core
make
```

Es importante que en la selección de paquetes no quede:

```text
Skip
```

sino un número de versión.

---

## 5.1 Verificar instalación

Desde **Cygwin Terminal**:

```bash
flex --version
bison --version
gcc --version
make --version
```

También se puede verificar la ubicación:

```bash
which flex
which bison
which gcc
which make
```

Idealmente deben aparecer rutas del tipo:

```text
/usr/bin/flex
/usr/bin/bison
/usr/bin/gcc
/usr/bin/make
```

---

# 6. Importante: PowerShell no es lo mismo que Cygwin

Uno de los primeros errores ocurrió al ejecutar:

```powershell
flex turing.l
```

desde PowerShell en VS Code.

PowerShell respondió algo similar a:

```text
flex : El término 'flex' no se reconoce...
```

Esto ocurrió porque Flex estaba instalado en Cygwin, pero PowerShell no lo tenía disponible en su PATH.

## Solución usada

Editar el archivo con VS Code, pero compilar desde:

```text
Cygwin Terminal
```

---

# 7. Carpeta del proyecto

Se creó:

```bash
mkdir certamen_turing
cd certamen_turing
```

Dentro de Cygwin:

```text
~/certamen_turing
```

equivale normalmente en Windows a:

```text
C:\cygwin64\home\usuario\certamen_turing
```

Para comprobar la ruta actual:

```bash
pwd
```

Para mostrar la ruta Windows:

```bash
cygpath -w .
```

Para abrir la carpeta en el explorador:

```bash
explorer .
```

---

# 8. Primer archivo Flex

El archivo principal del lexer es:

```text
turing.l
```

La estructura básica de Flex es:

```text
declaraciones
%%
reglas
%%
funciones auxiliares
```

La primera versión mínima utilizada fue:

```c
%{
#include <stdio.h>
%}

%%

"maquina" {
    printf("TOKEN: MAQUINA\n");
}

%%

int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}
```

---

# 9. ¿Qué hace `yylex()`?

`yylex()` es la función de análisis léxico generada por Flex.

Cuando se ejecuta:

```c
yylex();
```

el scanner comienza a leer la entrada y busca coincidencias con los patrones declarados.

---

# 10. Compilación del lexer

Desde Cygwin:

```bash
flex turing.l
```

Flex genera:

```text
lex.yy.c
```

Luego:

```bash
gcc lex.yy.c -lfl -o turing
```

Esto genera el ejecutable.

Finalmente:

```bash
./turing
```

---

# 11. Error encontrado: `premature EOF`

En una primera prueba apareció:

```text
turing.l:1: premature EOF
```

La causa fue que el archivo Flex estaba incompleto.

Flex espera la estructura:

```text
declaraciones
%%
reglas
%%
funciones auxiliares
```

Después de corregir el contenido de `turing.l`, el error desapareció.

---

# 12. Tokens definidos hasta ahora

## 12.1 Palabras reservadas principales

```text
MAQUINA
ALFABETO
ESTADOS
INICIAL
FINALES
TRANSICIONES
```

Lexemas asociados:

```text
maquina
alfabeto
estados
inicial
finales
transiciones
```

---

## 12.2 Movimientos

```text
IZQ
DER
QUIETO
```

Estos corresponden a movimientos permitidos por la Máquina de Turing.

---

## 12.3 Subrutinas

Se decidió utilizar:

```text
SUBRUTINA
USA
```

con los lexemas:

```text
subrutina
usa
```

### Importante

El certamen **sí exige la funcionalidad de subrutinas reutilizables**, incluyendo al menos una parametrizada por un entero.

Sin embargo, el enunciado no obliga a que las palabras del DSL sean literalmente:

```text
subrutina
usa
```

Estas palabras aparecen en un ejemplo ilustrativo del certamen.

Se decidió adoptarlas porque:

- son claras;
- están alineadas con el ejemplo dado;
- facilitan explicar el diseño;
- son fáciles de reconocer con Flex;
- luego serán simples de incorporar a la GLC.

---

## 12.4 Categorías generales

```text
ID
NUMERO
SIMBOLO
```

### ID

Ejemplos:

```text
Complemento
Duplicador
q0
qA
escribir_unos
```

Patrón usado:

```text
[a-zA-Z_][a-zA-Z0-9_]*
```

Significa:

- debe comenzar con una letra o `_`;
- puede continuar con cero o más letras, números o `_`.

---

### NUMERO

Ejemplos:

```text
0
5
123
```

Patrón:

```text
[0-9]+
```

El `+` significa:

```text
una o más repeticiones
```

---

### SIMBOLO

Esta fue una decisión de diseño importante.

Los símbolos del alfabeto se escribirán entre comillas simples:

```text
'0'
'1'
'_'
'a'
'#'
```

Patrón:

```text
\'[^\']\'
```

Esto permite distinguir:

```text
0      → NUMERO
'0'    → SIMBOLO
```

El certamen indica que cada símbolo del alfabeto es de un solo carácter, por lo que esta notación evita conflictos léxicos.

---

# 13. ¿Por qué poner los símbolos entre comillas?

Sin comillas:

```text
0
```

podría representar:

- un número entero para un parámetro;
- o un símbolo del alfabeto.

Eso genera una decisión léxica incómoda.

Con nuestra convención:

```text
0      → NUMERO
'0'    → SIMBOLO
```

la diferencia queda explícita.

Por ejemplo:

```text
escribir_unos(5)
```

usa:

```text
5 → NUMERO
```

Mientras:

```text
alfabeto { '0', '1', '_' }
```

usa:

```text
'0' → SIMBOLO
'1' → SIMBOLO
'_' → SIMBOLO
```

---

# 14. Símbolos estructurales

También se reconocen:

```text
{
}
:
;
,
->
(
)
```

Con los tokens:

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

Ejemplo:

```text
inicial: q0;
```

produce:

```text
INICIAL
DOS_PUNTOS
ID
PUNTO_COMA
```

---

# 15. Palabras reservadas antes de `ID`

La regla general:

```text
[a-zA-Z_][a-zA-Z0-9_]*
```

también puede reconocer palabras como:

```text
maquina
DER
usa
subrutina
```

Por eso las palabras reservadas deben aparecer antes de la regla general de `ID`.

Ejemplo:

```c
"DER" {
    printf("TOKEN: DER\n");
}

[a-zA-Z_][a-zA-Z0-9_]* {
    printf("TOKEN: ID, lexema: %s\n", yytext);
}
```

Así:

```text
DER → DER
```

y no:

```text
DER → ID
```

---

# 16. `yytext`

`yytext` contiene el lexema exacto que Flex acaba de reconocer.

Ejemplo:

```text
Duplicador
```

La regla:

```c
[a-zA-Z_][a-zA-Z0-9_]* {
    printf("TOKEN: ID, lexema: %s\n", yytext);
}
```

produce:

```text
TOKEN: ID, lexema: Duplicador
```

---

# 17. Espacios ignorados

Se utiliza:

```c
[ \t\n]+ {
    /* ignorar espacios, tabuladores y saltos de línea */
}
```

Esto permite consumir:

- espacios;
- tabuladores;
- saltos de línea.

No producen tokens.

---

# 18. Comentarios

Se decidió permitir comentarios estilo:

```text
// comentario
```

Regla:

```c
"//".* {
    /* ignorar comentario */
}
```

El comentario no produce ningún token.

---

# 19. Caracteres inválidos

Como última regla se agregó:

```c
. {
    printf("ERROR LEXICO: caracter no reconocido: %s\n", yytext);
}
```

El `.` funciona como regla general para cualquier carácter que no haya sido reconocido previamente.

Ejemplo:

```text
@
```

produce:

```text
ERROR LEXICO: caracter no reconocido: @
```

Esta regla debe quedar al final.

---

# 20. Código actual de `turing.l`

```c
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

[0-9]+ {
    printf("TOKEN: NUMERO, lexema: %s\n", yytext);
}

[a-zA-Z_][a-zA-Z0-9_]* {
    printf("TOKEN: ID, lexema: %s\n", yytext);
}

"//".* {
    /* ignorar comentario */
}

[ \t\n]+ {
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

. {
    printf("ERROR LEXICO: caracter no reconocido: %s\n", yytext);
}

%%

int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}
```

---

# 21. Pruebas realizadas

## Prueba 1 — palabra reservada e identificador

Entrada:

```text
maquina Duplicador
```

Salida esperada:

```text
TOKEN: MAQUINA
TOKEN: ID, lexema: Duplicador
```

---

## Prueba 2 — número

Entrada:

```text
123
```

Salida:

```text
TOKEN: NUMERO, lexema: 123
```

---

## Prueba 3 — movimiento

Entrada:

```text
q0, q1 -> qA, q0, DER;
```

Salida esperada:

```text
TOKEN: ID, lexema: q0
TOKEN: COMA
TOKEN: ID, lexema: q1
TOKEN: FLECHA
TOKEN: ID, lexema: qA
TOKEN: COMA
TOKEN: ID, lexema: q0
TOKEN: COMA
TOKEN: DER
TOKEN: PUNTO_COMA
```

---

## Prueba 4 — subrutinas

Entrada:

```text
subrutina escribir_unos
usa escribir_unos
```

Salida:

```text
TOKEN: SUBRUTINA
TOKEN: ID, lexema: escribir_unos
TOKEN: USA
TOKEN: ID, lexema: escribir_unos
```

---

## Prueba 5 — número vs símbolo

Entrada:

```text
0
'0'
'1'
'_'
'a'
```

Salida esperada:

```text
TOKEN: NUMERO, lexema: 0
TOKEN: SIMBOLO, lexema: '0'
TOKEN: SIMBOLO, lexema: '1'
TOKEN: SIMBOLO, lexema: '_'
TOKEN: SIMBOLO, lexema: 'a'
```

---

## Prueba 6 — comentario

Entrada:

```text
// esto es un comentario
```

No debería producir tokens.

---

## Prueba 7 — error léxico

Entrada:

```text
@
```

Salida:

```text
ERROR LEXICO: caracter no reconocido: @
```

---

# 22. Prueba completa recomendada

Entrada:

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

En esta etapa no se verifica todavía que la estructura sea correcta.

Flex solo debe reconocer y mostrar correctamente cada token.

---

# 23. Preguntas que surgieron durante el desarrollo

## ¿`maquina` y `MAQUINA` son lo mismo?

No.

```text
maquina → lexema
MAQUINA → token
```

---

## ¿`Duplicador` debería producir `DUPLICADOR`?

No.

Produce:

```text
ID
```

porque es un identificador elegido por el usuario.

---

## ¿Por qué `DER` no debe ser `ID`?

Porque tiene significado propio dentro del DSL.

Por eso se trata como palabra reservada:

```text
DER → DER
```

---

## ¿Por qué `subrutina` y `usa` son palabras reservadas?

El certamen exige definir e invocar subrutinas, pero no obliga a utilizar esas palabras exactas.

Se adoptaron porque aparecen en el ejemplo ilustrativo del enunciado y generan una sintaxis clara.

---

## ¿Por qué `'0'` es distinto de `0`?

Porque se decidió que:

```text
0   → NUMERO
'0' → SIMBOLO
```

Así se evita confundir parámetros enteros con símbolos del alfabeto.

---

## ¿El lexer ya valida que `q0` sea un estado declarado?

No.

Eso corresponde a una validación **semántica**, no léxica.

---

## ¿El lexer comprueba que `maquina` venga antes de un `ID`?

No.

Eso corresponde al **parser / gramática**.

---

# 24. Qué NO hace todavía el proyecto

Todavía no se ha implementado:

- Bison;
- Gramática Libre de Contexto;
- parser;
- acciones semánticas;
- tabla de símbolos;
- validación de estados;
- validación del alfabeto;
- determinismo de transiciones;
- representación interna de la máquina;
- cinta;
- cabezal;
- simulación;
- subrutinas reales;
- composición;
- Makefile final.

---

# 25. Próximo paso

El siguiente paso será comenzar la integración:

```text
Flex + Bison
```

Actualmente las reglas hacen cosas como:

```c
printf("TOKEN: MAQUINA\n");
```

Después pasarán a devolver tokens:

```c
return MAQUINA;
```

El parser recibirá esos tokens y podrá aplicar una GLC.

El primer objetivo de Bison será reconocer una construcción mínima como:

```text
maquina Complemento {
}
```

y luego iremos agregando:

```text
alfabeto
estados
inicial
finales
transiciones
subrutinas
```

de forma incremental.

---

# 26. Resumen mental del progreso

```text
CARACTERES
    ↓
LEXEMAS
    ↓
FLEX
    ↓
TOKENS
```

Hasta aquí llega el trabajo actual.

Lo siguiente será:

```text
TOKENS
    ↓
BISON
    ↓
GRAMÁTICA
    ↓
ESTRUCTURA SINTÁCTICA
```

Y posteriormente:

```text
ESTRUCTURA
    ↓
ACCIONES SEMÁNTICAS
    ↓
REPRESENTACIÓN INTERNA
    ↓
INTÉRPRETE
```

---

## Estado actual

**Lexer básico: terminado y probado.**

Siguiente etapa:

**Bison + Gramática Libre de Contexto.**
