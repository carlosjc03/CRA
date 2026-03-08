% 1. REGLA 1: PAGO DE ALQUILER (Propiedad con dueño)
% interactuar_con_casilla(Visitante, Casilla, ListaTodos, VisitanteFinal, ListaTodosFinal)
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, VisitanteFinal, JugadoresFinales) :-
    % A. Extraemos el nombre del visitante
    Visitante = jugador(NomV, _, _, _),
    
    % B. Buscamos si alguien en la lista tiene esta propiedad (y que no sea el propio visitante)
    member(jugador(NomDueno, PosD, DineroD, PropsD), Jugadores),
    NomDueno \= NomV,
    member(IdProp, PropsD), !, % El corte (!) evita que Prolog intente saltar a la Regla 0 si esto es verdad.
    
    % C. Calculamos el alquiler (10% del precio de compra)
    Alquiler is Precio // 10,
    
    % D. Empobrecemos al visitante
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    NuevoDinV is DinV - Alquiler,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, PropsV),
    
    % E. Enriquecemos al dueño
    NuevoDinD is DineroD + Alquiler,
    DuenoFinal = jugador(NomDueno, PosD, NuevoDinD, PropsD),
    
    % F. Actualizamos a ambos en la lista global
    actualizar_lista_jugadores(Jugadores, DuenoFinal, TempJugadores),
    actualizar_lista_jugadores(TempJugadores, VisitanteFinal, JugadoresFinales),
    
    % G. Imprimimos el mensaje de interacción
    write('💸 [Regla 1] -> Alquiler '), write(NomV), write(' paga '), write(Alquiler), write(' a '), write(NomDueno), nl.


% 2. REGLA 0: COMPRA DE PROPIEDADES (Propiedad sin dueño)
interactuar_con_casilla(Visitante, propiedad(IdProp, Precio, _), Jugadores, VisitanteFinal, JugadoresFinales) :-
    % A. Extraemos los datos del jugador visitante
    Visitante = jugador(NomV, PosV, DinV, PropsV),
    
    % B. Comprobamos si tiene fondos suficientes para comprar
    DinV >= Precio, !, % El corte (!) asegura que si tiene dinero, la compra sí o sí.
    
    % C. Descontamos el dinero y añadimos la propiedad a su lista
    NuevoDinV is DinV - Precio,
    VisitanteFinal = jugador(NomV, PosV, NuevoDinV, [IdProp | PropsV]),
    
    % D. Actualizamos la lista global con el nuevo jugador
    actualizar_lista_jugadores(Jugadores, VisitanteFinal, JugadoresFinales),
    
    % E. Imprimimos el mensaje de interacción
    write('🏠 [Regla 0] -> Compra '), write(NomV), write(' adquiere '), write(IdProp), write(' por '), write(Precio), nl.


% 3. CASOS POR DEFECTO (Sin dinero, Salida, Parking, etc.)
interactuar_con_casilla(Visitante, _, Jugadores, Visitante, JugadoresFinales) :-
    % Si cae aquí, significa que:
    % - Es una propiedad y no tiene dinero para comprarla.
    % - O es una casilla especial (parking, salida, suerte, etc.)
    % No pasa nada económico, solo guardamos al jugador con su nueva posición.
    
    actualizar_lista_jugadores(Jugadores, Visitante, JugadoresFinales).