% ==========================================
% ARCHIVO: test.pl
% BATERIA DE PRUEBAS OFICIAL (DEFENSA PL1)
% ==========================================

:- consult('main.pl').

% ===================================================================
% FASE 1: EL MOTOR BASICO (Solo movimiento y físicas del dado)
% Modo usado: fase1
% ===================================================================
test1_movimiento_simple :-
    tablero_inicial(Tablero), 
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 1.1: Movimiento Simple (1 Turno)'), nl,
    bucle_juego(Estado, 1, [], fase1).

test1_cobertura_conjunta :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 1.2: Cobertura Conjunta (95 Turnos -> 40/40 casillas)'), nl,
    bucle_juego(Estado, 95, [], fase1).

test1_cobertura_j1 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 1.3: Cobertura Individual J1 (143 Turnos)'), nl,
    bucle_juego(Estado, 143, [], fase1).

test1_cobertura_j2 :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador2, 2),
    write('>> TEST 1.4: Cobertura Individual J2 (204 Turnos)'), nl,
    bucle_juego(Estado, 204, [], fase1).

% ===================================================================
% FASE 2: ECONOMIA Y COMPRAS (Regla 0)
% Modo usado: fase2
% ===================================================================
test2_compra_inicial :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 2.1: Compra Inicial Unitaria (1 turno, 1500 euros)'), nl,
    bucle_juego(Estado, 1, [], fase2).

test2_compra_realista :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 2.2: Compra Realista hasta agotar saldo (150 turnos, 1500 euros)'), nl,
    bucle_juego(Estado, 150, [], fase2).

test2_compra_libertad :-
    tablero_inicial(Tablero),
    % Aqui damos 3600 euros para demostrar que vacian el tablero en 95 turnos
    Estado = estado([jugador(jugador1, 0, 3600, []), jugador(jugador2, 0, 3600, [])], Tablero, jugador1, 1),
    write('>> TEST 2.3: Libertad Total (95 turnos, inyeccion de 3600 euros)'), nl,
    bucle_juego(Estado, 95, [], fase2).

test2_liquidez_infinita :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 50000, []), jugador(jugador2, 0, 50000, [])], Tablero, jugador1, 1),
    write('>> TEST 2.4: Liquidez Infinita (Desbalance de 18 vs 10 con 50k euros)'), nl,
    bucle_juego(Estado, 200, [], fase2).

% ===================================================================
% FASE 3: ALQUILERES (Regla 1 y 2)
% Modo usado: fase3
% ===================================================================
test3_espiral_deuda :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 3.1: Espiral de Deuda (300 turnos, alquileres activos sin bancarrota)'), nl,
    bucle_juego(Estado, 300, [], fase3).

test3_inyeccion_capital :-
    tablero_inicial(Tablero),
    % Les damos 3000 euros. Como el J1 no se queda sin dinero, aplastara al J2.
    Estado = estado([jugador(jugador1, 0, 3000, []), jugador(jugador2, 0, 3000, [])], Tablero, jugador1, 1),
    write('>> TEST 3.2: Inyeccion 3000 euros (El J1 recupera el trono por rentas)'), nl,
    bucle_juego(Estado, 300, [], fase3).

% ===================================================================
% FASE 4: PARTIDA FINAL Y BANCARROTA (Reglas 3, 4, 5 y 6)
% Modo usado: simulacion
% ===================================================================
test4_monopolio_base :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 4.1: Bancarrota Directa (Muerte Subita, sin mejoras)'), nl,
    % Suponiendo que tienes un modo 'fase4' en tus reglas que hace eliminacion directa
    bucle_juego(Estado, 3000, [], fase4).

test4_carta_inmediata :-
    tablero_inicial(Tablero),
    % Lo ponemos en la casilla 1 para que al tirar caiga en la carta de la casilla 2 o 7
    Estado = estado([jugador(jugador1, 1, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 4.2: Caer en carta de manera inmediata'), nl,
    bucle_juego(Estado, 1, [], simulacion).

test4_simulacion_cartas(Turnos) :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 5000, []), jugador(jugador2, 0, 5000, [])], Tablero, jugador1, 1),
    write('>> TEST 4.3: Frecuencia de cartas en '), write(Turnos), write(' turnos (Dinero alto para evitar bancarrota prematura)'), nl,
    bucle_juego(Estado, Turnos, [], simulacion).

test4_partida_completa :-
    tablero_inicial(Tablero),
    Estado = estado([jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> TEST 4.4: Partida Real (Todo activado. El J2 sera eliminado)'), nl,
    bucle_juego(Estado, 2000, [], simulacion).