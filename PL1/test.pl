% ==========================================
% Archivo: test.pl
% Descripcion: Pruebas unitarias progresivas
% ==========================================

:- consult('main.pl').

% -------------------------------------------------------------------
% TEST 1: MOVIMIENTO PURO (Aislado, sin reglas economicas)
% -------------------------------------------------------------------
test1_movimiento_puro :-
    estado_inicial(estado(Jugadores, _, QuienMueve, NumTurno)),
    buscar_jugador(Jugadores, QuienMueve, JugadorFisico),
    write('>> TEST 1: MOVIMIENTO PURO (Sin economia)'), nl,
    write('   Estado Antes: '), write(JugadorFisico), nl,
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    write('   Dado sacado: '), write(Dado), nl,
    write('   Estado Despues: '), write(JugadorMovido), nl, nl.

% -------------------------------------------------------------------
% TEST 2: COMPRA DE PROPIEDAD (Regla 0)
% -------------------------------------------------------------------
test2_compra :-
    tablero_inicial(Tablero),
    EstadoPrueba = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 2: COMPRA DE PROPIEDAD'), nl,
    turno_limpio(EstadoPrueba, _, simulacion, _).

% -------------------------------------------------------------------
% TEST 3: PAGO DE ALQUILER (Regla 1)
% -------------------------------------------------------------------
test3_alquiler :-
    tablero_inicial(Tablero),
    EstadoPrueba = estado([jugador(jugador1, 0, 1500, [celeste1]), jugador(jugador2, 4, 1500, [])], Tablero, jugador2, 2),
    write('>> TEST 3: PAGO DE ALQUILER'), nl,
    turno_limpio(EstadoPrueba, _, simulacion, _).

% -------------------------------------------------------------------
% TEST 4: COBERTURA DEL TABLERO
% Objetivo: Ver cuantas casillas unicas se pisan en 100 turnos.
% -------------------------------------------------------------------
test4_cobertura :-
    estado_inicial(E0),
    write('>> TEST 4: COBERTURA DE TABLERO (100 Turnos)'), nl,
    bucle_juego(E0, 100, []).

% -------------------------------------------------------------------
% TEST 5: SIMULACION DE ESTRÉS
% Objetivo: Ejecutar 1500 turnos para ver el final del juego o si hay quiebra.
% -------------------------------------------------------------------
test5_estres :-
    estado_inicial(E0),
    write('>> TEST 5: JUEGO COMPLETO Y METRICAS FINALES'), nl,
    bucle_juego(E0, 1500, []).

test_todos :-
    test1_movimiento_puro,
    test2_compra,
    test3_alquiler,
    test4_cobertura,
    test5_estres,
    write('>> TODOS LOS TESTS FINALIZADOS.'), nl.