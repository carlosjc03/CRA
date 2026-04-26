% semantico.pl
% Hechos semánticos básicos

% semantico.pl
% Ontología para el Corpus de la Nueva Economía Espacial

% Entidades y organizaciones
tipo(spacex, empresa_privada).
tipo(planet_labs, empresa_privada).
tipo(blue_origin, empresa_privada).
tipo(virgin_galactic, empresa_privada).
tipo(nasa, agencia_gubernamental).
tipo(agencias, organizacion).
tipo(naciones, entidad_geopolitica).

% Objetos físicos y espaciales
tipo(satelites, objeto_espacial).
tipo(cubesats, objeto_espacial).
tipo(cohete, vehiculo_espacial).
tipo(tierra, planeta).
tipo(espacio, entorno_fisico).
tipo(combustible, recurso_fisico).
tipo(desechos, basura_fisica).
tipo(mapa, objeto_inanimado).
tipo(panorama, vista_general). 
tipo(mano, parte_del_cuerpo).

% Tecnología e Inteligencia Artificial
tipo(ia, tecnologia_intangible).
tipo(inteligencia, tecnologia_intangible).
tipo(xai, tecnologia_intangible).
tipo(software, tecnologia_intangible).
tipo(algoritmos, tecnologia_intangible).
tipo(datos, informacion).
tipo(aplicaciones, producto_software).
tipo(sistemas, tecnologia_intangible).

% Conceptos económicos y comerciales
tipo(mercado, concepto_economico).
tipo(economia, concepto_economico).
tipo(costos, magnitud_financiera).
tipo(inversiones, capital_financiero).
tipo(turismo, actividad_comercial).
tipo(industria, sector_comercial).
tipo(tarifa, magnitud_financiera).
tipo(reduccion, concepto_matematico).

% Ambigüedades Léxicas
tipo(flota, conjunto_vehiculos).      % Contexto espacial
tipo(flota, estado_flotacion).        % Contexto físico (verbo flotar)

tipo(redes, infraestructura_datos).   % Contexto tecnológico (redes neuronales)
tipo(redes, malla).                   % Contexto tradicional

tipo(operaciones, maniobras_tecnicas).% Contexto ingeniería
tipo(operaciones, cirugia_medica).    % Contexto médico

% Metáforas y/o incoherencias 
tipo(cajas_negras, objeto_fisico_opaco). % Para la metáfora de la IA como "cajas negras"
tipo(catalizador, sustancia_quimica).    % Para la metáfora "catalizador de cambios en la economía"
tipo(gota, medida_liquido_terrestre).    % Para la metáfora "gota de combustible"
tipo(vivo, cualidad_biologica).          % Para la metáfora "mapa vivo"
tipo(huella, marca_fisica_suelo).        % Para la metáfora "la IA ha dejado su huella"

% Verbos y acciones
tipo(disparando, accion_arma_fuego).     % Para la metáfora "las aplicaciones se están disparando"
tipo(remodelando, accion_arquitectonica).% Para la metáfora "remodelando el panorama"
tipo(convertirse, accion_transformacion).
tipo(capturan, accion_recoleccion).
tipo(orbitan, accion_trayectoria).
tipo(impulsando, accion_mecanica).