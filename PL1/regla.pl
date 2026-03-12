% ==========================================
% Archivo: regla.pl
% Descripcion: Motor economico y reglas especiales del juego.
% ==========================================

% -------------------------------------------------------------------
% REGLA 1.A: PAGO DE ALQUILER (Propiedades y Monopolio)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, Color), Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, _, _, _),
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores),
    NomDueno \= NomV,
    member(IdProp, PropsD), !, 
    
    Dueno = jugador(NomDueno, PosD, DineroD, PropsD),
    
    % Comprobamos si el dueño tiene el monopolio para aplicar el sablazo
    ( verificar_monopolio(Dueno, Color) ->
        Alquiler is Precio // 2,
        write('[ALQUILER MONOPOLIO] -> El dueño tiene todas las casillas de color '), write(Color), nl
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
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
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
% REGLA 0.A: COMPRA DE PROPIEDADES
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA] -> '), write(NomV), write(' adquiere la propiedad '), write(IdProp), write(' por '), write(Precio), nl.

% -------------------------------------------------------------------
% REGLA 0.B: COMPRA DE ESTACIONES
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdEstacion | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA] -> '), write(NomV), write(' adquiere la estacion '), write(IdEstacion), write(' por '), write(Precio), nl.

% -------------------------------------------------------------------
% REGLA 4: IMPUESTOS
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, impuesto(Cantidad), Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Cantidad,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[IMPUESTOS] -> '), write(NomV), write(' paga '), write(Cantidad), write(' a la banca.'), nl.

% -------------------------------------------------------------------
% REGLA 5: IR A LA CARCEL
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, ir_a_carcel, Jugadores, _TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, _, DinV, PropsV),
    VisitanteFinal = jugador(NomV, 10, DinV, PropsV), 
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[CARCEL] -> '), write(NomV), write(' va directo a la Carcel (Casilla 10).'), nl.

% -------------------------------------------------------------------
% REGLA 6: CARTAS (4 Resultados posibles)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, carta, Jugadores, TurnoGlobal, VisitanteFinal, JugadoresFinales) :-
    !,
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    
    ValorCarta is (TurnoGlobal * 47 + PosV * 11) mod 4,
    
    (ValorCarta =:= 0 ->
        Premio = 100,
        write('[CARTA] -> Error bancario a tu favor. '), write(NomV), write(' cobra 100.'), nl
    ; ValorCarta =:= 1 ->
        Premio = -50,
        write('[CARTA] -> Multa de trafico. '), write(NomV), write(' paga 50.'), nl
    ; ValorCarta =:= 2 ->
        Premio = 50,
        write('[CARTA] -> Premio de belleza. '), write(NomV), write(' cobra 50.'), nl
    ; 
        Premio = -100,
        write('[CARTA] -> Pago de impuestos atrasados. '), write(NomV), write(' paga 100.'), nl
    ),
    
    NuevoDinV is DinV + Premio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales).

% -------------------------------------------------------------------
% CASO POR DEFECTO (Parking, Salida, o sin dinero para comprar)
% -------------------------------------------------------------------
interactuar_con_casilla(Visitante, _, Jugadores, _TurnoGlobal, Visitante, JugadoresFinales) :-
    actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).

% -------------------------------------------------------------------
% VERIFICADOR DE MONOPOLIO (Regla 2)
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
    member(Prop, PropiedadesJugador),
    tiene_todas(Resto, PropiedadesJugador).

verificar_monopolio(jugador(_, _, _, PropsJugador), Color) :-
    grupo_color(Color, PropsColor),
    tiene_todas(PropsColor, PropsJugador).

% -------------------------------------------------------------------
% REGLA 3: BANCARROTA 
% -------------------------------------------------------------------
eliminar_jugador([], _, []).
eliminar_jugador([jugador(NomBuscado, _, _, _) | Resto], NomBuscado, Resto) :- !.
eliminar_jugador([J | Resto], NomBuscado, [J | RestoNuevo]) :-
    eliminar_jugador(Resto, NomBuscado, RestoNuevo).

aplicar_bancarrota(jugador(Nombre, _, Dinero, _), JugadoresActuales, JugadoresFinales) :-
    Dinero < 0, !,
    eliminar_jugador(JugadoresActuales, Nombre, JugadoresFinales),
    write('[BANCARROTA] -> '), write(Nombre), write(' ha quebrado y es eliminado del juego.'), nl.

aplicar_bancarrota(jugador(_, _, Dinero, _), Jugadores, Jugadores) :-
    Dinero >= 0.