% ==========================================
% Archivo: regla.pl
% Descripcion: Motor economico y reglas especiales del juego.
% ==========================================
% ===================================================================
% INTERRUPTORES DE DESARROLLO INCREMENTAL (Feature Flags)
% Esto nos permite aislar fases de prueba sin duplicar archivos.
% ===================================================================

% --- FASE 1: SOLO MOVIMIENTO ---
% Bloquea compras, alquileres, servicios, cartas e impuestos. 
interactuar_con_casilla(Visitante, propiedad(_,_,_), Jugadores, _, fase1, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, estacion(_,_), Jugadores, _, fase1, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, servicio(_,_), Jugadores, _, fase1, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, carta, Jugadores, _, fase1, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, impuesto(_), Jugadores, _, fase1, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).

% --- FASE 2: MOVIMIENTO + CARTAS E IMPUESTOS ---
% Bloquea las compras y los alquileres. Deja pasar lo demas.
interactuar_con_casilla(Visitante, propiedad(_,_,_), Jugadores, _, fase2, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, estacion(_,_), Jugadores, _, fase2, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, servicio(_,_), Jugadores, _, fase2, Visitante, JugadoresFinales) :- !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(V, C, J, T, fase2, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% --- FASE 3: MOVIMIENTO + CARTAS + COMPRAS (Sin Alquiler) ---
% Bloquea SOLO el pago de alquileres cuando la casilla ya es del enemigo.
interactuar_con_casilla(Visitante, propiedad(Id,_,_), Jugadores, _, fase3, Visitante, JugadoresFinales) :- 
    Visitante = jugador(NomV,_,_,_), member(jugador(NomD,_,_,PropsD), Jugadores), NomD \= NomV, member(Id, PropsD), !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, estacion(Id,_), Jugadores, _, fase3, Visitante, JugadoresFinales) :- 
    Visitante = jugador(NomV,_,_,_), member(jugador(NomD,_,_,PropsD), Jugadores), NomD \= NomV, member(Id, PropsD), !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(Visitante, servicio(Id,_), Jugadores, _, fase3, Visitante, JugadoresFinales) :- 
    Visitante = jugador(NomV,_,_,_), member(jugador(NomD,_,_,PropsD), Jugadores), NomD \= NomV, member(Id, PropsD), !, actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).
interactuar_con_casilla(V, C, J, T, fase3, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% ===================================================================
% A PARTIR DE AQUI ESTÁN TUS REGLAS NORMALES (Alquiler, Compras, etc.)
% ===================================================================
% -------------------------------------------------------------------
% REGLA 1.A: PAGO DE ALQUILER (Propiedades y Monopolio)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, Color), Jugadores, _TurnoGlobal, _Modo, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, _, _, _),
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores),
    NomDueno \= NomV,
    member(IdProp, PropsD), !, 
    
    Dueno = jugador(NomDueno, PosD, DineroD, PropsD),
    ( verificar_monopolio(Dueno, Color) ->
        Alquiler is Precio // 2,
        write('[ALQUILER MONOPOLIO] -> El dueno tiene el grupo de color '), write(Color), nl
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
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _TurnoGlobal, _Modo, VisitanteFinal, JugadoresFinales) :-
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
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _TurnoGlobal, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion CLAVE: Que nadie (ni yo, ni el otro) la tenga ya
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
% REGLA 0.B: COMPRA PROPIEDADES (MODO SIMULACION)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _TurnoGlobal, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion CLAVE: Que nadie (ni yo, ni el otro) la tenga ya
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdProp, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdProp), write(' por '), write(Precio), nl.

% -------------------------------------------------------------------
% REGLA 0.C: COMPRA ESTACIONES (MODO MANUAL)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _TurnoGlobal, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion CLAVE: Que nadie la tenga
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdEstacion, PropsOtro)),
    DinV >= Precio, !, 
    write('>>> INFO: La estacion '), write(IdEstacion), write(' esta libre y cuesta '), write(Precio), nl,
    write('>>> Tu saldo es '), write(DinV), write('. Deseas comprarla? (Escribe s. o n.): '),
    read(Respuesta),
    (Respuesta == s ->
        NuevoDinV is DinV - Precio,
        VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdEstacion | PropsV]),
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[REGLA 0 - COMPRA] -> Has adquirido '), write(IdEstacion), nl
    ;
        VisitanteFinal = Visitante,
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[PASAR] -> Has decidido ahorrar tu dinero.'), nl
    ).

% -------------------------------------------------------------------
% REGLA 0.D: COMPRA ESTACIONES (MODO SIMULACION)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _TurnoGlobal, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion CLAVE: Que nadie la tenga
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdEstacion, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdEstacion | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdEstacion), write(' por '), write(Precio), nl.

% -------------------------------------------------------------------
% REGLA 0.E: COMPRA SERVICIOS (MODO MANUAL)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, servicio(IdServicio, Precio), Jugadores, _TurnoGlobal, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion: Que nadie lo tenga
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdServicio, PropsOtro)),
    DinV >= Precio, !, 
    write('>>> INFO: El servicio '), write(IdServicio), write(' esta libre y cuesta '), write(Precio), nl,
    write('>>> Tu saldo es '), write(DinV), write('. Deseas comprarlo? (Escribe s. o n.): '),
    read(Respuesta),
    (Respuesta == s ->
        NuevoDinV is DinV - Precio,
        VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdServicio | PropsV]),
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[REGLA 0 - COMPRA] -> Has adquirido '), write(IdServicio), nl
    ;
        VisitanteFinal = Visitante,
        actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
        write('[PASAR] -> Has decidido ahorrar tu dinero.'), nl
    ).

% -------------------------------------------------------------------
% REGLA 0.F: COMPRA SERVICIOS (MODO SIMULACION)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, servicio(IdServicio, Precio), Jugadores, _TurnoGlobal, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Comprobacion: Que nadie lo tenga
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdServicio, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdServicio | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdServicio), write(' por '), write(Precio), nl.
% -------------------------------------------------------------------
% REGLA 4: IMPUESTOS
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, impuesto(Cantidad), Jugadores, _TurnoGlobal, _Modo, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Cantidad,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[IMPUESTOS] -> '), write(NomV), write(' paga '), write(Cantidad), write(' a la banca.'), nl.

% -------------------------------------------------------------------
% REGLA 5: IR A LA CARCEL 
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, ir_a_carcel, Jugadores, _TurnoGlobal, _Modo, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, _, DinV, PropsV),
    NuevoDinV is DinV - 50,
    VisitanteFinal = jugador(NomV, 10, NuevoDinV, PropsV), 
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[CARCEL] -> '), write(NomV), write(' cae en Ir a la Carcel. Paga fianza de 50 y va a la casilla 10.'), nl.

% -------------------------------------------------------------------
% REGLA 6: CARTAS 
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, carta, Jugadores, TurnoGlobal, _Modo, VisitanteFinal, JugadoresFinales) :-
    !,
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    ValorCarta is (TurnoGlobal * 47 + PosV * 11) mod 4,
    (ValorCarta =:= 0 -> Premio = 100, write('[CARTA] -> Error bancario. '), write(NomV), write(' cobra 100.'), nl
    ; ValorCarta =:= 1 -> Premio = -50, write('[CARTA] -> Multa. '), write(NomV), write(' paga 50.'), nl
    ; ValorCarta =:= 2 -> Premio = 50, write('[CARTA] -> Premio. '), write(NomV), write(' cobra 50.'), nl
    ; Premio = -100, write('[CARTA] -> Impuestos. '), write(NomV), write(' paga 100.'), nl),
    NuevoDinV is DinV + Premio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales).

% -------------------------------------------------------------------
% CASO POR DEFECTO 
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, _, Jugadores, _TurnoGlobal, _Modo, Visitante, JugadoresFinales) :-
    actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).

% -------------------------------------------------------------------
% MONOPOLIO Y BANCARROTA (Todo identico)
% -------------------------------------------------------------------
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
    (member(propiedad(PropAVender, PrecioOriginal, _), Tablero) ; member(estacion(PropAVender, PrecioOriginal), Tablero)),
    ValorVenta is PrecioOriginal // 2, 
    NuevoDin is Din + ValorVenta,
    write('[LIQUIDACION] -> '), write(Nom), write(' vende '), write(PropAVender), write(' por '), write(ValorVenta), nl,
    liquidar_activos(jugador(Nom, Pos, NuevoDin, RestoProps), Tablero, JugadorFinal).

aplicar_bancarrota(JugadorEnRiesgo, Tablero, JugadoresActuales, JugadoresFinales) :-
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

aplicar_bancarrota(Jugador, _, Jugadores, Jugadores) :-
    Jugador = jugador(_, _, Dinero, _), Dinero >= 0.


