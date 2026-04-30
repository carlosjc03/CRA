% sintactico.pl
% Gramatica de Clausulas Definidas (DCG) para el corpus de Tecnologia Espacial.
%
% Estructura general: cada constituyente devuelve un arbol con un functor
% estable (o, oc, or, ocm, gn, gv, gp, gadj, gadv) y como argumento la lista
% de sub-arboles que lo componen. Asi 'draw' recibe una estructura uniforme
% y la deteccion semantica sabe siempre donde buscar el sujeto y el verbo.
%
% Para que la gramatica acepte oraciones largas con muchos modificadores
% encadenados (gerundios, preposicionales, adjetivos en cadena...) los
% grupos nominal y verbal se construyen en dos partes: un nucleo y una
% cola opcional con cero o mas postmodificadores.

% ============================================================
% NIVEL ORACION
% ============================================================

% Punto de entrada. Probamos primero las construcciones mas grandes y
% bajamos hacia la simple para que el motor no se quede en el primer match.
oracion_dcg(Arbol) --> oracion_compuesta(Arbol).
oracion_dcg(Arbol) --> oracion_coordinada(Arbol).
oracion_dcg(Arbol) --> oracion_simple(Arbol).

% Oracion compuesta (ocm): tres o mas clausulas encadenadas. Para cubrir
% frases largas con varias comas y "y" intermedias.
oracion_compuesta(ocm(O1, Conj, O2, O3)) -->
    clausula(O1), [','],
    clausula(O2),
    conjuncion_coord(Conj),
    clausula(O3).

% Oracion coordinada (oc): clausula + conjuncion + clausula
oracion_coordinada(oc(O1, Conj, O2)) -->
    clausula(O1),
    conjuncion_coord(Conj),
    clausula(O2).

% Una "clausula" es siempre una oracion simple (las relativas se manejan
% dentro del GN, no a este nivel).
clausula(O) --> oracion_simple(O).

% Oracion simple (o): grupo nominal + grupo verbal
oracion_simple(o(GN, GV)) --> grupo_nominal(GN), grupo_verbal(GV).
% Oracion con sujeto eliptico (frecuente en pasivas reflejas y coordinadas):
% "las ponen a disposicion ...", "se ha visto ..."
oracion_simple(o(GV)) --> grupo_verbal(GV).
% Variante con adverbio inicial ("Tradicionalmente, ...", "Ademas, ...")
oracion_simple(o(adv(Adv), GN, GV)) -->
    adverbio_inicial(Adv), opt_coma,
    grupo_nominal(GN), grupo_verbal(GV).
% Variante "En el espacio, cada gota cuenta" (grupo preposicional inicial)
oracion_simple(o(GP, GN, GV)) -->
    grupo_preposicional(GP), [','],
    grupo_nominal(GN), grupo_verbal(GV).
% Variante sin coma: "en las ultimas decadas se ha visto un cambio..."
oracion_simple(o(GP, GN, GV)) -->
    grupo_preposicional(GP),
    grupo_nominal(GN), grupo_verbal(GV).
% Variante con sujeto eliptico tras GP: "en las ultimas decadas se ha visto..."
oracion_simple(o(GP, GV)) -->
    grupo_preposicional(GP),
    grupo_verbal(GV).

% Coma opcional (la usamos despues de adverbios iniciales)
opt_coma --> [','].
opt_coma --> [].

% ============================================================
% GRUPO NOMINAL
% ============================================================
% Un GN se construye como [nucleo | postmodificadores].
% El nucleo puede ser un nombre solo, det+nombre, o nombre propio compuesto.
% Los postmodificadores son una lista de adjetivos, gp, relativos o
% aposiciones, en cualquier orden y numero.

grupo_nominal(gn([Nucleo|Mods])) -->
    gn_nucleo(Nucleo),
    gn_postmods(Mods).

% Nucleos posibles
gn_nucleo(np(N1,N2)) --> nombre(N1), nombre(N2).            % "Planet Labs", "Blue Origin"
gn_nucleo(ddn(D1,D2,N)) --> determinante(D1), determinante(D2), nombre(N). % "todos los usuarios"
gn_nucleo(dn(D,N))   --> determinante(D), nombre(N).        % "el competidor"
gn_nucleo(dpn(D,Adj,N)) --> determinante(D), pre_adjetivo(Adj), nombre(N). % "el primer enfoque"
gn_nucleo(dpn(D,Adj,N)) --> determinante(D), adjetivo(Adj), nombre(N).     % "la nueva economia"
gn_nucleo(an(Adj,N)) --> adjetivo(Adj), nombre(N).          % "diversos aspectos", "pequenos satelites"
gn_nucleo(an(Pre,N)) --> pre_adjetivo(Pre), nombre(N).       % "nuevos caminos"
gn_nucleo(coord(N1,Conj,N2)) -->                              % "Luna y Marte"
    nombre(N1), conjuncion_coord(Conj), nombre(N2).
gn_nucleo(d(D))      --> determinante(D).                     % "el de los sistemas..." (pronombre)
gn_nucleo(cuant(Adv,GP)) --> adverbio(Adv), grupo_preposicional(GP). % "mas de cincuenta anos"
gn_nucleo(n(N))      --> nombre(N).                           % "Marte", "comercializacion"
gn_nucleo(pron(P))   --> pronombre_personal(P).               % "ella"

% Cadena de postmodificadores (cero o mas)
gn_postmods([M|Resto]) --> gn_postmod(M), gn_postmods(Resto).
gn_postmods([]) --> [].

% Tipos de postmodificador
gn_postmod(GAdj)            --> grupo_adjetival(GAdj).
gn_postmod(GP)              --> grupo_preposicional(GP).
gn_postmod(rel(Rel))        --> clausula_relativo(Rel).
gn_postmod(apos(Apos))      --> [','], aposicion(Apos).
gn_postmod(apos(Apos))      --> aposicion_sin_coma(Apos).
gn_postmod(como(Conj,GN))   --> conjuncion_subord(Conj), grupo_nominal(GN). % "como disciplina"
gn_postmod(coord_n(Conj,N)) --> conjuncion_coord(Conj), gn_nucleo(N).
gn_postmod(coord_adj(Conj,GAdj)) -->
    conjuncion_coord(Conj), grupo_adjetival(GAdj).

% Aposicion explicativa: "tambien conocida como Espacio 4.0"
aposicion(ap(Adv, Adj, Conj, GN)) -->
    adverbio(Adv), adjetivo(Adj), conjuncion_subord(Conj), grupo_nominal(GN).
aposicion(ap(Adj, Conj, GN)) -->
    adjetivo(Adj), conjuncion_subord(Conj), grupo_nominal(GN).
aposicion(ap(GP)) --> grupo_preposicional(GP).
aposicion(ap(GAdj)) --> grupo_adjetival(GAdj).
aposicion(ap(GN)) --> grupo_nominal(GN).

% Aposicion sin coma — exigimos un marcador (adverbio+adjetivo o adjetivo+conj)
% para no comernos cualquier cosa.
aposicion_sin_coma(ap(Adv, Adj, Conj, GN)) -->
    adverbio(Adv), adjetivo(Adj), conjuncion_subord(Conj), grupo_nominal(GN).

% Clausula de relativo: "que invierten en programas espaciales",
% "que les permiten realizar...", "lo que les permite tomar..."
clausula_relativo(or(que, GV))     --> [que], grupo_verbal(GV).
clausula_relativo(or(lo_que, GV))  --> [lo,que], grupo_verbal(GV).
clausula_relativo(or(que, Pron, GV)) -->                       % "que les permite ..."
    [que], pronombre_clitico(Pron), grupo_verbal(GV).

% ============================================================
% GRUPO VERBAL
% ============================================================
grupo_verbal(gv([Adv,Nucleo|Comps])) -->                       % "no es nueva"
    adverbio(Adv), gv_nucleo(Nucleo), gv_comps(Comps).
grupo_verbal(gv([Nucleo|Comps])) -->
    gv_nucleo(Nucleo),
    gv_comps(Comps).

% Nucleos verbales: simples, perifrasis, con pronombre proclitico, etc.
gv_nucleo(v(V))               --> verbo(V).
gv_nucleo(v(V1,V2))           --> verbo(V1), verbo(V2).            % "ha integrado", "ha visto"
gv_nucleo(v(V1,V2,V3))        --> verbo(V1), verbo(V2), verbo(V3). % "esta siendo testigo"
gv_nucleo(vpron(Pron,V))      --> pronombre_clitico(Pron), verbo(V). % "se especializa"
gv_nucleo(vpron(Pron,V1,V2))  -->                                  % "se ha visto", "se ha desarrollado"
    pronombre_clitico(Pron), verbo(V1), verbo(V2).
gv_nucleo(vpron(Pron,V1,V2,V3)) -->                                % "se estan expandiendo"
    pronombre_clitico(Pron), verbo(V1), verbo(V2), verbo(V3).

% Cadena de complementos del verbo
gv_comps([C|R]) --> gv_comp(C), gv_comps(R).
gv_comps([]) --> [].

% Tipos de complemento verbal
gv_comp(GN)                  --> grupo_nominal(GN).
gv_comp(GP)                  --> grupo_preposicional(GP).
gv_comp(GAdj)                --> grupo_adjetival(GAdj).
gv_comp(GAdv)                --> grupo_adverbial(GAdv).
gv_comp(coord_adj(C,GAdj))   --> conjuncion_coord(C), grupo_adjetival(GAdj).
gv_comp(ger(Ger))            --> [','], gerundio_clausula(Ger).
gv_comp(ger(Ger))            --> gerundio_clausula(Ger).
gv_comp(coord_ger(C,Ger))    --> conjuncion_coord(C), gerundio_clausula(Ger).
gv_comp(coord_ger(C,Ger))    --> [','], conjuncion_coord(C), gerundio_clausula(Ger).
gv_comp(subord(Conj,O))      --> conjuncion_subord(Conj), oracion_simple(O).
gv_comp(subord(Conj,O))      --> conjuncion_subord(Conj), oracion_coordinada(O).
gv_comp(coord_v(Conj,V))     --> conjuncion_coord(Conj), verbo(V).
gv_comp(inc(GN))             --> [','], [incluidas], grupo_nominal(GN).
gv_comp(inc(GN))             --> [','], [incluida],  grupo_nominal(GN).
gv_comp(inc(GN))             --> [','], [incluidos], grupo_nominal(GN).
gv_comp(inc(GN))             --> [','], [incluido],  grupo_nominal(GN).
% "incluidas X Y Z y mas" sin comas (oracion 30) — enumeracion asindeta
gv_comp(inc(Lista))          --> [incluidas], enum_gn(Lista).
gv_comp(inc(Lista))          --> [incluidos], enum_gn(Lista).
gv_comp(inc(Lista))          --> [incluida],  enum_gn(Lista).
gv_comp(inc(Lista))          --> [incluido],  enum_gn(Lista).
gv_comp(coma_extra)          --> [','].

% Enumeracion de GNs sin separadores: GN1 GN2 ... y GNn (o terminada en "y mas")
enum_gn([GN1,coord(C,Adv)])     --> grupo_nominal(GN1), conjuncion_coord(C), adverbio(Adv). % "... y mas"
enum_gn([GN1,coord(C,GN2)])     --> grupo_nominal(GN1), conjuncion_coord(C), grupo_nominal(GN2).
enum_gn([GN|Resto])             --> grupo_nominal(GN), enum_gn(Resto).
enum_gn([GN])                   --> grupo_nominal(GN).

% Una clausula de gerundio: gerundio + complementos
gerundio_clausula(gerc([V|C])) --> verbo_gerundio(V), gv_comps(C).

% ============================================================
% GRUPO PREPOSICIONAL
% ============================================================
grupo_preposicional(gp(P,GN))     --> preposicion(P), grupo_nominal(GN).
grupo_preposicional(gp(Adv,P,GN)) --> adverbio(Adv), preposicion(P), grupo_nominal(GN).
grupo_preposicional(gp(P,Inf))    --> preposicion(P), infinitivo_clausula(Inf).

infinitivo_clausula(infc([V|C])) --> verbo(V), gv_comps(C).

% ============================================================
% GRUPO ADJETIVAL
% ============================================================
grupo_adjetival(gadj([Adv,A|Rest])) --> adverbio(Adv), adjetivo(A), gadj_resto(Rest). % "algo directo", "muy altos"
grupo_adjetival(gadj([A|Rest])) --> adjetivo(A), gadj_resto(Rest).

gadj_resto([A|R])           --> adjetivo(A), gadj_resto(R).
gadj_resto([coord(C,A)|R])  --> conjuncion_coord(C), adjetivo(A), gadj_resto(R).
gadj_resto([coma_adj(A)|R]) --> [','], adjetivo(A), gadj_resto(R).
gadj_resto([gp(GP)|R])      --> grupo_preposicional(GP), gadj_resto(R).
gadj_resto([])              --> [].

% ============================================================
% GRUPO ADVERBIAL
% ============================================================
grupo_adverbial(gadv([A|R])) --> adverbio(A), gadv_resto(R).
gadv_resto([A|R])      --> adverbio(A), gadv_resto(R).
gadv_resto([gp(GP)|R]) --> grupo_preposicional(GP), gadv_resto(R).
gadv_resto([])         --> [].

% ============================================================
% LEXICO
% ============================================================

% --- Determinantes
determinante(det(D)) --> [D], { es_det(D) }.
es_det(el). es_det(la). es_det(los). es_det(las). es_det(lo).
es_det(un). es_det(una).
es_det(esta). es_det(estos). es_det(estas). es_det(este).
es_det(su). es_det(sus). es_det(cada). es_det(todos). es_det(todo).
es_det(cincuenta). es_det('5'). es_det('20'). es_det('4.0').
es_det(5). es_det(20).

% --- Pronombres
pronombre_clitico(pron(P)) --> [P], { es_pron_clit(P) }.
es_pron_clit(se). es_pron_clit(les). es_pron_clit(las). es_pron_clit(le).
es_pron_clit(lo).

pronombre_personal(pron(P)) --> [P], { es_pron_pers(P) }.
es_pron_pers(ella).

% --- Adjetivos pre-nominales (van delante del nombre)
pre_adjetivo(adj(A)) --> [A], { es_pre_adj(A) }.
es_pre_adj(primer). es_pre_adj(principal). es_pre_adj(nueva). es_pre_adj(nuevo).
es_pre_adj(nuevos). es_pre_adj(nuevas). es_pre_adj(mayor).

% --- Adverbios
adverbio(adv(A)) --> [A], { es_adv(A) }.
es_adv(algo). es_adv(perfectamente). es_adv(tambien). es_adv(tradicionalmente).
es_adv(potencialmente). es_adv(exponencialmente). es_adv(no). es_adv(mas).
es_adv(ahora). es_adv(ademas). es_adv(muy). es_adv(eficazmente). es_adv(ya).
es_adv(dentro). es_adv(largo). es_adv(siempre).

adverbio_inicial(adv(A)) --> [A], { es_adv_ini(A) }.
es_adv_ini(tradicionalmente). es_adv_ini(ademas). es_adv_ini(tambien).
es_adv_ini(ahora). es_adv_ini(siempre).

% --- Preposiciones
preposicion(prep(P)) --> [P], { es_prep(P) }.
es_prep(de). es_prep(en). es_prep(a). es_prep(con). es_prep(para).
es_prep(sobre). es_prep(entre). es_prep(hacia). es_prep(sin). es_prep(del).
es_prep(al). es_prep(por). es_prep(desde).

% --- Conjunciones
conjuncion(conj(C)) --> [C], { es_conj(C) }.
es_conj(y). es_conj(pero). es_conj(que). es_conj(como). es_conj(o). es_conj(mientras).

conjuncion_coord(conj(C)) --> [C], { es_conj_coord(C) }.
es_conj_coord(y). es_conj_coord(pero). es_conj_coord(o).

conjuncion_subord(conj(C)) --> [C], { es_conj_subord(C) }.
es_conj_subord(que). es_conj_subord(como). es_conj_subord(mientras).
es_conj_subord(porque).

% --- Verbos (incluye auxiliares y formas compuestas)
verbo(v(V)) --> [V], { es_verbo(V) }.
es_verbo(es). es_verbo(son). es_verbo(era). es_verbo(fue). es_verbo(han).
es_verbo(ha). es_verbo(esta). es_verbo(estan). es_verbo(esten). es_verbo(siendo).
es_verbo(integrado). es_verbo(convirtiendose). es_verbo(hace). es_verbo(significa).
es_verbo(visto). es_verbo(especializa). es_verbo(obtener). es_verbo(capturan).
es_verbo(ponen). es_verbo(pagando). es_verbo(invierten). es_verbo(representa).
es_verbo(expandiendo). es_verbo(abriendo). es_verbo(acelerando). es_verbo(mejorando).
es_verbo(utiliza). es_verbo(utilizan). es_verbo(analizar). es_verbo(aprender).
es_verbo(desarrollado). es_verbo(revolucionado). es_verbo(haciendolas).
es_verbo(equipados). es_verbo(permiten). es_verbo(permite). es_verbo(realizar).
es_verbo(realicen). es_verbo(tomen). es_verbo(tomar). es_verbo(cuenta).
es_verbo(mejora). es_verbo(requiere). es_verbo(tarda). es_verbo(recorrer).
es_verbo(dependiendo). es_verbo(aplica). es_verbo(figuraba). es_verbo(corren).
es_verbo(convertirse). es_verbo(disparando). es_verbo(dejado).
es_verbo(conocida).

% Verbos en gerundio (los que abren clausulas subordinadas de gerundio)
verbo_gerundio(vger(V)) --> [V], { es_gerundio(V) }.
es_gerundio(convirtiendose). es_gerundio(acelerando). es_gerundio(mejorando).
es_gerundio(pagando). es_gerundio(haciendolas). es_gerundio(dependiendo).
es_gerundio(abriendo). es_gerundio(expandiendo).

% --- Adjetivos
adjetivo(adj(A)) --> [A], { es_adj(A) }.
es_adj(directo). es_adj(diversos). es_adj(diversas). es_adj(espaciales).
es_adj(espacial). es_adj(nueva). es_adj(nuevo). es_adj(nuevos). es_adj(nuevas).
es_adj(conocida). es_adj(artificial). es_adj(explicable). es_adj(exclusivo).
es_adj(gubernamentales). es_adj(ultimas). es_adj(mayor). es_adj(pequenos).
es_adj(alta). es_adj(potenciales). es_adj(global). es_adj(record).
es_adj(comerciales). es_adj(incipiente). es_adj(lucrativo). es_adj(economicas).
es_adj(primer). es_adj(basados). es_adj(neuronales). es_adj(multiples).
es_adj(profundas). es_adj(satelitales). es_adj(agiles). es_adj(adaptables).
es_adj(resilientes). es_adj(minima). es_adj(humana). es_adj(vertebral).
es_adj(altos). es_adj(rutinarias). es_adj(constante). es_adj(principales).
es_adj(eficiente). es_adj(empresarial). es_adj(competitivo). es_adj(adecuado).
es_adj(debatidos). es_adj(principal). es_adj(negras). es_adj(incluidas).
es_adj(incluida). es_adj(incluidos). es_adj(incluido). es_adj(medica).

% --- Nombres (sustantivos del corpus)
nombre(n(N)) --> [N], { es_nombre(N) }.
es_nombre(competidor). es_nombre(spacex). es_nombre(blue). es_nombre(origin).
es_nombre(tecnologia). es_nombre(aspectos). es_nombre(actividades).
es_nombre(catalizador). es_nombre(cambios). es_nombre(precedentes).
es_nombre(economia). es_nombre(espacio). es_nombre('4.0').
es_nombre(termino). es_nombre(referencia). es_nombre(comercializacion).
es_nombre(democratizacion). es_nombre(exploracion). es_nombre(xai).
es_nombre(inteligencia). es_nombre(dominio). es_nombre(agencias).
es_nombre(decadas). es_nombre(cambio). es_nombre(planet). es_nombre(labs).
es_nombre(imagenes). es_nombre(tierra). es_nombre(traves). es_nombre(flota).
es_nombre(satelites). es_nombre(cubesats). es_nombre(resolucion).
es_nombre(superficie). es_nombre(disposicion). es_nombre(usuarios).
es_nombre(tarifa). es_nombre(nse). es_nombre(testigo). es_nombre(expansion).
es_nombre(numero). es_nombre(paises). es_nombre(actores). es_nombre(programas).
es_nombre(turismo). es_nombre(mercado). es_nombre(oportunidades).
es_nombre(union). es_nombre(caminos). es_nombre(innovacion). es_nombre(eficiencia).
es_nombre(misiones). es_nombre(enfoque). es_nombre(ia). es_nombre(sistemas).
es_nombre(reglas). es_nombre(dl). es_nombre(redes). es_nombre(capas).
es_nombre(datos). es_nombre(disciplina). es_nombre(investigacion).
es_nombre(anos). es_nombre(operaciones). es_nombre(algoritmos).
es_nombre(multitud). es_nombre(tareas). es_nombre(intervencion).
es_nombre(gota). es_nombre(combustible). es_nombre(columna).
es_nombre(comunicaciones). es_nombre(niveles). es_nombre(autonomia).
es_nombre(automatizacion). es_nombre(senal). es_nombre(radio).
es_nombre(minutos). es_nombre(distancia). es_nombre(marte).
es_nombre(posiciones). es_nombre(planetas). es_nombre(naves).
es_nombre(decisiones). es_nombre(comunicacion). es_nombre(robots).
es_nombre(analisis). es_nombre(terreno). es_nombre(reconocimiento).
es_nombre(objetos). es_nombre(navegacion). es_nombre(funcion).
es_nombre(entorno). es_nombre(luna). es_nombre(abundancia). es_nombre(recursos).
es_nombre(objetivos). es_nombre(isru). es_nombre(huella). es_nombre(ambito).
es_nombre(uso). es_nombre(sostenibilidad). es_nombre(procesamiento).
es_nombre(tecnicas). es_nombre(extraccion). es_nombre(informacion).
es_nombre(productos). es_nombre(momento). es_nombre(evolucion).
es_nombre(subsistemas). es_nombre(bordo). es_nombre(objeto).
es_nombre(convergencia). es_nombre(defensa). es_nombre(temas).
es_nombre(mundo). es_nombre(problema). es_nombre(riesgo). es_nombre(cajas).
es_nombre(aplicaciones). es_nombre(industrias). es_nombre(atencion).
es_nombre(finanzas). es_nombre(educacion). es_nombre(seguridad).
es_nombre(manufactura).

% ============================================================
% SIMPLIFICACION DE ORACIONES COMPUESTAS
% ============================================================
% Descompone una oracion compuesta o coordinada en una lista de
% oraciones simples equivalentes.

% Compuesta de tres clausulas
simplificar(ocm(O1,_,O2,O3), Lista) :-
    simplificar(O1, L1), simplificar(O2, L2), simplificar(O3, L3),
    append(L1, L2, L12), append(L12, L3, Lista).

% Coordinada
simplificar(oc(O1,_,O2), Lista) :-
    simplificar(O1, L1), simplificar(O2, L2),
    append(L1, L2, Lista).

% Oracion simple con relativo en el GN: si encontramos un postmod tipo
% rel(or(que,GV_rel)), separamos en dos oraciones.
simplificar(o(GN, GV), [o(GN_lim, GV_rel), o(GN_lim, GV)]) :-
    extraer_relativo(GN, GN_lim, GV_rel), !.

% Oracion simple con adverbio o GP inicial — la dejamos atomica
simplificar(o(_, GN, GV), [o(GN, GV)]).

% Oracion simple ya atomica
simplificar(o(GN, GV), [o(GN, GV)]).
simplificar(o(GV), [o(GV)]).

% Helper: si el GN tiene una clausula de relativo, la separa.
extraer_relativo(gn(Lista), gn(SinRel), GV_rel) :-
    select(rel(or(_, GV_rel)), Lista, SinRel).
extraer_relativo(gn(Lista), gn(SinRel), GV_rel) :-
    select(rel(or(_, _, GV_rel)), Lista, SinRel).
