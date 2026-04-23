% sintactico.pl
% Gramática de Cláusulas Definidas (DCG) - Estructura Universal

% --- REGLAS SINTÁCTICAS (DCG) ---

% Punto de entrada general
oracion_dcg(Arbol) --> oracion_coordinada(Arbol).
oracion_dcg(Arbol) --> oracion_simple(Arbol).

% Oración simple (o) [cite: 20]
oracion_simple(o(GN, GV)) --> grupo_nominal(GN), grupo_verbal(GV).

% Oración coordinada (oc) [cite: 21]
oracion_coordinada(oc(O1, Conj, O2)) --> 
    oracion_simple(O1), 
    conjuncion(Conj), 
    oracion_dcg(O2).

% Grupo Nominal (gn) 
grupo_nominal(gn(Det, N, Rel)) --> determinante(Det), nombre(N), clausula_relativo(Rel).
grupo_nominal(gn(Det, N, GP)) --> determinante(Det), nombre(N), grupo_preposicional(GP).
grupo_nominal(gn(Det, N)) --> determinante(Det), nombre(N).
grupo_nominal(gn(N)) --> nombre(N).

% Cláusula de relativo (or) [cite: 22]
clausula_relativo(or(que, GV)) --> [que], grupo_verbal(GV).

% Grupo Preposicional (gp) 
grupo_preposicional(gp(Prep, GN)) --> preposicion(Prep), grupo_nominal(GN).

% Grupo Adjetival (gadj) 
grupo_adjetival(gadj(Adj)) --> adjetivo(Adj).

% Grupo Adverbial (gadv) 
grupo_adverbial(gadv(Adv)) --> adverbio(Adv).

% Grupo Verbal (gv) 
% Opciones: verbo solo, verbo+GN, verbo+GAdj, verbo+GP, verbo+GAdv
grupo_verbal(gv(V, GN)) --> verbo(V), grupo_nominal(GN).
grupo_verbal(gv(V, GAdj)) --> verbo(V), grupo_adjetival(GAdj).
grupo_verbal(gv(V, GP)) --> verbo(V), grupo_preposicional(GP).
grupo_verbal(gv(V, GAdv)) --> verbo(V), grupo_adverbial(GAdv).
grupo_verbal(gv(V)) --> verbo(V).


% --- LÓGICA DE SIMPLIFICACIÓN --- [cite: 43]
simplificar(oc(O1, _Conj, O2), TodasSimples) :-
    simplificar(O1, S1),
    simplificar(O2, S2),
    append(S1, S2, TodasSimples).

simplificar(o(gn(N, or(que, GV_Rel)), GV_Principal), [o(gn(N), GV_Rel), o(gn(N), GV_Principal)]).
simplificar(o(gn(Det, N, or(que, GV_Rel)), GV_Principal), [o(gn(Det, N), GV_Rel), o(gn(Det, N), GV_Principal)]).
simplificar(o(GN, GV), [o(GN, GV)]).


% --- LÉXICO (AÑADIR AQUÍ LAS PALABRAS DE TU CORPUS) ---

% Determinantes (det) [cite: 32]
determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].

% Nombres (n) [cite: 33]
nombre(n(jose)) --> [jose].
nombre(n(maria)) --> [maria].
nombre(n(banco)) --> [banco].
nombre(n(acciones)) --> [acciones].
nombre(n(inflacion)) --> [inflacion].
nombre(n(ahorros)) --> [ahorros].
nombre(n(mercado)) --> [mercado].
nombre(n(bonos)) --> [bonos].

% Verbos (v) [cite: 34]
verbo(v(es)) --> [es].
verbo(v(tiene)) --> [tiene].
verbo(v(estudia)) --> [estudia].
verbo(v(compro)) --> [compro].
verbo(v(come)) --> [come].
verbo(v(vendio)) --> [vendio].
verbo(v(subio)) --> [subio].

% Adjetivos (adj) [cite: 35]
adjetivo(adj(alto)) --> [alto].
adjetivo(adj(morena)) --> [morena].
adjetivo(adj(estable)) --> [estable].

% Adverbios (adv) [cite: 36]
adverbio(adv(rapidamente)) --> [rapidamente].
adverbio(adv(hoy)) --> [hoy].

% Preposiciones (prep) [cite: 38]
preposicion(prep(de)) --> [de].
preposicion(prep(en)) --> [en].
preposicion(prep(con)) --> [con].

% Conjunciones (conj) [cite: 37]
conjuncion(conj(y)) --> [y].
conjuncion(conj(que)) --> [que].
conjuncion(conj(pero)) --> [pero].