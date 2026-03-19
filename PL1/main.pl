% ==========================================
% Archivo: main.pl
% Descripcion: Motor principal del juego de Monopoly
% ==========================================

:- consult('regla.pl').

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
    jugador(jugador1, 0, 1500, []), jugador(jugador2, 0, 1500, [])
]).

estado_inicial(estado(Jugadores, Tablero, jugador1, 1)) :-
    jugadores_iniciales(Jugadores), tablero_inicial(Tablero).

% 2.- MOVIMIENTO Y DADO
tirar_dado(NumTurno, Dado) :-
    ValorPseudo is (NumTurno * 73) + 19, Dado is (ValorPseudo mod 11) + 2.

mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado,jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado, Suma < 40, NuevaPos is Suma.
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado, Suma >= 40, NuevaPos is Suma mod 40, NuevoDinero is Dinero + 200.  

ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado) :-
    tirar_dado(NumTurno, DadoSacado), mover_jugador(JugadorActual, DadoSacado, JugadorActualizado). 

% 3.- MEMORIA Y LISTAS
siguiente_turno(jugador1, jugador2).
siguiente_turno(jugador2, jugador1). %siguiente_turno(jugador2, jugador3).
%siguiente_turno(jugador3, jugador1).

buscar_jugador([jugador(Nombre, Pos, Dinero, Props) | _], Nombre, jugador(Nombre, Pos, Dinero, Props)) :- !.
buscar_jugador([_ | Resto], Nombre, J) :- buscar_jugador(Resto, Nombre, J).

actualizar_lista_jugadores([jugador(Nombre, _, _, _) | Resto], jugador(Nombre, Pos, Dinero, Props), [jugador(Nombre, Pos, Dinero, Props ) | Resto]) :- !.
actualizar_lista_jugadores([J | Resto], JugadorActualizado, [J | NuevaLista]) :- actualizar_lista_jugadores(Resto, JugadorActualizado, NuevaLista).

% 4.- EL BUCLE PRINCIPAL 
jugar_turno(estado(Jugadores, Tablero, TurnoActual, NumTurno), Dado, Modo, estado(NuevosJugadores, Tablero, SiguienteJugador, NuevoNumTurno)) :-
    buscar_jugador(Jugadores, TurnoActual, JugadorFisico),
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),

    interactuar_con_casilla(JugadorMovido, CasillaActual, Jugadores, NumTurno, Modo, JugadorTrasEco, JugadoresTemp),
    aplicar_bancarrota(JugadorTrasEco, Tablero, JugadoresTemp, NuevosJugadores),

    siguiente_turno(TurnoActual, SiguienteJugador), NuevoNumTurno is NumTurno + 1.

% 5.- INTERFAZ VISUAL CRONOLOGICA
turno_limpio(EstadoAntes, EstadoDespues, Modo) :-
    EstadoAntes = estado(JugadoresAntes, Tablero, QuienMueve, NTurnos),
    buscar_jugador(JugadoresAntes, QuienMueve, JugadorActual),
    JugadorActual = jugador(_, PosAntes, DinAntes, PropsAntes),
    
    write('=================================================='), nl,
    write('TURNO DE: '), write(QuienMueve), write(' (Tirada Global: '), write(NTurnos), write(')'), nl,
    
    write('--- 1. ESTADO INICIAL ---'), nl,
    write('Posicion: '), write(PosAntes), write(' | Dinero: '), write(DinAntes), nl,
    write('Propiedades: '), write(PropsAntes), nl,
    
    ejecutar_movimiento(JugadorActual, NTurnos, JugadorMovido, Dado),
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, NombreCasilla),
    
    write('--- 2. ACCION ---'), nl,
    write('Tira el dado y saca: '), write(Dado), nl,
    write('Avanza a la casilla: '), write(NombreCasilla), write(' (Posicion '), write(NuevaPos), write(')'), nl,
    
    write('--- 3. EFECTO ---'), nl,
    jugar_turno(EstadoAntes, _, Modo, EstadoDespues),
    
    EstadoDespues = estado(NuevosJugadores, _, SiguienteTurno, _),
    
    write('--- 4. ESTADO FINAL ---'), nl,
    (buscar_jugador(NuevosJugadores, QuienMueve, jugador(_, _, DinFin, PropsFin)) ->
        write('Dinero resultante: '), write(DinFin), nl,
        write('Propiedades: '), write(PropsFin), nl
    ;
        write('Jugador fuera de la partida.'), nl
    ),
    write('Siguiente en jugar: '), write(SiguienteTurno), nl,
    write('=================================================='), nl, nl.
% ==========================================
% 6.- MODOS DE EJECUCION
% ==========================================

% SIMULACION AUTOMATICA
bucle_juego(_, 0) :- write('[FIN] Simulacion terminada.'), nl.
bucle_juego(EstadoActual, TurnosRestantes) :-
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente, simulacion),
    NuevosTurnosRestantes is TurnosRestantes - 1,
    bucle_juego(EstadoSiguiente, NuevosTurnosRestantes).

% MODO MANUAL INTERACTIVO
jugar :-
    write('Iniciando partida interactiva manual...'), nl,
    estado_inicial(E0),
    bucle_manual(E0).

bucle_manual(EstadoActual) :-
    turno_limpio(EstadoActual, EstadoSiguiente, manual),
    write('>> Escribe "s." para siguiente turno, o "n." para salir: '),
    read(Respuesta),
    (Respuesta == s -> bucle_manual(EstadoSiguiente) ; write('Partida finalizada por el usuario.'), nl).