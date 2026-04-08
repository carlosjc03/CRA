% ==============================================================================
% BLOQUE DE FASES INCREMENTALES (Filtros de pruebas)
% ==============================================================================
% Estos predicados actúan como "escudos". Antes de aplicar las reglas reales, 
% Prolog lee el "Modo" en el que estamos ejecutando la partida. 
% Si estamos en una fase de prueba, bloquea ciertas acciones mediante un corte (!)
% y simplemente devuelve al jugador tal y como estaba.

% --- FASE 1: SOLO MOVIMIENTO ---
% En esta fase, da igual dónde caigas. El corte (!) detiene la búsqueda de más reglas
% y actualizar_lista_jugadores simplemente guarda tu nueva posición sin tocar el dinero.
interactuar_con_casilla(V, propiedad(_,_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, estacion(_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, servicio(_,_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, carta, J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase1, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).

% --- FASE 2: COMPRAS SIN ALQUILER ---
% Aquí permitimos las compras delegando en el modo 'simulacion', pero OJO: 
% Si la propiedad ya tiene dueño (es decir, el Id está en los PropsD de alguien),
% interceptamos el turno con el corte (!) y no hacemos nada, evitando que se cobre el alquiler.
interactuar_con_casilla(V, propiedad(Id,_,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, estacion(Id,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, servicio(Id,_), J, _, fase2, V, JF) :- 
    member(jugador(_,_,_,PropsD), J), member(Id, PropsD), !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, carta, J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase2, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
% Si no se ha cumplido nada de lo de arriba (es decir, la calle está libre), le aplicamos las reglas normales.
interactuar_con_casilla(V, C, J, T, fase2, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% --- FASE 3: COMPRAS + ALQUILERES ---
% Igual que antes, pero ahora solo interceptamos las cartas, impuestos y cárcel. 
% Todo lo que sea propiedades y estaciones pasará al modo simulación normal.
interactuar_con_casilla(V, carta, J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase3, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, C, J, T, fase3, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).

% --- FASE 4: COMPRAS + ALQUILERES + BANCARROTA DIRECTA ---
% Aquí también interceptamos las cartas y la cárcel para probar solo la bancarrota pura.
interactuar_con_casilla(V, carta, J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, impuesto(_), J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, ir_a_carcel, J, _, fase4, V, JF) :- !, actualizar_lista_jugadores(J, V, JF).
interactuar_con_casilla(V, C, J, T, fase4, VF, JF) :- !, interactuar_con_casilla(V, C, J, T, simulacion, VF, JF).


% ==============================================================================
% REGLAS NORMALES DEL JUEGO (El motor económico principal)
% ==============================================================================

% REGLA 1.A: PAGO DE ALQUILER (Propiedades y Monopolio)
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, Color), Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, _, _, _),
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores), % Buscamos si alguien existe en la lista de jugadores...
    NomDueno \= NomV,                                            % ...que no sea yo mismo...
    member(IdProp, PropsD), !,                                   % ...y que tenga esta propiedad en su inventario.
    
    Dueno = jugador(NomDueno, PosD, DineroD, PropsD),
    % Comprobamos si nos aplican el sablazo del monopolio (50%) o alquiler normal (10%)
    ( verificar_monopolio(Dueno, Color) ->
        Alquiler is Precio // 2,
        write('[ALQUILER MONOPOLIO] -> El dueno tiene el grupo '), write(Color), nl
    ;
        Alquiler is Precio // 10
    ),
    
    % Hacemos la transferencia doble: Restamos al visitante y sumamos al dueño.
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Alquiler,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    NuevoDinD is DineroD + Alquiler,
    DuenoFinal = jugador(NomDueno, PosD, NuevoDinD, PropsD),
    
    % Actualizamos la lista global en dos pasos.
    actualizar_lista_jugadores(Jugadores, DuenoFinal, TempJugadores),
    actualizar_lista_jugadores(TempJugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 1] -> '), write(NomV), write(' paga '), write(Alquiler), write(' a '), write(NomDueno), nl.


% REGLA 1.B: PAGO DE ALQUILER (Estaciones)
% Es idéntica a la 1.A, pero sin comprobar el monopolio de colores.
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


% REGLA 0.A: COMPRA PROPIEDADES (MODO MANUAL)
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % La barra y el plus (\+) significan NEGACIÓN. 
    % Aquí exigimos que NO exista ningún jugador en la partida que tenga esta propiedad.
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdProp, PropsOtro)),
    DinV >= Precio, !, 
    
    % Interacción con el usuario mediante read/1.
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


% --- COMPRA ESTACIONES (MODO MANUAL) ---
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
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

% ---  COMPRA SERVICIOS (MODO MANUAL) ---
interactuar_con_casilla(Visitante, servicio(IdServicio, Precio), Jugadores, _, manual, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
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


% REGLA 0.B: COMPRA (MODO SIMULACION AUTOMATICA)
% Si la calle no la tiene nadie (\+) y hay dinero (>=), la compra inmediatamente.
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdProp, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]), % Metemos el IdProp en la cabeza de su lista de propiedades
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdProp), write(' por '), write(Precio), nl.

% Mismo comportamiento para estaciones...
interactuar_con_casilla(Visitante, estacion(IdEstacion, Precio), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdEstacion, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdEstacion | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdEstacion), write(' por '), write(Precio), nl.

% ... y para servicios.
interactuar_con_casilla(Visitante, servicio(IdServicio, Precio), Jugadores, _, simulacion, VisitanteFinal, JugadoresFinales) :-
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    \+ (member(jugador(_, _, _, PropsOtro), Jugadores), member(IdServicio, PropsOtro)),
    DinV >= Precio, !, 
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdServicio | PropsV]),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[REGLA 0 - COMPRA AUTO] -> '), write(NomV), write(' adquiere '), write(IdServicio), write(' por '), write(Precio), nl.


% REGLA 4, 5, 6: IMPUESTOS, CARCEL, CARTAS
interactuar_con_casilla(Visitante, impuesto(Cantidad), Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Cantidad, % El dinero simplemente se evapora, contrarrestando la inflación de la Salida.
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[IMPUESTOS] -> '), write(NomV), write(' paga '), write(Cantidad), write(' a la banca.'), nl.

interactuar_con_casilla(Visitante, ir_a_carcel, Jugadores, _, _, VisitanteFinal, JugadoresFinales) :-
    !, 
    Visitante = jugador(NomV, _, DinV, PropsV),
    NuevoDinV is DinV - 50,
    VisitanteFinal = jugador(NomV, 10, NuevoDinV, PropsV),  % Forzamos un teletransporte directo a la posición 10 (cárcel).
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    write('[CARCEL] -> '), write(NomV), write(' cae en Ir a la Carcel. Paga 50 y va a la 10.'), nl.

% Mecánica de Suerte.
interactuar_con_casilla(Visitante, carta, Jugadores, TurnoGlobal, _, VisitanteFinal, JugadoresFinales) :-
    !,
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    % Fórmula pseudoaleatoria cruzada (Turno y Posición) para simular una baraja barajada.
    ValorCarta is (TurnoGlobal * 47 + PosV * 11) mod 5,
    % Saber el numero de propiedades que tiene el jugador para calcular el impuesto de la carta 2.
    length(PropsV, NumProps),
    
    % Arbol de decisión para el tipo de carta.
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


% CASO POR DEFECTO 
% Si no se cumple nada de lo de arriba (ej: cae en Parking Gratuito), el estado se queda igual.
interactuar_con_casilla(Visitante, _, Jugadores, _, _, Visitante, JugadoresFinales) :-
    actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).


% ==============================================================================
% MONOPOLIO Y BANCARROTA (Utilidades y cierres de turno)
% ==============================================================================

% Diccionario o "Base de Conocimiento" de los grupos del tablero.
grupo_color(marron, [marron1, marron2]).
grupo_color(celeste, [celeste1, celeste2, celeste3]).
grupo_color(rosa, [rosa1, rosa2, rosa3]).
grupo_color(naranja, [naranja1, naranja2, naranja3]).
grupo_color(rojo, [rojo1, rojo2, rojo3]).
grupo_color(amarillo, [amarillo1, amarillo2, amarillo3]).
grupo_color(verde, [verde1, verde2, verde3]).
grupo_color(azul, [azul1, azul2]).

% Comprobador recursivo de listas. Comprueba si todos los elementos de la Lista A (las calles de un color)
% existen dentro de la Lista B (el inventario del jugador).
tiene_todas([], _).
tiene_todas([Prop | Resto], PropiedadesJugador) :-
    member(Prop, PropiedadesJugador), tiene_todas(Resto, PropiedadesJugador).

% Función puente para comprobar el monopolio.
verificar_monopolio(jugador(_, _, _, PropsJugador), Color) :-
    grupo_color(Color, PropsColor), tiene_todas(PropsColor, PropsJugador).

% Utilidad para borrar a un jugador de la partida.
eliminar_jugador([], _, []).
eliminar_jugador([jugador(NomBuscado, _, _, _) | Resto], NomBuscado, Resto) :- !.
eliminar_jugador([J | Resto], NomBuscado, [J | RestoNuevo]) :- eliminar_jugador(Resto, NomBuscado, RestoNuevo).

% Lógica recursiva de liquidación de activos (venta a mitad de precio).
% Caso Base 1: Si ya tienes dinero positivo, la recursión para.
liquidar_activos(jugador(Nom, Pos, Din, Props), _, jugador(Nom, Pos, Din, Props)) :- Din >= 0, !.
% Caso Base 2: Si no tienes propiedades para vender, la recursión para (probablemente mueras).
liquidar_activos(jugador(Nom, Pos, Din, []), _, jugador(Nom, Pos, Din, [])) :- !.
% Paso Recursivo: Si estás en negativo y tienes propiedades, saca la primera de la lista,
% busca su precio original en el tablero, saca el 50%, suma el dinero, y se vuelve a llamar a sí misma.
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
% En las fases iniciales descubrimos que no pasaba nada si bajaban de cero, 
% así que simplemente atrapamos el estado negativo y dejamos que siga jugando.
aplicar_bancarrota(Jugador, _, Jugadores, Modo, Jugadores) :- 
    member(Modo, [fase1, fase2, fase3]), 
    Jugador = jugador(_, _, Dinero, _), Dinero < 0, !.

% ---> BANCARROTA DIRECTA (FASE 4 - Sin liquidar) <---
% Una versión simplificada para la primera implementación de la Fase 4. Muerte súbita.
aplicar_bancarrota(JugadorEnRiesgo, _, JugadoresActuales, fase4, JugadoresFinales) :-
    JugadorEnRiesgo = jugador(Nombre, _, Dinero, _),
    Dinero < 0, !,
    eliminar_jugador(JugadoresActuales, Nombre, JugadoresFinales),
    write('[BANCARROTA DIRECTA] -> '), write(Nombre), write(' no puede pagar y es eliminado (Sin liquidacion).'), nl.

% ---> BANCARROTA COMPLETA (MODOS DEFINITIVOS: SIMULACION Y MANUAL) <---
% El sistema final de quiebras. Si detecta saldo negativo, intenta la venta forzada.
aplicar_bancarrota(JugadorEnRiesgo, Tablero, JugadoresActuales, Modo, JugadoresFinales) :-
    member(Modo, [simulacion, manual]),
    JugadorEnRiesgo = jugador(Nombre, _, Dinero, _),
    Dinero < 0, !,
    liquidar_activos(JugadorEnRiesgo, Tablero, JugadorTrasLiquidar),  % Intentamos el rescate económico.
    JugadorTrasLiquidar = jugador(_, _, DineroFinal, _),
    
    % Tras vender todo lo que pueda, ¿sigue en negativo?
    (DineroFinal < 0 ->
        eliminar_jugador(JugadoresActuales, Nombre, JugadoresFinales), % Sí -> Se le borra del juego.
        write('[BANCARROTA DEFINITIVA] -> '), write(Nombre), write(' es eliminado.'), nl
    ;
        actualizar_lista_jugadores(JugadoresActuales, JugadorTrasLiquidar, JugadoresFinales), % No -> Se salva por los pelos.
        write('[RESCATE] -> '), write(Nombre), write(' ha sobrevivido.'), nl
    ).

% Caso por defecto (Dinero en positivo, no hace falta hacer nada)
aplicar_bancarrota(Jugador, _, Jugadores, _, Jugadores) :-
    Jugador = jugador(_, _, Dinero, _), Dinero >= 0.