# Probar archivos de main y test
- Para el main, ejecuta el comando **estado_inicial(E0), bucle_juego(E0, 15).**, donde E0 es el **estado inicial** y 15 es el **número de turnos que quieres ejecutar**
- Para el test (que basicamente seria lo mismo pero con diferente número de turnos y sin que se imprima E0 al final) ejecuta el comando **test_todos.**
- *Nota: antes de ejecutarlo en ambos, importa el archivo correspondiente con el botón de Consult*


# CRA - Prácticas de CRA
1. Escribir el código

Escribir hechos y/o reglas en un archivo y guardarlo en formato .pl.

💡 Consejo: Esto se puede hacer en Visual Studio Code en vez del editor básico de Prolog para tener colores en la sintaxis y diferenciar las cosas más fácilmente.

## ¿Cómo funciona esto?

Sigue estos 4 pasos para arrancar con tus prácticas:

### 1. Escribir el código
Escribir  hechos y/o reglas en un archivo y guardarlo en formato `.pl`. 

> **💡 Consejo:** De hecho, esto se puede hacer en **Visual Studio Code** en vez del editor básico de Prolog para tener colores en la sintaxis y diferenciar las cosas más fácilmente.

### 2. Cargar los datos (Consult)
Abre el intérprete de Prolog y carga el archivo de la siguiente manera:
**`File` -> `Consult...` -> `TuArchivo.pl`** *(el que hemos creado en el paso 1)*.

### 3. Comprobar que no hay errores
Si todo va bien (es decir, el código está bien estructurado y no hay fallos de sintaxis o letras 'ñ' dando problemas), nos saldrá un mensaje en la consola confirmando que todo está correcto, algo como esto:

<img width="814" height="86" alt="image" src="https://github.com/user-attachments/assets/9593bac6-f82a-4664-99b9-56a11623b066" />

### 4. Probar el código en la consola
Ahora solo nos queda hacer preguntas en la consola (`?-`) para probar que todo funciona tal y como hemos diseñado. 

Por ejemplo, si tenemos en cuenta el ejemplo de `listas.pl` con nuestra base de datos:
```prolog
mi_lista([pepe, carlos, juan, javier]).

Podríamos escribir esta consulta en la consola usando el operador |:
```prolog
mi_lista([Cabeza | Cola]).

Y el intérprete nos escupiría como respuesta la lista separada

```prolog
Cabeza = pepe,
Cola = [carlos, juan, javier].
