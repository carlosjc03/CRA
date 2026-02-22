mi_lista([pepe, carlos, juan, javier]).

% mi_lista([Cabeza | Cola]).

% Cabeza = pepe,
% Cola = [carlos, juan, javier].


% Tambien se pueden sacar mas de una cabeza de la lista:

% mi_lista([Cabeza1, Cabeza2 | Cola]). 

% Cabeza1 = pepe,
% Cabeza2 = carlos,
% Cola = [juan, javier].


% Se puede ignorar, la cabeza (o algunos de sus elementos) y la cola de la lista usando el simbolo _:

% ?- mi_lista([Primero, _, Tercero | _]).

% Primero = pepe,
% Tercero = juan.

%Cómo lo lee Prolog:

% Primero: Me guardo a pepe.
% _: Hay un nombre aquí (carlos), pero me han puesto un guion bajo, así que lo ignoro.
% Tercero: Me guardo a juan.
% | _: Todo lo que quede en la cola (javier), lo ignoro también.

 
% NUEVA REGLA (Usando | para construir)
anadir_al_principio(NuevoNombre, ListaFinal) :-
    mi_lista(LosChicos),                       % Prolog busca tu lista y la guarda en LosChicos
    ListaFinal = [NuevoNombre | LosChicos].    % Prolog pega el NuevoNombre a la cabeza de LosChicos

% ?- anadir_al_principio(maria, ListaFinal). % a ListaFinal la podria llamar como quiera, es una variable que se va a llenar con el resultado de la regla.
% ListaFinal = [maria, pepe, carlos, juan, javier].

% Lo que Prolog hará:
% Verá que NuevoNombre es maria.
% Irá a buscar mi_lista y sacará a los 4 chicos.
% Usará el | para construir la lista final, poniendo a maria como cabeza y a los chicos como cola.


% Ejercicio 4: Recorrer una lista para calcular su longitud
% Queremos crear un predicado ***list_longitud(Lista, N)***
% que reciba una lista, la recorra entera, y nos devuelva en la variable N cuántos elementos tiene

% Caso base: La longitud de una lista vacía es 0.
list_longitud([], 0).

% Caso recursivo: Corto la cabeza (_), saco la longitud de la cola (Y), y sumo 1.
list_longitud([_ | Y], N) :-
    list_longitud(Y, N1),   % Llamada recursiva con la cola
    N is N1 + 1.            % Operación aritmética para sumar

% list_longitud([a,b,c,d], X).  ---> X = 4.

% consult('C:/Users/TuUsuario/Desktop/datos.pl').   

