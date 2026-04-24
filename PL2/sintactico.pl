% sintactico.pl
% Gramática DCG - Versión Robusta para el Corpus Espacial

% --- REGLAS SINTÁCTICAS ---
oracion_dcg(Arbol) --> oracion_coordinada(Arbol).
oracion_dcg(Arbol) --> oracion_simple(Arbol).

oracion_simple(o(GN, GV)) --> grupo_nominal(GN), grupo_verbal(GV).

oracion_coordinada(oc(O1, Conj, O2)) --> 
    oracion_simple(O1), 
    conjuncion(Conj), 
    oracion_dcg(O2).

% --- Grupo Nominal (gn) ---
% 1. Caso complejo: Det + N + Adv + Adj + GP (Ej: "un competidor algo directo de...")
grupo_nominal(gn(Det, N, GAdv, GAdj, GP)) --> determinante(Det), nombre(N), grupo_adverbial(GAdv), grupo_adjetival(GAdj), grupo_preposicional(GP).
% 2. Caso coordinado: N1 y N2 (Ej: "comercializacion y democratizacion de...")
grupo_nominal(gn_coord(N1, Conj, N2, GP)) --> nombre(N1), conjuncion(Conj), nombre(N2), grupo_preposicional(GP).
% 3. Caso con adjetivo previo: Det + Adj + N + Adj (Ej: "la nueva economia espacial")
grupo_nominal(gn(Det, Adj1, N, Adj2)) --> determinante(Det), adjetivo(Adj1), nombre(N), adjetivo(Adj2).
% 4. Casos estándar con complementos
grupo_nominal(gn(Det, N, Rel)) --> determinante(Det), nombre(N), clausula_relativo(Rel).
grupo_nominal(gn(Det, N, GAdj)) --> determinante(Det), nombre(N), grupo_adjetival(GAdj).
grupo_nominal(gn(Det, N, GP)) --> determinante(Det), nombre(N), grupo_preposicional(GP).
grupo_nominal(gn(Det, N)) --> determinante(Det), nombre(N).
grupo_nominal(gn(N, GAdj)) --> nombre(N), grupo_adjetival(GAdj).
grupo_nominal(gn(N)) --> nombre(N).

%  Det + Nombre + Adjetivo + Grupo Preposicional (ej: "las oportunidades economicas dentro de...")
grupo_nominal(gn(Det, N, GAdj, GP)) --> determinante(Det), nombre(N), grupo_adjetival(GAdj), grupo_preposicional(GP).

% Dos nombres propios seguidos sin determinante (ej: "blue origin" o "planet labs")
grupo_nominal(gn(N1, N2)) --> nombre(N1), nombre(N2).

% --- Complementos y Grupos ---
clausula_relativo(or(que, GV)) --> [que], grupo_verbal(GV).
clausula_relativo(or(lo, que, GV)) --> [lo, que], grupo_verbal(GV).

% Grupo Preposicional recursivo (Soporta: "de la tierra en el espacio")
grupo_preposicional(gp(Prep, GN, GP)) --> preposicion(Prep), grupo_nominal(GN), grupo_preposicional(GP).
grupo_preposicional(gp(Prep, GN)) --> preposicion(Prep), grupo_nominal(GN).
% Adverbio + Preposicion + GN (ej: "dentro de la economia espacial" o "a traves de su flota")
grupo_preposicional(gp(Adv, Prep, GN)) --> adverbio(Adv), preposicion(Prep), grupo_nominal(GN).

% Grupo Adjetival (Soporta: "artificial explicable")
grupo_adjetival(gadj(A1, A2)) --> adjetivo(A1), adjetivo(A2).
grupo_adjetival(gadj(Adj)) --> adjetivo(Adj).

grupo_adverbial(gadv(Adv)) --> adverbio(Adv).

% --- Grupo Verbal (gv) ---
% Añadimos soporte para Verbo + Adverbio (Ej: "se estan expandiendo exponencialmente")
grupo_verbal(gv(Pron, V, GAdv)) --> pronombre(Pron), verbo(V), grupo_adverbial(GAdv).
grupo_verbal(gv(Pron, V, Comp)) --> pronombre(Pron), verbo(V), complemento(Comp).
grupo_verbal(gv(V, GAdv)) --> verbo(V), grupo_adverbial(GAdv).
grupo_verbal(gv(V, Comp)) --> verbo(V), complemento(Comp).
grupo_verbal(gv(V)) --> verbo(V).

complemento(GN) --> grupo_nominal(GN).
complemento(GAdj) --> grupo_adjetival(GAdj).
complemento(GP) --> grupo_preposicional(GP).

% --- LÓGICA DE SIMPLIFICACIÓN ---
simplificar(oc(O1, _Conj, O2), TodasSimples) :-
    simplificar(O1, S1), simplificar(O2, S2), append(S1, S2, TodasSimples).
simplificar(o(gn(N, or(que, GV_Rel)), GV_Principal), [o(gn(N), GV_Rel), o(gn(N), GV_Principal)]).
simplificar(o(gn(Det, N, or(que, GV_Rel)), GV_Principal), [o(gn(Det, N), GV_Rel), o(gn(Det, N), GV_Principal)]).
simplificar(o(GN, GV), [o(GN, GV)]).
% --- LÉXICO (COMPLETO PARA LAS 30 FRASES) ---

% Determinantes
determinante(det(el)) --> [el].
determinante(det(la)) --> [la].
determinante(det(los)) --> [los].
determinante(det(las)) --> [las].
determinante(det(un)) --> [un].
determinante(det(una)) --> [una].
determinante(det(esta)) --> [esta].
determinante(det(estos)) --> [estos].
determinante(det(su)) --> [su].
determinante(det(cada)) --> [cada].
determinante(det(todos)) --> [todos].
determinante(det(cincuenta)) --> [cincuenta].
determinante(det(cinco)) --> [5].
determinante(det(veinte)) --> [20].

% Pronombres
pronombre(pron(se)) --> [se].
pronombre(pron(les)) --> [les].
pronombre(pron(lo)) --> [lo].
pronombre(pron(ella)) --> [ella].

% Nombres
nombre(n(competidor)) --> [competidor].
nombre(n(spacex)) --> [spacex].
nombre(n(blue)) --> [blue].
nombre(n(origin)) --> [origin].
nombre(n(tecnologia)) --> [tecnologia].
nombre(n(aspectos)) --> [aspectos].
nombre(n(actividades)) --> [actividades].
nombre(n(catalizador)) --> [catalizador].
nombre(n(cambios)) --> [cambios].
nombre(n(precedentes)) --> [precedentes].
nombre(n(economia)) --> [economia].
nombre(n(espacio)) --> [espacio].
nombre(n(cuatro_cero)) --> ['4.0'].
nombre(n(termino)) --> [termino].
nombre(n(referencia)) --> [referencia].
nombre(n(comercializacion)) --> [comercializacion].
nombre(n(democratizacion)) --> [democratizacion].
nombre(n(exploracion)) --> [exploracion].
nombre(n(xai)) --> [xai].
nombre(n(inteligencia)) --> [inteligencia].
nombre(n(dominio)) --> [dominio].
nombre(n(agencias)) --> [agencias].
nombre(n(decadas)) --> [decadas].
nombre(n(cambio)) --> [cambio].
nombre(n(planet)) --> [planet].
nombre(n(labs)) --> [labs].
nombre(n(imagenes)) --> [imagenes].
nombre(n(tierra)) --> [tierra].
nombre(n(traves)) --> [traves].
nombre(n(flota)) --> [flota].
nombre(n(satelites)) --> [satelites].
nombre(n(cubesats)) --> [cubesats].
nombre(n(resolucion)) --> [resolucion].
nombre(n(superficie)) --> [superficie].
nombre(n(disposicion)) --> [disposicion].
nombre(n(usuarios)) --> [usuarios].
nombre(n(tarifa)) --> [tarifa].
nombre(n(nse)) --> [nse].
nombre(n(testigo)) --> [testigo].
nombre(n(expansion)) --> [expansion].
nombre(n(numero)) --> [numero].
nombre(n(paises)) --> [paises].
nombre(n(actores)) --> [actores].
nombre(n(programas)) --> [programas].
nombre(n(turismo)) --> [turismo].
nombre(n(mercado)) --> [mercado].
nombre(n(oportunidades)) --> [oportunidades].
nombre(n(union)) --> [union].
nombre(n(caminos)) --> [caminos].
nombre(n(innovacion)) --> [innovacion].
nombre(n(eficiencia)) --> [eficiencia].
nombre(n(misiones)) --> [misiones].
nombre(n(enfoque)) --> [enfoque].
nombre(n(ia)) --> [ia].
nombre(n(sistemas)) --> [sistemas].
nombre(n(reglas)) --> [reglas].
nombre(n(dl)) --> [dl].
nombre(n(redes)) --> [redes].
nombre(n(capas)) --> [capas].
nombre(n(datos)) --> [datos].
nombre(n(disciplina)) --> [disciplina].
nombre(n(investigacion)) --> [investigacion].
nombre(n(largo)) --> [largo].
nombre(n(anos)) --> [anos].
nombre(n(operaciones)) --> [operaciones].
nombre(n(algoritmos)) --> [algoritmos].
nombre(n(multitud)) --> [multitud].
nombre(n(tareas)) --> [tareas].
nombre(n(intervencion)) --> [intervencion].
nombre(n(gota)) --> [gota].
nombre(n(combustible)) --> [combustible].
nombre(n(columna)) --> [columna].
nombre(n(comunicaciones)) --> [comunicaciones].
nombre(n(niveles)) --> [niveles].
nombre(n(autonomia)) --> [autonomia].
nombre(n(automatizacion)) --> [automatizacion].
nombre(n(senal)) --> [senal].
nombre(n(radio)) --> [radio].
nombre(n(minutos)) --> [minutos].
nombre(n(distancia)) --> [distancia].
nombre(n(marte)) --> [marte].
nombre(n(posiciones)) --> [posiciones].
nombre(n(planetas)) --> [planetas].
nombre(n(naves)) --> [naves].
nombre(n(decisiones)) --> [decisiones].
nombre(n(comunicacion)) --> [comunicacion].
nombre(n(robots)) --> [robots].
nombre(n(analisis)) --> [analisis].
nombre(n(terreno)) --> [terreno].
nombre(n(reconocimiento)) --> [reconocimiento].
nombre(n(objetos)) --> [objetos].
nombre(n(navegacion)) --> [navegacion].
nombre(n(funcion)) --> [funcion].
nombre(n(entorno)) --> [entorno].
nombre(n(luna)) --> [luna].
nombre(n(abundancia)) --> [abundancia].
nombre(n(recursos)) --> [recursos].
nombre(n(objetivos)) --> [objetivos].
nombre(n(isru)) --> [isru].
nombre(n(huella)) --> [huella].
nombre(n(ambito)) --> [ambito].
nombre(n(uso)) --> [uso].
nombre(n(sostenibilidad)) --> [sostenibilidad].
nombre(n(procesamiento)) --> [procesamiento].
nombre(n(tecnicas)) --> [tecnicas].
nombre(n(extraccion)) --> [extraccion].
nombre(n(informacion)) --> [informacion].
nombre(n(productos)) --> [productos].
nombre(n(momento)) --> [momento].
nombre(n(evolucion)) --> [evolucion].
nombre(n(subsistemas)) --> [subsistemas].
nombre(n(bordo)) --> [bordo].
nombre(n(objeto)) --> [objeto].
nombre(n(convergencia)) --> [convergencia].
nombre(n(defensa)) --> [defensa].
nombre(n(temas)) --> [temas].
nombre(n(mundo)) --> [mundo].
nombre(n(problema)) --> [problema].
nombre(n(riesgo)) --> [riesgo].
nombre(n(cajas)) --> [cajas].
nombre(n(aplicaciones)) --> [aplicaciones].
nombre(n(industrias)) --> [industrias].
nombre(n(atencion)) --> [atencion].
nombre(n(finanzas)) --> [finanzas].
nombre(n(educacion)) --> [educacion].
nombre(n(seguridad)) --> [seguridad].
nombre(n(manufactura)) --> [manufactura].

% Verbos
verbo(v(es)) --> [es].
verbo(v(son)) --> [son].
verbo(v(era)) --> [era].
verbo(v(fue)) --> [fue].
verbo(v(ha, integrado)) --> [ha, integrado].
verbo(v(convirtiendose)) --> [convirtiendose].
verbo(v(hace)) --> [hace].
verbo(v(significa)) --> [significa].
verbo(v(ha, visto)) --> [ha, visto].
verbo(v(especializa)) --> [especializa].
verbo(v(obtener)) --> [obtener].
verbo(v(capturan)) --> [capturan].
verbo(v(ponen)) --> [ponen].
verbo(v(pagando)) --> [pagando].
verbo(v(esta, siendo)) --> [esta, siendo].
verbo(v(invierten)) --> [invierten].
verbo(v(representa)) --> [representa].
verbo(v(estan, expandiendo)) --> [estan, expandiendo].
verbo(v(esta, abriendo)) --> [esta, abriendo].
verbo(v(acelerando)) --> [acelerando].
verbo(v(mejorando)) --> [mejorando].
verbo(v(utiliza)) --> [utiliza].
verbo(v(analizar)) --> [analizar].
verbo(v(aprender)) --> [aprender].
verbo(v(ha, desarrollado)) --> [ha, desarrollado].
verbo(v(ha, revolucionado)) --> [ha, revolucionado].
verbo(v(haciendolas)) --> [haciendolas].
verbo(v(estan, equipados)) --> [estan, equipados].
verbo(v(permiten)) --> [permiten].
verbo(v(realizar)) --> [realizar].
verbo(v(cuenta)) --> [cuenta].
verbo(v(mejora)) --> [mejora].
verbo(v(requiere)) --> [requiere].
verbo(v(tarda)) --> [tarda].
verbo(v(recorrer)) --> [recorrer].
verbo(v(dependiendo)) --> [dependiendo].
verbo(v(permite)) --> [permite].
verbo(v(realicen)) --> [realicen].
verbo(v(tomen)) --> [tomen].
verbo(v(utilizan)) --> [utilizan].
verbo(v(tomar)) --> [tomar].
verbo(v(ha, dejado)) --> [ha, dejado].
verbo(v(esten)) --> [esten].
verbo(v(aplica)) --> [aplica].
verbo(v(figuraba)) --> [figuraba].
verbo(v(corren)) --> [corren].
verbo(v(convertirse)) --> [convertirse].
verbo(v(estan, disparando)) --> [estan, disparando].

% Adjetivos
adjetivo(adj(directo)) --> [directo].
adjetivo(adj(diversos)) --> [diversos].
adjetivo(adj(espaciales)) --> [espaciales].
adjetivo(adj(espacial)) --> [espacial].
adjetivo(adj(nueva)) --> [nueva].
adjetivo(adj(conocida)) --> [conocida].
adjetivo(adj(artificial)) --> [artificial].
adjetivo(adj(explicable)) --> [explicable].
adjetivo(adj(exclusivo)) --> [exclusivo].
adjetivo(adj(gubernamentales)) --> [gubernamentales].
adjetivo(adj(ultimas)) --> [ultimas].
adjetivo(adj(mayor)) --> [mayor].
adjetivo(adj(pequenos)) --> [pequenos].
adjetivo(adj(alta)) --> [alta].
adjetivo(adj(potenciales)) --> [potenciales].
adjetivo(adj(global)) --> [global].
adjetivo(adj(record)) --> [record].
adjetivo(adj(comerciales)) --> [comerciales].
adjetivo(adj(incipiente)) --> [incipiente].
adjetivo(adj(lucrativo)) --> [lucrativo].
adjetivo(adj(economicas)) --> [economicas].
adjetivo(adj(nuevos)) --> [nuevos].
adjetivo(adj(primer)) --> [primer].
adjetivo(adj(basados)) --> [basados].
adjetivo(adj(neuronales)) --> [neuronales].
adjetivo(adj(multiples)) --> [multiples].
adjetivo(adj(profundas)) --> [profundas].
adjetivo(adj(satelitales)) --> [satelitales].
adjetivo(adj(agiles)) --> [agiles].
adjetivo(adj(adaptables)) --> [adaptables].
adjetivo(adj(resilientes)) --> [resilientes].
adjetivo(adj(minima)) --> [minima].
adjetivo(adj(humana)) --> [humana].
adjetivo(adj(vertebral)) --> [vertebral].
adjetivo(adj(altos)) --> [altos].
adjetivo(adj(rutinarias)) --> [rutinarias].
adjetivo(adj(constante)) --> [constante].
adjetivo(adj(principales)) --> [principales].
adjetivo(adj(eficiente)) --> [eficiente].
adjetivo(adj(empresarial)) --> [empresarial].
adjetivo(adj(competitivo)) --> [competitivo].
adjetivo(adj(adecuado)) --> [adecuado].
adjetivo(adj(debatidos)) --> [debatidos].
adjetivo(adj(principal)) --> [principal].
adjetivo(adj(negras)) --> [negras].
adjetivo(adj(diversas)) --> [diversas].
adjetivo(adj(incluidas)) --> [incluidas].
adjetivo(adj(medica)) --> [medica].

% Adverbios
adverbio(adv(algo)) --> [algo].
adverbio(adv(perfectamente)) --> [perfectamente].
adverbio(adv(tambien)) --> [tambien].
adverbio(adv(tradicionalmente)) --> [tradicionalmente].
adverbio(adv(potencialmente)) --> [potencialmente].
adverbio(adv(exponencialmente)) --> [exponencialmente].
adverbio(adv(no)) --> [no].
adverbio(adv(mas)) --> [mas].
adverbio(adv(ahora)) --> [ahora].
adverbio(adv(ademas)) --> [ademas].
adverbio(adv(muy)) --> [muy].
adverbio(adv(eficazmente)) --> [eficazmente].
adverbio(adv(ya)) --> [ya].
adverbio(adv(dentro)) --> [dentro].

% Preposiciones
preposicion(prep(de)) --> [de].
preposicion(prep(en)) --> [en].
preposicion(prep(sin)) --> [sin].
preposicion(prep(a)) --> [a].
preposicion(prep(hacia)) --> [hacia].
preposicion(prep(con)) --> [con].
preposicion(prep(para)) --> [para].
preposicion(prep(sobre)) --> [sobre].
preposicion(prep(entre)) --> [entre].
preposicion(prep(del)) --> [del].

% Conjunciones
conjuncion(conj(y)) --> [y].
conjuncion(conj(como)) --> [como].
conjuncion(conj(que)) --> [que].
conjuncion(conj(pero)) --> [pero].