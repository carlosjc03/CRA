% semantico.pl
% Ontologia ligera del corpus (tecnologia espacial / nueva economia espacial).
% Asigna a las palabras relevantes uno o mas tipos semanticos. Estos tipos
% son los que usa deteccion.pl para encender alarmas de ambiguedad,
% incoherencia o metafora.
%
% Convencion: tipo(Palabra, Categoria).
% Si una palabra tiene varias entradas con categorias distintas se considera
% lexicamente ambigua (deteccion.pl lo detecta automaticamente).

% ============================================================
% ENTIDADES, ORGANIZACIONES, LUGARES
% ============================================================
tipo(spacex, empresa_privada).
tipo(blue, empresa_privada).
tipo(origin, empresa_privada).
tipo(planet, empresa_privada).
tipo(labs, empresa_privada).
tipo(agencias, organizacion).
tipo(paises, entidad_geopolitica).
tipo(nse, concepto_economico).        % Nueva Economia Espacial = concepto, no agente humano
tipo(isru, tecnologia_intangible).    % In Situ Resource Utilization

% ============================================================
% OBJETOS Y ENTORNOS FISICOS
% ============================================================
tipo(satelites, objeto_espacial).
tipo(cubesats, objeto_espacial).
tipo(naves, vehiculo_espacial).
tipo(robots, objeto_fisico).
tipo(tierra, planeta).
tipo(luna, planeta).
tipo(marte, planeta).
tipo(planetas, planeta).
tipo(espacio, entorno_fisico).
tipo(combustible, recurso_fisico).
tipo(senal, fenomeno_fisico).
tipo(radio, fenomeno_fisico).

% ============================================================
% TECNOLOGIA E IA
% ============================================================
tipo(ia, tecnologia_intangible).
tipo(inteligencia, tecnologia_intangible).
tipo(xai, tecnologia_intangible).
tipo(dl, tecnologia_intangible).
tipo(algoritmos, tecnologia_intangible).
tipo(sistemas, tecnologia_intangible).
tipo(tecnologia, tecnologia_intangible).
tipo(aplicaciones, producto_software).
tipo(software, tecnologia_intangible).

% ============================================================
% CONCEPTOS ECONOMICOS Y COMERCIALES
% ============================================================
tipo(mercado, concepto_economico).
tipo(economia, concepto_economico).
tipo(turismo, concepto_economico).
tipo(comercializacion, concepto_economico).
tipo(democratizacion, concepto_economico).
tipo(union, concepto_abstracto).
tipo(convergencia, concepto_abstracto).
tipo(industrias, sector_comercial).
tipo(finanzas, sector_comercial).
tipo(manufactura, sector_comercial).

% ============================================================
% ELEMENTOS QUE APARECEN EN METAFORAS CONOCIDAS
% ============================================================
tipo(gota, medida_liquido).            % "cada gota cuenta" -> metafora de cantidad minima
tipo(huella, marca_fisica).            % "ha dejado huella"
tipo(cajas, objeto_fisico).            % "cajas negras"
tipo(columna, parte_anatomica).        % "columna vertebral"
tipo(caminos, lugar_fisico).           % "abriendo caminos"
tipo(problema, concepto_abstracto).    % oracion 29
tipo(riesgo, concepto_abstracto).      % "corren el riesgo"

% ============================================================
% AMBIGUEDADES LEXICAS DEL DOMINIO
% ============================================================
% Estas son las palabras que el Excel marca como ambiguas. Cada una recibe
% al menos dos tipos semanticos.

% "flota" (oracion 6): conjunto de barcos vs. conjunto de satelites
tipo(flota, conjunto_vehiculos_acuaticos).
tipo(flota, conjunto_satelites).

% "redes" (oracion 13): mallas fisicas vs. estructuras computacionales
tipo(redes, malla_fisica).
tipo(redes, estructura_computacional).

% "capas" (oracion 13): estratos fisicos vs. capas computacionales
tipo(capas, estrato_fisico).
tipo(capas, capa_computacional).

% "reconocimiento" (oracion 22): identificacion visual vs. premio/honor
tipo(reconocimiento, identificacion_visual).
tipo(reconocimiento, distincion_honorifica).

% "operaciones" — en este corpus sale en oraciones correctas, pero
% etimologicamente es ambigua (cirugia / maniobra tecnica). La dejamos
% declarada para la mejora futura.
tipo(operaciones, maniobra_tecnica).
tipo(operaciones, cirugia_medica).

% ============================================================
% VERBOS Y ACCIONES
% ============================================================
% Los verbos llevan el tipo que describe la naturaleza de la accion.

% Acciones de armas o explosivos (literalmente)
tipo(disparando, accion_arma_fuego).

% Acciones fisicas humanas: requieren agente animado/humano
tipo(abriendo, accion_fisica_humana).      % "abriendo caminos"
tipo(dejado, accion_marca_fisica).         % "ha dejado huella"
tipo(mejora, accion_estructural).          % "mejora la columna vertebral"
tipo(cuenta, accion_relevancia).           % "cada gota cuenta"

% Acciones de transformacion (metaforicas para entidades intangibles)
tipo(convertirse, accion_transformacion).
tipo(corren, accion_riesgo).               % "corren el riesgo"

% Acciones perceptuales o testimoniales (humanas)
tipo(siendo, accion_perceptual_humana).    % "esta siendo testigo"

% Otras acciones (las dejamos catalogadas para futuras reglas)
tipo(integrado, accion_proceso).
tipo(revolucionado, accion_proceso).
tipo(expandiendo, accion_proceso).
tipo(mejora, accion_proceso).
tipo(permite, accion_proceso).
tipo(requiere, accion_proceso).
tipo(utiliza, accion_proceso).
tipo(captura, accion_recoleccion).
tipo(capturan, accion_recoleccion).