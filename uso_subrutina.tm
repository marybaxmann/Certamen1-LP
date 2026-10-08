subrutina mover(n) {
    estados { s0, s1 }
    inicial: s0;
    finales: { s1 };

    transiciones {
        s0, '0' -> s1, '0', DER;
    }
}

maquina A {
    alfabeto { '0', '_' }

    estados { q0, qA }
    inicial: q0;
    finales: { qA };

    usa mover(3);

    transiciones {
        q0, '_' -> qA, '_', QUIETO;
    }
}