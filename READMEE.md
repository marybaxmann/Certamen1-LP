# Intérprete de Máquina de Turing

Proyecto desarrollado para el Certamen I de Lenguajes de Programación II.

El programa implementa un lenguaje específico de dominio (DSL) para definir y ejecutar máquinas de Turing deterministas de una cinta utilizando Flex, Bison y C.

## Requisitos

Para compilar y ejecutar el proyecto se requiere:

- GCC
- Flex
- Bison
- libfl
- Make

El proyecto fue desarrollado y probado utilizando Cygwin en Windows.

## Estructura del proyecto

- `turing.l`: analizador léxico implementado con Flex.
- `turing.y`: gramática y acciones semánticas implementadas con Bison.
- `turing.h`: estructuras, constantes, variables externas y prototipos.
- `turing.c`: almacenamiento y validación de estados, símbolos, transiciones y subrutinas.
- `interprete.c`: ejecución de la máquina de Turing.
- `main.c`: punto de entrada del programa.
- `*.tm`: archivos de prueba escritos en el DSL.
- `Makefile`: automatiza la compilación del proyecto.

## Compilación

Ejecutar:

```bash
make
```

El `Makefile` genera automáticamente los archivos necesarios de Bison y Flex y posteriormente compila el programa con GCC.

## Ejecución

Ejemplo:

```bash
./turing < prueba.tm
```

También puede utilizarse:

```bash
make run
```

Para ejecutar el ejemplo de subrutinas:

```bash
make run-subrutina
```

## Ejemplo básico del DSL

```
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

## Características implementadas

El lenguaje permite definir:

- alfabeto;
- estados;
- estado inicial;
- estados finales;
- transiciones;
- movimientos `IZQ`, `DER` y `QUIETO`;
- subrutinas;
- invocación de subrutinas con parámetro entero.

También se realizan validaciones semánticas, entre ellas:

- verificación de estados declarados;
- verificación de símbolos pertenecientes al alfabeto;
- validación del estado inicial;
- validación de estados finales;
- control de determinismo de las transiciones.

## Subrutinas

Las subrutinas se almacenan de forma separada y posteriormente pueden ser utilizadas desde una máquina.

Ejemplo:

```
subrutina mover(n) {
    estados { s0, s1 }

    inicial: s0;

    finales: { s1 };

    transiciones {
        s0, '0' -> s1, '0', DER;
    }
}
```

Una invocación como:

```
usa mover(3);
```

genera varias copias de la subrutina antes de la ejecución.

Los estados de cada copia son renombrados para evitar colisiones, por ejemplo:

```
mover_1_s0
mover_1_s1
mover_2_s0
mover_2_s1
```

Las distintas copias son conectadas mediante transiciones que conservan el símbolo leído y utilizan el movimiento `QUIETO`.

## Archivos generados

Durante la compilación se generan automáticamente:

- `turing.tab.c`
- `turing.tab.h`
- `lex.yy.c`
- `turing`

Estos archivos no deben editarse manualmente, ya que pueden regenerarse utilizando:

```bash
make
```

## Limpieza del proyecto

Para eliminar los archivos generados por la compilación:

```bash
make clean
```

Luego se puede reconstruir todo con `make`.
