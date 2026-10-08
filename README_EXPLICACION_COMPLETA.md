# Guía Completa de Estudio — Intérprete de Máquina de Turing con Flex, Bison y C

## 1. ¿Qué hicimos en este proyecto?

En este proyecto construimos un pequeño lenguaje específico de dominio, o **DSL** (*Domain Specific Language*), para definir y ejecutar máquinas de Turing deterministas de una cinta.

La idea es que una persona pueda escribir una máquina utilizando una sintaxis como:

```text
maquina A {
    alfabeto { '0', '1', '_' }

    estados { q0, q1, qA }

    inicial: q0;

    finales: { qA };

    transiciones {
        q0, '0' -> q1, '1', DER;
        q1, '_' -> qA, '_', QUIETO;
    }
}
```

Nuestro programa debe:

1. Leer ese archivo.
2. Reconocer sus elementos.
3. Comprobar que la sintaxis sea correcta.
4. Comprobar ciertas reglas semánticas.
5. Guardar internamente la máquina.
6. Inicializar una cinta.
7. Ejecutar las transiciones.
8. Detenerse cuando llega a un estado final o cuando no existe una transición aplicable.

Además, el lenguaje soporta **subrutinas**, que pueden expandirse antes de ejecutar la máquina.

---

# 2. Tecnologías utilizadas

El proyecto utiliza principalmente:

- C
- Flex
- Bison
- GCC
- Make
- Cygwin

Flex y Bison cumplen funciones diferentes.

Una forma sencilla de recordarlo es:

```text
Flex  → reconoce palabras/patrones
Bison → reconoce estructuras
C     → guarda y ejecuta la máquina
```

---

# 3. Flujo general del programa

El flujo completo es:

```text
archivo .tm
    ↓
Flex
    ↓
tokens
    ↓
Bison
    ↓
gramática
    ↓
acciones semánticas
    ↓
estructuras internas en C
    ↓
intérprete
    ↓
ejecución de la Máquina de Turing
```

Por ejemplo:

```text
maquina A {
```

primero es leído por Flex.

Flex reconoce:

```text
maquina
```

como:

```text
MAQUINA
```

y:

```text
A
```

como:

```text
ID
```

Luego Bison recibe algo parecido a:

```text
MAQUINA ID LLAVE_IZQ
```

y verifica si esa secuencia está permitida por la gramática.

---

# 4. Estructura del proyecto

Actualmente el proyecto está separado en varios archivos.

## `turing.l`

Contiene el **analizador léxico** implementado con Flex.

Su responsabilidad es reconocer elementos como:

```text
maquina
alfabeto
estados
inicial
finales
transiciones
subrutina
usa
IZQ
DER
QUIETO
```

También reconoce:

```text
ID
SIMBOLO
NUMERO
```

---

## `turing.y`

Contiene:

- la gramática de Bison;
- las producciones del lenguaje;
- acciones semánticas;
- llamadas a funciones de validación;
- manejo de errores sintácticos.

---

## `turing.h`

Es el archivo de cabecera compartido.

Contiene principalmente:

- constantes;
- estructuras;
- enumeraciones;
- declaraciones `extern`;
- prototipos de funciones.

---

## `turing.c`

Contiene la lógica relacionada con:

- estados;
- símbolos;
- transiciones;
- estados finales;
- determinismo;
- subrutinas;
- expansión de subrutinas.

---

## `interprete.c`

Contiene la lógica de ejecución:

- cinta;
- cabezal;
- búsqueda de transiciones;
- escritura;
- movimiento;
- actualización del estado;
- detención.

---

## `main.c`

Es el punto de entrada del programa.

Aquí comienza la ejecución de C mediante:

```c
int main()
```

Se llama al parser y, si corresponde, se inicializa y ejecuta la máquina.

---

## `Makefile`

Automatiza la compilación.

En vez de escribir manualmente:

```bash
bison -d turing.y
flex turing.l
gcc main.c turing.c interprete.c turing.tab.c lex.yy.c -lfl -o turing
```

podemos ejecutar:

```bash
# 1. Prueba básica
make run
# 2. Máquina con subrutinas compuestas
make run-subrutina
# 3. Incrementador binario (1011 -> 1100)
make run-incrementador
# 4. Sumador unario (11 + 111 = 11111)
make run-sumador

# 5. ¿Qué es un DSL?

DSL significa:

```text
Domain Specific Language
```

o:

```text
Lenguaje Específico de Dominio
```

Es un lenguaje diseñado para resolver un problema concreto.

En nuestro caso, el dominio es:

```text
definición y ejecución de máquinas de Turing
```

Nuestro lenguaje no pretende reemplazar a C, Java o Python.

Está diseñado específicamente para poder escribir cosas como:

```text
alfabeto { '0', '1', '_' }
```

o:

```text
q0, '0' -> q1, '1', DER;
```

---

# 6. Flex: análisis léxico

Flex realiza el **análisis léxico**.

Su misión es leer caracteres y agruparlos en unidades significativas.

Por ejemplo, si encuentra:

```text
maquina
```

puede devolver:

```text
MAQUINA
```

Una regla típica sería:

```lex
"maquina" {
    return MAQUINA;
}
```

Otro ejemplo:

```lex
"DER" {
    return DER;
}
```

---

# 7. Lexema versus token

Esta diferencia es importante.

Si tenemos:

```text
q0
```

el **lexema** es:

```text
q0
```

El **token** puede ser:

```text
ID
```

Otro ejemplo:

```text
mover
```

Lexema:

```text
mover
```

Token:

```text
ID
```

El token representa una categoría.

El lexema es el texto concreto leído.

---

# 8. Expresión regular del identificador

Una regla típica para nuestros identificadores es:

```lex
[a-zA-Z_][a-zA-Z0-9_]*
```

Esto permite identificadores como:

```text
q0
qA
estado_1
mover
subrutina1
```

La primera posición debe ser:

```text
letra o _
```

Luego pueden aparecer:

```text
letras
números
_
```

---

# 9. Símbolos de la cinta

En nuestro lenguaje los símbolos se escriben como:

```text
'0'
'1'
'_'
```

La expresión utilizada reconoce **un único carácter entre comillas simples**.

Conceptualmente:

```lex
\'[^\']\'
```

Esto es coherente con nuestra representación de cinta:

```c
char cinta[TAM_CINTA];
```

Cada celda almacena un único `char`.

---

# 10. ¿Por qué `_`?

Utilizamos:

```text
_
```

como símbolo blanco de la cinta.

Por ejemplo:

```text
0 0 1 _ _ _ _ _
```

Después del contenido de entrada, el resto de las posiciones se inicializan con `_`.

---

# 11. Bison: análisis sintáctico

Bison realiza el **análisis sintáctico**.

Flex responde:

> ¿Qué elemento encontré?

Bison responde:

> ¿Estos elementos aparecen en un orden válido?

Por ejemplo, podemos tener una producción como:

```bison
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
```

Esto define la estructura de una máquina.

---

# 12. Terminales y no terminales

## Terminales

Los tokens provenientes de Flex son símbolos terminales.

Ejemplos:

```text
MAQUINA
ALFABETO
ESTADOS
INICIAL
FINALES
TRANSICIONES
ID
SIMBOLO
NUMERO
DER
IZQ
QUIETO
```

---

## No terminales

Los elementos que nosotros definimos mediante reglas de gramática son no terminales.

Ejemplos:

```text
programa
declaracion
maquina
subrutina
estados
lista_estados
transiciones
transicion
movimiento
```

---

# 13. Producciones de Bison

Una regla puede verse así:

```bison
programa:
      declaracion
    | programa declaracion
;
```

Esto significa que un programa puede ser:

```text
una declaración
```

o:

```text
un programa seguido de otra declaración
```

Gracias a eso se pueden procesar múltiples declaraciones.

---

# 14. ¿Qué significa `:` en Bison?

En:

```bison
programa:
    declaracion
;
```

los dos puntos significan aproximadamente:

```text
programa puede producir declaracion
```

---

# 15. ¿Qué significa `|`?

Representa alternativas.

Por ejemplo:

```bison
movimiento:
      IZQ
    | DER
    | QUIETO
;
```

significa:

```text
movimiento puede ser IZQ
o DER
o QUIETO
```

---

# 16. ¿Qué significa `;`?

Finaliza una producción de la gramática.

Por ejemplo:

```bison
movimiento:
      IZQ
    | DER
    | QUIETO
;
```

---

# 17. Recursividad en la gramática

La gramática puede ser recursiva.

Ejemplo:

```bison
programa:
      declaracion
    | programa declaracion
;
```

Esto permite una cantidad variable de declaraciones.

Lo mismo puede utilizarse para listas.

Por ejemplo, conceptualmente:

```text
estado
estado , estado
estado , estado , estado
...
```

---

# 18. `%empty`

Bison permite representar una producción vacía.

Por ejemplo:

```bison
usos_opcionales:
      %empty
    | usos_opcionales uso_subrutina
;
```

Esto significa que puede haber:

```text
ningún uso de subrutina
```

o:

```text
uno o varios usos de subrutina
```

---

# 19. `%union`

Los tokens pueden transportar información.

Por ejemplo, un `ID` necesita transportar su nombre.

Si Flex encuentra:

```text
q0
```

no basta con decirle a Bison:

```text
esto es un ID
```

También queremos conservar:

```text
"q0"
```

Para eso se utiliza `%union`.

Conceptualmente:

```c
%union {
    char *texto;
    int numero;
    TipoMovimiento movimiento;
}
```

Así podemos almacenar distintos tipos de valores.

---

# 20. `yylval`

Flex utiliza `yylval` para enviar información a Bison.

Por ejemplo:

```c
yylval.texto = strdup(yytext);
return ID;
```

Significa:

```text
Token: ID
Valor asociado: texto encontrado
```

Si el texto era:

```text
q0
```

Bison recibe el token `ID` junto con `"q0"`.

---

# 21. ¿Qué es `yytext`?

`yytext` contiene el texto que Flex acaba de reconocer.

Si Flex reconoce:

```text
mover
```

entonces:

```c
yytext
```

contiene aproximadamente:

```text
"mover"
```

---

# 22. ¿Qué son `$1`, `$2`, `$3`?

Dentro de una acción de Bison, los símbolos de la producción se numeran.

Ejemplo:

```bison
MAQUINA ID LLAVE_IZQ
```

Entonces:

```text
$1 = MAQUINA
$2 = ID
$3 = LLAVE_IZQ
```

Si el usuario escribió:

```text
maquina A {
```

el valor asociado a:

```text
$2
```

es:

```text
"A"
```

---

# 23. ¿Qué es `$$`?

`$$` representa el valor producido por el no terminal actual.

Ejemplo:

```bison
movimiento:
      IZQ     { $$ = MOV_IZQ; }
    | DER     { $$ = MOV_DER; }
    | QUIETO  { $$ = MOV_QUIETO; }
;
```

Si se reconoce:

```text
DER
```

el valor del no terminal `movimiento` será:

```text
MOV_DER
```

---

# 24. Acciones semánticas

Bison permite ejecutar código C cuando una producción es reconocida.

Por ejemplo:

```bison
lista_estados:
    ID
    {
        agregar_estado($1);
    }
;
```

Cuando reconoce un identificador perteneciente a una lista de estados, llama:

```c
agregar_estado(...)
```

De esta manera no solo reconocemos sintaxis.

También construimos la representación interna de la máquina.

---

# 25. Diferencia entre sintaxis y semántica

Esta es una de las preguntas más importantes.

## Error sintáctico

Significa que el texto no cumple la gramática.

Por ejemplo:

```text
inicial q0;
```

si nuestro lenguaje exige:

```text
inicial: q0;
```

Falta `:`.

Eso es un error sintáctico.

---

## Error semántico

La estructura puede estar bien escrita, pero su significado no es válido.

Ejemplo:

```text
estados { q0, qA }

inicial: q5;
```

La sintaxis puede ser correcta.

Pero:

```text
q5
```

no fue declarado.

Eso es un error semántico.

---

# 26. Estructura `Transicion`

Las transiciones se representan mediante una estructura.

Conceptualmente:

```c
typedef struct {
    char *estado_origen;
    char *simbolo_leido;
    char *estado_destino;
    char *simbolo_escrito;
    TipoMovimiento movimiento;
} Transicion;
```

---

# 27. Ejemplo de transición

Si el DSL contiene:

```text
q0, '0' -> q1, '1', DER;
```

internamente guardamos:

```text
estado_origen   = q0
simbolo_leido   = '0'
estado_destino  = q1
simbolo_escrito = '1'
movimiento      = MOV_DER
```

---

# 28. Enumeración de movimientos

Los movimientos están representados mediante un `enum`.

Conceptualmente:

```c
typedef enum {
    MOV_IZQ,
    MOV_DER,
    MOV_QUIETO
} TipoMovimiento;
```

Normalmente C les asigna:

```text
MOV_IZQ    = 0
MOV_DER    = 1
MOV_QUIETO = 2
```

Por eso durante nuestras pruebas aparecían cosas como:

```text
movimiento=1
```

que correspondía a:

```text
DER
```

y:

```text
movimiento=2
```

que correspondía a:

```text
QUIETO
```

---

# 29. Tablas internas

La máquina se almacena mediante arreglos.

Por ejemplo:

```c
char *tabla_estados[MAX_ESTADOS];
```

guarda estados.

```c
char *tabla_simbolos[MAX_SIMBOLOS];
```

guarda símbolos.

```c
Transicion tabla_transiciones[MAX_TRANSICIONES];
```

guarda transiciones.

```c
char *tabla_finales[MAX_FINALES];
```

guarda estados finales.

---

# 30. ¿Para qué sirven los contadores?

Junto a cada tabla tenemos variables como:

```c
int cantidad_estados;
int cantidad_simbolos;
int cantidad_transiciones;
int cantidad_finales;
```

Estas indican cuántas posiciones de cada arreglo están ocupadas.

Por ejemplo:

```text
cantidad_estados = 3
```

significa que tenemos tres estados guardados.

---

# 31. ¿Qué es un puntero?

Un puntero almacena una dirección de memoria.

Por ejemplo:

```c
Transicion *t;
```

`t` no contiene directamente una transición.

Contiene la dirección donde se encuentra una transición.

---

# 32. Operador `&`

Si tenemos:

```c
tabla_transiciones[i]
```

podemos obtener su dirección con:

```c
&tabla_transiciones[i]
```

Entonces:

```c
Transicion *t = &tabla_transiciones[i];
```

hace que `t` apunte a esa transición.

---

# 33. Operador `->`

Cuando tenemos un puntero a una estructura, usamos:

```c
->
```

Por ejemplo:

```c
t->estado_origen
```

es equivalente conceptualmente a:

```text
acceder al campo estado_origen
de la transición apuntada por t
```

---

# 34. ¿Qué es `NULL`?

`NULL` significa que un puntero no apunta a un objeto válido.

Por ejemplo:

```c
Transicion *t = buscar_transicion(...);
```

Si no encontramos ninguna transición:

```c
return NULL;
```

Entonces podemos comprobar:

```c
if (t == NULL)
```

---

# 35. ¿Qué significa `extern`?

Las variables globales deben definirse una sola vez.

Por ejemplo, en `turing.c`:

```c
Transicion tabla_transiciones[MAX_TRANSICIONES];
```

Pero otros archivos necesitan utilizar esa tabla.

En `turing.h` escribimos:

```c
extern Transicion tabla_transiciones[MAX_TRANSICIONES];
```

`extern` significa aproximadamente:

```text
esta variable existe, pero está definida en otro archivo
```

No crea una segunda tabla.

---

# 36. ¿Por qué existe `turing.h`?

Sin un archivo común tendríamos que repetir estructuras y prototipos en varios archivos.

`turing.h` permite compartir:

```text
structs
enums
constantes
prototipos
extern
```

entre:

```text
main.c
turing.c
interprete.c
turing.y
```

---

# 37. La cinta

La cinta se implementa mediante:

```c
char cinta[TAM_CINTA];
```

Por ejemplo:

```text
0 1 1 _ _ _ _ _
```

Cada posición del arreglo representa una celda.

---

# 38. Cabezal

La posición del cabezal se guarda mediante:

```c
int posicion_cabezal;
```

Por ejemplo:

```text
posicion_cabezal = 0
```

significa:

```text
primera celda
```

Si la cinta es:

```text
0 1 _
```

podemos mostrarla como:

```text
[0] 1 _
```

---

# 39. Inicialización de la cinta

La cinta primero se llena con:

```text
_
```

Después se copia la cadena de entrada.

Por ejemplo:

```c
inicializar_cinta("000");
```

produce:

```text
0 0 0 _ _ _ _ _ ...
```

El cabezal comienza en:

```text
posición 0
```

---

# 40. Conversión del símbolo

Las transiciones almacenan los símbolos como textos del tipo:

```text
'0'
```

Pero la cinta almacena:

```c
'0'
```

como un único carácter.

Por eso usamos una función que convierte:

```text
0
```

en una cadena:

```text
'0'
```

para poder buscar la transición correspondiente.

---

# 41. Búsqueda de una transición

El intérprete necesita responder:

> Estoy en este estado y leo este símbolo. ¿Qué hago?

Por ejemplo:

```text
estado actual = q0
símbolo leído = '0'
```

busca:

```text
(q0, '0')
```

en la tabla.

Si encuentra:

```text
q0, '0' -> q1, '1', DER
```

la ejecuta.

---

# 42. Ejecución de una transición

Una transición realiza tres operaciones principales.

Supongamos:

```text
q0, '0' -> q1, '1', DER
```

Entonces:

### 1. Escribir

```text
'0' → '1'
```

### 2. Cambiar estado

```text
q0 → q1
```

### 3. Mover el cabezal

```text
DER
```

Por tanto:

```c
posicion_cabezal++;
```

---

# 43. Movimiento IZQ

Si el movimiento es:

```text
IZQ
```

hacemos conceptualmente:

```c
posicion_cabezal--;
```

---

# 44. Movimiento DER

Si es:

```text
DER
```

hacemos:

```c
posicion_cabezal++;
```

---

# 45. Movimiento QUIETO

Si es:

```text
QUIETO
```

el cabezal no cambia de posición.

Esto es especialmente importante para conectar bloques de subrutinas.

---

# 46. Estado actual

La variable:

```c
char *estado_actual;
```

indica en qué estado se encuentra actualmente la máquina.

Por ejemplo:

```text
q0
```

Después de una transición puede pasar a:

```text
q1
```

---

# 47. Estado final

Antes de seguir ejecutando transiciones se comprueba si:

```text
estado_actual
```

pertenece a:

```text
tabla_finales
```

Si sí:

```text
la ejecución termina
```

---

# 48. ¿Qué ocurre si no existe transición?

Por ejemplo, estamos en:

```text
q1
```

leyendo:

```text
'1'
```

pero no existe:

```text
q1, '1' -> ...
```

Entonces:

```text
buscar_transicion(...)
```

devuelve:

```text
NULL
```

y la máquina se detiene.

Durante nuestras pruebas apareció:

```text
Maquina detenida: no existe transicion para (q0, '_').
```

Eso no significa necesariamente que el programa esté roto.

Significa que no existe una regla definida para esa combinación.

---

# 49. Determinismo

Nuestro proyecto implementa una Máquina de Turing determinista.

Esto significa que para un mismo par:

```text
(estado, símbolo)
```

puede existir como máximo una transición.

Por ejemplo, esto sería incorrecto:

```text
q0, '0' -> q1, '1', DER;
q0, '0' -> q2, '0', IZQ;
```

Las dos utilizan:

```text
(q0, '0')
```

La máquina tendría dos decisiones posibles.

---

# 50. Validación del determinismo

Antes de almacenar una nueva transición preguntamos:

```c
existe_transicion(estado, simbolo)
```

Si ya existe una transición para esa combinación:

```text
se produce un error semántico
```

---

# 51. Estados declarados

Si una transición contiene:

```text
q5
```

pero `q5` no aparece en:

```text
estados { ... }
```

se debe detectar un error semántico.

Lo mismo ocurre con:

```text
inicial
finales
```

---

# 52. Símbolos declarados

Si el alfabeto es:

```text
{ '0', '1', '_' }
```

una transición que utiliza:

```text
'x'
```

no debería ser válida.

Se verifica mediante:

```c
existe_simbolo(...)
```

---

# 53. ¿Por qué el blanco debe estar en el alfabeto?

Nuestra cinta utiliza:

```text
_
```

como blanco.

Por eso el lenguaje espera que `_` forme parte del alfabeto de la máquina.

Esto permite definir transiciones como:

```text
q1, '_' -> qA, '_', QUIETO;
```

---

# 54. Subrutinas

Una de las partes más importantes del proyecto fue agregar subrutinas.

Ejemplo:

```text
subrutina mover(n) {
    estados { s0, s1 }

    inicial: s0;

    finales: { s1 };

    transiciones {
        s0, '0' -> s1, '0', DER;
    }
}
```

---

# 55. Estructura `Subrutina`

Las subrutinas tienen su propia estructura.

Conceptualmente:

```c
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
```

---

# 56. ¿Por qué almacenar la subrutina separadamente?

Cuando se lee:

```text
subrutina mover(n)
```

sus estados:

```text
s0
s1
```

no deberían mezclarse inmediatamente con:

```text
q0
qA
```

de la máquina principal.

Por eso usamos:

```c
dentro_subrutina
```

y:

```c
subrutina_actual
```

---

# 57. `dentro_subrutina`

Cuando estamos analizando una subrutina:

```c
dentro_subrutina = 1;
```

Entonces funciones como:

```c
agregar_estado(...)
```

saben que el estado debe guardarse dentro de:

```text
subrutina_actual
```

y no dentro de la máquina principal.

---

# 58. Acción intermedia de Bison

En la regla de subrutina utilizamos una acción antes de terminar toda la producción.

Conceptualmente:

```bison
SUBRUTINA ID ...
{
    crear subrutina;
    seleccionar subrutina actual;
    dentro_subrutina = 1;
}
estados
inicial
finales
transiciones
...
```

Esto es necesario porque cuando Bison empieza a procesar:

```text
estados
inicial
finales
transiciones
```

ya debe saber:

```text
estos datos pertenecen a una subrutina
```

---

# 59. ¿Qué pasa al terminar la subrutina?

Al finalizar:

```c
dentro_subrutina = 0;
subrutina_actual = NULL;
```

Esto significa:

```text
ya no estamos guardando información dentro de una subrutina
```

---

# 60. Búsqueda de una subrutina

Cuando la máquina contiene:

```text
usa mover(3);
```

primero buscamos:

```text
mover
```

en:

```text
tabla_subrutinas
```

utilizando:

```c
buscar_subrutina(...)
```

Si no existe:

```text
error semántico
```

---

# 61. Parámetro entero

Nuestra sintaxis permite:

```text
usa mover(3);
```

El:

```text
3
```

es reconocido por Flex como:

```text
NUMERO
```

y se convierte a entero.

En nuestro diseño actual, ese entero representa la cantidad de copias que se expanden.

---

# 62. Importante sobre el parámetro

Que:

```text
mover(3)
```

signifique:

```text
crear tres copias
```

es una decisión de diseño de nuestra implementación.

No es una propiedad universal de Bison ni de todas las máquinas de Turing.

---

# 63. Validación del alfabeto de una subrutina

La subrutina se declara antes de la máquina.

Por eso cuando se almacena originalmente aún no necesariamente tenemos el alfabeto de la máquina que la utilizará.

Al ejecutar:

```text
usa mover(3);
```

podemos comparar los símbolos de la subrutina con:

```text
alfabeto de la máquina
```

Por ejemplo, si la subrutina utiliza:

```text
'0'
```

pero la máquina solo tiene:

```text
'1'
'_'
```

la invocación no debería ser válida.

---

# 64. Expansión de una subrutina

La invocación:

```text
usa mover(3);
```

no se ejecuta como una función de C.

Antes de ejecutar la Máquina de Turing generamos estados y transiciones equivalentes.

Este proceso se llama:

```text
expansión
```

---

# 65. Primer problema: nombres repetidos

La subrutina original tiene:

```text
s0
s1
```

Si copiamos tres veces exactamente los mismos nombres tendríamos:

```text
s0
s1
s0
s1
s0
s1
```

Esto produciría colisiones.

---

# 66. Renombrado de estados

Por eso generamos nombres únicos.

Para:

```text
mover(3)
```

generamos:

```text
mover_1_s0
mover_1_s1

mover_2_s0
mover_2_s1

mover_3_s0
mover_3_s1
```

---

# 67. Significado de un nombre expandido

Por ejemplo:

```text
mover_2_s0
```

puede leerse como:

```text
mover = nombre de subrutina
2     = segunda copia
s0    = estado original
```

---

# 68. `snprintf`

Los nombres se crean con `snprintf`.

Ejemplo:

```c
snprintf(
    nombre_nuevo,
    sizeof(nombre_nuevo),
    "%s_%d_%s",
    s->nombre,
    r,
    s->estados[i]
);
```

Si:

```text
nombre = mover
r = 2
estado = s0
```

obtenemos:

```text
mover_2_s0
```

---

# 69. ¿Por qué usamos `strdup()`?

Este punto puede aparecer en una interrogación.

Dentro de la función podemos tener:

```c
char nombre_nuevo[200];
```

Ese arreglo es local.

Si simplemente almacenáramos un puntero a él, ese contenido podría dejar de ser válido después.

Por eso usamos:

```c
strdup(nombre_nuevo);
```

`strdup()` crea una copia independiente del texto.

---

# 70. Copia de transiciones

La subrutina original tiene:

```text
s0, '0' -> s1, '0', DER;
```

Primera copia:

```text
mover_1_s0, '0'
->
mover_1_s1, '0', DER
```

Segunda copia:

```text
mover_2_s0, '0'
->
mover_2_s1, '0', DER
```

Tercera copia:

```text
mover_3_s0, '0'
->
mover_3_s1, '0', DER
```

---

# 71. ¿Por qué no basta con copiar los estados?

Porque una máquina funciona mediante transiciones.

Si creáramos:

```text
mover_1_s0
mover_1_s1
```

pero no copiáramos:

```text
s0 -> s1
```

los nuevos estados existirían pero no tendrían comportamiento.

---

# 72. Segundo problema: las copias estaban desconectadas

Después de copiar las transiciones teníamos:

```text
mover_1_s0 -> mover_1_s1

mover_2_s0 -> mover_2_s1

mover_3_s0 -> mover_3_s1
```

Pero no teníamos:

```text
mover_1 → mover_2
mover_2 → mover_3
```

Por lo tanto las tres copias estaban separadas.

---

# 73. ¿Cómo conectamos las copias?

Queremos:

```text
mover_1_s1
      ↓
mover_2_s0
```

Pero una Máquina de Turing necesita siempre una transición con:

```text
estado
símbolo leído
estado destino
símbolo escrito
movimiento
```

No podemos crear simplemente:

```text
mover_1_s1 -> mover_2_s0
```

---

# 74. Transiciones identidad

Para conectar bloques utilizamos transiciones que:

```text
leen un símbolo
escriben el mismo símbolo
no mueven el cabezal
cambian únicamente de estado
```

Por ejemplo:

```text
mover_1_s1, '0'
->
mover_2_s0, '0', QUIETO
```

---

# 75. ¿Por qué una transición por cada símbolo?

Supongamos que el alfabeto es:

```text
{ '0', '_' }
```

Cuando llegamos a:

```text
mover_1_s1
```

no sabemos necesariamente si el cabezal está sobre:

```text
'0'
```

o:

```text
'_'
```

Por eso generamos:

```text
mover_1_s1, '0' -> mover_2_s0, '0', QUIETO
mover_1_s1, '_'  -> mover_2_s0, '_', QUIETO
```

Así el cambio de bloque funciona independientemente del símbolo leído.

---

# 76. ¿Por qué QUIETO?

Porque queremos conectar dos bloques sin:

```text
mover el cabezal
```

y sin:

```text
cambiar el contenido de la cinta
```

Queremos cambiar solamente:

```text
estado actual
```

---

# 77. Encadenamiento de `mover(3)`

Nuestro resultado fue:

```text
mover_1_s0
      ↓
mover_1_s1
      ↓
mover_2_s0
      ↓
mover_2_s1
      ↓
mover_3_s0
      ↓
mover_3_s1
```

---

# 78. Tercer problema: la máquina nunca entraba a la subrutina

Aunque ya habíamos creado todos esos estados, la máquina seguía comenzando en:

```text
q0
```

y tenía:

```text
q0 -> qA
```

Por eso las transiciones de `mover` eran inalcanzables.

---

# 79. Estado inicial original

Antes de modificar el flujo guardamos:

```c
char *inicio_maquina = estado_actual;
```

En nuestro ejemplo:

```text
inicio_maquina = q0
```

Esto es importante porque después necesitamos regresar a la máquina principal.

---

# 80. Nuevo inicio

Después de expandir la subrutina cambiamos:

```text
estado_actual
```

por:

```text
mover_1_s0
```

Así el intérprete comienza ejecutando la primera copia.

---

# 81. Salida de la subrutina

Al terminar:

```text
mover_3_s1
```

conectamos con:

```text
q0
```

mediante transiciones identidad.

Por ejemplo:

```text
mover_3_s1, '_'
->
q0, '_', QUIETO
```

---

# 82. Flujo completo comprobado

Finalmente obtuvimos:

```text
mover_1_s0
↓
mover_1_s1
↓
mover_2_s0
↓
mover_2_s1
↓
mover_3_s0
↓
mover_3_s1
↓
q0
↓
qA
```

---

# 83. Prueba realizada

Utilizamos:

```c
inicializar_cinta("000");
```

La cinta comenzó:

```text
[0] 0 0 _
```

Primera copia:

```text
[0] 0 0 _
→
0 [0] 0 _
```

Segunda copia:

```text
0 [0] 0 _
→
0 0 [0] _
```

Tercera copia:

```text
0 0 [0] _
→
0 0 0 [_]
```

Luego:

```text
mover_3_s1
```

regresó a:

```text
q0
```

---

# 84. Error que encontramos durante esa prueba

Inicialmente la máquina principal tenía:

```text
q0, '0' -> qA, '0', QUIETO;
```

Pero después de mover tres veces, el cabezal estaba sobre:

```text
_
```

Entonces ocurrió:

```text
Maquina detenida: no existe transicion para (q0, '_').
```

---

# 85. ¿Era un error del intérprete?

No.

El intérprete estaba funcionando correctamente.

El problema era que la máquina no tenía una transición definida para:

```text
(q0, '_')
```

---

# 86. Corrección de la prueba

Cambiamos:

```text
q0, '0' -> qA, '0', QUIETO;
```

por:

```text
q0, '_' -> qA, '_', QUIETO;
```

Entonces la ejecución terminó correctamente:

```text
Maquina detenida en estado final: qA
```

---

# 87. Lección importante de esa prueba

Que una máquina se detenga porque no tiene transición no significa necesariamente que nuestro programa esté mal.

Puede significar que la **máquina definida por el usuario está incompleta para esa entrada**.

---

# 88. `main.c`

El `main` es pequeño porque tratamos de separar responsabilidades.

Conceptualmente:

```c
int main() {
    int resultado = yyparse();

    if (resultado == 0 && maquina_definida) {
        inicializar_cinta("000");
        mostrar_cinta();
        ejecutar_maquina();
    }

    return resultado;
}
```

---

# 89. ¿Qué hace `yyparse()`?

`yyparse()` es una función generada por Bison.

Inicia el análisis sintáctico.

Durante ese análisis:

```text
Flex entrega tokens
Bison aplica producciones
se ejecutan acciones semánticas
se construye la máquina
```

---

# 90. ¿Por qué `main.c` no debería contener toda la lógica?

Porque queremos separar responsabilidades.

Una organización más limpia es:

```text
main.c
↓
inicio

turing.y
↓
gramática

turing.l
↓
lexer

turing.c
↓
modelo y validaciones

interprete.c
↓
ejecución
```

---

# 91. Archivos generados automáticamente

Bison genera:

```text
turing.tab.c
turing.tab.h
```

Flex genera:

```text
lex.yy.c
```

GCC genera:

```text
turing
```

o eventualmente:

```text
turing.exe
```

---

# 92. ¿Se deben editar `lex.yy.c` o `turing.tab.c`?

No.

Son archivos generados.

Si queremos cambiar el lexer:

```text
editamos turing.l
```

Si queremos cambiar la gramática:

```text
editamos turing.y
```

Después volvemos a generar.

---

# 93. Compilación manual

Antes compilábamos mediante:

```bash
bison -d turing.y
flex turing.l
gcc main.c turing.c interprete.c turing.tab.c lex.yy.c -lfl -o turing
```

---

# 94. Bison

Este comando:

```bash
bison -d turing.y
```

genera:

```text
turing.tab.c
turing.tab.h
```

La opción:

```text
-d
```

hace que Bison genere también el archivo de cabecera.

---

# 95. Flex

Después:

```bash
flex turing.l
```

genera:

```text
lex.yy.c
```

---

# 96. GCC

Finalmente:

```bash
gcc main.c turing.c interprete.c turing.tab.c lex.yy.c -lfl -o turing
```

compila todo.

---

# 97. ¿Qué significa `-lfl`?

Indica al enlazador que utilice la biblioteca asociada a Flex:

```text
libfl
```

---

# 98. Makefile

Ahora automatizamos ese proceso.

Podemos ejecutar:

```bash
make
```

y Make determina qué archivos debe generar y compilar.

---

# 99. `make clean`

Ejecutar:

```bash
make clean
```

elimina los archivos generados.

Por ejemplo:

```text
turing
turing.exe
turing.tab.c
turing.tab.h
lex.yy.c
*.o
```

---

# 100. ¿Por qué es útil `make clean`?

Permite comprobar que el proyecto realmente puede reconstruirse desde los archivos fuente.

Una buena prueba es:

```bash
make clean
make
```

Si vuelve a compilar:

```text
el proyecto puede reconstruirse correctamente
```

---

# 101. Warnings que aparecieron

Al compilar con:

```text
-Wall -Wextra
```

aparecieron advertencias como:

```text
warning: 'input' defined but not used
warning: 'yyunput' defined but not used
```

Estas advertencias provenían de:

```text
lex.yy.c
```

que es código generado automáticamente por Flex.

No impidieron la compilación.

---

# 102. ¿Warning es lo mismo que error?

No.

## Error

Puede impedir la compilación.

## Warning

Es una advertencia.

El compilador informa algo potencialmente relevante, pero puede generar el ejecutable igualmente.

---

# 103. Cygwin

Estamos trabajando en Windows, pero utilizamos Cygwin para disponer de herramientas habituales de Unix.

Por ejemplo:

```text
bash
gcc
make
flex
bison
libfl
```

---

# 104. VS Code versus Cygwin

VS Code es el editor.

Cygwin proporciona el entorno y las herramientas de compilación.

Por eso pueden aparecer situaciones donde VS Code muestre una advertencia de IntelliSense pero:

```bash
gcc
```

dentro de Cygwin compile correctamente.

---

# 105. Caso de `unistd.h`

Durante el desarrollo podía aparecer un error visual de VS Code relacionado con:

```text
unistd.h
```

pero la compilación con Cygwin funcionaba.

Eso ocurre porque:

```text
IntelliSense de VS Code
```

y:

```text
compilador de Cygwin
```

no necesariamente están utilizando exactamente las mismas rutas de cabeceras.

---

# 106. Estado actual del proyecto

Hasta la última prueba realizada funciona:

```text
análisis léxico
análisis sintáctico
declaración de alfabeto
declaración de estados
estado inicial
estados finales
transiciones
movimientos
intérprete
cinta
determinismo
subrutinas
parámetro entero
expansión de subrutinas
renombrado de estados
copia de transiciones
conexión entre copias
entrada a la subrutina
salida hacia la máquina principal
Makefile
```

Todavía existen casos que deben probarse específicamente antes de afirmar que todo el lenguaje funciona en cualquier situación.

---

# 107. Pendientes de validación

En la próxima sesión se debe probar deliberadamente:

- estado inicial inexistente;
- estado final inexistente;
- estado de transición inexistente;
- símbolo inexistente;
- transición duplicada;
- ausencia del símbolo blanco;
- subrutina inexistente;
- parámetro igual a cero;
- posibles parámetros negativos según la gramática;
- incompatibilidad entre alfabeto y subrutina;
- múltiples declaraciones;
- múltiples máquinas;
- múltiples usos de una misma subrutina;
- límites de tablas;
- movimiento fuera de los límites de la cinta;
- reconstrucción completa con `make clean && make`.

No debemos afirmar que esos casos están solucionados hasta probarlos.

---

# 108. Cómo estudiar este proyecto

No conviene memorizar cada línea.

La forma recomendada es comprender primero este mapa:

```text
archivo .tm
↓
Flex
↓
tokens
↓
Bison
↓
gramática
↓
acciones semánticas
↓
tablas y estructuras
↓
intérprete
↓
cinta + cabezal
```

Después comprender:

```text
subrutina
↓
almacenamiento independiente
↓
usa mover(3)
↓
validación
↓
expansión
↓
renombrado
↓
copia de transiciones
↓
conexión
↓
ejecución
```

---

# 109. Preguntas tipo profesor

A continuación se presentan preguntas que podrían hacerse durante una interrogación oral.

---

## Pregunta 1: ¿Qué hace Flex?

Flex realiza el análisis léxico.

Lee caracteres del archivo de entrada y los agrupa en tokens según expresiones regulares.

Por ejemplo:

```text
maquina
```

se reconoce como:

```text
MAQUINA
```

y:

```text
q0
```

como:

```text
ID
```

---

## Pregunta 2: ¿Qué hace Bison?

Bison realiza el análisis sintáctico.

Recibe los tokens generados por Flex y verifica que cumplan las producciones definidas en la gramática.

También ejecuta acciones semánticas asociadas a esas producciones.

---

## Pregunta 3: ¿Cuál es la diferencia entre Flex y Bison?

Respuesta corta:

```text
Flex reconoce elementos individuales.
Bison reconoce cómo se combinan esos elementos.
```

Ejemplo:

Flex puede reconocer:

```text
MAQUINA ID LLAVE_IZQ
```

Bison determina que esa secuencia puede ser el comienzo de una declaración de máquina.

---

## Pregunta 4: ¿Qué es un token?

Es una categoría léxica.

Ejemplos:

```text
ID
NUMERO
SIMBOLO
MAQUINA
DER
```

---

## Pregunta 5: ¿Qué es un lexema?

Es el texto concreto reconocido.

Por ejemplo:

```text
q0
```

es un lexema cuyo token es:

```text
ID
```

---

## Pregunta 6: ¿`q0` es un token?

No exactamente.

`q0` es el lexema.

El token es:

```text
ID
```

---

## Pregunta 7: ¿Qué diferencia hay entre terminal y no terminal?

Los terminales son los tokens.

Ejemplo:

```text
ID
MAQUINA
SIMBOLO
```

Los no terminales son categorías definidas por nuestra gramática.

Ejemplo:

```text
maquina
transicion
lista_estados
```

---

## Pregunta 8: ¿Qué hace `%union`?

Permite especificar los tipos de datos que pueden transportar los tokens o no terminales.

Por ejemplo:

```text
texto
número
movimiento
```

---

## Pregunta 9: ¿Qué contiene `$1`?

Contiene el valor semántico del primer elemento de una producción.

Por ejemplo:

```bison
MAQUINA ID
```

`$2` contiene el valor asociado al `ID`.

---

## Pregunta 10: ¿Qué significa `$$`?

Es el valor semántico producido por el no terminal actual.

Por ejemplo:

```bison
DER { $$ = MOV_DER; }
```

---

## Pregunta 11: ¿Cuál es la diferencia entre error sintáctico y semántico?

Un error sintáctico viola la gramática.

Ejemplo:

```text
inicial q0;
```

cuando se requiere:

```text
inicial: q0;
```

Un error semántico tiene una sintaxis válida pero un significado inválido.

Ejemplo:

```text
inicial: q5;
```

cuando `q5` no fue declarado.

---

## Pregunta 12: ¿Cómo representan una transición?

Con una estructura que guarda:

```text
estado origen
símbolo leído
estado destino
símbolo escrito
movimiento
```

---

## Pregunta 13: ¿Cómo garantizan que la máquina sea determinista?

Antes de agregar una transición comprobamos que no exista otra para la misma combinación:

```text
(estado origen, símbolo leído)
```

Solo puede existir una.

---

## Pregunta 14: ¿Por qué esto no es determinista?

```text
q0, '0' -> q1, '1', DER;
q0, '0' -> q2, '0', IZQ;
```

Porque ambas transiciones tienen la misma entrada:

```text
(q0, '0')
```

La máquina tendría dos posibles decisiones.

---

## Pregunta 15: ¿Cómo se representa la cinta?

Mediante un arreglo de caracteres:

```c
char cinta[TAM_CINTA];
```

Cada posición representa una celda.

---

## Pregunta 16: ¿Por qué usan `char`?

Porque el proyecto utiliza símbolos individuales de un carácter.

Cada celda almacena un símbolo.

---

## Pregunta 17: ¿Qué representa `_`?

El símbolo blanco de la cinta.

---

## Pregunta 18: ¿Cómo saben dónde está el cabezal?

Mediante:

```c
int posicion_cabezal;
```

---

## Pregunta 19: ¿Qué ocurre al ejecutar `DER`?

Incrementamos la posición:

```c
posicion_cabezal++;
```

---

## Pregunta 20: ¿Qué ocurre al ejecutar `IZQ`?

Disminuimos la posición:

```c
posicion_cabezal--;
```

---

## Pregunta 21: ¿Qué ocurre con `QUIETO`?

La posición del cabezal no cambia.

Solo pueden cambiar:

```text
símbolo
estado
```

según la transición.

---

## Pregunta 22: ¿Qué pasa si el intérprete no encuentra una transición?

La búsqueda devuelve `NULL` y la máquina se detiene indicando que no existe una transición para el estado y símbolo actuales.

---

## Pregunta 23: ¿Qué es `NULL`?

Representa que un puntero no apunta a un objeto válido.

---

## Pregunta 24: ¿Qué es un puntero?

Una variable que almacena una dirección de memoria.

---

## Pregunta 25: ¿Qué significa esto?

```c
Transicion *t;
```

Significa que `t` puede apuntar a una estructura de tipo `Transicion`.

---

## Pregunta 26: ¿Qué significa `&tabla[i]`?

Obtiene la dirección de memoria del elemento:

```text
tabla[i]
```

---

## Pregunta 27: ¿Qué significa `t->estado_origen`?

Accede al campo:

```text
estado_origen
```

de la estructura a la que apunta `t`.

---

## Pregunta 28: ¿Qué significa `extern`?

Indica que una variable está definida en otro archivo.

Permite compartir una misma variable global sin volver a definirla.

---

## Pregunta 29: ¿Para qué sirve `turing.h`?

Para compartir estructuras, enumeraciones, constantes, prototipos y variables externas entre los diferentes archivos.

---

## Pregunta 30: ¿Por qué separaron el proyecto en varios archivos?

Para separar responsabilidades.

Por ejemplo:

```text
lexer        → turing.l
gramática    → turing.y
modelo       → turing.c
intérprete   → interprete.c
inicio       → main.c
```

Esto facilita entender y mantener el programa.

---

## Pregunta 31: ¿Quién ejecuta realmente la Máquina de Turing: Bison o el intérprete?

El intérprete.

Bison analiza la descripción y construye la representación de la máquina.

La ejecución se realiza posteriormente mediante nuestras funciones en C.

---

## Pregunta 32: ¿Qué hace `yyparse()`?

Inicia el parser generado por Bison.

Durante esa ejecución, Bison solicita tokens a Flex y aplica las reglas de la gramática.

---

## Pregunta 33: ¿Qué hace `yylex()`?

Es la función utilizada para obtener el siguiente token desde Flex.

---

## Pregunta 34: ¿Por qué no editar directamente `lex.yy.c`?

Porque se genera automáticamente desde:

```text
turing.l
```

Cualquier cambio manual puede perderse la próxima vez que se ejecute Flex.

---

## Pregunta 35: ¿Por qué no editar `turing.tab.c`?

Porque Bison lo genera automáticamente a partir de:

```text
turing.y
```

---

## Pregunta 36: ¿Qué hace `make`?

Automatiza la generación y compilación del proyecto.

Ejecuta Bison, Flex y GCC cuando corresponde.

---

## Pregunta 37: ¿Qué hace `make clean`?

Elimina archivos generados para poder reconstruir el proyecto desde cero.

---

## Pregunta 38: ¿Para qué sirve el Makefile?

Evita que el usuario tenga que recordar y ejecutar manualmente todos los comandos de compilación.

También especifica dependencias entre archivos.

---

## Pregunta 39: ¿Por qué apareció un warning de `input` o `yyunput`?

Porque Flex genera funciones auxiliares que nuestro lexer puede no utilizar.

Como compilamos con:

```text
-Wall -Wextra
```

GCC informa que esas funciones están definidas pero no utilizadas.

No impide generar el ejecutable.

---

# 110. Preguntas tipo profesor sobre subrutinas

## Pregunta 40: ¿Cómo almacenan una subrutina?

Utilizamos una estructura `Subrutina` que contiene:

```text
nombre
parámetro
estados
estado inicial
estados finales
transiciones
```

---

## Pregunta 41: ¿Por qué no agregan directamente los estados de una subrutina a la máquina?

Porque primero queremos conservarla como una unidad independiente y reutilizable.

Solo cuando aparece:

```text
usa ...
```

se expande dentro de la máquina.

---

## Pregunta 42: ¿Cómo sabe `agregar_estado()` si está agregando un estado de máquina o de subrutina?

Comprueba el contexto:

```c
dentro_subrutina
```

Si es verdadero, agrega el estado a la subrutina actual.

Si no, lo agrega a la máquina principal.

---

## Pregunta 43: ¿Para qué existe `subrutina_actual`?

Para saber a qué subrutina deben agregarse los estados, finales y transiciones que Bison está leyendo actualmente.

---

## Pregunta 44: ¿Qué hace `usa mover(3)`?

En nuestra implementación:

1. busca la subrutina `mover`;
2. valida que pueda utilizarse con el alfabeto de la máquina;
3. toma el parámetro entero `3`;
4. genera tres copias;
5. renombra sus estados;
6. copia sus transiciones;
7. conecta las copias;
8. conecta el bloque expandido con la máquina principal.

---

## Pregunta 45: ¿Por qué necesitan renombrar los estados?

Para evitar colisiones.

Si copiáramos tres veces:

```text
s0
s1
```

no podríamos distinguir a qué copia pertenece cada estado.

---

## Pregunta 46: ¿Qué nombre generan?

Por ejemplo:

```text
mover_2_s0
```

indica:

```text
subrutina mover
segunda copia
estado original s0
```

---

## Pregunta 47: ¿Por qué usan `strdup()` al crear esos nombres?

Porque los nombres se generan inicialmente en arreglos locales.

`strdup()` crea una copia independiente que permanece disponible cuando termina la iteración o la función.

---

## Pregunta 48: ¿Por qué no basta con copiar las transiciones de una subrutina?

Porque esas transiciones también deben apuntar a los nuevos nombres de estado.

Además, las distintas copias deben quedar conectadas entre sí y con la máquina principal.

---

## Pregunta 49: ¿Por qué no basta con copiar los estados y transiciones?

Porque podrían quedar inalcanzables.

Eso ocurrió durante el desarrollo: las copias existían, pero la máquina comenzaba en `q0`, por lo que nunca ingresaba a `mover_1_s0`.

---

## Pregunta 50: ¿Cómo solucionaron que la subrutina fuera inalcanzable?

Guardamos el inicio original:

```c
char *inicio_maquina = estado_actual;
```

y cambiamos temporalmente el inicio de ejecución hacia:

```text
mover_1_s0
```

Luego la última copia vuelve al inicio original.

---

## Pregunta 51: ¿Por qué guardan `inicio_maquina` antes de cambiar `estado_actual`?

Porque necesitamos recordar el estado inicial original para saber a qué estado regresar cuando termina la expansión.

En nuestro ejemplo:

```text
q0
```

---

## Pregunta 52: ¿Cómo conectan la primera copia con la segunda?

Desde los estados finales de la primera copia hacia el estado inicial de la segunda.

Ejemplo:

```text
mover_1_s1
→
mover_2_s0
```

---

## Pregunta 53: ¿Por qué no hacen simplemente `mover_1_s1 -> mover_2_s0`?

Porque una transición de Máquina de Turing necesita especificar:

```text
símbolo leído
símbolo escrito
movimiento
```

No implementamos transiciones epsilon.

---

## Pregunta 54: ¿Cómo resuelven la ausencia de transiciones epsilon?

Generamos transiciones identidad.

Por ejemplo:

```text
mover_1_s1, '0'
->
mover_2_s0, '0', QUIETO
```

---

## Pregunta 55: ¿Qué es una transición identidad en este contexto?

Una transición que:

```text
lee un símbolo
escribe el mismo símbolo
no mueve el cabezal
cambia de estado
```

---

## Pregunta 56: ¿Por qué generan una transición de conexión para cada símbolo del alfabeto?

Porque no sabemos qué símbolo estará bajo el cabezal cuando termine la copia anterior.

Así permitimos continuar sin modificar la cinta para cualquiera de los símbolos válidos.

---

## Pregunta 57: ¿Por qué utilizan `QUIETO` para conectar?

Porque no queremos que la conexión entre bloques altere la posición del cabezal.

---

## Pregunta 58: ¿Por qué el bucle de conexión usa `r < repeticiones`?

Con tres copias necesitamos:

```text
1 → 2
2 → 3
```

No necesitamos:

```text
3 → 4
```

porque la copia 4 no existe.

---

## Pregunta 59: ¿Por qué `mover(3)` terminó con el cabezal sobre `_`?

Porque cada copia ejecutó:

```text
DER
```

sobre una cinta inicial:

```text
000_
```

Después de tres movimientos a la derecha quedó sobre el primer blanco.

---

## Pregunta 60: Durante una prueba apareció:

```text
Maquina detenida: no existe transicion para (q0, '_').
```

¿Eso significaba que la expansión estaba mal?

No.

La expansión funcionó correctamente.

La subrutina dejó el cabezal sobre `_`, pero la máquina principal tenía una transición solamente para:

```text
(q0, '0')
```

Al cambiar la prueba a:

```text
q0, '_' -> qA, '_', QUIETO;
```

la máquina terminó correctamente.

---

# 111. Preguntas de razonamiento que podrían hacer

## Pregunta 61: Si la máquina está en `q0` leyendo `'0'`, ¿cómo sabe qué transición elegir?

Busca en la tabla una transición cuyo:

```text
estado_origen = q0
simbolo_leido = '0'
```

Como la máquina es determinista, debe existir como máximo una.

---

## Pregunta 62: ¿Qué ocurriría si hubiera dos?

Sería una violación del determinismo y debería detectarse como error semántico.

---

## Pregunta 63: ¿Qué ocurre si no hay ninguna?

La máquina se detiene porque no hay comportamiento definido para esa configuración.

---

## Pregunta 64: ¿Qué información define completamente la configuración instantánea de esta implementación?

A nivel práctico necesitamos principalmente:

```text
contenido de la cinta
posición del cabezal
estado actual
```

---

## Pregunta 65: ¿Por qué la gramática por sí sola no puede detectar todos los errores?

Porque la gramática comprueba estructura.

Por ejemplo:

```text
inicial: q99;
```

puede tener una forma sintácticamente correcta.

Para saber si `q99` fue declarado necesitamos consultar información almacenada previamente.

Eso corresponde a análisis semántico.

---

## Pregunta 66: Entonces, ¿dónde se valida que un estado exista?

Mediante funciones de C llamadas desde acciones semánticas de Bison.

Por ejemplo:

```c
existe_estado(...)
```

---

## Pregunta 67: ¿Flex podría comprobar que `q99` está declarado?

No debería ser responsabilidad del lexer.

Flex reconoce que `q99` tiene forma de identificador.

La existencia del estado es una condición semántica.

---

## Pregunta 68: ¿Una expresión regular es suficiente para describir todo el lenguaje?

No.

Las expresiones regulares sirven bien para tokens.

La estructura completa del lenguaje requiere una gramática.

---

## Pregunta 69: ¿Por qué se necesita Bison si Flex ya reconoce palabras?

Porque reconocer palabras no es suficiente para saber si aparecen en un orden válido.

Flex puede reconocer:

```text
INICIAL
ID
PUNTO_COMA
```

pero Bison determina cómo deben combinarse.

---

## Pregunta 70: ¿Qué ocurre primero: Flex o Bison?

En términos conceptuales:

```text
Bison está analizando
↓
necesita el siguiente token
↓
llama a Flex
↓
Flex devuelve un token
```

Ambos trabajan coordinadamente.

---

# 112. Ejercicio mental completo

Supongamos:

```text
q0, '0' -> q1, '1', DER;
```

y la cinta es:

```text
[0] 0 _
```

Estado actual:

```text
q0
```

### Paso 1

Leer:

```text
'0'
```

### Paso 2

Buscar:

```text
(q0, '0')
```

### Paso 3

Encontrar:

```text
q0, '0' -> q1, '1', DER
```

### Paso 4

Escribir:

```text
'1'
```

Cinta:

```text
[1] 0 _
```

### Paso 5

Cambiar estado:

```text
q1
```

### Paso 6

Mover DER:

```text
1 [0] _
```

Resultado:

```text
estado_actual = q1
posicion_cabezal = 1
```

---

# 113. Forma corta de explicar todo el proyecto oralmente

Si el profesor pide:

> Explíqueme qué hace su proyecto.

Una respuesta posible es:

> El proyecto implementa un DSL para definir máquinas de Turing deterministas de una cinta. Flex realiza el análisis léxico y transforma los lexemas en tokens. Bison utiliza esos tokens para validar la gramática y ejecutar acciones semánticas que construyen una representación interna de estados, símbolos y transiciones. Luego un intérprete escrito en C inicializa la cinta, mantiene el estado y la posición del cabezal, busca la transición correspondiente a cada configuración y la ejecuta hasta alcanzar un estado final o no encontrar una transición. También implementamos subrutinas que se almacenan separadamente y se expanden antes de la ejecución mediante renombrado y composición de estados y transiciones.

---

# 114. Forma corta de explicar las subrutinas

Si pregunta:

> ¿Cómo implementaron las subrutinas?

Respuesta:

> Las subrutinas se almacenan en una estructura independiente mientras Bison las analiza. Cuando aparece una instrucción `usa`, buscamos la subrutina, validamos sus símbolos contra el alfabeto de la máquina y generamos copias de sus estados y transiciones. Cada copia renombra sus estados para evitar colisiones. Después conectamos los estados finales de una copia con el estado inicial de la siguiente mediante transiciones identidad con movimiento QUIETO. Finalmente hacemos que la ejecución comience en la primera copia y que la última retorne al flujo de la máquina principal.

---

# 115. Forma corta de explicar determinismo

Si pregunta:

> ¿Cómo garantizan determinismo?

Respuesta:

> Antes de almacenar una transición verificamos si ya existe otra con el mismo estado de origen y símbolo leído. Si existe, rechazamos la nueva transición como error semántico. Así cada configuración `(estado, símbolo)` tiene como máximo una transición aplicable.

---

# 116. Forma corta de explicar error sintáctico versus semántico

Si pregunta:

> ¿Cuál es la diferencia entre sintaxis y semántica en su proyecto?

Respuesta:

> La sintaxis determina si el código sigue la estructura definida por la gramática, mientras que la semántica verifica que lo escrito tenga sentido. Por ejemplo, olvidar los dos puntos de `inicial:` es un error sintáctico; indicar como inicial un estado que nunca fue declarado es un error semántico.

---

# 117. Qué NO decir en la defensa

No decir:

```text
Flex ejecuta la máquina.
```

Incorrecto.

No decir:

```text
Bison lee directamente caracteres.
```

Bison trabaja principalmente con tokens entregados por el lexer.

No decir:

```text
q0 es un token.
```

Mejor:

```text
q0 es un lexema cuyo token es ID.
```

No decir:

```text
NULL significa cero.
```

En este contexto representa un puntero que no apunta a un objeto válido.

No decir:

```text
extern crea la variable.
```

`extern` declara que la variable existe en otra unidad de compilación.

No decir:

```text
QUIETO no hace nada.
```

Puede cambiar símbolo y estado; lo que no cambia es la posición del cabezal.

No decir:

```text
mover(3) siempre significa repetir tres veces en cualquier lenguaje.
```

Es la semántica que definimos para nuestro DSL.

---

# 118. Orden recomendado para estudiar mañana

## Nivel 1 — entender el flujo

Memorizar conceptualmente:

```text
Flex
↓
tokens
↓
Bison
↓
estructuras
↓
intérprete
```

## Nivel 2 — entender una transición

Ser capaz de explicar:

```text
q0, '0' -> q1, '1', DER
```

## Nivel 3 — entender validaciones

Dominar:

```text
estado declarado
símbolo declarado
determinismo
estado inicial
estado final
```

## Nivel 4 — entender C

Repasar:

```text
struct
puntero
NULL
&
->
extern
strdup
```

## Nivel 5 — entender subrutinas

Repasar:

```text
Subrutina
dentro_subrutina
subrutina_actual
usa
expansión
renombrado
transiciones identidad
QUIETO
```

---

# 119. Mini interrogación de práctica

Intentar responder sin mirar las respuestas.

### 1.

¿Qué diferencia hay entre un lexema y un token?

### 2.

¿Qué problema resuelve Flex?

### 3.

¿Qué problema resuelve Bison?

### 4.

¿Qué diferencia hay entre un terminal y un no terminal?

### 5.

¿Qué significa `$2` en una acción de Bison?

### 6.

¿Qué significa `$$`?

### 7.

¿Por qué un estado inexistente es un error semántico y no sintáctico?

### 8.

¿Cómo se representa una transición en C?

### 9.

¿Qué significa:

```c
Transicion *t;
```

### 10.

¿Qué significa:

```c
&t[i]
```

o equivalente?

### 11.

¿Qué significa `NULL`?

### 12.

¿Qué hace `extern`?

### 13.

¿Cómo se representa la cinta?

### 14.

¿Cómo se representa el cabezal?

### 15.

¿Qué hace una transición `DER`?

### 16.

¿Qué hace `QUIETO`?

### 17.

¿Cómo garantizamos determinismo?

### 18.

¿Qué pasa si no existe una transición para `(estado, símbolo)`?

### 19.

¿Por qué las subrutinas se guardan separadamente?

### 20.

¿Qué significa `dentro_subrutina`?

### 21.

¿Qué hace `usa mover(3)`?

### 22.

¿Por qué renombramos `s0` a `mover_1_s0`?

### 23.

¿Por qué usamos `strdup()`?

### 24.

¿Por qué hay que conectar las copias después de expandirlas?

### 25.

¿Por qué usamos transiciones `QUIETO` entre las copias?

### 26.

¿Por qué necesitamos una transición por símbolo del alfabeto?

### 27.

¿Por qué guardamos `inicio_maquina`?

### 28.

¿Por qué el primer intento terminó diciendo que no existía transición para `(q0, '_')`?

### 29.

¿Eso significaba que nuestro intérprete estaba malo?

### 30.

¿Cuál fue la corrección de esa prueba?

### 31.

¿Qué genera Bison?

### 32.

¿Qué genera Flex?

### 33.

¿Qué hace GCC?

### 34.

¿Qué hace el Makefile?

### 35.

¿Qué hace `make clean`?

---

# 120. Respuestas rápidas de la mini interrogación

### 1.
Lexema es el texto concreto; token es su categoría.

### 2.
Flex realiza análisis léxico.

### 3.
Bison realiza análisis sintáctico y ejecuta acciones asociadas a la gramática.

### 4.
Terminales son tokens; no terminales son construcciones definidas en la gramática.

### 5.
Es el valor semántico del segundo símbolo de una producción.

### 6.
Es el valor resultante del no terminal actual.

### 7.
Porque la estructura puede ser válida aunque el estado no exista.

### 8.
Mediante una estructura con origen, símbolo leído, destino, símbolo escrito y movimiento.

### 9.
Es un puntero a `Transicion`.

### 10.
Obtiene la dirección del elemento.

### 11.
Indica que un puntero no apunta a un objeto válido.

### 12.
Declara una variable definida en otro archivo.

### 13.
Con un arreglo de `char`.

### 14.
Con un entero que indica la posición actual.

### 15.
Mueve el cabezal una posición a la derecha.

### 16.
Mantiene el cabezal en la misma celda.

### 17.
No permitiendo dos transiciones con el mismo `(estado, símbolo)`.

### 18.
La máquina se detiene.

### 19.
Para mantenerlas independientes hasta que sean invocadas.

### 20.
Indica si actualmente estamos leyendo el cuerpo de una subrutina.

### 21.
En nuestro diseño, expande tres copias de `mover`.

### 22.
Para evitar colisiones de estados.

### 23.
Para conservar una copia persistente de un nombre generado localmente.

### 24.
Porque de lo contrario serían bloques independientes e inalcanzables entre sí.

### 25.
Para cambiar de bloque sin mover el cabezal.

### 26.
Porque el símbolo leído al finalizar una copia puede variar.

### 27.
Para poder regresar al flujo original de la máquina.

### 28.
Porque después de tres movimientos a la derecha el cabezal quedó sobre `_`.

### 29.
No. La máquina definida no tenía una transición para esa configuración.

### 30.
Agregar/cambiar la transición de `q0` para aceptar `_`.

### 31.
`turing.tab.c` y `turing.tab.h`.

### 32.
`lex.yy.c`.

### 33.
Compila y enlaza los archivos C.

### 34.
Automatiza todo el proceso de generación y compilación.

### 35.
Elimina archivos generados para reconstruir el proyecto desde cero.

---

# 121. Pendientes para mañana

Antes de considerar la entrega definitivamente cerrada debemos realizar pruebas deliberadas.

## Pruebas semánticas

Probar:

```text
estado inicial inexistente
estado final inexistente
estado origen inexistente
estado destino inexistente
símbolo fuera del alfabeto
transición duplicada
subrutina inexistente
subrutina incompatible con alfabeto
repeticiones igual a cero
```

## Pruebas estructurales

Revisar:

```text
más de una máquina
más de una subrutina
más de un usa
misma subrutina utilizada más de una vez
```

## Casos límite

Revisar:

```text
cabezal intentando salir de la cinta
cantidad máxima de estados
cantidad máxima de transiciones
```

## Compilación

Ejecutar:

```bash
make clean
make
```

y verificar que pueda reconstruirse desde cero.

## Git

Revisar:

```bash
git status
```

Después:

```bash
git add .
git commit
git push
```

solo cuando hayamos comprobado que todo está correcto.

---

# 122. Resumen final

El proyecto puede resumirse mediante:

```text
TEXTO DEL DSL
      ↓
     FLEX
      ↓
    TOKENS
      ↓
    BISON
      ↓
GRAMÁTICA + SEMÁNTICA
      ↓
ESTRUCTURAS EN C
      ↓
   INTÉRPRETE
      ↓
CINTA + CABEZAL + ESTADO
      ↓
EJECUCIÓN DE TRANSICIONES
```

Y para las subrutinas:

```text
SUBRUTINA
   ↓
ALMACENAMIENTO SEPARADO
   ↓
usa mover(3)
   ↓
VALIDACIÓN
   ↓
EXPANSIÓN
   ↓
RENOMBRADO
   ↓
COPIA DE TRANSICIONES
   ↓
CONEXIÓN CON QUIETO
   ↓
EJECUCIÓN
```

La idea más importante no es memorizar todo el código.

La idea es poder explicar:

```text
qué hace cada componente,
por qué existe,
qué problema resuelve,
y cómo se conecta con el resto del proyecto.
```