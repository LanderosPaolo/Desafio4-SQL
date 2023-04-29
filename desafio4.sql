/* Creando la base de datos*/
CREATE DATABASE "desafio4-Paolo-Landeros-123";

/* Ingresando a la base de datos*/
\c "desafio4-Paolo-Landeros-123"

/* Creando las tablas con los datos que nos proporciona el ejercicio*/
CREATE TABLE peliculas (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(255),
    anno INTEGER
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    tag VARCHAR(32)
);

/*1. Crea el modelo (revisa bien cuál es el tipo de relación antes de crearlo), respeta las
claves primarias, foráneas y tipos de datos.*/
CREATE TABLE peliculas_tags (
    id SERIAL PRIMARY KEY,
    peliculas_id INTEGER, 
    tags_id INTEGER,
    FOREIGN KEY (peliculas_id) REFERENCES peliculas(id),
    FOREIGN KEY (tags_id) REFERENCES tags(id)
);

/*2. Inserta 5 películas y 5 tags, la primera película tiene que tener 3 tags asociados, la
segunda película debe tener dos tags asociados.*/
    -- Agregando 5 peliculas a la tabla peliculas
INSERT INTO peliculas (id, nombre, anno)
VALUES
(1, 'The Dark Knight', 2008),
(2, 'Pulp Fiction', 1994),
(3, 'Star Wars', 1977),
(4, 'The Godfather', 1974),
(5, 'Leon The Professional', 1994);

    -- Agregando 5 tags a la tabla tags
INSERT INTO tags (id, tag)
VALUES
(1, 'Drama'),
(2, 'Ciencia ficcion'),
(3, 'Crimen'),
(4, 'Comedia acida'),
(5, 'Accion');

    -- Agregando 3 tags a la primera pelicula en la tabla peliculas_tags
INSERT INTO peliculas_tags (peliculas_id, tags_id)
VALUES
(1, 1),
(1, 3),
(1, 5);

    -- Agregando 2 tags a la segunda pelicula en la tabla peliculas
INSERT INTO peliculas_tags (peliculas_id, tags_id)
VALUES
(2, 3),
(2, 4);

/*3. Cuenta la cantidad de tags que tiene cada película. Si una película no tiene tags debe
mostrar 0.*/
SELECT p.nombre, COUNT(pt.tags_id) AS cantidad_tags
FROM peliculas p
LEFT JOIN peliculas_tags pt ON p.id = pt.peliculas_id
GROUP BY p.nombre
ORDER BY cantidad_tags DESC;

/*4. Crea las tablas respetando los nombres, tipos, claves primarias y foráneas y tipos de
datos.*/
CREATE TABLE preguntas (
    id INTEGER PRIMARY KEY,
    pregunta VARCHAR(255),
    respuesta_correcta VARCHAR(255)
);

CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY,
    nombre VARCHAR(255),
    edad INTEGER
);

CREATE TABLE respuestas (
    id INTEGER PRIMARY KEY,
    respuesta VARCHAR(255),
    usuario_id INTEGER,
    pregunta_id INTEGER,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (pregunta_id) REFERENCES preguntas(id)
);

/*5. Agrega datos, 5 usuarios y 5 preguntas, la primera pregunta debe estar contestada
dos veces correctamente por distintos usuarios, la pregunta 2 debe estar contestada
correctamente sólo por un usuario, y las otras 2 respuestas deben estar incorrectas.*/
    -- Agregando 5 usuarios
INSERT INTO usuarios
VALUES
(1, 'Maria', 25),
(2, 'Pedro', 30),
(3, 'Juan', 28),
(4, 'Alejandro', 22),
(5, 'Laura', 38);

    -- Agregando 5 preguntas
INSERT INTO preguntas
VALUES
(1, '¿Que significa HTML?', 'HyperText Markup Language'),
(2, '¿Que significa CSS?', 'Cascading Style Sheets'),
(3, '¿Que es JavaScript?', 'Es un lenguaje de programacion'),
(4, '¿Que significa API?', 'Application Programming Interface'),
(5, '¿Que significa SQL', 'Structured Query Language');

    -- La primera pregunta debe estar contestada 2 veces correctamente por distintos usuarios
INSERT INTO respuestas
VALUES
(1, 'HyperText Markup Language', 1, 1),
(2, 'HyperText Markup Language', 5, 1);

    -- La pregunta 2 debe estar contestada correctamente solo por un usuario y las otras 2 respuestas deben estar incorrectas
INSERT INTO respuestas
VALUES
(3, 'Cascading Style Sheets', 3, 2),
(4, 'Application Programming Interface', 4, 2),
(5, 'Es un lenguaje de programacion', 2, 2);

/*6. Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la
pregunta).*/
SELECT u.nombre, COUNT(respuesta_correcta) AS respuestas_correctas
FROM preguntas p
INNER JOIN respuestas r ON p.id = r.pregunta_id
INNER JOIN usuarios u ON u.id = r.usuario_id
WHERE p.respuesta_correcta = r.respuesta
GROUP BY u.nombre;

/*7. Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios tuvieron la
respuesta correcta.*/
SELECT p.pregunta, p.respuesta_correcta, COUNT(r.respuesta) AS usuarios_con_respuesta_correcta
FROM preguntas p
INNER JOIN respuestas r ON p.id = r.pregunta_id
WHERE p.respuesta_correcta = r.respuesta
GROUP BY p.pregunta, p.respuesta_correcta, r.respuesta;

/*8. Implementa borrado en cascada de las respuestas al borrar un usuario y borrar el
primer usuario para probar la implementación.*/
ALTER TABLE respuestas
DROP CONSTRAINT IF EXISTS respuestas_usuario_id_fkey,
ADD CONSTRAINT respuestas_usuario_id_fkey
FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE;

    -- Borrando el primer usuario
DELETE FROM usuarios
WHERE id = 1;

    -- Comprobando que se haya borrado el usuario
SELECT * FROM usuarios;

    -- Comprobando que se haya borrado la respuesta
SELECT * FROM respuestas;

/*9. Crea una restricción que impida insertar usuarios menores de 18 años en la base de
datos.*/
ALTER TABLE usuarios
ADD CONSTRAINT c_edad_usuarios
CHECK (edad >= 18);

    -- Comprobando restriccion con edad menor a 18
INSERT INTO usuarios
VALUES
(6, 'Francisco', 17); 
--ERROR:  el nuevo registro para la relación «usuarios» viola la restricción «check» «ck_edad_usuarios»
--DETALLE:  La fila que falla contiene (6, Francisco, 17).

    -- Compronado restriccion con edad igual a 18
INSERT INTO usuarios
VALUES
(6, 'Alejandra', 18);
-- INSERT 0 1

    -- Comrpobando restriccion con edad mayor a 18
INSERT INTO usuarios
VALUES
(7, 'Isaac', 19);
-- INSERT 0 1

/*10. Altera la tabla existente de usuarios agregando el campo email con la restricción de
único.*/
ALTER TABLE usuarios
ADD COLUMN email VARCHAR(255),
ADD CONSTRAINT u_email UNIQUE(email);

    -- Comprobando restriccion
INSERT INTO usuarios (id, nombre, edad, email)
VALUES
(8, 'Romina', 27, 'romina@email.com');
-- INSERT 0 1

INSERT INTO usuarios
VALUES
(9, 'Romina', 32, 'romina@email.com');
-- ERROR:  llave duplicada viola restricción de unicidad «u_email»
-- DETALLE:  Ya existe la llave (email)=(romina@email.com).
