% semantico.pl
% Hechos semánticos básicos

% semantico.pl
% Ontología para el Corpus de la Nueva Economía Espacial

% Ambigüedades Léxicas
tipo(flota, conjunto_barcos). tipo(flota, conjunto_satelites).
tipo(redes, malla_fisica). tipo(redes, estructura_computacional).
tipo(capas, estrato_fisico). tipo(capas, nivel_logico).
tipo(mercado, lugar_fisico). tipo(mercado, concepto_economico).
tipo(objeto, cosa_fisica). tipo(objeto, cuerpo_celeste).

% Metáforas e Incoherencias
tipo(ia, tecnologia_intangible). tipo(xai, tecnologia_intangible).
tipo(nse, concepto_economico). tipo(economia, concepto_economico).
tipo(aplicaciones, software_intangible).

% Acciones "Problemáticas" para entes abstractos
tipo(desempena, accion_humana). 
tipo(testigo, accion_humana).
tipo(abrir, accion_fisica).
tipo(huella, rastro_fisico).
tipo(disparar, accion_fisica).
tipo(correr, accion_fisica).