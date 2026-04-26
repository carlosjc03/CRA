% main.pl
:- consult('draw.pl').
:- consult('conjunto_oraciones.pl').
:- consult('sintactico.pl').
:- consult('semantico.pl').
:- consult('deteccion.pl').
:- consult('mejoras.pl').

analizar_oracion(ID) :-
    oracion(ID, ListaPalabras),
    format('--- ANALIZANDO ORACIÓN ~w ---~n', [ID]),
    write('Texto: '), write(ListaPalabras), nl,
    
    % 1. Análisis Sintáctico
    (oracion_dcg(Arbol, ListaPalabras, []) ->
        format('~n[1] Árbol Sintáctico Completo:~n'),
        draw(Arbol),
        
        % 2. Simplificación Inteligente
		(simplificar(Arbol, ListaSimples) ->
            length(ListaSimples, NumSimples),
            ( NumSimples > 1 ->
                format('~n[2] Simplificación (~w oraciones simples detectadas):~n', [NumSimples]),
                imprimir_simples(ListaSimples)
            ;
                format('~n[2] Simplificación:~n  -> La oración ya es simple.~n')
            )
        ;   % Fallback si simplificar no devuelve nada o no está implementado
            ListaSimples = [Arbol]
        ),
        
        % 3. Detección de Problemas Semánticos
        format('~n[3] Análisis de Problemas de Interpretación:~n'),
        analizar_problemas(ListaPalabras, ListaSimples)
    ;
        write('~n[!]Error: La oración no cumple las reglas sintácticas o faltan palabras en el léxico.'), nl
    ).

analizar_todo :-
    findall(ID, oracion(ID, _), IDs),
    maplist(analizar_oracion, IDs).

imprimir_simples([]).
imprimir_simples([O|Resto]) :-
    draw(O),
    imprimir_simples(Resto).