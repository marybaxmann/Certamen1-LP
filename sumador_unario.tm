maquina SumadorUnario {
    alfabeto { '1', '+', '_' }

    estados { q0, q1, q2, q_fin }

    inicial: q0;

    finales: { q_fin };

    transiciones {
        // 1. Avanzar sobre el primer numero de 1s hasta encontrar el '+'
        q0, '1' -> q0, '1', DER;
        q0, '+' -> q1, '1', DER;

        // 2. Avanzar sobre el segundo numero de 1s hasta encontrar el final '_'
        q1, '1' -> q1, '1', DER;
        q1, '_' -> q2, '_', IZQ;

        // 3. Borrar el 1 sobrante al final para compensar el '+' convertido en 1
        q2, '1' -> q_fin, '_', QUIETO;
    }
}
