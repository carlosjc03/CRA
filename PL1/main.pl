% ==========================================
% Archivo: main.pl
% Descripcion: Motor principal del juego de Monopoly
% ==========================================

:- consult('regla.pl').
:- consult('metricas.pl'). 

% 1.- TABLERO Y JUGADORES
tablero_inicial([
    salida, propiedad(marron1, 60, marron), carta, propiedad(marron2, 60, marron),
    impuesto(200), estacion(sur, 200), propiedad(celeste1, 100, celeste), carta,
    propiedad(celeste2, 100, celeste), propiedad(celeste3, 120, celeste), carcel_visita,
    propiedad(rosa1, 140, rosa), servicio(electricidad, 150), propiedad(rosa2, 140, rosa),
    propiedad(rosa3, 160, rosa), estacion(oeste, 200), propiedad(naranja1, 180, naranja),
    carta, propiedad(naranja2, 180, naranja), propiedad(naranja3, 200, naranja),
    parking, propiedad(rojo1, 220, rojo), carta, propiedad(rojo2, 220, rojo),
    propiedad(rojo3, 240, rojo), estacion(norte, 200), propiedad(amarillo1, 260, amarillo),
    propiedad(amarillo2, 260, amarillo), servicio(agua, 150), propiedad(amarillo3, 280, amarillo),
    ir_a_carcel, propiedad(verde1, 300, verde), propiedad(verde2, 300, verde), carta,
    propiedad(verde3, 320, verde), estacion(este, 200), carta, propiedad(azul1, 350, azul),
    impuesto(100), propiedad(azul2, 400, azul)
]).

jugadores_iniciales([
    jugador(jugador1, 0, 115500, []), 
    jugador(jugador2, 0, 115500, [])
]).

estado_inicial(estado(Jugadores, Tablero, jugador1, 1)) :-
    jugadores_iniciales(Jugadores), 
    tablero_inicial(Tablero).

% 2.- MOVIMIENTO Y DADO
tirar_dado(NumTurno, Dado) :-
    ValorPseudo is (NumTurno * 73) + 19, Dado is (ValorPseudo mod 11) + 2.

mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado, Suma < 40, NuevaPos is Suma.
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado, Suma >= 40, NuevaPos is Suma mod 40, NuevoDinero is Dinero + 200.  

ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado) :-
    tirar_dado(NumTurno, DadoSacado), 
    mover_jugador(JugadorActual, DadoSacado, JugadorActualizado). 

% 3.- MEMORIA Y LISTAS 
buscar_jugador([jugador(Nombre, Pos, Dinero, Props) | _], Nombre, jugador(Nombre, Pos, Dinero, Props)) :- !.
buscar_jugador([_ | Resto], Nombre, J) :- buscar_jugador(Resto, Nombre, J).

actualizar_lista_jugadores([jugador(Nombre, _, _, _) | Resto], jugador(Nombre, Pos, Dinero, Props), [jugador(Nombre, Pos, Dinero, Props ) | Resto]) :- !.
actualizar_lista_jugadores([J | Resto], JugadorActualizado, [J | NuevaLista]) :- actualizar_lista_jugadores(Resto, JugadorActualizado, NuevaLista).

siguiente_en_lista(Actual, Lista, Siguiente) :-
    append(_, [jugador(Actual,_,_,_) | Resto], Lista),
    ( Resto = [jugador(Siguiente,_,_,_) | _] -> true
    ; Lista = [jugador(Siguiente,_,_,_) | _] ).

asegurar_turno(SiguienteIdeal, NuevosJugadores, SiguienteIdeal) :-
    buscar_jugador(NuevosJugadores, SiguienteIdeal, _), !.
asegurar_turno(_, [jugador(Primero,_,_,_) | _], Primero).

% 4.- EL BUCLE PRINCIPAL 
jugar_turno(estado(Jugadores, Tablero, TurnoActual, NumTurno), Dado, Modo, estado(NuevosJugadores, Tablero, SiguienteReal, NuevoNumTurno)) :-
    buscar_jugador(Jugadores, TurnoActual, JugadorFisico),
    siguiente_en_lista(TurnoActual, Jugadores, SiguienteIdeal), 
    
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),

    interactuar_con_casilla(JugadorMovido, CasillaActual, Jugadores, NumTurno, Modo, JugadorTrasEco, JugadoresTemp),
    aplicar_bancarrota(JugadorTrasEco, Tablero, JugadoresTemp, NuevosJugadores),

    asegurar_turno(SiguienteIdeal, NuevosJugadores, SiguienteReal), 
    NuevoNumTurno is NumTurno + 1.

% 5.- INTERFAZ VISUAL Y EXTRACCION DE EVENTOS PARA METRICAS
turno_limpio(EstadoAntes, EstadoDespues, Modo, EventosDelTurno) :-
    EstadoAntes = estado(JugadoresAntes, Tablero, QuienMueve, NTurnos),
    buscar_jugador(JugadoresAntes, QuienMueve, JugadorActual),
    JugadorActual = jugador(_, _PosAntes, _DinAntes, PropsAntes),
    
    write('=================================================='), nl,
    write('TURNO DE: '), write(QuienMueve), write(' (Tirada Global: '), write(NTurnos), write(')'), nl,
    
    ejecutar_movimiento(JugadorActual, NTurnos, JugadorMovido, Dado),
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),
    extraer_nombre(CasillaActual, NombreSimple),
    
    write('--- ACCION ---'), nl,
    write('Saca un: '), write(Dado), write(' -> Cae en: '), write(NombreSimple), nl,
    
    jugar_turno(EstadoAntes, _, Modo, EstadoDespues),
    
    EstadoDespues = estado(NuevosJugadores, _, SiguienteTurno, _),
    ( buscar_jugador(NuevosJugadores, QuienMueve, jugador(_, _, _, PropsNuevas)),
      length(PropsNuevas, L1), length(PropsAntes, L2), L1 > L2 ->
        PropsNuevas = [PropComprada | _],
        EventoCompra = [evento_compra(QuienMueve, PropComprada)]
    ;
        EventoCompra = []
    ),
    
% AQUI ESTA EL CAMBIO: Guardamos 'NuevaPos' en lugar de 'NombreSimple'
    append([evento_dado(QuienMueve, Dado), evento_visita(QuienMueve, NuevaPos)], EventoCompra, EventosDelTurno),
    
    write('--- ESTADO FINAL ---'), nl,
    (buscar_jugador(NuevosJugadores, QuienMueve, jugador(_, _, DinFin, _PropsFin)) ->
        write('Dinero: '), write(DinFin), nl,
        write('Siguiente en jugar: '), write(SiguienteTurno), nl
    ;
        write('Siguiente en jugar: '), write(SiguienteTurno), nl
    ),
    write('=================================================='), nl, nl.

% ==========================================
% 6.- MODOS DE EJECUCION Y FIN DE JUEGO
% ==========================================

bucle_juego(EstadoActual, _, Historial) :-
    EstadoActual = estado(Jugadores, _, _, _),
    length(Jugadores, 1), !, 
    Jugadores = [jugador(Ganador, _, _, _)],
    write('FIN DEL JUEGO: Solo queda un jugador en pie.'), nl,
    write('EL GANADOR ES: '), write(Ganador), nl,
    mostrar_metricas(EstadoActual, Historial).

bucle_juego(EstadoActual, 0, Historial) :- 
    !,
    write('Limite de turnos de simulacion alcanzado.'), nl,
    mostrar_metricas(EstadoActual, Historial).

bucle_juego(EstadoActual, TurnosRestantes, HistorialActual) :-
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente, simulacion, EventosNuevos),
    append(HistorialActual, EventosNuevos, HistorialActualizado),
    NuevosTurnosRestantes is TurnosRestantes - 1,
    bucle_juego(EstadoSiguiente, NuevosTurnosRestantes, HistorialActualizado).

jugar :-
    write('Iniciando partida interactiva manual...'), nl,
    estado_inicial(E0),
    bucle_manual(E0, []).

bucle_manual(EstadoActual, HistorialActual) :-
    EstadoActual = estado(Jugadores, _, _, _),
    (length(Jugadores, 1) ->
        Jugadores = [jugador(Ganador, _, _, _)],
        write('EL GANADOR ES: '), write(Ganador), nl,
        mostrar_metricas(EstadoActual, HistorialActual)
    ;
        turno_limpio(EstadoActual, EstadoSiguiente, manual, EventosNuevos),
        append(HistorialActual, EventosNuevos, HistorialActualizado),
        write('>> Escribe "s." para siguiente turno, o "n." para salir: '),
        read(Respuesta),
        (Respuesta == s -> bucle_manual(EstadoSiguiente, HistorialActualizado) ; write('Partida finalizada.'), nl)
    ).