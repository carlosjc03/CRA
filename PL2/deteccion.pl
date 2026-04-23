% deteccion.pl

% 2.3.1. Detección de Ambigüedad Léxica
% Una palabra es ambigua si tiene dos tipos semánticos diferentes.
ambigua(Palabra) :-
    tipo(Palabra, Tipo1),
    tipo(Palabra, Tipo2),
    Tipo1 \= Tipo2.

% 2.3.3. Uso no literal (Metáforas simples)
% Ejemplo: un fenómeno económico ("inflación") haciendo una acción física ("comer").
metaphora(Sujeto, Verbo) :-
    tipo(Sujeto, fenomeno_economico),
    tipo(Verbo, accion_fisica).