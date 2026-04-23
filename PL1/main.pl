:- consult('regla.pl').
:- consult('metricas.pl'). 

% ==========================================
% 1.- TABLERO Y JUGADORES (Estructuras Estáticas)
% ==========================================

% Representación del tablero como una lista de 40 elementos. Cada elemento es una estructura que representa el tipo de casilla y sus atributos.
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

% Lista inicial con la "caja" de datos de cada jugador. 
% Todos empiezan en la casilla 0, con 1500€ y una lista vacía [] que será su inventario.
jugadores_iniciales([
    jugador(jugador1, 0, 1500, []), 
    jugador(jugador2, 0, 1500, [])
]).

% Empaqueta todos los elementos iniciales en una única estructura llamada Estado.
% Este será el estado "0" que se le pasará al bucle principal para arrancar la partida.
estado_inicial(estado(Jugadores, Tablero, jugador1, 1)) :-
    jugadores_iniciales(Jugadores), 
    tablero_inicial(Tablero).


% ==========================================
% 2.- MOVIMIENTO Y DADO (Física del juego)
% ==========================================

% Dado determinista. Usa el reloj de la partida (NumTurno) para generar un número del 2 al 12.
% Esto garantiza que las simulaciones sean exactas y reproducibles.
tirar_dado(NumTurno, Dado) :-
    ValorPseudo is (NumTurno * 73) + 19, Dado is (ValorPseudo mod 11) + 2.

% Físicas de movimiento. Caso 1: El jugador avanza y no se sale del tablero (< 40).
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado, Suma < 40, NuevaPos is Suma.

% Caso 2: El jugador completa una vuelta (>= 40). 
% Usamos (mod 40) para recolocarlo al principio e inyectamos los 200€ del Bono de Salida.
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado, Suma >= 40, NuevaPos is Suma mod 40, NuevoDinero is Dinero + 200. 

% Función puente: Agrupa la tirada y el movimiento para no tener que llamarlas por separado.
% Devuelve al jugador ya modificado y el valor que sacó (para poder imprimirlo luego).
ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado) :-
    tirar_dado(NumTurno, DadoSacado), 
    mover_jugador(JugadorActual, DadoSacado, JugadorActualizado). 


% ==========================================
% 3.- MEMORIA Y LISTAS (Gestión de base de datos)
% ==========================================

% Busca recursivamente en la lista de jugadores y devuelve la estructura completa del que coincida con "Nombre".
buscar_jugador([jugador(Nombre, Pos, Dinero, Props) | _], Nombre, jugador(Nombre, Pos, Dinero, Props)) :- !.
buscar_jugador([_ | Resto], Nombre, J) :- buscar_jugador(Resto, Nombre, J).

% Recorre la lista de jugadores, encuentra al que se acaba de actualizar, y lo sustituye por su versión nueva.
actualizar_lista_jugadores([jugador(Nombre, _, _, _) | Resto], jugador(Nombre, Pos, Dinero, Props), [jugador(Nombre, Pos, Dinero, Props ) | Resto]) :- !.
actualizar_lista_jugadores([J | Resto], JugadorActualizado, [J | NuevaLista]) :- actualizar_lista_jugadores(Resto, JugadorActualizado, NuevaLista).

% Lógica de turnos circular. Saca al jugador actual de la cabeza de la lista y busca quién es el siguiente.
% Si llegamos al final de la lista, vuelve al principio.
siguiente_en_lista(Actual, Lista, Siguiente) :-
    append(_, [jugador(Actual,_,_,_) | Resto], Lista),
    ( Resto = [jugador(Siguiente,_,_,_) | _] -> true
    ; Lista = [jugador(Siguiente,_,_,_) | _] ).

% Verifica si el jugador al que le toca sigue vivo. Si ha sido eliminado en este turno,
% le pasa el turno al que haya quedado como primero de la lista.
asegurar_turno(SiguienteIdeal, NuevosJugadores, SiguienteIdeal) :-
    buscar_jugador(NuevosJugadores, SiguienteIdeal, _), !.
asegurar_turno(_, [jugador(Primero,_,_,_) | _], Primero).


% ==========================================
% 4.- EL BUCLE PRINCIPAL (Transición de Estados)
% ==========================================

% Recibe un Estado y devuelve el Estado del siguiente turno.
jugar_turno(estado(Jugadores, Tablero, TurnoActual, NumTurno), Dado, Modo, estado(NuevosJugadores, Tablero, SiguienteReal, NuevoNumTurno)) :-

    % Buscamos al quien le toca jugar en la lista de jugadores para obtener su estructura completa (posición, dinero, propiedades).
    buscar_jugador(Jugadores, TurnoActual, JugadorFisico),
    % Mira quien es el siguiente en jugar según el orden ideal (el que estaba después en la lista al empezar el turno). 
    % Esto es importante para detectar eliminaciones por bancarrota, ya que si por ej al final del turno el
    % jugador que iba a tirar a continuacuion quiebra, y es eliminado la funcion asegurar_turno que está al final 
    % se encargará de pasarle el turno a j1 (o j3 si hubiera mas jugadores) que es el siguiente en la lista, en vez 
    % de intentar dárselo a j2 que ya no existe.
    siguiente_en_lista(TurnoActual, Jugadores, SiguienteIdeal), 
    
    % 1. Tiramos dado y movemos al jugador.
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    
    % 2. Buscamos en qué casilla exacta del tablero ha caido usando el indice (su posicion).
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),

    % 3. Delegamos a regla.pl para procesar compras, alquileres o cartas.
    interactuar_con_casilla(JugadorMovido, CasillaActual, Jugadores, NumTurno, Modo, JugadorTrasEco, JugadoresTemp),
    
    % 4. Comprobamos si las acciones anteriores lo han dejado en números rojos.
    aplicar_bancarrota(JugadorTrasEco, Tablero, JugadoresTemp, Modo, NuevosJugadores),

    % 5. Aseguramos a quién le toca luego e incrementamos el reloj global de la partida.
    asegurar_turno(SiguienteIdeal, NuevosJugadores, SiguienteReal), 
    NuevoNumTurno is NumTurno + 1.


% ==========================================
% 5.- INTERFAZ VISUAL Y EVENTOS (Telemetría)
% ==========================================

% Es un "envoltorio" de jugar_turno. No altera la lógica, solo se encarga de imprimir 
% por consola lo que está pasando y de generar el Historial de eventos para métricas.pl.
turno_limpio(EstadoAntes, EstadoDespues, Modo, EventosDelTurno) :-
    EstadoAntes = estado(JugadoresAntes, Tablero, QuienMueve, NTurnos),
    buscar_jugador(JugadoresAntes, QuienMueve, JugadorActual),
    JugadorActual = jugador(_, PosAntes, DineroAntes, PropsAntes), 
    
    write('=================================================='), nl,
    write('TURNO DE: '), write(QuienMueve), write(' (Tirada Global: '), write(NTurnos), write(')'), nl,
    
    jugar_turno(EstadoAntes, DadoSacado, Modo, EstadoDespues),
    EstadoDespues = estado(NuevosJugadores, _, SiguienteTurno, _),
    
    % Si el jugador sigue existiendo en la lista nueva (no ha quebrado), procesamos sus logs.
    (buscar_jugador(NuevosJugadores, QuienMueve, JugadorTrasTurno) ->
        JugadorTrasTurno = jugador(_, NuevaPos, DinFin, PropsNuevas),
        
        % Calculamos la posición sin el salto a 0 para el mapa de calor de métricas.
        SumaPos is PosAntes + DadoSacado,
        PosIntermedia is SumaPos mod 40,
        
        nth0(NuevaPos, Tablero, CasillaActual),
        extraer_nombre(CasillaActual, NombreSimple),
        
        write('--- ACCION ---'), nl,
        write('Saca un: '), write(DadoSacado), write(' -> Termina en: '), write(NombreSimple), nl,
        
        % Detectamos si ha comprado algo comparando la longitud de su inventario antes y después.
        length(PropsNuevas, L1), length(PropsAntes, L2),
        (L1 > L2 ->
            PropsNuevas = [PropComprada | _],
            EventoCompra = [evento_compra(QuienMueve, PropComprada)]
        ;
            EventoCompra = []
        ),
        
        % Detectamos si ha caído en una carta y calculamos cuánto le ha quitado/dado el evento.
        ( member(PosIntermedia, [2, 7, 17, 22, 33, 36]) ->
            (PosIntermedia < PosAntes -> BonoSalida = 200 ; BonoSalida = 0),
            NetoCarta is DinFin - DineroAntes - BonoSalida,
            EventoCarta = [evento_carta(QuienMueve, NetoCarta)]
        ;
            EventoCarta = []
        ),
        
        % Empaquetamos todo en el Historial para las estadísticas de final de partida.
        append([evento_dado(QuienMueve, DadoSacado), evento_visita(QuienMueve, PosIntermedia)], EventoCompra, TempEventos),
        append(TempEventos, EventoCarta, EventosDelTurno),
        
        write('--- ESTADO FINAL ---'), nl,
        write('Dinero: '), write(DinFin), nl
    ; 
        % Si no está en la lista nueva, es que aplicar_bancarrota lo ha eliminado.
        EventosDelTurno = [evento_dado(QuienMueve, DadoSacado)],
        write('--- ACCION ---'), nl,
        write('Saca un: '), write(DadoSacado), nl,
        write('--- ESTADO FINAL ---'), nl,
        write('Jugador eliminado por bancarrota.'), nl
    ),
    
    write('Siguiente en jugar: '), write(SiguienteTurno), nl,
    write('=================================================='), nl, nl.


% ==========================================
% 6.- MODOS DE EJECUCION Y FIN DE JUEGO
% ==========================================
% El bucle se define por recursión. Se evalúan los casos base primero para saber si hay que parar.

% Caso Base 1: Victoria. Si la longitud de la lista de jugadores es 1, ha ganado.
bucle_juego(EstadoActual, _, Historial, _) :-
    EstadoActual = estado(Jugadores, _, _, _),
    length(Jugadores, 1), !, 
    Jugadores = [jugador(Ganador, _, _, _)],
    write('FIN DEL JUEGO: Solo queda un jugador en pie.'), nl,
    write('EL GANADOR ES: '), write(Ganador), nl,
    mostrar_metricas(EstadoActual, Historial).

% Caso Base 2: Límite de Tiempo. Si el contador llega a 0, paramos para evitar bucles infinitos.
bucle_juego(EstadoActual, TurnosRestantes, Historial, _) :- 
    EstadoActual = estado(Jugadores, _, _, _),
    length(Jugadores, N), N > 1,
    TurnosRestantes =< 0, !,
    write('Limite de turnos de simulacion alcanzado.'), nl,
    mostrar_metricas(EstadoActual, Historial).

% Paso Recursivo: Si quedan turnos y más de un jugador, jugamos el turno, restamos 1 al reloj,
% y volvems a llamar a la función con el nuevo Estado y el Historial actualizado.
bucle_juego(EstadoActual, TurnosRestantes, HistorialActual, Modo) :-
    EstadoActual = estado(Jugadores, _, _, _),
    length(Jugadores, N), N > 1,
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente, Modo, EventosNuevos),
    append(HistorialActual, EventosNuevos, HistorialActualizado),
    NuevosTurnosRestantes is TurnosRestantes - 1,
    bucle_juego(EstadoSiguiente, NuevosTurnosRestantes, HistorialActualizado, Modo).

% Modo interactivo (Mejora): Permite al usuario avanzar paso a paso.
jugar :-
    write('Iniciando partida interactiva manual...'), nl,
    estado_inicial(E0),
    bucle_manual(E0, []).

% En vez de usar un contador de turnos, espera el input ("s.") del usuario para ejecutar la recursión.
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