/*HAY QUE AÑADIR SINTAXIS AL SINTATICO V2 PQ COMO CAMBIAS TIEMPO DE LOS GERUNDIOS,
NO LAS RECONOCE*/

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
% Este predicado convierte de un formato al otro sin perder informacion,
% de modo que no haga falta tocar draw.pl.

aplanar(X, A) :- number(X), !, atom_number(A, X).      % numeros -> atomos
aplanar(X, X) :- (var(X) ; atomic(X)), !.
aplanar([H|T], [HP|TP]) :- !, aplanar(H, HP), aplanar(T, TP).
aplanar([], []) :- !.
aplanar(Term, Plano) :-
    Term =.. [F|Args],
    aplanar_args(Args, ArgsPlanos),
    Plano =.. [F|ArgsPlanos].

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
    format('Texto: '), escribir_palabras(Lista), nl,

    % --- 1) Tipo y arbol sintactico
    ( tipo_oracion(ID, T) -> nombre_tipo(T, NT) ; NT = '(sin clasificar)' ),
    format('~n[1] Tipo sintactico: ~w~n', [NT]),

    ( once(oracion_dcg(Arbol, Lista, []))
    ->  format('    Arbol completo:~n~n'),
        aplanar(Arbol, ArbolPlano),
        catch(draw(ArbolPlano), _, write('    (no se pudo dibujar)')),

        % --- 2) Simplificacion
        format('~n[2] Simplificacion:~n'),
        ( simples(ID, ListaSimples) ->
            length(ListaSimples, N),
            ( N > 1
            ->  format('    La oracion se descompone en ~w oraciones simples:~n', [N]),
                mostrar_simples_legibles(ListaSimples, 1)
            ;   format('    La oracion ya es simple.~n')
            )
        ;   format('    (no hay simplificacion declarada)~n'),
            ListaSimples = [Lista]
        ),

        % --- 3) Deteccion de problemas semanticos
        format('~n[3] Analisis semantico:~n'),
        analizar_problemas_legible(Lista, ListaSimples)
    ;   format('~n[!] La oracion no se puede analizar con la gramatica actual.~n')
    ).

% Imprimir cada simplificacion como texto legible y, si la gramatica es
% capaz de parsearla, dibujar tambien su arbol. Si la simple incluye
% palabras que aun no estan en el lexico (por la reformulacion linguistica
% al simplificar), simplemente saltamos el dibujo sin error.
mostrar_simples_legibles([], _).
mostrar_simples_legibles([S|Resto], N) :-
    format('     ~w) ', [N]),
    escribir_palabras(S), nl,
    ( catch(once(oracion_dcg(ArbSimple, S, [])), _, fail)
    ->  format('~n        Arbol:~n~n'),
        aplanar(ArbSimple, ArbPlano),
        catch(draw(ArbPlano), _, write('        (no se pudo dibujar)')),
        nl
    ;   format('        (no se puede dibujar el arbol con el lexico actual)~n')
    ),
    N1 is N + 1,
    mostrar_simples_legibles(Resto, N1).

% Reconstruye el texto separando palabras con espacios
escribir_palabras([]).
escribir_palabras([P]) :- !, write(P).
escribir_palabras([P|R]) :- write(P), write(' '), escribir_palabras(R).

% ============================================================
% ANALISIS SEMANTICO LEGIBLE
% ============================================================
% Variante de analizar_problemas/2 que toma listas de palabras (en lugar
% de arboles ya parseados). Reanaliza cada simple para extraer sujeto/verbo.
% Si una simplificacion usa palabras no definidas en el lexico (porque al
% reformular hemos introducido alguna forma verbal nueva), se salta esa
% simple sin error y sigue con las demas.

analizar_problemas_legible(ListaPalabras, SimplesPalabras) :-
    % --- Ambiguedades sobre la oracion completa
    findall(P, (member(P, ListaPalabras), ambigua(P)), AmbBrutas),
    sort(AmbBrutas, Ambigs),

    % --- Reanalisis de cada simple para sacar sujeto-verbo
    findall(prob(T,S,V),
        ( member(SP, SimplesPalabras),
          catch(
            ( oracion_dcg(Arb, SP, []),
              extraer_sv(Arb, S, V),
              clasificar_problema(S, V, T)
            ), _, fail)
        ),
        ProbsPorSimple),

    % --- Tambien sobre el arbol original (no perdemos detecciones)
    ( catch(once(oracion_dcg(ArbOrig, ListaPalabras, [])), _, fail)
    -> findall(prob(T,S,V),
            ( extraer_sv(ArbOrig, S, V),
              clasificar_problema(S, V, T)
            ), ProbsOrig)
    ;  ProbsOrig = []
    ),

    append(ProbsPorSimple, ProbsOrig, TodosProbs),
    sort(TodosProbs, ProblemasFinal),

    imprimir_resultado(Ambigs, ProblemasFinal).

% ============================================================
% ANALIZAR TODO EL CORPUS
% ============================================================

analizar_todo :-
    findall(ID, oracion(ID, _), IDs),
    forall(member(ID, IDs), analizar_oracion(ID)).

% ============================================================
% TABLA RESUMEN
% ============================================================
% Vista rapida con el tipo declarado de cada oracion y si la gramatica
% es capaz de parsearla.

resumen :-
    format('~nID  TIPO                              PARSEO~n'),
    format('--  --------------------------------  --------~n'),
    findall(ID, oracion(ID, _), IDs),
    forall(member(ID, IDs),
        ( oracion(ID, L),
          ( tipo_oracion(ID, T) -> nombre_tipo(T, NT) ; NT = '(?)' ),
          ( oracion_dcg(_, L, []) -> P = ok ; P = fail ),
          format('~|~t~w~3+  ~w~t~36|  ~w~n', [ID, NT, P])
        )).