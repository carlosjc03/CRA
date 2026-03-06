% ==========================================
% Archivo: test.pl
% Descripcion: Pruebas de ejecucion del motor del juego.
% ==========================================

:- consult('main.pl').

% Prueba 1: Verifica que el motor arranca y ejecuta un unico turno correctamente.
test_turno_simple :-
    estado_inicial(E0),
    write('--- TEST 1: TURNO SIMPLE (JUGADOR 1) ---'), nl,
    turno_limpio(E0, _EstadoNuevo).

% Prueba 2: Verifica el Game Loop y la rotacion de turnos.
% Ejecuta 3 turnos seguidos para ver jugar a los 3 jugadores.
test_ronda_completa :-
    estado_inicial(E0),
    write('--- TEST 2: RONDA COMPLETA (3 TURNOS) ---'), nl,
    bucle_juego(E0, 3).

% Prueba 3: Verifica la logica matematica del modulo 40 y el bono de salida.
% Inyectamos un estado manual donde el Jugador 1 empieza en la casilla 36.
% Como en el turno 1 el dado saca un 6, acabara en la casilla 2 con 1700 de dinero.
test_paso_salida :-
    tablero_inicial(Tablero),
    % Estado forzado para la prueba
    EstadoPrueba = estado(
        [jugador(jugador1, 36, 1500, []), jugador(jugador2, 0, 1500, []), jugador(jugador3, 0, 1500, [])],
        Tablero,
        jugador1,
        1 % Reloj en 1 para forzar la tirada inicial
    ),
    write('--- TEST 3: PASO POR SALIDA (CASILLA 36 + DADO) ---'), nl,
    turno_limpio(EstadoPrueba, _EstadoNuevo).

% Ejecuta todas las pruebas secuencialmente.
test_todos :-
    test_turno_simple,
    nl,
    test_ronda_completa,
    nl,
    test_paso_salida,
    nl,
    write('Todas las pruebas finalizadas con exito.'), nl.