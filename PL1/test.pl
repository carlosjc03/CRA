% ==========================================
% Archivo: test.pl
% Descripcion: Escenarios de prueba 
% ==========================================

:- consult('main.pl').

test1_compras :-
    estado_inicial(E0),
    write('>> ESCENARIO 1: Primeras compras iniciales'), nl,
    turno_limpio(E0, _).

test2_monopolio :-
    tablero_inicial(Tablero),
    EstadoPrueba = estado([jugador(jugador1, 37, 1500, [marron1]), jugador(jugador2, 0, 1500, [])], Tablero, jugador1, 1),
    write('>> ESCENARIO 2: Monopolio Formado'), nl,
    turno_limpio(EstadoPrueba, EstadoFinal),
    EstadoFinal = estado([Jugador1Final | _], _, _, _),
    (verificar_monopolio(Jugador1Final, marron) ->
        write('[EXITO]: Monopolio detectado correctamente.'), nl
    ;
        write('[ERROR]: Monopolio no detectado.'), nl
    ).

test3_bancarrota :-
    tablero_inicial(Tablero),
    EstadoPrueba = estado([jugador(jugador1, 0, 1500, [azul2]), jugador(jugador2, 37, 20, [])], Tablero, jugador2, 2),
    write('>> ESCENARIO 3: Bancarrota forzada'), nl,
    turno_limpio(EstadoPrueba, _).

test4_alquileres :-
    tablero_inicial(Tablero),
    EstadoPrueba = estado([jugador(jugador1, 35, 1500, [celeste1]), jugador(jugador2, 4, 1500, [marron1])], Tablero, jugador1, 1),
    write('>> ESCENARIO 4: Alquileres consecutivos'), nl,
    turno_limpio(EstadoPrueba, EstadoMitad),
    turno_limpio(EstadoMitad, _).

test5_simulacion :-
    estado_inicial(E0),
    write('>> ESCENARIO 5: Simulacion 50 turnos'), nl,
    bucle_juego(E0, 50).

test_todos :-
    test1_compras, nl,
    test2_monopolio, nl,
    test3_bancarrota, nl,
    test4_alquileres, nl,
    test5_simulacion, nl,
    write('>> TODOS LOS ESCENARIOS FINALIZADOS.'), nl.