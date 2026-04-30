% main.pl
% Punto de entrada del sistema. Carga todos los modulos y expone los
% predicados de alto nivel para analizar oraciones del corpus.
%
% Uso tipico desde el interprete:
%   ?- consult(main).
%   ?- analizar_oracion(7).
%   ?- analizar_todo.
 
:- set_prolog_flag(encoding, utf8).
 
:- consult('draw').
:- consult('sintactico').
:- consult('semantico').
:- consult('deteccion').
:- consult('mejoras').
:- consult('conjunto_oraciones').
 
% ============================================================
% APLANADOR PARA DRAW
% ============================================================
% Nuestra gramatica devuelve arboles donde los hijos van en una lista
% (ej. gn([dn(...), gp(...), gadj(...)])). draw.pl espera arboles donde
% cada hijo es un argumento del termino padre (ej. gn(dn(...), gp(...))).
% Este predicado convierte de un formato al otro sin perder informacion.
 
aplanar(X, A) :- number(X), !, atom_number(A, X).      % numeros -> atomos
aplanar(X, X) :- (var(X) ; atomic(X)), !.
aplanar([H|T], [HP|TP]) :- !, aplanar(H, HP), aplanar(T, TP).
aplanar([], []) :- !.
aplanar(Term, Plano) :-
    Term =.. [F|Args],
    aplanar_args(Args, ArgsPlanos),
    Plano =.. [F|ArgsPlanos].
 
% Si algun argumento es una lista, sus elementos suben a ser argumentos
% hermanos del padre.
aplanar_args([], []).
aplanar_args([Arg|Resto], Salida) :-
    is_list(Arg), !,
    maplist(aplanar, Arg, ArgPlanos),
    aplanar_args(Resto, RestoPlanos),
    append(ArgPlanos, RestoPlanos, Salida).
aplanar_args([Arg|Resto], [ArgPlano|RestoPlanos]) :-
    aplanar(Arg, ArgPlano),
    aplanar_args(Resto, RestoPlanos).
 
% ============================================================
% ANALISIS DE UNA ORACION
% ============================================================
 
analizar_oracion(ID) :-
    oracion(ID, Lista),
    format('~n========================================================~n'),
    format('   ANALIZANDO ORACION ~w~n', [ID]),
    format('========================================================~n'),
    format('Texto: ~w~n', [Lista]),
 
    % --- 1) Analisis sintactico
    ( once(oracion_dcg(Arbol, Lista, []))
    ->  tipo_oracion(Arbol, TipoStr),
        format('~n[1] Tipo sintactico: ~w~n', [TipoStr]),
        format('    Arbol completo:~n~n'),
        aplanar(Arbol, ArbolPlano),
        catch(draw(ArbolPlano), _, write('    (no se pudo dibujar)')),
 
        % --- 2) Simplificacion
        ( simplificar(Arbol, Simples) -> true ; Simples = [Arbol] ),
        length(Simples, N),
        ( N > 1
        ->  format('~n[2] Simplificacion: ~w oraciones simples obtenidas.~n', [N]),
            mostrar_simples(Simples, 1)
        ;   format('~n[2] Simplificacion: la oracion ya es simple.~n')
        ),
 
        % --- 3) Deteccion de problemas
        format('~n[3] Analisis semantico:~n'),
        analizar_problemas(Lista, Simples)
    ;   format('~n[!] La oracion no se puede analizar con la gramatica actual.~n')
    ).
 
% Etiqueta del tipo de oracion segun el functor del arbol raiz.
tipo_oracion(ocm(_,_,_,_), 'Compuesta (ocm)').
tipo_oracion(oc(_,_,_),   'Coordinada (oc)').
tipo_oracion(o(GN, GV),   Tipo) :-
    ( contiene_relativo(GN) ; contiene_relativo(GV) ), !,
    Tipo = 'Simple con subordinada de relativo (or)'.
tipo_oracion(o(_,_),      'Simple (o)').
tipo_oracion(o(_,_,_),    'Simple con modificador inicial (o)').
tipo_oracion(o(_,_,_,_),  'Simple compleja (o)').
tipo_oracion(o(_),        'Simple con sujeto eliptico (o)').
 
% Helper para detectar relativos anidados
contiene_relativo(T) :-
    compound(T),
    ( T = rel(_)
    ; T = or(_,_)
    ; T = or(_,_,_)
    ; ( T =.. [_|Args], member(A, Args), contiene_relativo(A) )
    ; ( is_list(T), member(E, T), contiene_relativo(E) )
    ).
 
mostrar_simples([], _).
mostrar_simples([S|Resto], N) :-
    format('    Simple ~w:~n', [N]),
    aplanar(S, SP),
    catch(draw(SP), _, write('    (no se pudo dibujar)')),
    nl,
    N1 is N + 1,
    mostrar_simples(Resto, N1).
 
% ============================================================
% ANALIZAR TODO EL CORPUS
% ============================================================
 
analizar_todo :-
    findall(ID, oracion(ID, _), IDs),
    forall(member(ID, IDs), analizar_oracion(ID)).
 
% ============================================================
% UTILIDADES DE PRUEBA RAPIDA
% ============================================================
 
% Solo arbol y tipo, sin draw (para ejecutar todo el corpus rapido).
resumen :-
    findall(ID, oracion(ID, _), IDs),
    forall(member(ID, IDs),
        ( oracion(ID, L),
          ( once(oracion_dcg(Arbol, L, []))
          ->  Arbol =.. [Functor|_],
              format('~w  ~w~n', [ID, Functor])
          ;   format('~w  FAIL~n', [ID])
          )
        )).
    