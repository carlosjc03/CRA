:- consult('regla.pl').
% 1.- TABLERO, JUGADORES INICIALES Y ESTADO INICIAL
% tablero_inicial con 40 casillas donde cada casilla corresponde a una propiedad, servicio, impuesto o casilla especial
tablero_inicial([
    salida,                                 % 0
    propiedad(marron1, 60, marron),
    carta_comunidad,
    propiedad(marron2, 60, marron),
    impuesto(200),
    estacion(sur, 200),
    propiedad(celeste1, 100, celeste),
    carta_suerte,
    propiedad(celeste2, 100, celeste),
    propiedad(celeste3, 120, celeste),
    carcel_visita,                          % 10
    propiedad(rosa1, 140, rosa),
    servicio(electricidad, 150),
    propiedad(rosa2, 140, rosa),
    propiedad(rosa3, 160, rosa),
    estacion(oeste, 200),
    propiedad(naranja1, 180, naranja),
    carta_comunidad,
    propiedad(naranja2, 180, naranja),
    propiedad(naranja3, 200, naranja),
    parking,                                % 20
    propiedad(rojo1, 220, rojo),
    carta_suerte,
    propiedad(rojo2, 220, rojo),
    propiedad(rojo3, 240, rojo),
    estacion(norte, 200),
    propiedad(amarillo1, 260, amarillo),
    propiedad(amarillo2, 260, amarillo),
    servicio(agua, 150),
    propiedad(amarillo3, 280, amarillo),
    ir_a_carcel,                            % 30
    propiedad(verde1, 300, verde),
    propiedad(verde2, 300, verde),
    carta_comunidad,
    propiedad(verde3, 320, verde),
    estacion(este, 200),
    carta_suerte,
    propiedad(azul1, 350, azul),
    impuesto(100),
    propiedad(azul2, 400, azul)             % 39
]).

% jugadores_iniciales con su nombre, posición inicial, dinero inicial y propiedades
jugadores_iniciales([
    jugador(jugador1, 0, 1500, []),
    jugador(jugador2, 0, 1500, [])
]).

% estado_inicial: Ahora incluye un 1 al final, que es el Contador de Turnos (NumTurno)
estado_inicial(estado(Jugadores, Tablero, jugador1, 1)) :-
    jugadores_iniciales(Jugadores),
    tablero_inicial(Tablero).

% MOVIMIENTO Y DADO

% tirar_dado(NumTurno, DadoGenerado)
% Genera un número pseudoaleatorio entre 2 y 12 usando el número de turno.
tirar_dado(NumTurno, Dado) :-
    ValorPseudo is (NumTurno * 73) + 19, 
    Dado is (ValorPseudo mod 11) + 2.

% mover_jugador(JugadorActual, ValorDado, JugadorActualizado)
mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, Dinero, Props)) :-
    Suma is Pos + Dado,
    Suma < 40,
    NuevaPos is Suma.

mover_jugador(jugador(Nombre, Pos, Dinero, Props), Dado, jugador(Nombre, NuevaPos, NuevoDinero, Props)) :-
    Suma is Pos + Dado,
    Suma >= 40,
    NuevaPos is Suma mod 40,      
    NuevoDinero is Dinero + 200.  

% ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado)
ejecutar_movimiento(JugadorActual, NumTurno, JugadorActualizado, DadoSacado) :-
    tirar_dado(NumTurno, DadoSacado),                               
    mover_jugador(JugadorActual, DadoSacado, JugadorActualizado). 


% 3. LÓGICA DE TURNOS Y PERSISTENCIA (MEMORIA)

% siguiente_turno(Actual, Siguiente)
siguiente_turno(jugador1, jugador2).
siguiente_turno(jugador2, jugador1).

% buscar_jugador: Encuentra al jugador en la lista
buscar_jugador([jugador(Nombre, Pos, Dinero, Props) | _], Nombre, jugador(Nombre, Pos, Dinero, Props)) :- !.
buscar_jugador([_ | Resto], Nombre, J) :- buscar_jugador(Resto, Nombre, J).

% actualizar_lista_jugadores: Crea una nueva lista con el jugador movido
actualizar_lista_jugadores([jugador(Nombre, _, _, _) | Resto], jugador(Nombre, Pos, Dinero, Props), [jugador(Nombre, Pos, Dinero, Props ) | Resto]) :- !.
actualizar_lista_jugadores([J | Resto], JugadorActualizado, [J | NuevaLista]) :-
    actualizar_lista_jugadores(Resto, JugadorActualizado, NuevaLista).

% 4. EL BUCLE PRINCIPAL (jugar_turno)

% jugar_turno(EstadoAntes, Dado, EstadoDespues)
jugar_turno(estado(Jugadores, Tablero, TurnoActual, NumTurno), Dado, estado(NuevosJugadores, Tablero, SiguienteJugador, NuevoNumTurno)) :-
    
    % A. Buscamos los datos del jugador al que le toca
    buscar_jugador(Jugadores, TurnoActual, JugadorFisico),
    
    % B. Ejecutamos el movimiento (esto tira el dado matemáticamente y guarda el valor en 'Dado')
    ejecutar_movimiento(JugadorFisico, NumTurno, JugadorMovido, Dado),
    
    % C. Miramos en qué casilla física ha caído
    JugadorMovido = jugador(_, NuevaPos, _, _),
    nth0(NuevaPos, Tablero, CasillaActual),

	% D. Aplicamos reglas de economía desde regla.pl
    interactuar_con_casilla(JugadorMovido, CasillaActual, Jugadores, _JugadorFinal, NuevosJugadores),

    % E. Pasamos el turno al siguiente jugador
    siguiente_turno(TurnoActual, SiguienteJugador),
    
    % F. Sumamos 1 al reloj de la partida
    NuevoNumTurno is NumTurno + 1.


%  5.-BUCLE JUEGO

% bucle_juego(EstadoActual, NumeroDeTurnosA_Simular)
% Caso base: Si le pedimos que juegue 0 turnos, se para.
bucle_juego(_, 0) :- 
    write('🏁 Simulación terminada.'), nl.

% Caso recursivo: Juega 1 turno, resta 1 al contador, y vuelve a llamarse a sí mismo.
bucle_juego(EstadoActual, TurnosRestantes) :-
    TurnosRestantes > 0,
    turno_limpio(EstadoActual, EstadoSiguiente),
    NuevosTurnosRestantes is TurnosRestantes - 1,
    % Se llama a sí mismo pasando el estado "fresco" para el siguiente turno
    bucle_juego(EstadoSiguiente, NuevosTurnosRestantes).


% 6. INTERFAZ VISUAL (Para jugar sin que salga el tablero entero)

turno_limpio(EstadoAntes, EstadoDespues) :-
    % 1. Abrimos el estado ANTES de jugar para saber quién va a mover y sacar el Tablero
    EstadoAntes = estado(_, Tablero, QuienMueve, _),
    
    % 2. Jugamos el turno (la máquina calcula todo por detrás)
    jugar_turno(EstadoAntes, Dado, EstadoDespues),
    
    % 3. Abrimos el estado DESPUÉS para sacar la nueva lista de jugadores
    EstadoDespues = estado(JugadoresNuevos, _, SiguienteTurno, NTurnos),
    
    % 4. Buscamos al jugador que acaba de mover en la lista NUEVA para ver dónde ha acabado
    buscar_jugador(JugadoresNuevos, QuienMueve, jugador(_, NuevaPos, NuevoDinero, _)),
    
    % 5. Buscamos el nombre de esa posición en el tablero
    nth0(NuevaPos, Tablero, NombreCasilla),
    
    % 6. Imprimimos una tarjeta visual preciosa
    write('TURNO DE: '), write(QuienMueve), nl,
    write( 'Dado sacado: '), write(Dado), nl,
    write('Cae en:      '), write(NombreCasilla), write(' (Casilla '), write(NuevaPos), write(')'), nl,
    write('Dinero:      '), write(NuevoDinero), nl,
    write('Siguiente:   '), write(SiguienteTurno), write(' (Tirada Global: '), write(NTurnos), write(')'), nl,
    write('--------------------------------------------------'), nl.