% ==========================================
% Archivo: regla.pl
% Descripcion: Motor economico y reglas especiales del juego.
% ==========================================

% ===================================================================
% BLOQUE DE FASES INCREMENTALES (Alineado con la Memoria)
% ===================================================================

% --- FASE 1: SOLO MOVIMIENTO (Sin compras, sin alquiler, sin cartas/carcel) ---
interactuar_con_casilla(V, propiedad(_,_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, estacion(_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, servicio(_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, carta, J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).

% --- FASE 2: COMPRAS SIN ALQUILER (Regla 0 activa, lo demas bloqueado) ---
interactuar_con_casilla(V, propiedad(Id,_,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, estacion(Id,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, servicio(Id,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, carta, J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, C, J, T, fase2, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% --- FASE 3: COMPRAS + ALQUILERES (Regla 1 y 2. Sin cartas/carcel/impuestos) ---
interactuar_con_casilla(V, carta, J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, C, J, T, fase3, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% --- FASE 4: COMPRAS + ALQUILERES + BANCARROTA ---
interactuar_con_casilla(V, carta, J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, C, J, T, fase4, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% ===================================================================
% REGLAS NORMALES DEL JUEGO (Alquiler, Compras, Cartas)
% ===================================================================

% -------------------------------------------------------------------
% REGLA 1.A: PAGO DE ALQUILER (Propiedades y Monopolio)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, Color), Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, _, _, _),
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores),
    NomDueno \= NomV,
    member(IdProp, PropsD), !, 
    
    Dueno = jugador(NomDueno, PosD, DineroD, PropsD),
    ( verificar_monopolio(Dueno, Color) ->
        Alquiler is Precio / 2,
        write('[ALQUILER MONOPOLIO] -> El dueno tiene el grupo '), write(Color), nl
    ;
        Alquiler is Precio // 10
    ),
    
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Alquiler,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    NuevoDinD is DineroD + Alquiler,
    DuenoFinal = jugador(NomDueno, PosD, NuevoDinD, PropsD),
    actualizar_lista_jugadores(Jugadores, DuenoFinal, TempJugadores),
    actualizar_lista_jugadores(TempJugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 1] -> '), write(NomV), write(' paga '), write(Alquiler), write(' a '), write(NomDueno), nl.

% -------------------------------------------------------------------
% REGLA 1.B: PAGO DE ALQUILER (Estaciones)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, _, _, _),
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores),
    NomDueno \= NomV,
    member(IdEstacion, PropsD), !, 
    Alquiler is Precio // 10,
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Alquiler,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    NuevoDinD is DineroD + Alquiler,
    DuenoFinal = jugador(NomDueno, PosD, NuevoDinD, PropsD),
    actualizar_lista_jugadores(Jugadores, DuenoFinal, TempJugadores),
    actualizar_lista_jugadores(TempJugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 1 - ESTACION] -> '), write(NomV), write(' paga '), write(Alquiler), write(' a '), write(NomDueno), nl.

% -------------------------------------------------------------------
% REGLA 0.A: COMPRA PROPIEDADES (MODO MANUAL)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdProp, PropsOtro)),
    DinV >= Precio, !, 
    write('>>> INFO: La propiedad '), write(IdProp), write(' esta libre y cuesta '), write(Precio), nl,
    write('>>> Tu saldo es '), write(DinV), write('. Deseas comprarla? (Escribe s. o n.): '),
    read(Respuesta),
    (Respuesta == s ->
        NuevoDinV is DinV - Precio,
        VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]),
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[REGLA 0 - COMPRA] -> Has adquirido '), write(IdProp), nl
    ;
        VisitanteFinal = Visitante,
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[PASAR] -> Has decidido ahorrar tu dinero.'), nl
    ).

% -------------------------------------------------------------------
% REGLA 0.B: COMPRA PROPIEDADES Y SERVICIOS (MODO SIMULACION)
% -------------------------------------------------------------------
% Propiedad
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdProp, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdProp), write(' por '), write(Precio), nl.

% Estacion
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdEstacion, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdEstacion | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdEstacion), write(' por '), write(Precio), nl.

% Servicio
interactuar_con_casilla(Visitante, servicio(IdServicio, Precio), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdServicio, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdServicio | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdServicio), write(' por '), write(Precio), nl.

% -------------------------------------------------------------------
% REGLA 4, 5, 6: IMPUESTOS, CARCEL, CARTAS
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, impuesto(Cantidad), Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Cantidad,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[IMPUESTOS] -> '), write(NomV), write(' paga '), write(Cantidad), write(' a la banca.'), nl.

interactuar_con_casilla(Visitante, ir_a_carcel, Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, _, DinV, PropsV),
    NuevoDinV is DinV - 50,
    VisitanteFinal = jugador(NomV, 10, NuevoDinV, PropsV), 
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[CARCEL] -> '), write(NomV), write(' cae en Ir a la Carcel. Paga 50 y va a la 10.'), nl.

interactuar_con_casilla(Visitante, carta, Jugadores, TurnoGlobal, _, VisitanteFinal, JugadoresFinales) :-
    !,
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    ValorCarta is (TurnoGlobal * 47 + PosV * 11) mod 5,
	length(PropsV, NumProps),
    (ValorCarta =:= 0 -> Tipo = 'Error Bancario', Premio = 100
    ; ValorCarta =:= 1 -> Tipo = 'Multa de Trafico', Premio = -50
	; ValorCarta =:= 2 -> Tipo = 'Impuesto al Patrimonio (40 x propiedad)', Premio is -(NumProps * 40)
    ; ValorCarta =:= 3 -> Tipo = 'Premio', Premio = 50
    ; Tipo = 'Impuestos Extra', Premio = -100),
    
    write('[CARTA] -> '), write(NomV), write(' en casilla '), write(PosV), 
    write(' recibe: '), write(Tipo), write(' ('), write(Premio), write(' euros)'), nl,
    
    NuevoDinV is DinV + Premio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales).

% -------------------------------------------------------------------
% CASO POR DEFECTO 
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, _, Jugadores, _, _, Visitante, JugadoresFinales) :-
    actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).

% ===================================================================
% MONOPOLIO Y BANCARROTA
% ===================================================================
grupo_color(marron, [marron1, marron2]).
grupo_color(celeste, [celeste1, celeste2, celeste3]).
grupo_color(rosa, [rosa1, rosa2, rosa3]).
grupo_color(naranja, [naranja1, naranja2, naranja3]).
grupo_color(rojo, [rojo1, rojo2, rojo3]).
grupo_color(amarillo, [amarillo1, amarillo2, amarillo3]).
grupo_color(verde, [verde1, verde2, verde3]).
grupo_color(azul, [azul1, azul2]).

tiene_todas([], _).
tiene_todas([Prop | Resto], PropiedadesJugador) :-
    member(Prop, PropiedadesJugador), tiene_todas(Resto, PropiedadesJugador).

verificar_monopolio(jugador(_, _, _, PropsJugador), Color) :-
    grupo_color(Color, PropsColor), tiene_todas(PropsColor, PropsJugador).

eliminar_jugador([], _, []).
eliminar_jugador([jugador(NomBuscado, _, _, _) | Resto], NomBuscado, Resto) :- !.
eliminar_jugador([J | Resto], NomBuscado, [J | RestoNuevo]) :- eliminar_jugador(Resto, NomBuscado, RestoNuevo).

liquidar_activos(jugador(Nom, Pos, Din, Props), _, jugador(Nom, Pos, Din, Props)) :- Din >= 0, !.
liquidar_activos(jugador(Nom, Pos, Din, []), _, jugador(Nom, Pos, Din, [])) :- !.
liquidar_activos(jugador(Nom, Pos, Din, [PropAVender | RestoProps]), Tablero, JugadorFinal) :-
    ( member(propiedad(PropAVender, PrecioOriginal, _), Tablero) 
    ; member(estacion(PropAVender, PrecioOriginal), Tablero)
    ; member(servicio(PropAVender, PrecioOriginal), Tablero)
    ), !,
    ValorVenta is PrecioOriginal // 2, 
    NuevoDin is Din + ValorVenta,
    write('[LIQUIDACION] -> '), write(Nom), write(' vende '), write(PropAVender), write(' por '), write(ValorVenta), nl,
    liquidar_activos(jugador(Nom, Pos, NuevoDin, RestoProps), Tablero, JugadorFinal).

% ---> BANCARROTA DESACTIVADA EN FASES DE PRUEBA (fase1, fase2, fase3) <---
aplicar_bancarrota(Jugador, _, Jugadores, Modo, Jugadores) :- 
    member(Modo, [fase1, fase2, fase3]), 
    Jugador = jugador(_, _, Dinero, _), Dinero < 0, !.

% ---> BANCARROTA DIRECTA (FASE 4 - Sin liquidar) <---
aplicar_bancarrota(JugadorEnRiesgo, _, JugadoresActuales, fase4, JugadoresFinales) :-
    JugadorEnRiesgo = jugador(Nombre, _, Dinero, _),
    Dinero < 0, !,
    eliminar_jugador(JugadoresActuales, Nombre, JugadoresFinales),
    write('[BANCARROTA DIRECTA] -> '), write(Nombre), write(' no puede pagar y es eliminado (Sin liquidacion).'), nl.

% ---> BANCARROTA COMPLETA (MEJORAS: SIMULACION Y MANUAL) <---
aplicar_bancarrota(JugadorEnRiesgo, Tablero, JugadoresActuales, Modo, JugadoresFinales) :-
    member(Modo, [simulacion, manual]),
    JugadorEnRiesgo = jugador(Nombre, _, Dinero, _),
    Dinero < 0, !,
    liquidar_activos(JugadorEnRiesgo, Tablero, JugadorTrasLiquidar),
    JugadorTrasLiquidar = jugador(_, _, DineroFinal, _),
    (DineroFinal < 0 ->
        eliminar_jugador(JugadoresActuales, Nombre, JugadoresFinales),
        write('[BANCARROTA DEFINITIVA] -> '), write(Nombre), write(' es eliminado.'), nl
    ;
        actualizar_lista_jugadores(JugadoresActuales, JugadorTrasLiquidar, JugadoresFinales),
        write('[RESCATE] -> '), write(Nombre), write(' ha sobrevivido.'), nl
    ).

% Caso por defecto (Dinero en positivo)
aplicar_bancarrota(Jugador, _, Jugadores, _, Jugadores) :-
    Jugador = jugador(_, _, Dinero, _), Dinero >= 0.