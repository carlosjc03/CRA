% deteccion.pl
% Modulo de deteccion de problemas semanticos:
%   1) Ambiguedad lexica: una palabra de la oracion tiene mas de un tipo
%      semantico distinto declarado en semantico.pl.
%   2) Incoherencia semantica: el sujeto y el verbo de la oracion son
%      incompatibles segun nuestras reglas de coherencia.
%   3) Uso no literal (metafora): combinaciones sujeto-verbo o sujeto-objeto
%      que el sistema reconoce como metaforicas en este corpus.
%
% La idea es no resolver el significado, sino solo "encender alarmas" cuando
% encontramos algo que merece revisarse.

% ============================================================
% PUNTO DE ENTRADA
% ============================================================

% analizar_problemas(+ListaPalabras, +ListaArbolesSimples)
% Imprime las advertencias (ambiguedades + metaforas/incoherencias).
analizar_problemas(ListaPalabras, ListaSimples) :-
    % --- 1) Ambiguedades lexicas
    findall(P, (member(P, ListaPalabras), ambigua(P)), AmbBrutas),
    sort(AmbBrutas, Ambigs),

    % --- 2) Incoherencias y metaforas (sujeto-verbo y sujeto-objeto)
    findall(prob(Tipo,S,V),
            ( member(Arbol, ListaSimples),
              extraer_sv(Arbol, S, V),
              clasificar_problema(S, V, Tipo)
            ),
            ProbsBrutos),
    sort(ProbsBrutos, Problemas),

    imprimir_resultado(Ambigs, Problemas).

% ============================================================
% IMPRESION
% ============================================================

imprimir_resultado([], []) :-
    write('  -> Oracion correcta. Sin problemas aparentes.'), nl.
imprimir_resultado(Ambigs, Probs) :-
    ( Ambigs == [] -> true ; imprimir_ambig(Ambigs) ),
    ( Probs  == [] -> true ; imprimir_probs(Probs) ).

imprimir_ambig([]).
imprimir_ambig([P|R]) :-
    findall(T, tipo(P, T), Tipos),
    format('  -> [AMBIGUEDAD LEXICA] La palabra "~w" admite varios significados: ~w.~n',
           [P, Tipos]),
    imprimir_ambig(R).

imprimir_probs([]).
imprimir_probs([prob(metafora,S,V)|R]) :-
    format('  -> [USO NO LITERAL] El sujeto "~w" no realiza literalmente la accion "~w" (metafora).~n',
           [S, V]),
    imprimir_probs(R).
imprimir_probs([prob(incoherencia,S,V)|R]) :-
    format('  -> [INCOHERENCIA SEMANTICA] La combinacion sujeto "~w" + verbo "~w" no es coherente.~n',
           [S, V]),
    imprimir_probs(R).

% ============================================================
% AMBIGUEDAD LEXICA
% ============================================================
% Una palabra es ambigua si tiene declarados dos o mas tipos distintos en
% semantico.pl. Usamos @< para no contar la pareja al reves.
ambigua(Palabra) :-
    tipo(Palabra, T1),
    tipo(Palabra, T2),
    T1 @< T2.

% ============================================================
% EXTRACCION DE SUJETO Y VERBO
% ============================================================
% Recorre el arbol y devuelve el primer par (Sujeto, Verbo) que encuentra.
% Funciona con cualquier estructura de oracion simple: o(GN,GV), o(Adv,GN,GV),
% o(GP,GN,GV), incluso o(GV) (sujeto eliptico, en cuyo caso devuelve '_eliptico').

:- discontiguous extraer_sv/3.

% extraer_sv(+Arbol, -Sujeto, -Verbo)
extraer_sv(o(GN, GV), Suj, Verb) :-
    nucleo_nombre(GN, Suj),
    nucleo_verbo(GV, Verb).
extraer_sv(o(_, GN, GV), Suj, Verb) :-
    nucleo_nombre(GN, Suj),
    nucleo_verbo(GV, Verb).
extraer_sv(o(_, _, GN, GV), Suj, Verb) :-
    nucleo_nombre(GN, Suj),
    nucleo_verbo(GV, Verb).
extraer_sv(o(GV), '_eliptico', Verb) :-
    nucleo_verbo(GV, Verb).

% Tambien intentamos extraer pares (Sujeto, Verbo) "secundarios" que
% aparezcan en oraciones subordinadas dentro del GV. Esto permite cazar
% metaforas como "los sistemas corren el riesgo de convertirse en cajas negras".
extraer_sv(Arbol, Suj, Verb) :-
    nonvar(Arbol),
    contiene_oracion_anidada(Arbol, OAnid),
    Arbol \== OAnid,
    extraer_sv(OAnid, Suj, Verb).

% Tambien capturamos verbos dentro de clausulas de infinitivo (infc).
% Por ejemplo "de convertirse en cajas negras" -> verbo significativo es 'convertirse'.
extraer_sv(Arbol, Suj, Verb) :-
    nonvar(Arbol),
    extraer_sv_principal(Arbol, Suj, _),
    contiene_infinitivo(Arbol, Verb).

% Busca subarboles 'o(...)' dentro de un arbol concreto (Term debe estar
% instanciado para que el recorrido sea seguro).
contiene_oracion_anidada(Term, O) :-
    nonvar(Term),
    compound(Term),
    Term =.. [_|Args],
    member(A, Args),
    ( is_list(A) -> member(E, A), buscar_o(E, O)
    ; buscar_o(A, O)
    ).

buscar_o(Term, Term) :-
    nonvar(Term),
    functor(Term, o, _).
buscar_o(Term, O) :-
    nonvar(Term),
    compound(Term),
    Term =.. [_|Args],
    member(A, Args),
    ( is_list(A) -> member(E, A), buscar_o(E, O)
    ; buscar_o(A, O)
    ).

extraer_sv_principal(o(GN, GV), Suj, Verb) :-
    nucleo_nombre(GN, Suj), nucleo_verbo(GV, Verb).
extraer_sv_principal(o(_, GN, GV), Suj, Verb) :-
    nucleo_nombre(GN, Suj), nucleo_verbo(GV, Verb).

contiene_infinitivo(Term, V) :-
    nonvar(Term),
    compound(Term),
    ( Term = infc([v(V)|_])
    ; Term =.. [_|Args],
      member(A, Args),
      ( is_list(A) -> member(E, A), contiene_infinitivo(E, V)
      ; contiene_infinitivo(A, V)
      )
    ).

% nucleo_nombre(+GN, -Palabra)
% Devuelve el sustantivo nuclear del primer GN. Lo busca recorriendo la
% lista de hijos del GN hasta que encuentra el nucleo (n, dn, dpn, np, an, etc.)
nucleo_nombre(gn([Nucleo|_]), Palabra) :-
    nombre_de_nucleo(Nucleo, Palabra).

nombre_de_nucleo(n(n(P)), P).
nombre_de_nucleo(dn(_, n(P)), P).
nombre_de_nucleo(ddn(_, _, n(P)), P).
nombre_de_nucleo(dpn(_, _, n(P)), P).
nombre_de_nucleo(an(_, n(P)), P).
nombre_de_nucleo(np(n(P), _), P).        % "Planet Labs" -> Planet
nombre_de_nucleo(coord(n(P), _, _), P).  % "Luna y Marte" -> Luna
nombre_de_nucleo(d(_), '_pronombre').    % "el de los sistemas..."
nombre_de_nucleo(pron(pron(P)), P).      % "ella"
nombre_de_nucleo(cuant(_, _), '_cuantificador').

% nucleo_verbo(+GV, -Palabra)
% Devuelve la forma verbal nuclear (la que indica la accion principal).
% Si el nucleo es un auxiliar y existe un gerundio complementario, devolvemos
% el gerundio (es lo que aporta el significado: "esta abriendo" -> abriendo).
nucleo_verbo(gv(Lista), V) :- verbo_significativo(Lista, V).
nucleo_verbo(gv([adv(_)|Resto]), V) :- verbo_significativo(Resto, V).

% Recorre la lista de hijos del GV buscando primero un gerundio (mas
% significativo que el auxiliar) y, si no hay, devolviendo el verbo principal.
verbo_significativo(Lista, V) :-
    member(ger(gerc([vger(V)|_])), Lista), !.
verbo_significativo([Nucleo|_], V) :-
    verbo_de_nucleo(Nucleo, V).

verbo_de_nucleo(v(v(V)), V).
verbo_de_nucleo(v(v(_), v(V)), V).        % "ha integrado" -> integrado
verbo_de_nucleo(v(v(_), v(_), v(V)), V).
verbo_de_nucleo(vpron(_, v(V)), V).
verbo_de_nucleo(vpron(_, v(_), v(V)), V). % "se ha visto" -> visto
verbo_de_nucleo(vpron(_, v(_), v(_), v(V)), V). % "se estan disparando" -> disparando

% ============================================================
% MOTOR DE INCOHERENCIAS Y METAFORAS
% ============================================================
% clasificar_problema(+Sujeto, +Verbo, -Tipo)
% Tipo puede ser 'metafora' o 'incoherencia'.

% --- METAFORAS ---

% Cosas intangibles (tecnologia, conceptos) que ejecutan acciones de
% armas/fuego: "las aplicaciones se estan disparando"
clasificar_problema(S, V, metafora) :-
    (   tipo(S, tecnologia_intangible)
    ;   tipo(S, producto_software)
    ;   tipo(S, concepto_economico)
    ),
    tipo(V, accion_arma_fuego).

% Cosas intangibles que "abren caminos" o "remodelan" (acciones fisicas
% reservadas a agentes humanos o herramientas).
clasificar_problema(S, V, metafora) :-
    (   tipo(S, tecnologia_intangible)
    ;   tipo(S, producto_software)
    ;   tipo(S, concepto_economico)
    ;   tipo(S, concepto_abstracto)
    ),
    tipo(V, accion_fisica_humana).

% Tecnologia o concepto abstracto que mejora estructuras anatomicas:
% "la IA mejora la columna vertebral de las redes" (oracion 18)
clasificar_problema(S, V, metafora) :-
    (   tipo(S, tecnologia_intangible)
    ;   tipo(S, concepto_abstracto)
    ),
    tipo(V, accion_estructural).

% Sujeto que es una medida fisica usado con verbo de relevancia:
% "cada gota cuenta" (oracion 17)
clasificar_problema(S, V, metafora) :-
    tipo(S, medida_liquido),
    tipo(V, accion_relevancia).

% Tecnologia intangible que sufre una transformacion en objeto fisico:
% "los sistemas (de IA) corren el riesgo de convertirse en cajas negras"
clasificar_problema(S, V, metafora) :-
    (   tipo(S, tecnologia_intangible)
    ;   tipo(S, concepto_abstracto)
    ),
    tipo(V, accion_transformacion).

% Tecnologia intangible que "deja huella" (marca fisica): metafora de oracion 24
clasificar_problema(S, V, metafora) :-
    tipo(S, tecnologia_intangible),
    tipo(V, accion_marca_fisica).

% --- INCOHERENCIAS ---

% Concepto economico/abstracto que realiza una accion humana sensorial:
% "la NSE esta siendo testigo" -> testigo es un rol humano
clasificar_problema(S, V, incoherencia) :-
    (   tipo(S, concepto_economico)
    ;   tipo(S, organizacion)
    ;   tipo(S, entidad_geopolitica)
    ),
    tipo(V, accion_perceptual_humana).