% ==========================================
% Archivo: main.pl
% Descripcion: Motor principal del juego de Monopoly
% ==========================================

:- consult('regla.pl').

% 1.- TABLERO, JUGADORES INICIALES Y ESTADO INICIAL
tablero_inicial([
    salida,                                 % 0
    propiedad(marron1, 60, marron),
    carta,                        % 2
    propiedad(marron2, 60, marron),
    impuesto(200),                          % 4
    estacion(sur, 200),
    propiedad(celeste1, 100, celeste),      % 6
    carta,                           % 7
    propiedad(celeste2, 100, celeste),
    propiedad(celeste3, 120, celeste),
    carcel_visita,                          % 10
    propiedad(rosa1, 140, rosa),
    servicio(electricidad, 150),
    propiedad(rosa2, 140, rosa),
    propiedad(rosa3, 160, rosa),
    estacion(oeste, 200),
    propiedad(naranja1, 180, naranja),
    carta,                        % 17
    propiedad(naranja2, 180, naranja),
    propiedad(naranja3, 200, naranja),
    parking,                                % 20
    propiedad(rojo1, 220, rojo),
    carta,                           % 22
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
    carta,                        % 33
    propiedad(verde3, 320, verde),
    estacion(este, 200),
    carta,                           % 36
    propiedad(azul1, 350, azul),
    impuesto(100),                          % 38
    propiedad(azul2, 400, azul)             % 39
]).


jugadores_iniciales([
    jugador(jugador1, 0, 1500, []),
    jugador(jugador2, 0, 1500, [])
]).

estado_inicial(estado(Jugadores, Tablero, jugador1, 1)) :-
    jugadores_iniciales(Jugadores),
    tablero_inicial(Tablero).

% 2.- MOVIMIENTO Y DADO
tirar_dado(NumTurno, Dado) :-
    ValorPseudo is (NumTurno * 73) + 19, 
    Dado is (ValorPseudo mod 11) + 2.

mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado, Suma < 40, NuevaPos is Suma.

mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado, Suma >= 40,
    NuevaPos is Suma mod 40,      
    NuevoDinero is Dinero + 200.  

ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado) :-
    tirar_dado(NumTurno, DadoSacado),                               
    mover_jugador(JugadorActual, DadoSacado, JugadorActualizado). 

% 3.- MEMORIA Y LISTAS
siguiente_turno(jugador1, jugador2).
siguiente_turno(jugador2, jugador1).

buscar_jugador([jugador(Nombre, Pos, Dinero, Props) | _], Nombre, jugador(Nombre, Pos, Dinero, Props)) :- !.
buscar_jugador([_ | Resto], Nombre, J) :- buscar_jugador(Resto, Nombre, J).

actualizar_lista_jugadores([jugador(Nombre, _, _, _) | Resto], jugador(Nombre, Pos, Dinero, Props), [jugador(Nombre, Pos, Dinero, Props ) | Resto]) :- !.
actualizar_lista_jugadores([J | Resto], JugadorActualizado, [J | NuevaLista]) :-
    actualizar_lista_jugadores(Resto, JugadorActualizado, NuevaLista).

% 4.- EL BUCLE PRINCIPAL
jugar_turno(estado(Jugadores, Tablero, TurnoActual, NumTurno), Dado, estado(NuevosJugadores, Tablero, SiguienteJugador, NuevoNumTurno)) :-
    buscar_jugador(Jugadores, TurnoActual, JugadorFisico),
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),

    interactuar_con_casilla(JugadorMovido, CasillaActual, Jugadores, NumTurno, JugadorTrasEconomia, JugadoresTemporales),
    aplicar_bancarrota(JugadorTrasEconomia, JugadoresTemporales, NuevosJugadores),

    siguiente_turno(TurnoActual, SiguienteJugador),
    NuevoNumTurno is NumTurno + 1.

% 5.- BUCLE DE JUEGO
bucle_juego(_, 0) :- 
    write('[FIN] Simulacion terminada.'), nl.

bucle_juego(EstadoActual, TurnosRestantes) :-
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente),
    NuevosTurnosRestantes is TurnosRestantes - 1,
    bucle_juego(EstadoSiguiente, NuevosTurnosRestantes).

% 6.- INTERFAZ VISUAL
turno_limpio(EstadoAntes, EstadoDespues) :-
    % Extraemos info
    EstadoAntes = estado(JugadoresAntes, Tablero, QuienMueve, NTurnos),
    buscar_jugador(JugadoresAntes, QuienMueve, JugadorActual),
    JugadorActual = jugador(_, PosAntes, DinAntes, PropsAntes),
    
    write('=================================================='), nl,
    write('TURNO DE: '), write(QuienMueve), write(' (Tirada Global: '), write(NTurnos), write(')'), nl,
    
    % PASO 1: ESTADO INICIAL
    write('--- 1. ESTADO INICIAL ---'), nl,
    write('Posicion: '), write(PosAntes), write(' | Dinero: '), write(DinAntes), nl,
    write('Propiedades: '), write(PropsAntes), nl,
    
    % PASO 2: TIRADA Y MOVIMIENTO
    ejecutar_movimiento(JugadorActual, NTurnos, JugadorMovido, Dado),
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, NombreCasilla),
    
    write('--- 2. ACCION ---'), nl,
    write('Tira el dado y saca: '), write(Dado), nl,
    write('Avanza a la casilla: '), write(NombreCasilla), write(' (Posicion '), write(NuevaPos), write(')'), nl,
    
    % PASO 3: EFECTOS Y REGLAS (Aqui saltan los mensajes de regla.pl)
    write('--- 3. EFECTO ---'), nl,
    interactuar_con_casilla(JugadorMovido, NombreCasilla, JugadoresAntes, NTurnos, JugadorTrasEco, JugadoresTemp),
    aplicar_bancarrota(JugadorTrasEco, JugadoresTemp, NuevosJugadores),
    
    % Generamos el nuevo estado global
    siguiente_turno(QuienMueve, SiguienteJugador),
    NuevoNumTurno is NTurnos + 1,
    EstadoDespues = estado(NuevosJugadores, Tablero, SiguienteJugador, NuevoNumTurno),
    
    % PASO 4: ESTADO FINAL
    write('--- 4. ESTADO FINAL ---'), nl,
    (buscar_jugador(NuevosJugadores, QuienMueve, jugador(_, _, DinFin, PropsFin)) ->
        write('Dinero resultante: '), write(DinFin), nl,
        write('Propiedades actualizadas: '), write(PropsFin), nl
    ;
        % Si la regla de bancarrota lo ha borrado de la lista
        write('Jugador fuera de la partida.'), nl
    ),
    write('=================================================='), nl, nl.