% Cargar archivo main para saber todas las reglas para ejecutar el movimiento del jugador.
:- consult('main.pl').

% test_1
test_movimiento :-

    JugadorInicial = jugador(jugador1, 0, 1500, []), 
    dados_partida(ListaDados),
    
    ejecutar_movimiento(JugadorInicial, ListaDados, JugadorNuevo, DadosSobrantes),
    
    write('--- TEST 1: MOVIMIENTO NORMAL ---'), nl,
    write('Estado Inicial:   '), write(JugadorInicial), nl,
    write('Estado Nuevo:     '), write(JugadorNuevo), nl,
    write('Dados que sobran: '), write(DadosSobrantes), nl,
    write('--- FIN DE LA PRUEBA ---'), nl.

% test_vuelta (damos una vuelta al tablero)
test_vuelta :-

    JugadorInicial = jugador(jugador1, 36, 1500, []), 
    dados_partida(ListaDados),
    
    ejecutar_movimiento(JugadorInicial, ListaDados, JugadorNuevo, DadosSobrantes),   
    
    write('--- TEST 2: PASO POR SALIDA ---'), nl,
    write('Estado Inicial:   '), write(JugadorInicial), nl,
    write('Estado Nuevo:     '), write(JugadorNuevo), nl,
    write('Dados que sobran: '), write(DadosSobrantes), nl,
    write('--- FIN DE LA PRUEBA ---'), nl.

test_todos :-
    test_movimiento,
    test_vuelta.