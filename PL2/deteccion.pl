% deteccion.pl

% Recopila todos los problemas, borra duplicados y los imprime
analizar_problemas(ListaPalabras, ListaSimples) :-
    % 1. Busca ambigüedades (eliminando repetidos con 'sort')
    findall(Palabra, (member(Palabra, ListaPalabras), ambigua(Palabra)), AmbigsBrutas),
    sort(AmbigsBrutas, Ambigs), 
    
    % 2. Busca metáforas extrayendo sujeto y verbo de los árboles
    findall(met(S,V), (member(Arbol, ListaSimples), extraer_sujeto_verbo(Arbol, S, V), metaphora(S,V)), MetasBrutas),
    sort(MetasBrutas, Metas),
    
    % 3. Imprime resultados
    imprimir_problemas(Ambigs, Metas).

% Si ambas listas están vacías, la oración es perfecta
imprimir_problemas([], []) :-
    write('  -> Oración Correcta. Sin problemas aparentes.'), nl.
    
% Si hay algo, lo imprime
imprimir_problemas(Ambigs, Metas) :-
    imprimir_ambig(Ambigs),
    imprimir_metas(Metas).

imprimir_ambig([]).
imprimir_ambig([P|Resto]) :-
    format('  -> [ADVERTENCIA] Ambigüedad léxica detectada en la palabra: "~w".~n', [P]),
    imprimir_ambig(Resto).

imprimir_metas([]).
imprimir_metas([met(S,V)|Resto]) :-
    format('  -> [ADVERTENCIA] Uso no literal detectado: El sujeto "~w" no puede realizar la acción de "~w".~n', [S, V]),
    imprimir_metas(Resto).

% --- REGLAS LÓGICAS BASE ---

% El operador @< fuerza a que Tipo1 vaya antes alfabéticamente que Tipo2.
% Así Prolog no hace el chequeo inverso y evitamos que salga dos veces.
ambigua(Palabra) :-
    tipo(Palabra, Tipo1),
    tipo(Palabra, Tipo2),
    Tipo1 @< Tipo2.

% Extrae el Sujeto (N) y el Verbo (V) de las ramas del árbol (soporta adjetivos y preposiciones)
extraer_sujeto_verbo(o(gn(_, n(S), _), gv(v(V), _)), S, V).
extraer_sujeto_verbo(o(gn(n(S), _), gv(v(V), _)), S, V).
extraer_sujeto_verbo(o(gn(_, n(S)), gv(v(V), _)), S, V).
extraer_sujeto_verbo(o(gn(n(S)), gv(v(V), _)), S, V).
extraer_sujeto_verbo(o(gn(_, n(S)), gv(v(V))), S, V).
% Soporte para los nuevos árboles complejos
extraer_sujeto_verbo(o(gn(_, _, n(S), _, _), gv(v(V), _)), S, V).
extraer_sujeto_verbo(o(gn_coord(_, n(S), _, _, _), gv(v(V), _)), S, V).

metaphora(Sujeto, Verbo) :-
    tipo(Sujeto, tecnologia_intangible),
    (tipo(Verbo, accion_fisica) ; tipo(Verbo, accion_humana)).

