% ==============================================================================
% 1. HERRAMIENTAS BÁSICAS DE CONTEO
% ==============================================================================
% Esta función es el motor principal de nuestras estadísticas. 
% Recorre el Historial (la lista gigante de eventos) y cuenta cuántas veces 
% aparece un elemento exacto (por ejemplo, cuántas veces salió un 7 en el dado).
contar_ocurrencias(_, [], 0).
% Si la cabeza de la lista coincide con lo que buscamos, sumamos 1 y seguimos mirando el resto.
contar_ocurrencias(Elemento, [Elemento | Resto], N) :-
    !, contar_ocurrencias(Elemento, Resto, N1), N is N1 + 1.
% Si no coincide, simplemente ignoramos este elemento y seguimos buscando.
contar_ocurrencias(Elemento, [_ | Resto], N) :-
    contar_ocurrencias(Elemento, Resto, N).


% ==============================================================================
% 2. CÁLCULO DEL PATRIMONIO TOTAL (Liquidez + Activos)
% ==============================================================================
% Para saber quién va ganando realmente, no basta con mirar el dinero en efectivo.
% Esta función suma el dinero del bolsillo más el valor original de todas las casas que posee.
patrimonio_total(jugador(_, _, Dinero, Props), Tablero, Total) :-
    sumar_valor_props(Props, Tablero, 0, ValorProps),
    Total is Dinero + ValorProps.

% Recursión que recorre el inventario del jugador.
sumar_valor_props([], _, Acumulador, Acumulador).
sumar_valor_props([Prop | Resto], Tablero, Acumulador, Total) :-
    % Busca la propiedad en el tablero para extraer su Precio base.
    % Usamos el punto y coma (OR) porque puede ser una propiedad normal, estación o servicio.
    ( member(propiedad(Prop, Precio, _), Tablero) 
    ; member(estacion(Prop, Precio), Tablero) 
    ; member(servicio(Prop, Precio), Tablero) 
    ), !,
    NuevoAcumulador is Acumulador + Precio,
    sumar_valor_props(Resto, Tablero, NuevoAcumulador, Total).
% Caso de seguridad por si hay basura en la lista.
sumar_valor_props([_ | Resto], Tablero, Acumulador, Total) :- 
    sumar_valor_props(Resto, Tablero, Acumulador, Total).


% ==============================================================================
% 3.  REPORTE DE MÉTRICAS (Formateo e impresión)
% ==============================================================================
% Esta es la función que se llama al final de la partida. 
% Coge toda la "caja negra" de datos y la imprime bonita por consola.
mostrar_metricas(estado(Jugadores, Tablero, _, _), Historial) :-
    write(''), nl,
    write('--- REPORTE DE METRICAS (ANALISIS DE LA SIMULACION) ---'), nl,
    
    write('>> ESTADISTICAS DEL DADO (Por Jugador):'), nl,
    imprimir_dados(2, 12, Historial), % Llama a una función que va del 2 al 12 contando.
    nl,
    
    write('>> MAPA DE CALOR (VISITAS POR CASILLA):'), nl,
    imprimir_mapa_calor(Tablero, 0, Historial), % Recorre el tablero desde la casilla 0.
    
    % Calculamos cuántas casillas DISTINTAS se han pisado para ver la tasa de exploración.
    contar_unicas_global(Historial, NumGlobal),
    contar_unicas_jugador(jugador1, Historial, NumJ1),
    contar_unicas_jugador(jugador2, Historial, NumJ2),
    write('   ------------------------------------------------'), nl,
    write('   RESUMEN DE EXPLORACION (Casillas unicas pisadas):'), nl,
    write('   - En computo global: '), write(NumGlobal), write(' de 40 casillas.'), nl,
    write('   - jugador1 ha pisado: '), write(NumJ1), write(' de 40 casillas.'), nl,
    write('   - jugador2 ha pisado: '), write(NumJ2), write(' de 40 casillas.'), nl,
    nl,
    
    write('>> REGISTRO HISTORICO DE COMPRAS:'), nl,
    imprimir_compras(Historial),
    nl,
    
    % Extraemos las propiedades. Usamos un If-Then-Else (-> ;) por si un jugador 
    % ha muerto en bancarrota y ya no existe en la lista de Jugadores.
    ( member(jugador(jugador1, _, _, PropsJ1_Bruto), Jugadores) -> true ; PropsJ1_Bruto = [] ),
    ( member(jugador(jugador2, _, _, PropsJ2_Bruto), Jugadores) -> true ; PropsJ2_Bruto = [] ),
    % Sort ordena alfabéticamente la lista para que se lea mejor en el reporte.
    sort(PropsJ1_Bruto, PropsJ1_Limpias),
    sort(PropsJ2_Bruto, PropsJ2_Limpias),

    length(PropsJ1_Limpias, TotalJ1),
    length(PropsJ2_Limpias, TotalJ2),
    TotalCompradas is TotalJ1 + TotalJ2,
    
    write('>> INVENTARIO FINAL DE PROPIEDADES ('), write(TotalCompradas), write('/28 adquiridas):'), nl,
    write('   jugador1 ['), write(TotalJ1), write(']: '), write(PropsJ1_Limpias), nl,
    write('   jugador2 ['), write(TotalJ2), write(']: '), write(PropsJ2_Limpias), nl,
    nl,
    
    % Analizamos si las cartas les han dado dinero o les han arruinado.
    mostrar_resumen_cartas(Historial),
    
    write('>> RANKING FINAL (Patrimonio Total = Dinero + Activos):'), nl,
    generar_ranking(Jugadores, Tablero, [], RankingDesordenado),
    % Prolog ordena de menor a mayor. Como queremos al más rico primero, 
    % lo ordenamos y luego le damos la vuelta con reverse/2.
    sort(RankingDesordenado, RankingOrdenado), 
    reverse(RankingOrdenado, RankingFinal),    
    imprimir_ranking(RankingFinal).


% ==============================================================================
% FUNCIONES AUXILIARES DE IMPRESIÓN Y FILTRADO
% ==============================================================================

% Bucle que va desde el número 2 hasta el 12 buscando en el historial.
imprimir_dados(Actual, Max, _) :- Actual > Max, !.
imprimir_dados(Actual, Max, Historial) :-
    contar_ocurrencias(evento_dado(jugador1, Actual), Historial, C1),
    contar_ocurrencias(evento_dado(jugador2, Actual), Historial, C2),
    Total is C1 + C2,
    (Total > 0 -> % Solo imprime si alguien ha sacado ese número alguna vez.
        write('   Valor '), write(Actual), write(' -> '),
        write('jugador1: '), write(C1), write(' veces | '),
        write('jugador2: '), write(C2), write(' veces'), nl
    ; true),
    Siguiente is Actual + 1,
    imprimir_dados(Siguiente, Max, Historial).

% Bucle para recorrer el tablero visualizando dónde se cae más a menudo.
imprimir_mapa_calor([], _, _).
imprimir_mapa_calor([Casilla | Resto], Indice, Historial) :-
    extraer_nombre(Casilla, Nombre), % Limpiamos la estructura compleja para imprimir solo el átomo.
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


% --- FILTROS DE EXPLORACIÓN (CASILLAS ÚNICAS) ---
% Extrae solo los números de posición del Historial.
extraer_casillas_global([], []).
extraer_casillas_global([evento_visita(_, Pos) | Resto], [Pos | RestoCasillas]) :- !, extraer_casillas_global(Resto, RestoCasillas).
extraer_casillas_global([_ | Resto], Casillas) :- extraer_casillas_global(Resto, Casillas).

% sort/2 elimina automáticamente los duplicados de una lista.
% Así que al ordenar la lista de visitas y contar su longitud (length), 
% sabemos exactamente cuántas casillas diferentes han pisado.
contar_unicas_global(Historial, Num) :-
    extraer_casillas_global(Historial, TodasCasillas),
    sort(TodasCasillas, CasillasUnicas), 
    length(CasillasUnicas, Num).

% Hace exactamente lo mismo pero filtrando solo los eventos de un jugador en concreto.
extraer_casillas_jugador(_, [], []).
extraer_casillas_jugador(JugadorFiltro, [evento_visita(JugadorFiltro, Pos) | Resto], [Pos | RestoCasillas]) :- 
    !, extraer_casillas_jugador(JugadorFiltro, Resto, RestoCasillas).
extraer_casillas_jugador(JugadorFiltro, [_ | Resto], Casillas) :- 
    extraer_casillas_jugador(JugadorFiltro, Resto, Casillas).

contar_unicas_jugador(JugadorFiltro, Historial, Num) :-
    extraer_casillas_jugador(JugadorFiltro, Historial, CasillasDelJugador),
    sort(CasillasDelJugador, CasillasUnicas),
    length(CasillasUnicas, Num).


% Utilidad "embellecedora" para que en consola salga "naranja1" en vez de "propiedad(naranja1, 180, naranja)".
extraer_nombre(propiedad(N, _, _), N) :- !.
extraer_nombre(estacion(N, _), N) :- !.
extraer_nombre(impuesto(_), impuesto) :- !.
extraer_nombre(servicio(N, _), N) :- !.
extraer_nombre(N, N).

% Filtra el Historial ignorando dados y visitas, imprimiendo solo las compras.
imprimir_compras([]).
imprimir_compras([evento_compra(J, P) | Resto]) :-
    !, write('   - '), write(J), write(' compro '), write(P), nl,
    imprimir_compras(Resto).
imprimir_compras([_ | Resto]) :- imprimir_compras(Resto).


% Crea una lista de listas con el formato [[DineroTotal, Nombre], [DineroTotal2, Nombre2]] 
% para poder ordenarla numéricamente de forma sencilla.
generar_ranking([], _, Ranking, Ranking).
generar_ranking([Jugador | Resto], Tablero, Acum, RankingFinal) :-
    Jugador = jugador(Nombre, _, _, _),
    patrimonio_total(Jugador, Tablero, Total),
    generar_ranking(Resto, Tablero, [[Total, Nombre] | Acum], RankingFinal).

imprimir_ranking([]).
imprimir_ranking([[Total, Nombre] | Resto]) :-
    write('   '), write(Nombre), write(' -> Patrimonio total: '), write(Total), nl,
    imprimir_ranking(Resto).


% ==============================================================================
% ANÁLISIS ESTADÍSTICO DE CARTAS (Suerte)
% ==============================================================================
% Recorre el Historial buscando los evento_carta y va sumando (o restando) 
% el premio económico que generaron, para ver si la suerte fue buena o mala.
sumar_cartas(_, [], 0).
sumar_cartas(Jugador, [evento_carta(Jugador, Premio) | Resto], Total) :-
    !, sumar_cartas(Jugador, Resto, SubTotal), Total is SubTotal + Premio.
sumar_cartas(Jugador, [_ | Resto], Total) :- 
    sumar_cartas(Jugador, Resto, Total).

mostrar_resumen_cartas(Historial) :-
    write('>> FRECUENCIA DE CAIDA EN CASILLAS DE CARTA (Suerte/Caja):'), nl,
    % Las casillas de carta están fijas en estas posiciones del tablero.
    imprimir_linea_carta(2, Historial),
    imprimir_linea_carta(7, Historial),
    imprimir_linea_carta(17, Historial),
    imprimir_linea_carta(22, Historial),
    imprimir_linea_carta(33, Historial),
    imprimir_linea_carta(36, Historial),
    nl,
    % Imprimimos el balance exacto que han tenido ambos jugadores por efecto de las cartas (positivo o negativo)
    sumar_cartas(jugador1, Historial, Bal1),
    sumar_cartas(jugador2, Historial, Bal2),
    write('   - Balance J1 tras efecto de cartas: '), write(Bal1), write(' euros.'), nl,
    write('   - Balance J2 tras efecto de cartas: '), write(Bal2), write(' euros.'), nl,
    nl.

imprimir_linea_carta(Pos, Historial) :-
    contar_ocurrencias(evento_visita(jugador1, Pos), Historial, C1),
    contar_ocurrencias(evento_visita(jugador2, Pos), Historial, C2),
    Total is C1 + C2,
    (Total > 0 ->
        write('   - Carta en Casilla '), write(Pos), write(' -> '),
        write('jugador1: '), write(C1), write(' veces | '),
        write('jugador2: '), write(C2), write(' veces'), nl
    ; 
        write('   - Carta en Casilla '), write(Pos), write(' -> Nadie ha caido aqui aun.'), nl
    ).