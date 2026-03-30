% ==========================================
% Archivo: test.pl
% Descripcion: Bateria de Pruebas - FASE 1 (Movimiento Aislado)
% ==========================================

:- consult('main.pl').

% ===================================================================
% TEST 1: MOVIMIENTO SIMPLE (1 Turno, 1 Jugador)
% ===================================================================
test1_movimiento_simple :-
    tablero_inicial(Tablero), % <--- Usamos el tablero REAL de main.pl
    Estado = estado([jugador(jugador1, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 1: Movimiento Simple (1 Turno)'), nl,
    bucle_juego_prueba(Estado, 1, [], fase1). % <--- Llamamos al motor de pruebas en fase1

% ===================================================================
% TEST 2: MOVIMIENTO LIBRE (X Turnos, Ambos Jugadores)
% Ejecucion en consola: ?- test2_movimiento_libre(20).
% ===================================================================
test2_movimiento_libre(Turnos) :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 2: Movimiento Libre | Turnos: '), write(Turnos), nl,
    bucle_juego_prueba(Estado, Turnos, [], fase1).

% ===================================================================
% TEST 3: COBERTURA CONJUNTA (95 Turnos)
% Objetivo: Demostrar que entre los dos pisan las 40 casillas.
% ===================================================================
test3_cobertura_conjunta :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 3: Cobertura Conjunta (95 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 95, [], fase1).

% ===================================================================
% TEST 4: COBERTURA INDIVIDUAL JUGADOR 1 (143 Turnos)
% Objetivo: Demostrar que el J1 necesita 143 turnos para el 40/40.
% ===================================================================
test4_cobertura_j1 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 4: Cobertura J1 (143 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 143, [], fase1).

% ===================================================================
% TEST 5: COBERTURA INDIVIDUAL JUGADOR 2 (204 Turnos)
% Objetivo: Demostrar la resonancia del J2 por culpa de la carcel.
% ===================================================================
test5_cobertura_j2 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador2, 0, 50000, [])], Tablero, jugador2, 2), % <--- Solo el J2
    write('>> TEST 5: Cobertura J2 (204 Turnos -> 40/40 casillas)'), nl,
    bucle_juego_prueba(Estado, 204, [], fase1).

% ===================================================================
% MOTOR INTERNO PARA INYECTAR LAS FASES (Imprescindible)
% ===================================================================
bucle_juego_prueba(EstadoActual, 0, Historial, _) :- !, mostrar_metricas(EstadoActual, Historial).
bucle_juego_prueba(EstadoActual, TurnosRestantes, HistorialActual, Modo) :-
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente, Modo, EventosNuevos),
    append(HistorialActual, EventosNuevos, HistorialActualizado),
    N is TurnosRestantes - 1,
    bucle_juego_prueba(EstadoSiguiente, N, HistorialActualizado, Modo).