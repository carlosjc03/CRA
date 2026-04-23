% main.pl
:- consult('draw.pl').
:- consult('conjunto_oraciones.pl').
:- consult('sintactico.pl').
:- consult('semantico.pl').
:- consult('deteccion.pl').
:- consult('mejoras.pl').

% Predicado principal para el análisis completo de la práctica
analizar_oracion(ID) :-
    oracion(ID, ListaPalabras),
    format('--- ANALIZANDO ORACIÓN ~w ---~n', [ID]),
    write('Texto: '), write(ListaPalabras), nl,
    
    % 1. Análisis Sintáctico y dibujo del árbol original
    (oracion_dcg(Arbol, ListaPalabras, []) ->
        format('~n[1] Árbol Sintáctico Completo:~n'),
        draw(Arbol),
        
        % 2. Simplificación (Descomponer en oraciones simples)
        format('~n[2] Simplificación de la oración:~n'),
        simplificar(Arbol, ListaSimples),
        imprimir_simples(ListaSimples)
    ;
        write('Error: La oración no cumple las reglas sintácticas.'), nl
    ).

% Auxiliar para imprimir y dibujar cada oración simple resultante
imprimir_simples([]).
imprimir_simples([O|Resto]) :-
    write('-> Oración simple detectada:'), nl,
    draw(O),
    imprimir_simples(Resto).