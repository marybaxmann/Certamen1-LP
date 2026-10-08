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