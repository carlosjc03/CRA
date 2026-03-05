% ===================================================================
% ARCHIVO: test.pl
% Pruebas unitarias para validar la base de datos y la física del juego.
% ===================================================================

% 1. Le decimos a Prolog que cargue tu código principal (main.pl)
:- consult('main.pl').

% 2. Iniciamos el bloque de pruebas
:- begin_tests(pruebas_monopolio).

% -------------------------------------------------------------------
% TEST 1: Validación del Tablero
% -------------------------------------------------------------------
test(tablero_40_casillas) :-
    tablero_inicial(Tablero),
    length(Tablero, 40). % Verificamos que tenga exactamente 40 casillas.

% -------------------------------------------------------------------
% TEST 2: Validación de Jugadores y Estado Inicial
% -------------------------------------------------------------------
test(estado_inicial_correcto) :-
    % Comprobamos que el estado inicial devuelva al jugador1 y el turno 1
    estado_inicial(estado(Jugadores, _Tablero, jugador1, 1)),
    length(Jugadores, 3). % Verificamos que haya 3 jugadores en la lista.

% -------------------------------------------------------------------
% TEST 3: Generador Pseudoaleatorio (LCG)
% -------------------------------------------------------------------
test(dado_matematico) :-
    tirar_dado(1, Dado1),
    Dado1 == 6,           % Turno 1: ((1 * 73) + 19) mod 11 + 2 = 6
    tirar_dado(2, Dado2),
    Dado2 == 2.           % Turno 2: ((2 * 73) + 19) mod 11 + 2 = 2

% -------------------------------------------------------------------
% TEST 4: Movimiento Normal (Sin pasar por Salida)
% -------------------------------------------------------------------
test(movimiento_normal) :-
    Jugador = jugador(jugador1, 0, 1500, []),
    mover_jugador(Jugador, 5, JugadorActualizado),
    % Verificamos que se movió a la casilla 5 y su dinero está intacto
    JugadorActualizado == jugador(jugador1, 5, 1500, []).

% -------------------------------------------------------------------
% TEST 5: Movimiento Circular y Paso por Salida
% -------------------------------------------------------------------
test(paso_por_salida) :-
    Jugador = jugador(jugador2, 38, 1500, []),
    mover_jugador(Jugador, 5, JugadorActualizado),
    % Verificamos el módulo 40 (38+5=43 -> casilla 3) y el bono de +200
    JugadorActualizado == jugador(jugador2, 3, 1700, []).

% -------------------------------------------------------------------
% TEST 6: Ejecución completa del movimiento (Integración)
% -------------------------------------------------------------------
test(ejecutar_movimiento_integrado) :-
    Jugador = jugador(jugador3, 0, 1500, []),
    ejecutar_movimiento(Jugador, 1, JugadorActualizado, DadoSacado),
    % En el turno 1, el dado debe ser 6, así que el jugador termina en la casilla 6.
    DadoSacado == 6,
    JugadorActualizado == jugador(jugador3, 6, 1500, []).

% Cerramos el bloque de pruebas
:- end_tests(pruebas_monopolio).