% importar los archivos de reglas y métricas cuando los creemos
%:- consult('reglal.pl').
%   :- consult('metricas.pl').


% tablero_inicial con 40 casillas donde cada casilla corresponde a una propiedad, servicio, impuesto o casilla especial
tablero_inicial([
    salida,                                 % 0
    propiedad(marron1, 60, marron),
    carta_comunidad,
    propiedad(marron2, 60, marron),
    impuesto(200),
    estacion(sur, 200),
    propiedad(celeste1, 100, celeste),
    carta_suerte,
    propiedad(celeste2, 100, celeste),
    propiedad(celeste3, 120, celeste),
    carcel_visita,                          % 10
    propiedad(rosa1, 140, rosa),
    servicio(electricidad, 150),
    propiedad(rosa2, 140, rosa),
    propiedad(rosa3, 160, rosa),
    estacion(oeste, 200),
    propiedad(naranja1, 180, naranja),
    carta_comunidad,
    propiedad(naranja2, 180, naranja),
    propiedad(naranja3, 200, naranja),
    parking,                                % 20
    propiedad(rojo1, 220, rojo),
    carta_suerte,
    propiedad(rojo2, 220, rojo),
    propiedad(rojo3, 240, rojo),
    estacion(norte, 200),
    propiedad(amarillo1, 260, amarillo),
    propiedad(amarillo2, 260, amarillo),
    servicio(agua, 150),
    propiedad(amarillo3, 280, amarillo),
    ir_a_carcel,                            % 30
    propiedad(verde1, 300, verde),
    propiedad(verde2, 300, verde),
    carta_comunidad,
    propiedad(verde3, 320, verde),
    estacion(este, 200),
    carta_suerte,
    propiedad(azul1, 350, azul),
    impuesto(100),
    propiedad(azul2, 400, azul)             % 39
]).


% jugadores iniciales con su nombre, posición inicial, dinero inicial y propiedades iniciales (vacías)
jugadores_iniciales([
    jugador(jugador1, 0, 1500, []),
    jugador(jugador2, 0, 1500, []),
    jugador(jugador3, 0, 1500, [])
]).


% estado_inicial con la lista de jugadores, el tablero y el jugador al que le toca tirar.
% Lo agrupamos en un estado para facilitar su manejo en el juego, y asi evitamos tener 
% un montón de variables al movernos por el tablero y avanzar turnos.
estado_inicial(estado(Jugadores, Tablero, jugador1)) :-
    jugadores_iniciales(Jugadores),
    tablero_inicial(Tablero).

% Simulación de dados. Creamos una lista de ejemplo con las tiradas para simular la partida turno a turno.
dados_partida([6,1,5,3,4,2]).

% mover_jugador(JugadorActual, ValorDado, JugadorActualizado)
% Caso A: Movimiento normal (No damos una vuelta entera y no pasamos por la Salida).
% La nueva posición es menor a 40. El dinero y las propiedades no cambian.
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado,
    Suma < 40,
    NuevaPos is Suma.

% Caso B: Paso por la Salida (La suma es 40 o mayor).
% Aplicamos módulo 40 para dar la vuelta y sumamos 200 al dinero.
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado,
    Suma >= 40,
    NuevaPos is Suma mod 40,      % Control circular de la posición
    NuevoDinero is Dinero + 200.  % Gestión del paso por salida (Bono de 200)

% ejecutar_movimiento(JugadorActual, ListaDados, JugadorActualizado, DadosRestantes)
% Toma el primer dado de la lista (DadoActual) para mover al jugador, 
% y devuelve la lista de dados sobrantes (DadosRestantes) para el siguiente turno.
ejecutar_movimiento(JugadorActual, [DadoActual | DadosRestantes], JugadorActualizado, DadosRestantes) :-
    mover_jugador(JugadorActual, DadoActual, JugadorActualizado).