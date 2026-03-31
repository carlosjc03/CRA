% ==========================================
% Archivo: test.pl
% Descripcion: Bateria de Pruebas Incremental (Defensa)
% ==========================================

:- consult('main.pl').

% ===================================================================
% TEST 1: MOVIMIENTO SIMPLE (1 Turno)
% ===================================================================
test1_movimiento_simple :-
    tablero_inicial(Tablero), 
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 1: Movimiento Simple (1 Turno)'), nl,
    bucle_juego_prueba(Estado, 1, [], fase1, 0, 0).

% ===================================================================
% TEST 2: MOVIMIENTO LIBRE (X Turnos, Ambos Jugadores)
% ===================================================================
test2_movimiento_libre(Turnos) :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 2: Movimiento Libre | Turnos: '), write(Turnos), nl,
    bucle_juego_prueba(Estado, Turnos, [], fase1, 0, 0).

% ===================================================================
% TEST 3: COBERTURA CONJUNTA (95 Turnos)
% ===================================================================
test3_cobertura_conjunta :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 3: Cobertura Conjunta (95 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 95, [], fase1, 0, 0).

% ===================================================================
% TEST 4: COBERTURA INDIVIDUAL JUGADOR 1 (143 Turnos)
% ===================================================================
test4_cobertura_j1 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 4: Cobertura J1 (143 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 143, [], fase1, 0, 0).

% ===================================================================
% TEST 5: COBERTURA INDIVIDUAL JUGADOR 2 (204 Turnos)
% ===================================================================
test5_cobertura_j2 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador2, 2),
    write('>> TEST 5: Cobertura J2 (204 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 204, [], fase1, 0, 0).

% ===================================================================
% TEST 6: CARTA INMEDIATA (Unitario)
% ===================================================================
test_carta_inmediata :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 1, 5000, []), jugador(jugador2, 0, 5000, [])], Tablero, jugador1, 1),
    write('>> TEST 6: CAER EN CARTA EN TURNO 1'), nl,
    bucle_juego_prueba(Estado, 1, [], fase2, 0, 0).

% ===================================================================
% TEST 7: SIMULACION DE CARTAS (X turnos)
% ===================================================================
test_simulacion_cartas(Turnos) :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 5000, []), jugador(jugador2, 0, 5000, [])], Tablero, jugador1, 1),
    write('>> TEST 7: FRECUENCIA DE CARTAS EN '), write(Turnos), write(' TURNOS'), nl,
    bucle_juego_prueba(Estado, Turnos, [], fase2, 0, 0).



% ===================================================================
% FASE 3: COMPRAS (Movimiento + Cartas + Compras, SIN ALQUILER)
% ===================================================================

% -------------------------------------------------------------------
% TEST 8: COMPRA INICIAL (Poco dinero, pocos turnos)
% Objetivo: Ver que con 1000 euros compran las primeras calles que pisan y el saldo baja.
% -------------------------------------------------------------------
test_compra_inicial :-
    tablero_inicial(Tablero),
    % Empiezan con 1500 euros.
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 8: COMPRA INICIAL (1 turnos, 1500 euros)'), nl,
    bucle_juego_prueba(Estado, 1, [], fase3, 0, 0).

% -------------------------------------------------------------------
% TEST 9: LIBERTAD TOTAL (Vaciando el tablero)
% Objetivo: Con dinero normal (1500), en 95 turnos deberian comprar casi todo el tablero.
% Si ponemos el dinero a 2000, las compran todas; si no hay que esperar al turno 153 para que el ciclo de compras se complete.
% -------------------------------------------------------------------
test_compra_libertad :-
    tablero_inicial(Tablero),
    % Les damos 1500 euros para asegurarnos de que el dinero no les frena.
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 9: LIBERTAD TOTAL (95 turnos, Dinero Ilimitado)'), nl,
    bucle_juego_prueba(Estado, 95, [], fase3, 0, 0).

% -------------------------------------------------------------------
% TEST 10: REALISMO HASTA AGOTAR SALDO (Supervivencia)
% Objetivo: Con los 1500 euros reales. Compraran a tope al principio, pero luego 
% el sistema debera rechazar las compras por falta de saldo sin romper el juego.
% -------------------------------------------------------------------
test_compra_realista :-
    tablero_inicial(Tablero),
    % Saldo real oficial del juego (1500)
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 10: COMPRA REALISTA (150 turnos, 1500 euros)'), nl,
    bucle_juego_prueba(Estado, 150, [], fase3, 0, 0).

% ===================================================================
% MOTOR INTERNO PARA INYECTAR LAS FASES (Patron Acumulador 100% Legal)
% ===================================================================

% CASO BASE: Imprimir metricas y balance de suerte
bucle_juego_prueba(EstadoActual, 0, Historial, _, BalanceCartasJ1, BalanceCartasJ2) :- 
    !, 
    mostrar_metricas(EstadoActual, Historial),
    nl, write('=================================================='), nl,
    write('>> IMPACTO ECONOMICO EXACTO DE LAS CARTAS'), nl,
    write('   - jugador1 ha obtenido un neto de: '), write(BalanceCartasJ1), write(' euros por suerte.'), nl,
    write('   - jugador2 ha obtenido un neto de: '), write(BalanceCartasJ2), write(' euros por suerte.'), nl,
    write('=================================================='), nl.

% CASO RECURSIVO: Extraer telemetría sin modificar el motor base
bucle_juego_prueba(EstadoActual, TurnosRestantes, HistorialActual, Modo, BalC1, BalC2) :-
    TurnosRestantes > 0,
    
    % 1. Miramos el estado ANTES de tirar
    EstadoActual = estado(JugadoresAntes, _, JugadorTurno, _),
    member(jugador(JugadorTurno, PosAntes, DineroAntes, _), JugadoresAntes),

    % 2. Dejamos que el motor normal (main.pl) haga su trabajo
    turno_limpio(EstadoActual, EstadoSiguiente, Modo, EventosNuevos),

    % 3. Miramos el estado DESPUES de tirar
    EstadoSiguiente = estado(JugadoresDespues, _, _, _),
    member(jugador(JugadorTurno, PosDespues, DineroDespues, _), JugadoresDespues),

    % 4. Calculo matematico aislado para auditar la suerte (Casillas: 2,7,17,22,33,36)
    ( member(PosDespues, [2, 7, 17, 22, 33, 36]) ->
        (PosDespues < PosAntes -> BonoSalida = 200 ; BonoSalida = 0),
        NetoCarta is DineroDespues - DineroAntes - BonoSalida,
        (JugadorTurno == jugador1 ->
            NuevoBalC1 is BalC1 + NetoCarta, NuevoBalC2 = BalC2
        ;
            NuevoBalC2 is BalC2 + NetoCarta, NuevoBalC1 = BalC1
        )
    ;
        NuevoBalC1 = BalC1, NuevoBalC2 = BalC2
    ),

    % 5. Recursividad
    append(HistorialActual, EventosNuevos, HistorialActualizado),
    N is TurnosRestantes - 1,
    bucle_juego_prueba(EstadoSiguiente, N, HistorialActualizado, Modo, NuevoBalC1, NuevoBalC2).