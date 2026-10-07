subrutina mover {
    estados { q0, q1 }
    inicial: q0;
    finales: { q1 };
    transiciones {
        q0, '0' -> q1, '0', DER;
    }
}

