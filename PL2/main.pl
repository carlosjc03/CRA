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
        simplificar(Arbol, ListaSimples),
        length(ListaSimples, NumSimples),
        ( NumSimples > 1 ->
            format('~n[2] Simplificación (Oración descompuesta en ~w simples):~n', [NumSimples]),
            imprimir_simples(ListaSimples)
        ;
            format('~n[2] Simplificación:~n  -> La oración ya es simple. No requiere descomposición.~n')
        ),
        
        % 3. Detección de Problemas Semánticos
        format('~n[3] Análisis de Problemas de Interpretación:~n'),
        analizar_problemas(ListaPalabras, ListaSimples)
    ;
        write('Error: La oración no cumple las reglas sintácticas o faltan palabras en el léxico.'), nl
    ).

imprimir_simples([]).
imprimir_simples([O|Resto]) :-
    draw(O),
    imprimir_simples(Resto).