maquina IncrementadorBinario {
    alfabeto { '0', '1', '_' }

    estados { q_inicio, q_buscar_fin, q_sumar, q_final }

    inicial: q_inicio;

    finales: { q_final };

    transiciones {
        // 1. Avanzar hacia la derecha hasta encontrar el blanco
        q_inicio, '0' -> q_buscar_fin, '0', DER;
        q_inicio, '1' -> q_buscar_fin, '1', DER;
        q_inicio, '_' -> q_final, '1', QUIETO;

        q_buscar_fin, '0' -> q_buscar_fin, '0', DER;
        q_buscar_fin, '1' -> q_buscar_fin, '1', DER;
        q_buscar_fin, '_' -> q_sumar, '_', IZQ;

        // 2. Sumar 1 desde el bit menos significativo hacia la izquierda
        // Si encuentra 0, lo cambia por 1 y termina
        q_sumar, '0' -> q_final, '1', QUIETO;

        // Si encuentra 1, lo cambia por 0 y arrastra acarreo
        q_sumar, '1' -> q_sumar, '0', IZQ;

        // Si llega al inicio (blanco), escribe 1 y termina
        q_sumar, '_' -> q_final, '1', QUIETO;
    }
}
