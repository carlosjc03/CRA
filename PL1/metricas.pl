% ==========================================
% Archivo: metricas.pl
% Descripcion: Calculo de estadisticas usando manipulacion de listas PURA
% ==========================================

% 1. CONTADOR DE OCURRENCIAS
contar_ocurrencias(_, [], 0).
contar_ocurrencias(Elemento, [Elemento | Resto], N) :-
    !, contar_ocurrencias(Elemento, Resto, N1), N is N1 + 1.
contar_ocurrencias(Elemento, [_ | Resto], N) :-
    contar_ocurrencias(Elemento, Resto, N).

% 2. PATRIMONIO TOTAL
patrimonio_total(jugador(_, _, Dinero, Props), Tablero, Total) :-
    sumar_valor_props(Props, Tablero, 0, ValorProps),
    Total is Dinero + ValorProps.

sumar_valor_props([], _, Acumulador, Acumulador).
sumar_valor_props([Prop | Resto], Tablero, Acumulador, Total) :-
    (member(propiedad(Prop, Precio, _), Tablero) ; member(estacion(Prop, Precio), Tablero)), !,
    NuevoAcumulador is Acumulador + Precio,
    sumar_valor_props(Resto, Tablero, NuevoAcumulador, Total).

% 3. MOSTRAR METRICAS
mostrar_metricas(estado(Jugadores, Tablero, _, _), Historial) :-
    write(''), nl,
    write('--- REPORTE DE METRICAS (ANALISIS DE LA SIMULACION) ---'), nl,
    
    write('>> ESTADISTICAS DEL DADO (Por Jugador):'), nl,
    imprimir_dados(2, 12, Historial),
    nl,
    
    write('>> MAPA DE CALOR (VISITAS POR CASILLA):'), nl,
    imprimir_mapa_calor(Tablero, 0, Historial),
    
    % --- NUEVO RESUMEN DETALLADO POR JUGADOR ---
    contar_unicas_global(Historial, NumGlobal),
    contar_unicas_jugador(jugador1, Historial, NumJ1),
    contar_unicas_jugador(jugador2, Historial, NumJ2),
    write('   ------------------------------------------------'), nl,
    write('   RESUMEN DE EXPLORACION (Casillas unicas pisadas):'), nl,
    write('   - En computo global: '), write(NumGlobal), write(' de 40 casillas.'), nl,
    write('   - jugador1 ha pisado: '), write(NumJ1), write(' de 40 casillas.'), nl,
    write('   - jugador2 ha pisado: '), write(NumJ2), write(' de 40 casillas.'), nl,
    nl,
    
    write('>> REGISTRO DE COMPRAS:'), nl,
    imprimir_compras(Historial),
    nl,
    
    write('>> RANKING FINAL (Patrimonio Total = Dinero + Activos):'), nl,
    generar_ranking(Jugadores, Tablero, [], RankingDesordenado),
    sort(RankingDesordenado, RankingOrdenado), 
    reverse(RankingOrdenado, RankingFinal),    
    imprimir_ranking(RankingFinal).

% --- Funciones auxiliares de impresion ---

imprimir_dados(Actual, Max, _) :- Actual > Max, !.
imprimir_dados(Actual, Max, Historial) :-
    contar_ocurrencias(evento_dado(jugador1, Actual), Historial, C1),
    contar_ocurrencias(evento_dado(jugador2, Actual), Historial, C2),
    Total is C1 + C2,
    (Total > 0 ->
        write('   Valor '), write(Actual), write(' -> '),
        write('jugador1: '), write(C1), write(' veces | '),
        write('jugador2: '), write(C2), write(' veces'), nl
    ; true),
    Siguiente is Actual + 1,
    imprimir_dados(Siguiente, Max, Historial).

imprimir_mapa_calor([], _, _).
imprimir_mapa_calor([Casilla | Resto], Indice, Historial) :-
    extraer_nombre(Casilla, Nombre),
    contar_ocurrencias(evento_visita(jugador1, Indice), Historial, C1),
    contar_ocurrencias(evento_visita(jugador2, Indice), Historial, C2),
    Total is C1 + C2,
    (Total > 0 ->
        write('   - [Casilla '), write(Indice), write('] '), write(Nombre), write(' -> '),
        write('jugador1: '), write(C1), write(' veces | '),
        write('jugador2: '), write(C2), write(' veces'), nl
    ; true),
    SigIndice is Indice + 1,
    imprimir_mapa_calor(Resto, SigIndice, Historial).

% --- FILTROS DE CASILLAS UNICAS ---

% 1. Global (Ambos jugadores)
extraer_casillas_global([], []).
extraer_casillas_global([evento_visita(_, Pos) | Resto], [Pos | RestoCasillas]) :- !, extraer_casillas_global(Resto, RestoCasillas).
extraer_casillas_global([_ | Resto], Casillas) :- extraer_casillas_global(Resto, Casillas).

contar_unicas_global(Historial, Num) :-
    extraer_casillas_global(Historial, TodasCasillas),
    sort(TodasCasillas, CasillasUnicas), 
    length(CasillasUnicas, Num).

% 2. Por Jugador individual
extraer_casillas_jugador(_, [], []).
extraer_casillas_jugador(JugadorFiltro, [evento_visita(JugadorFiltro, Pos) | Resto], [Pos | RestoCasillas]) :- 
    !, extraer_casillas_jugador(JugadorFiltro, Resto, RestoCasillas).
extraer_casillas_jugador(JugadorFiltro, [_ | Resto], Casillas) :- 
    extraer_casillas_jugador(JugadorFiltro, Resto, Casillas).

contar_unicas_jugador(JugadorFiltro, Historial, Num) :-
    extraer_casillas_jugador(JugadorFiltro, Historial, CasillasDelJugador),
    sort(CasillasDelJugador, CasillasUnicas),
    length(CasillasUnicas, Num).

% ---------------------------------

extraer_nombre(propiedad(N, _, _), N) :- !.
extraer_nombre(estacion(N, _), N) :- !.
extraer_nombre(impuesto(_), impuesto) :- !.
extraer_nombre(servicio(N, _), N) :- !.
extraer_nombre(N, N).

imprimir_compras([]).
imprimir_compras([evento_compra(J, P) | Resto]) :-
    !, write('   - '), write(J), write(' compro '), write(P), nl,
    imprimir_compras(Resto).
imprimir_compras([_ | Resto]) :- imprimir_compras(Resto).

generar_ranking([], _, Ranking, Ranking).
generar_ranking([Jugador | Resto], Tablero, Acum, RankingFinal) :-
    Jugador = jugador(Nombre, _, _, _),
    patrimonio_total(Jugador, Tablero, Total),
    generar_ranking(Resto, Tablero, [[Total, Nombre] | Acum], RankingFinal).

imprimir_ranking([]).
imprimir_ranking([[Total, Nombre] | Resto]) :-
    write('   '), write(Nombre), write(' -> Patrimonio total: '), write(Total), nl,
    imprimir_ranking(Resto).