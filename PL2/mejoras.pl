% mejoras.pl
% Modulo reservado para implementar las mejoras del apartado 4 del enunciado.
% El nucleo de la practica (apartados 2.1, 2.2 y 2.3) funciona sin necesidad
% de este archivo. Aqui dejamos planteadas tres mejoras candidatas que el
% equipo puede desarrollar para subir la nota.
%
% Las mejoras propuestas son las siguientes (cumplen la metodologia del
% apartado 4.2: revision teorica -> propuesta -> codigo -> pruebas).
%
% --------------------------------------------------------------
% MEJORA 1 - Asignacion de funciones sintacticas
% --------------------------------------------------------------
% Idea: a partir del arbol devuelto por oracion_dcg/3, etiquetar cada
% constituyente con su funcion en la oracion (Sujeto, Verbo principal,
% Complemento Directo, Complemento Indirecto, Complemento Circunstancial,
% Atributo). Util para informes mas legibles.
%
% Esquema:
%   funciones(+Arbol, -ListaFunciones)
%   funciones(o(GN,GV), [sujeto-GN, predicado-GV]).
%   funciones_pred(GV, [verbo-V, cd-GN, cc-GP, ...]) :- ...
%
% Ejemplo de uso:
%   ?- oracion(4, L), oracion_dcg(A, L, []), funciones(A, F).
%   F = [sujeto-gn([n(n(xai))]),
%        predicado-gv([v(v(significa)), gn(...)])].
%
% --------------------------------------------------------------
% MEJORA 2 - Manejo basico de plurales y genero
% --------------------------------------------------------------
% Idea: en lugar de declarar nombre/adjetivo para cada forma flexionada,
% definir una raiz y un conjunto de terminaciones validas. Asi "satelite",
% "satelites", "ia", "ias" comparten una unica entrada.
%
% Esquema:
%   nombre(n(N)) --> [P], { lema(P, N), categoria(N, sustantivo) }.
%   lema(satelites, satelite). lema(satelite, satelite).
%   lema(operaciones, operacion). ...
%
% --------------------------------------------------------------
% MEJORA 3 - Generacion de explicaciones automaticas
% --------------------------------------------------------------
% Idea: cuando deteccion.pl marca una metafora, en vez de emitir el mismo
% mensaje generico para todos los casos, generar una explicacion adaptada
% al tipo concreto del sujeto y del verbo.
%
% Esquema:
%   explicar(metafora, S, V) :-
%       tipo(S, TS), tipo(V, TV),
%       formato_explicacion(TS, TV, Texto),
%       writeln(Texto).
%
%   formato_explicacion(tecnologia_intangible, accion_arma_fuego, T) :-
%       T = '   En este corpus "disparando" se usa con sentido figurado de
%             aumentar de forma rapida, no de hacer un disparo.'.
%
% --------------------------------------------------------------
% Estado actual: ninguna mejora implementada.
% Si se desarrollan, se anadiran los predicados aqui y se llamaran desde
% main.pl despues del bloque [3] de analizar_oracion/1.
% --------------------------------------------------------------

% (Sin codigo activo todavia.)