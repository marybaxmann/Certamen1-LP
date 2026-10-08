maquina A {
    alfabeto { '0', '1', '_' }
    estados { q0, q1, qA }
    inicial: q0;
    finales: { qA };

    transiciones {
        q0, '0' -> q1, '1', DER;
        q1, '0' -> q0, '0', IZQ;
        q0, '1' -> qA, '1', QUIETO;
    }
}