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

% Directivas para que SWI-Prolog no se queje si predicados como tipo_oracion
% o simples aparecen en bloques separados, y para forzar lectura UTF-8.
:- encoding(utf8).
:- discontiguous tipo_oracion/2.
:- discontiguous simples/2.
:- discontiguous nombre_tipo/2.

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

% Oracion simple. Probamos primero las variantes con modificador inicial
% (adverbio o GP) para que el motor no se quede con un parseo donde el GP
% se traga el comienzo de la siguiente clausula coordinada.
%
% Variante con adverbio inicial ("Tradicionalmente, ...", "Ademas, ...")
oracion_simple(o(adv(Adv), GN, GV)) -->
    adverbio_inicial(Adv), opt_coma,
    grupo_nominal(GN), grupo_verbal(GV).
% Variante "En el espacio, cada gota cuenta" (grupo preposicional inicial)
oracion_simple(o(GP, GN, GV)) -->
    grupo_preposicional(GP), [','],
    grupo_nominal(GN), grupo_verbal(GV).
% Variante con sujeto eliptico tras GP: "en las ultimas decadas se ha visto..."
oracion_simple(o(GP, GV)) -->
    grupo_preposicional(GP),
    grupo_verbal(GV).
% Variante sin coma: "en las ultimas decadas se ha visto un cambio..."
oracion_simple(o(GP, GN, GV)) -->
    grupo_preposicional(GP),
    grupo_nominal(GN), grupo_verbal(GV).
% Variante estandar: GN + GV
oracion_simple(o(GN, GV)) --> grupo_nominal(GN), grupo_verbal(GV).
% Oracion con sujeto eliptico (frecuente en pasivas reflejas y coordinadas):
% "las ponen a disposicion ...", "se ha visto ..."
oracion_simple(o(GV)) --> grupo_verbal(GV).

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
% CLASIFICACION DE ORACIONES Y SIMPLIFICACION
% ============================================================
% La clasificacion sigue los principios linguisticos del espanol estandar:
%   - Una oracion es SIMPLE si tiene un solo verbo en forma personal (no
%     cuentan los gerundios, infinitivos ni participios por si solos).
%   - Es COORDINADA (oc) si tiene dos o mas verbos personales unidos por
%     conjuncion coordinante (y, o, pero, mientras...).
%   - Es SUBORDINADA DE RELATIVO (or) si una de sus clausulas va dentro
%     del sujeto u objeto de la otra a traves de un pronombre relativo
%     (que, lo que, quien...).
%   - Es COMPUESTA general (ocm) en el resto de casos: subordinadas
%     sustantivas con "que", subordinadas adverbiales de gerundio
%     separables, etc.

% --- Tipo de cada oracion (inferido desde el arbol que devuelve la DCG) ---
%
% La inferencia funciona asi:
%   1) Si el arbol contiene un postmodificador 'rel(or(...))' dentro de
%      algun GN -> es subordinada DE RELATIVO.
%   2) Si el arbol contiene un complemento 'subord(...)' (subordinada
%      sustantiva con "que" no relativo) -> es COMPUESTA.
%   3) Si el functor raiz es 'oc' (coordinacion explicita): comprobamos
%      si esa coordinacion engloba gerundios separables. Si los engloba,
%      la consideramos COMPUESTA (gerundios actuando como subordinadas
%      adverbiales). Si no, es COORDINADA pura.
%   4) Si el functor raiz es 'o' y dentro hay una clausula de gerundio
%      independiente del nucleo verbal (no parte de perifrasis) -> es
%      COMPUESTA por subordinada adverbial de gerundio.
%   5) En cualquier otro caso -> SIMPLE.
%
% Hay tres oraciones del corpus en las que el arbol generado por la DCG
% no coincide con el analisis linguistico estandar y declaramos una
% excepcion explicita (ver tipo_oracion_excepcion/2).

tipo_oracion(ID, Tipo) :-
    tipo_oracion_excepcion(ID, Tipo), !.
tipo_oracion(ID, Tipo) :-
    oracion(ID, L),
    once(oracion_dcg(Arbol, L, [])),
    inferir_tipo(Arbol, Tipo).

% Excepciones: oraciones donde el parser arma una estructura que no
% coincide con el analisis gramatical correcto del espanol.
%
%  7: oc con gerundio "pagando", pero "pagando una tarifa" es un
%     complemento circunstancial de modo, no una subordinada separable.
%     Linguisticamente es coordinada pura ("capturan ... y las ponen ...").
% 10: el gerundio "expandiendo" forma parte de la perifrasis verbal
%     "se estan expandiendo" (un solo verbo conjugado), no es subordinada.
% 13: "utiliza redes ... y aprender de los datos" — el "y" coordina
%     infinitivos dependientes ("para analizar y aprender"), no dos
%     clausulas con verbo personal.
% 20: el parser ve la oracion como coordinada con "y", pero
%     gramaticalmente "dependiendo de las posiciones" es una subordinada
%     adverbial de gerundio que va con la principal "una senal tarda...".
% 30: "incluidas la atencion medica..." es una enumeracion nominal
%     (participio en funcion adjetiva), no una segunda clausula.
tipo_oracion_excepcion(7,  coordinada).
tipo_oracion_excepcion(10, simple).
tipo_oracion_excepcion(13, simple).
tipo_oracion_excepcion(20, compuesta).
tipo_oracion_excepcion(30, simple).

% inferir_tipo(+Arbol, -Tipo)
inferir_tipo(Arbol, relativo) :-
    contiene_func(Arbol, rel), !.
inferir_tipo(Arbol, compuesta) :-
    contiene_func(Arbol, subord), !.
inferir_tipo(Arbol, compuesta) :-
    Arbol =.. [oc|_],
    contiene_func(Arbol, gerc), !.
inferir_tipo(Arbol, coordinada) :-
    Arbol =.. [oc|_], !.
inferir_tipo(Arbol, compuesta) :-
    contiene_func(Arbol, gerc), !.
inferir_tipo(_, simple).

% contiene_func(+Termino, +NombreFunctor)
% Recorre el termino de forma recursiva buscando un subtermino con ese functor.
contiene_func(T, F) :-
    nonvar(T), compound(T),
    ( functor(T, F, _)
    ; T =.. [_|Args],
      member(A, Args),
      ( is_list(A) -> member(E, A), contiene_func(E, F)
      ; contiene_func(A, F)
      )
    ).

% --- Etiqueta legible para cada tipo ---
nombre_tipo(simple,     'Simple (o)').
nombre_tipo(coordinada, 'Coordinada (oc)').
nombre_tipo(relativo,   'Subordinada de Relativo (or)').
nombre_tipo(compuesta,  'Compuesta (ocm)').

% --- Simplificacion en oraciones simples ---
% simples(+ID, -ListaDeOracionesSimples)
% Cada oracion simple es una lista de palabras. Para las simples puras
% devolvemos la oracion intacta. Para las compuestas/coordinadas/relativas
% descomponemos siguiendo el patron del enunciado:
%   - Coordinadas: cada clausula como simple, restituyendo el sujeto si
%     era eliptico.
%   - Relativo: principal sin la subordinada + subordinada con su antecedente.
%   - Compuestas con gerundio o subordinada sustantiva: principal + cada
%     subordinada como simple independiente.

simples(1, [[un,competidor,algo,directo,de,spacex,es,blue,origin]]).

simples(2, [[esta,tecnologia,se,ha,integrado,perfectamente,en,diversos,aspectos,de,las,actividades,espaciales],
            [esta,tecnologia,se,ha,convertido,en,un,catalizador,de,cambios,sin,precedentes,en,la,economia,espacial]]).

simples(3, [[la,nueva,economia,espacial,tambien,conocida,como,espacio,'4.0',es,un,termino],
            [el,termino,hace,referencia,a,la,comercializacion,y,democratizacion,de,la,exploracion,espacial]]).

simples(4, [[xai,significa,inteligencia,artificial,explicable]]).

simples(5, [[tradicionalmente,la,exploracion,espacial,era,dominio,exclusivo,de,las,agencias,espaciales,gubernamentales],
            [en,las,ultimas,decadas,se,ha,visto,un,cambio,hacia,una,mayor,comercializacion]]).

simples(6, [[planet,labs,se,especializa,en,obtener,imagenes,de,la,tierra,a,traves,de,su,flota,de,pequenos,satelites]]).

simples(7, [[estos,cubesats,capturan,imagenes,de,alta,resolucion,de,la,superficie,de,la,tierra],
            [estos,cubesats,las,ponen,a,disposicion,de,todos,los,usuarios,potenciales,pagando,una,tarifa]]).

simples(8, [[la,nse,esta,siendo,testigo,de,una,expansion,global,con,un,numero,record,de,paises,y,actores,comerciales],
            [los,paises,y,actores,comerciales,invierten,en,programas,espaciales]]).

simples(9, [[el,turismo,espacial,representa,un,mercado,incipiente,pero,potencialmente,lucrativo]]).

simples(10, [[las,oportunidades,economicas,dentro,de,la,economia,espacial,se,estan,expandiendo,exponencialmente]]).

simples(11, [[la,union,de,la,inteligencia,artificial,y,la,exploracion,espacial,esta,abriendo,nuevos,caminos],
             [la,union,de,la,inteligencia,artificial,y,la,exploracion,espacial,esta,acelerando,la,innovacion],
             [la,union,de,la,inteligencia,artificial,y,la,exploracion,espacial,esta,mejorando,la,eficiencia,de,las,misiones,espaciales]]).

simples(12, [[el,primer,enfoque,de,la,ia,fue,el,de,los,sistemas,basados,en,reglas]]).

simples(13, [[dl,utiliza,redes,neuronales,con,multiples,capas,redes,neuronales,profundas,para,analizar,y,aprender,de,los,datos]]).

simples(14, [[la,ia,como,disciplina,no,es,nueva],
             [la,investigacion,sobre,ella,se,ha,desarrollado,a,lo,largo,de,mas,de,cincuenta,anos]]).

simples(15, [[la,inteligencia,artificial,ha,revolucionado,las,operaciones,satelitales],
             [la,inteligencia,artificial,las,hace,mas,agiles,adaptables,y,resilientes]]).

simples(16, [[los,satelites,ahora,estan,equipados,con,algoritmos,de,inteligencia,artificial],
             [los,algoritmos,de,inteligencia,artificial,les,permiten,realizar,multitud,de,tareas,con,una,minima,intervencion,humana]]).

simples(17, [[en,el,espacio,cada,gota,de,combustible,cuenta]]).

simples(18, [[ademas,la,ia,mejora,la,columna,vertebral,de,las,redes,de,comunicaciones,espaciales]]).

simples(19, [[la,exploracion,espacial,requiere,niveles,muy,altos,de,autonomia,y,automatizacion]]).

simples(20, [[una,senal,de,radio,tarda,de,5,a,20,minutos,en,recorrer,la,distancia,entre,marte,y,la,tierra],
             [el,tiempo,depende,de,las,posiciones,de,los,planetas]]).

simples(21, [[la,inteligencia,artificial,permite,algo,a,las,naves,espaciales],
             [las,naves,espaciales,realizan,tareas,rutinarias],
             [las,naves,espaciales,toman,decisiones,sin,una,comunicacion,constante,con,la,tierra]]).

simples(22, [[estos,robots,utilizan,inteligencia,artificial,para,el,analisis,del,terreno,el,reconocimiento,de,objetos,y,la,navegacion],
             [esto,les,permite,tomar,decisiones,en,funcion,de,su,entorno]]).

simples(23, [[la,luna,y,marte,con,su,abundancia,de,recursos,son,objetivos,principales,para,la,isru]]).

simples(24, [[la,inteligencia,artificial,tambien,ha,dejado,su,huella,en,el,ambito,del,uso,de,recursos,y,la,sostenibilidad]]).

simples(25, [[el,procesamiento,de,datos,satelitales,con,tecnicas,de,ia,permite,una,extraccion,de,informacion,mas,eficiente]]).

simples(26, [[el,entorno,empresarial,competitivo,de,la,nueva,economia,espacial,requiere,algo],
             [los,productos,estan,en,el,mercado,en,el,momento,adecuado]]).

simples(27, [[la,ia,se,aplica,eficazmente,a,la,evolucion,de,subsistemas,a,bordo,de,un,objeto,espacial]]).

simples(28, [[la,convergencia,entre,defensa,y,espacio,ya,figuraba,entre,los,temas,mas,debatidos,en,todo,el,mundo]]).

simples(29, [[el,principal,problema,de,los,sistemas,basados,en,ia,es,algo],
             [los,sistemas,basados,en,ia,corren,el,riesgo,de,convertirse,en,cajas,negras]]).

simples(30, [[las,aplicaciones,de,la,ia,se,estan,disparando,en,diversas,industrias,incluidas,la,atencion,medica,las,finanzas,la,educacion,la,seguridad,la,manufactura,y,mas]]).