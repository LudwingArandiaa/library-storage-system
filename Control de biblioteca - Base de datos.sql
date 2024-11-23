-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 21-06-2024 a las 01:56:03
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `biblioteca`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CrearPrestamo` (IN `cedula_empleado` VARCHAR(15), `cedula_usuario` VARCHAR(15), `libro_titulo` VARCHAR(50))   BEGIN
	IF (SELECT ci_empleado FROM empleados WHERE ci_empleado = cedula_empleado) IS NOT NULL AND (SELECT ci_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) IS NOT NULL AND (SELECT titulo_libro FROM libros WHERE titulo_libro = libro_titulo) IS NOT NULL THEN
    	IF (SELECT state_empleado FROM empleados WHERE ci_empleado = cedula_empleado) AND (SELECT state_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) AND (SELECT state_libro FROM libros WHERE titulo_libro = libro_titulo) THEN
        	IF NOT (SELECT penalizacion FROM usuarios WHERE ci_usuario = cedula_usuario) THEN
            	INSERT INTO usuario_empleado (id_empleado, id_usuario) VALUES ((SELECT id_empleado FROM empleados WHERE ci_empleado = cedula_empleado),(SELECT id_usuario FROM usuarios WHERE ci_usuario = cedula_usuario));
            	INSERT INTO prestamos (id_libro, id_us_em) VALUES ((SELECT id_libro FROM libros WHERE titulo_libro = libro_titulo),(SELECT id_us_em FROM usuario_empleado ORDER BY id_us_em DESC LIMIT 1));
                SELECT (SELECT nombre_empleado FROM empleados WHERE ci_empleado = cedula_empleado) AS empleado_remitente, (SELECT nombre_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) AS usuario_receptor, (SELECT titulo_libro FROM libros WHERE titulo_libro = libro_titulo) AS libro_prestado, fecha AS fecha_emision, fecha_limite AS fecha_tope FROM prestamos ORDER BY id_prestamo DESC LIMIT 1;
            ELSE
            	SELECT "El usuario está penalizado." AS Denegado;
            END IF;
        ELSE
        	SELECT "Uno de los tres datos ingresados no está disponible." AS Denegado;
        END IF;
    ELSE
    	SELECT "Uno de los tres datos ingresados no existe." AS Denegado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DevolverLibro` (IN `cedula_usuario` VARCHAR(15))   BEGIN
    IF (SELECT ci_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) IS NOT NULL AND (SELECT state_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) = 0 THEN
        UPDATE prestamos SET fecha_entrega = NOW() WHERE id_us_em = (SELECT id_us_em FROM prestamos WHERE id_us_em = (SELECT id_us_em FROM usuario_empleado WHERE id_usuario = (SELECT id_usuario FROM usuarios WHERE ci_usuario = cedula_usuario) ORDER BY id_us_em DESC LIMIT 1) AND fecha_entrega IS NULL);
        UPDATE usuarios SET state_usuario = 1 WHERE ci_usuario = cedula_usuario;
        SELECT "Devolución realizada con éxito" AS Notificacion;
    ELSE
        SELECT "El usuario no existe o no ha hecho un prestamo." AS Denegado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FiltrarPorAutor` (IN `n_autor` VARCHAR(15))   BEGIN 
IF (SELECT Autor_Nombre FROM Autores_Libros WHERE Autor_Nombre = n_autor LIMIT 1) IS NOT NULL OR (SELECT Autor_Apellido FROM Autores_Libros WHERE Autor_Apellido = n_autor LIMIT 1) IS NOT NULL THEN
    SELECT Libro_Titulo AS Titulo, 
    Autor_Nombre AS Nombre, Autor_Apellido AS Apellido, 
    Libro_Editorial AS Editorial, 
    Libro_Sinopsis AS Sinopsis, 
    Libro_Idioma AS Idioma,
    Libro_Fecha AS Fecha FROM Tabla_Libros INNER JOIN Libros_Detalles ON Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID INNER JOIN Autores_Libros ON Autores_Libros.Autor_ID = Tabla_Libros.Autor_ID
    WHERE Autor_Nombre = n_autor OR Autor_Apellido = n_autor AND Libro_Estado = 1; 

ELSE
SELECT  "El autor solicitado no está disponible..." AS Lo_sentimos;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FiltrarPorEditorial` (IN `editorial_b` VARCHAR(35))   BEGIN
	IF (SELECT Libro_Editorial FROM Tabla_Libros WHERE Libro_Editorial = editorial_b LIMIT 1) IS NOT NULL THEN
    	SELECT Libro_Titulo AS Titulo,
    	(SELECT CONCAT(Autor_Nombre, ' ', Autor_Apellido) FROM Autores_Libros WHERE Autores_Libros.Autor_ID = Tabla_Libros.Autor_ID) AS Autor,
    	(SELECT Libro_Genero FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Genero,
    	(SELECT Libro_Sinopsis FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Sinopsis,
    	(SELECT Libro_Idioma FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Idioma,
    	(SELECT Libro_Fecha FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Fecha FROM Tabla_Libros
    	WHERE Libro_Estado = 1 AND Libro_Editorial = editorial_b;
    ELSE
    	SELECT "La editorial que buscas no está disponible." AS Lo_sentimos;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FiltrarPorFecha` (IN `i_fecha` YEAR(4))   BEGIN
IF (SELECT Fecha_Libro FROM Detalles_Libros WHERE Fecha_Libro = i_fecha LIMIT 1) IS NOT NULL THEN
    SELECT Libro_Titulo AS Titulo, 
    Autor_Nombre AS Nombre, Autor_Apellido AS Apellido, 
    Libro_Editorial AS Editorial, 
    Libro_Sinopsis AS Sinopsis, 
    Libro_Idioma AS Idioma,
    Libro_Fecha AS Fecha FROM Tabla_Libros INNER JOIN Libros_Detalles ON Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID INNER JOIN Autores_Libros ON Autores_Libros.Autor_ID = Tabla_Libros.Autor_ID WHERE Libro_Fecha = i_fecha AND Libro_Estado = 1 ; 
ELSE 
SELECT "La fecha de emisión no ha sido encontrada..." AS Lo_sentimos;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FiltrarPorGenero` (IN `i_genero` VARCHAR(20))   BEGIN
IF (SELECT Libro_Genero FROM Libros_Detalles WHERE Libro_Genero = i_genero LIMIT 1) IS NOT NULL THEN
    SELECT CONCAT(Autor_Nombre, ' ',Autor_Apellido) AS Nombre_Apellido, 
    Libro_Editorial AS Editorial,
    Libro_Sinopsis AS Sinopsis,
    Libro_Genero AS Genero, Libro_Idioma AS Idioma,
    Libro_Fecha AS Fecha FROM Tabla_Libros INNER JOIN Autores_Libros ON Autores_Libros.Autor_ID = Tabla_Libros.Autor_ID INNER JOIN Libros_Detalles ON Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID WHERE Libro_Estado = 1 AND Libros_Detalles.Libro_Genero = i_genero;
ELSE
    SELECT "El género ingresado no existe..." AS Lo_sentimos;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LibrosDisponibles` ()   BEGIN
IF (SELECT SUM(Libro_Estado) FROM Tabla_Libros) = 0 THEN 
    SELECT "No existen ejemplares en este momento..." AS Lo_sentimos;
ELSE

    SELECT Libro_Titulo AS Titulo,
    (SELECT CONCAT(Autor_Nombre, ' ', Autor_Apellido) FROM Autores_Libros WHERE Autores_Libros.Autor_ID = Tabla_Libros.Autor_ID) AS Autor, Libro_Editorial AS Editorial,
    (SELECT Libro_Genero FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Genero,
    (SELECT Libro_Sinopsis FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Sinopsis,
    (SELECT Libro_Idioma FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Idioma,
    (SELECT Libro_Fecha FROM Libros_Detalles WHERE Libros_Detalles.Libro_ID = Tabla_Libros.Libro_ID) AS Fecha FROM Tabla_Libros WHERE Libro_Estado = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `QuitarPenalizacion` (IN `cedula` VARCHAR(15))   BEGIN
    IF (SELECT ci_usuario FROM usuarios WHERE ci_usuario = cedula) IS NOT NULL AND (SELECT penalizacion FROM usuarios WHERE ci_usuario = cedula) THEN
        UPDATE usuarios SET penalizacion = 0 WHERE ci_usuario = cedula;
        SELECT "Penalizacion removida con éxito." AS Finalizado;
    ELSE
        SELECT "El usuario no existe o no está penalizado" AS Denegado;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerDevolucionesPendientes` ()   BEGIN
IF (SELECT fecha FROM prestamos WHERE fecha_entrega IS NULL LIMIT 1) IS NOT NULL THEN
    SELECT CONCAT(nombre_usuario, ' ', apellido_usuario) AS Cliente, titulo_libro AS Libro_prestado, fecha AS Fecha_Emision FROM prestamos
    INNER JOIN libros ON libros.id_libro = prestamos.id_libro
    INNER JOIN usuario_empleado ON prestamos.id_us_em = usuario_empleado.id_us_em
    INNER JOIN usuarios ON usuarios.id_usuario = usuario_empleado.id_usuario
    WHERE prestamos.fecha_entrega IS NULL;
ELSE
    SELECT "No existen devoluciones pendientes" AS Denegado;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerPenalizaciones` ()   BEGIN
IF (SELECT SUM(penalizacion) FROM usuarios) THEN
SELECT ci_usuario AS Cedula_Usuario, CONCAT(nombre_usuario, ' ', apellido_usuario) AS Nombre_Completo, username AS Nombre_de_usuario FROM usuarios
WHERE usuarios.penalizacion = 1;
ELSE
SELECT "No existen usuarios penalizados." AS Denegado;
END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `autores`
--

CREATE TABLE `autores` (
  `id_autor` int(11) NOT NULL COMMENT 'Clave Primaria del autor.',
  `nombre_autor` varchar(15) NOT NULL COMMENT 'Nombre del autor.',
  `apellido_autor` varchar(15) NOT NULL COMMENT 'Apellido del autor.',
  `nacionalidad` varchar(25) NOT NULL COMMENT 'Nacionalidad o lugar de nacimiento del autor.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `autores`
--

INSERT INTO `autores` (`id_autor`, `nombre_autor`, `apellido_autor`, `nacionalidad`) VALUES
(1, 'Gabriel', 'García', 'Colombiano'),
(2, 'Haruki', 'Murakami', 'Japonés'),
(3, 'Jhonas', 'Rowling', 'Británica'),
(4, 'George', 'Orwell', 'Británico'),
(5, 'Paulo', 'Coelho', 'Brasileño'),
(6, 'Agatha', 'Christie', 'Británica'),
(7, 'Franz', 'Kafka', 'Checo'),
(8, 'Isabel', 'Allende', 'Chilena'),
(9, 'Mario', 'Vargas', 'Peruano'),
(10, 'Virginia', 'Woolf', 'Británica'),
(11, 'Charles', 'Dickens', 'Británico'),
(12, 'Ernest', 'Hemingway', 'Estadounidense'),
(13, 'Elena', 'Ferrante', 'Italiana'),
(14, 'Yukio', 'Mishima', 'Japonés'),
(15, 'Herta', 'Müller', 'Rumana'),
(16, 'Milan', 'Kundera', 'Checo'),
(17, 'Salman', 'Rushdie', 'Indio'),
(18, 'Roberto', 'Bolaño', 'Chileno'),
(19, 'Antón', 'Chejov', 'Ruso'),
(20, 'Chimamanda', 'Ngozi', 'Nigeriana'),
(21, 'Donatella', 'Pietrantonio', 'Italiana'),
(22, 'John', 'Steinbeck', 'Estadounidense'),
(23, 'Dostoievski', 'lepe', 'Ruso'),
(24, 'Margaret', 'Atwood', 'Canadiense'),
(25, 'Miguel', 'Cervantes', 'Español'),
(26, 'Percy', 'Bysshe', 'Británico'),
(27, 'William', 'Faulkner', 'Estadounidense'),
(28, 'Laura', 'Esquivel', 'Mexicana'),
(29, 'Italo', 'Calvino', 'Italiano'),
(30, 'Mark', 'Twain', 'Estadounidense');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `autores_libros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `autores_libros` (
`Autor_ID` int(11)
,`Autor_Nombre` varchar(15)
,`Autor_Apellido` varchar(15)
,`Autor_Nacionalidad` varchar(25)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `datos_empleados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `datos_empleados` (
`Empleado_ID` int(11)
,`Empleado_Nombre` varchar(15)
,`Empleado_Apellido` varchar(15)
,`Empleado_Nacimiento` date
,`Empleado_CI` varchar(15)
,`Empleado_Direccion` varchar(75)
,`Empleado_Telefono` varchar(10)
,`Empleado_Email` varchar(50)
,`Empleado_Estado` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalles_libros`
--

CREATE TABLE `detalles_libros` (
  `id_detlibro` int(11) NOT NULL COMMENT 'Clave Primaria de los detalles del libro.',
  `genero` varchar(20) NOT NULL COMMENT 'Género literario del libro.',
  `cantidad_ejempl` int(11) NOT NULL DEFAULT 1 COMMENT 'Cantidad de ejemplares existentes.',
  `sinopsis` varchar(255) NOT NULL DEFAULT 'Sin sinopsis' COMMENT 'Sipnosis del libro.',
  `idioma` varchar(15) NOT NULL DEFAULT 'Ninguno' COMMENT 'Idioma del libro.',
  `fecha_libro` year(4) NOT NULL DEFAULT year(curdate()) COMMENT 'Año de edición del libro.',
  `id_libro` int(11) NOT NULL COMMENT 'Clave Foránea perteneciente al libro.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `detalles_libros`
--

INSERT INTO `detalles_libros` (`id_detlibro`, `genero`, `cantidad_ejempl`, `sinopsis`, `idioma`, `fecha_libro`, `id_libro`) VALUES
(1, 'Ciencia Ficción', 4, 'En un futuro distópico, una joven con una voz prodigiosa debe usar su talento para desafiar al régimen opresor y salvar a su pueblo.', 'Español', '1992', 1),
(2, 'Fantasía ', 5, 'Un niño huérfano descubre un portal mágico que lo lleva a un reino donde las almas perdidas vagan sin descanso. Con la ayuda de un hada rebelde, emprende una misión para liberarlas.', 'Inglés', '2000', 2),
(3, 'Aventura Histórica', 7, 'Un joven ninja relata sus experiencias en el Japón feudal, desde su entrenamiento hasta su participación en batallas épicas y misiones secretas.', 'Japonés', '2007', 3),
(4, 'Romance Espacial', 2, 'Dos astronautas de diferentes culturas se enamoran durante una misión a un planeta alienígena, desafiando las normas y arriesgando sus vidas.', 'Francés', '2002', 4),
(5, 'Misterio', 8, 'Un detective aficionado se adentra en una biblioteca antigua y misteriosa en busca de un libro legendario que se dice que posee un poder inimaginable.', 'Alemán', '2007', 5),
(6, 'Realismo Mágico', 5, 'Un chamán anciano transmite su sabiduría a una joven de la ciudad, guiándola en un viaje de autodescubrimiento y conexión con la naturaleza.', 'Portugués', '1997', 6),
(7, 'Terror Gótico', 2, 'Un grupo de exploradores urbanos se aventura en las catacumbas debajo de una ciudad europea, donde descubren una presencia maligna que despierta con su llegada.', 'Italiano', '2002', 7),
(8, 'Poesía Romántica', 8, 'Un poeta apasionado escribe sonetos a la luna, expresando su amor por una mujer inalcanzable y su anhelo de un futuro juntos.', 'Chino', '2008', 8),
(9, 'Fantasía Épica', 1, 'Un músico talentoso debe usar su música para unir a las diferentes razas de un mundo dividido y evitar una guerra devastadora.', 'Ruso', '1987', 9),
(10, 'Drama Histórico', 5, 'Una mujer lucha por sobrevivir en un país devastado por la guerra, encontrando esperanza y fuerza en la comunidad y en su propia determinación.', 'Árabe', '1999', 10),
(11, 'Fantasía Aventurera', 4, 'Un grupo de héroes es elegido para cumplir una antigua profecía y salvar al mundo de una oscuridad que se avecina.', 'Griego', '2004', 11),
(12, 'Fantasía Infantil', 7, ' Un niño pequeño descubre un jardín mágico donde los sueños se hacen realidad, pero pronto aprende que la magia tiene un precio.', 'Hindi', '2009', 12),
(13, 'Thriller Psicológico', 4, 'Un detective investiga una serie de asesinatos espeluznantes donde las víctimas parecen ser controladas como marionetas.', 'Coreano', '2012', 13),
(14, 'Mitología Azteca', 6, ' Una joven princesa azteca descubre su destino como la reencarnación de la diosa del sol y debe enfrentar a un enemigo poderoso que amenaza a su pueblo.', 'Náhuatl', '2015', 14),
(15, 'Drama Histórico', 3, ' Un joven samurái lucha por preservar su código de honor en un mundo que cambia rápidamente durante la era Meiji.', 'Japonés', '2016', 15),
(16, 'Ciencia Ficción', 2, ' Un explorador se adentra en una biblioteca infinita en busca de un libro que contiene el conocimiento del universo.', 'Inglés', '2011', 16),
(17, 'Realismo Mágico', 4, ' Un pastor español emprende un viaje en busca de un tesoro legendario, guiado por un alquimista misterioso y sus enseñanzas.', 'Portugués', '2017', 17),
(18, 'Romance Gótico', 9, ' La turbulenta historia de amor entre Heathcliff y Catherine Earnshaw se desarrolla en una aislada granja en la campiña inglesa.', 'Inglés', '2008', 18),
(19, 'Distopía Política', 3, ' En un futuro totalitario, un hombre lucha por mantener su individualidad y su cordura frente a la vigilancia constante del Gran Hermano.', 'Inglés', '2017', 19),
(20, 'Fantasía Épica', 6, ' Un hobbit llamado Frodo emprende una peligrosa misión para destruir el Anillo Único y salvar la Tierra Media del Señor Oscuro Sauron.', 'Inglés', '2018', 20),
(21, 'Aventura Marítima', 1, '  Un capitán obsesionado persigue a un cachalote blanco gigante, embarcándose en un viaje lleno de peligros y reflexiones sobre la naturaleza del hombre.', 'Inglés', '1984', 21),
(22, 'Romance de Época', 4, 'Elizabeth Bennet y Fitzwilliam Darcy superan sus prejuicios sociales y orgullo personal para descubrir un amor verdadero.', 'Inglés', '2012', 22),
(23, 'Realismo Mágico', 2, ' La historia de la familia Buendía se desarrolla a lo largo de siete generaciones en el pueblo ficticio de Macondo, marcado por la soledad y la decadencia.', 'Español', '1976', 23),
(24, 'Novela Caballeresca', 10, ' Un hidalgo de la Mancha emprende un viaje de aventuras creyendo ser un caballero andante, acompañado por su fiel escudero Sancho Panza.', 'Español', '1982', 24),
(25, 'Tragedia', 8, ' El príncipe de Dinamarca lucha contra la locura y la venganza tras la muerte de su padre y el matrimonio de su madre con su tío.', 'Español', '2006', 25),
(26, 'Fantasía Infantil', 4, ' Un piloto se encuentra con un pequeño príncipe proveniente de un asteroide, quien le enseña sobre la amistad, el amor y la importancia de lo esencial.', 'Francés', '1994', 26),
(27, 'Novela Psicológica', 3, 'Un exestudiante pobre comete un asesinato y debe lidiar con la culpa y la persecución de la policía.', 'Ruso', '2018', 27),
(28, 'Novela Romántica', 1, ' Jay Gatsby, un millonario misterioso, organiza fiestas extravagantes para recuperar a su antiguo amor, Daisy Buchanan. ', 'Inglés', '2022', 28),
(29, 'Fantasía Infantil', 5, ' Alicia cae por un agujero de conejo y se adentra en un mundo surrealista lleno de personajes extraños y aventuras emocionantes.', 'Inglés', '1982', 29),
(30, 'Fábula Política', 6, ' Los animales de una granja se rebelan contra su dueño humano y establecen una sociedad igualitaria, pero pronto la corrupción y el totalitarismo se apoderan de ellos.', 'Inglés', '2010', 30);

--
-- Disparadores `detalles_libros`
--
DELIMITER $$
CREATE TRIGGER `LibrosAgotados` AFTER UPDATE ON `detalles_libros` FOR EACH ROW BEGIN
	IF NEW.cantidad_ejempl = 0 AND OLD.cantidad_ejempl > 0 THEN
    	UPDATE libros SET state_libro = 0 WHERE libros.id_libro = OLD.id_libro;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `LibrosRehabilitados` AFTER UPDATE ON `detalles_libros` FOR EACH ROW BEGIN
	IF NEW.cantidad_ejempl > 0 AND OLD.cantidad_ejempl = 0 THEN
    	UPDATE libros SET state_libro = 1 WHERE libros.id_libro = OLD.id_libro;
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(11) NOT NULL COMMENT 'Clave Primaria del empleado.',
  `nombre_empleado` varchar(15) NOT NULL COMMENT 'Nombre del empleado.',
  `apellido_empleado` varchar(15) NOT NULL COMMENT 'Apellido del empleado.',
  `fecha_nacimiento_empleado` date NOT NULL COMMENT 'Fecha de nacimiento del empleado.',
  `CI_empleado` varchar(15) NOT NULL COMMENT 'Cédula de identidad del empleado.',
  `direccion` varchar(75) NOT NULL COMMENT 'Dirección de vivienda del empleado.',
  `telefono` varchar(10) NOT NULL DEFAULT 'Ninguno' COMMENT 'Número de teléfono móvil del empleado.',
  `email` varchar(50) NOT NULL DEFAULT 'Ninguno' COMMENT 'Correo electrónico del empleado.',
  `state_empleado` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado actual del empleado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombre_empleado`, `apellido_empleado`, `fecha_nacimiento_empleado`, `CI_empleado`, `direccion`, `telefono`, `email`, `state_empleado`) VALUES
(1, 'Valeria', 'Rodríguez', '1993-11-22', '987654321', 'Av. Principal, Ciudad XYZ', '555-4321', 'santiago.perez@email.com', 1),
(2, 'Santiago', 'Pérez', '1987-05-15', '123456789', 'Calle 123, Ciudad ABC', '555-1234', 'valeria.rodriguez@email.com', 1),
(3, 'Alejandro', 'Gómez', '1985-03-10', '246813579', 'Carrera 45, Ciudad LMN', '555-2468', 'alejandro.gomez@email.com', 1),
(4, 'Carolina', 'Pérez', '1987-05-15', '555888777', 'Calle 123, Ciudad ABC', '555-7777', 'carolina.vargas@email.com', 1),
(5, 'Juan', 'Martínez', '1982-06-25', '369258147', 'Av. Central, Ciudad RST', '555-3692', 'juan.martinez@email.com', 1),
(6, 'Lucía', 'Hernández', '1988-12-18', '741852963', 'Carrera 78, Ciudad UVW', '555-8529', 'lucia.hernandez@email.com', 1),
(7, 'Roberto', 'López', '1995-04-07', '159357486', 'Calle 63, Ciudad XYZ', '555-1593', 'roberto.lopez@email.com', 1),
(8, 'Mariana', 'Sánchez', '1984-06-30', '369147258', 'Av. Sur, Ciudad RST', '555-3691', 'mariana.sanchez@email.com', 1),
(9, 'Manuel', 'Torres', '1991-01-12', '741963852', 'Calle 54, Ciudad ABC', ' 555-7419', 'manuel.torres@email.com', 1),
(10, 'Laura', 'Ramírez', '1986-08-05', '963258147', 'Av. Norte, Ciudad QWE', '555-9632', 'laura.ramirez@email.com', 1);

--
-- Disparadores `empleados`
--
DELIMITER $$
CREATE TRIGGER `EmpleadoSuspendido` AFTER UPDATE ON `empleados` FOR EACH ROW BEGIN
	IF (SELECT ci_usuario FROM usuarios WHERE usuarios.ci_usuario = OLD.CI_empleado) IS NOT NULL THEN
		UPDATE usuarios SET rol = 'usuario' WHERE usuarios.ci_usuario = OLD.CI_empleado;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ModificarUsuarioDeNuevoEmpleado` AFTER INSERT ON `empleados` FOR EACH ROW BEGIN
	IF (SELECT ci_usuario FROM usuarios WHERE usuarios.ci_usuario = NEW.CI_empleado) IS NOT NULL THEN
		UPDATE usuarios SET rol = 'empleado' WHERE usuarios.ci_usuario = NEW.CI_empleado;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `RehabilitarEmpleado` AFTER UPDATE ON `empleados` FOR EACH ROW BEGIN
	IF (SELECT ci_usuario FROM usuarios WHERE usuarios.ci_usuario = OLD.CI_empleado) IS NOT NULL AND NEW.state_empleado = 1 AND OLD.state_empleado = 0 THEN
		UPDATE usuarios SET rol = 'empleado' WHERE usuarios.ci_usuario = OLD.CI_empleado;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `empleado_usuario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `empleado_usuario` (
`User_Emp_ID` int(11)
,`Usuario_ID` int(11)
,`Empleado_ID` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `libros`
--

CREATE TABLE `libros` (
  `id_libro` int(11) NOT NULL COMMENT 'Clave Primaria del libro.',
  `titulo_libro` varchar(50) NOT NULL COMMENT 'Título del libro.',
  `editorial` varchar(35) NOT NULL COMMENT 'Editorial del libro.',
  `state_libro` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Existencia del libro.',
  `id_autor` int(11) NOT NULL COMMENT 'Clave Foránea perteneciente al autor.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `libros`
--

INSERT INTO `libros` (`id_libro`, `titulo_libro`, `editorial`, `state_libro`, `id_autor`) VALUES
(1, 'La Canción de las Estrellas', 'Luces Brillantes Editorial', 1, 1),
(2, 'El Reino de las Almas Olvidadas', 'Estrellas Fugaces Editor', 1, 2),
(3, 'El Diario de un Ninja ', 'Mundo de Papel Publishing', 1, 3),
(4, 'Crónicas de Terra Nova ', 'Páginas Doradas Editorial', 1, 4),
(5, 'El Misterio de la Biblioteca Perdida ', 'Plumas y Tinteros Press', 1, 5),
(6, 'El Hechizo del Chamán', 'Aventuras Literarias', 1, 6),
(7, 'Leyendas del Inframundo ', 'Océano de Libros ', 1, 7),
(8, 'Sonetos a la Luna ', 'Imaginación Infinita ', 1, 8),
(9, 'Sinfonía de Almas ', 'Sueños de Tinta Press', 1, 9),
(10, 'El Vuelo del Fénix', 'Letras Encantadas', 1, 10),
(11, 'La Profecía del Oráculo ', 'Palabras Mágicas Editor', 1, 11),
(12, 'El Jardín de los Sueños ', 'Libros Alados Editorial', 1, 12),
(13, 'El Maestro de las Marionetas ', 'Universo de Escrituras ', 1, 13),
(14, 'La Hija del Sol ', 'Escritores Soñadores ', 1, 14),
(15, 'El Último Samurai ', ' Hojas de Palabras ', 1, 15),
(16, 'La Biblioteca de Babel ', 'Páginas Encantadas', 1, 16),
(17, 'El Alquimista ', 'Laberinto de Historias ', 1, 17),
(18, 'Cumbres Borrascosas', 'Tinta Creativa Publisher', 1, 18),
(19, '1984', 'Palabras en Fuego ', 1, 19),
(20, 'El Señor de los Anillos', 'Escritores del Alma Press', 1, 20),
(21, 'Moby Dick ', 'Libros en el Viento ', 1, 21),
(22, 'Orgullo y Prejuicio ', 'Tren de Letras Editorial', 1, 22),
(23, 'Soledad y cien años ', 'Nubes de Papel ', 1, 23),
(24, 'Don Quijote de la Mancha ', 'Camino de Libros Press', 1, 24),
(25, 'Hamlet', 'Espejo de Palabras ', 1, 25),
(26, 'El Principito', 'Fuego Literario ', 1, 26),
(27, 'Crimen y Castigo', 'Páginas en Blanco ', 1, 27),
(28, 'El Gran Gatsby', 'Sueños de Papel ', 1, 28),
(29, 'Alicia en el País de las Maravillas', 'Plumas Aladas Publisher', 1, 29),
(30, 'Rebelión en la Granja ', 'Mar de Libros Press', 1, 30);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `libros_detalles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `libros_detalles` (
`DetallesLibros_ID` int(11)
,`Libro_Genero` varchar(20)
,`Cantidad_Ejemplares` int(11)
,`Libro_Sinopsis` varchar(255)
,`Libro_Idioma` varchar(15)
,`Libro_Fecha` year(4)
,`Libro_ID` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `libros_prestamos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `libros_prestamos` (
`Prestamo_ID` int(11)
,`Fecha_Emision` datetime
,`Fecha_Tope` datetime
,`Fecha_Recepcion` datetime
,`Prestamo_Estado` tinyint(1)
,`Libro_ID` int(11)
,`User_Emp_ID` int(11)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `prestamos`
--

CREATE TABLE `prestamos` (
  `id_prestamo` int(11) NOT NULL COMMENT 'Clave Primaria del préstamo.',
  `fecha` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'Fecha y hora de la realización del préstamo.',
  `fecha_limite` datetime NOT NULL DEFAULT (current_timestamp() + interval 15 day) COMMENT 'Fecha y hora límite para entregar el préstamo.',
  `fecha_entrega` datetime DEFAULT NULL COMMENT 'Fecha y hora de entrega del préstamo.',
  `state` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado actual del préstamo.',
  `id_libro` int(11) NOT NULL COMMENT 'Clave Foránea perteneciente al libro.',
  `id_us_em` int(11) NOT NULL COMMENT 'Clave Fóranea perteneciente a la tabla puente usuario-empleado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `prestamos`
--

INSERT INTO `prestamos` (`id_prestamo`, `fecha`, `fecha_limite`, `fecha_entrega`, `state`, `id_libro`, `id_us_em`) VALUES
(1, '2024-06-19 09:18:17', '2024-07-04 09:18:17', NULL, 1, 21, 1),
(2, '2024-06-19 20:08:16', '2024-07-04 20:08:16', '2024-06-19 20:17:59', 1, 8, 2),
(3, '2024-06-19 20:15:49', '2024-07-04 20:15:49', NULL, 1, 21, 3),
(4, '2024-06-20 16:32:31', '2024-07-05 16:32:31', '2024-06-20 16:34:11', 1, 7, 4);

--
-- Disparadores `prestamos`
--
DELIMITER $$
CREATE TRIGGER `PenalizarUsuario` AFTER UPDATE ON `prestamos` FOR EACH ROW BEGIN
	IF OLD.fecha_entrega IS NULL AND NEW.fecha_entrega > OLD.fecha_limite THEN
		UPDATE usuarios SET penalizacion = 1 WHERE id_usuario = (SELECT id_usuario FROM usuario_empleado WHERE usuario_empleado.id_us_em = OLD.id_us_em);
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `RestarLibroPorPrestamo` AFTER INSERT ON `prestamos` FOR EACH ROW BEGIN
UPDATE detalles_libros SET detalles_libros.cantidad_ejempl = detalles_libros.cantidad_ejempl - 1 WHERE detalles_libros.id_libro = NEW.id_libro;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `SumarLibroPorDevolucion` AFTER UPDATE ON `prestamos` FOR EACH ROW BEGIN
	IF OLD.fecha_entrega IS NULL AND NEW.fecha_entrega IS NOT NULL THEN
		UPDATE detalles_libros SET cantidad_ejempl = detalles_libros.cantidad_ejempl + 1 WHERE detalles_libros.id_libro = OLD.id_libro;
	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `SuspenderUsuarioPorLectura` AFTER INSERT ON `prestamos` FOR EACH ROW BEGIN
	UPDATE usuarios SET state_usuario = 0 WHERE id_usuario = (SELECT id_usuario FROM usuario_empleado WHERE usuario_empleado.id_us_em = NEW.id_us_em);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tabla_libros`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tabla_libros` (
`Libro_ID` int(11)
,`Libro_Titulo` varchar(50)
,`Libro_Editorial` varchar(35)
,`Libro_Estado` tinyint(1)
,`Autor_ID` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `tabla_usuarios`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `tabla_usuarios` (
`Usuario_ID` int(11)
,`Usuario_Nombre` varchar(15)
,`Usuario_Apellido` varchar(15)
,`Usuario_Nacimiento` date
,`Usuario_Username` varchar(20)
,`Usuario_Penalizacion` tinyint(1)
,`Usuario_Estado` tinyint(1)
,`Usuario_Rol` enum('usuario','empleado')
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL COMMENT 'Clave Primaria del usuario.',
  `nombre_usuario` varchar(15) NOT NULL COMMENT 'Nombre del usuario.',
  `apellido_usuario` varchar(15) NOT NULL COMMENT 'Apellido del usuario.',
  `ci_usuario` varchar(15) NOT NULL COMMENT 'Cédula de identidad del usuario.',
  `fecha_nacimiento_usuario` date NOT NULL COMMENT 'Fecha de nacimiento del usuario.',
  `username` varchar(20) NOT NULL COMMENT 'Username del usuario.',
  `contrasena` varchar(16) NOT NULL COMMENT 'Contraseña de acceso del usuario.',
  `penalizacion` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Penalización por atraso de entrega.',
  `state_usuario` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Estado actual del usuario.',
  `rol` enum('usuario','empleado') NOT NULL DEFAULT 'usuario' COMMENT 'Rol del registrado (usuario o empleado).'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre_usuario`, `apellido_usuario`, `ci_usuario`, `fecha_nacimiento_usuario`, `username`, `contrasena`, `penalizacion`, `state_usuario`, `rol`) VALUES
(1, 'Juan', 'Perez', '1234567890', '1990-01-01', 'jperez', 'contraseña123', 0, 1, 'usuario'),
(2, 'Maria', 'Rodriguez', '2345678901', '1995-02-02', 'mrodriguez', '12345678', 0, 1, 'usuario'),
(3, 'Carlos', 'Gomez', '3456789012', '2000-03-03', 'cgomez', 'gomez123', 0, 0, 'usuario'),
(4, 'Laura', 'Hernandez', '4567890123', '1985-04-04', 'lhernandez', 'laura123', 0, 1, 'usuario'),
(5, 'Luis', 'Martinez', '5678901234', '1993-05-05', 'lmartinez', 'martinez123', 0, 1, 'usuario'),
(6, 'Ana', 'Sanchez', '6789012345', '1988-06-06', 'jlopez', 'ana1988', 0, 1, 'usuario'),
(7, 'Jorge', 'Lopez', '7890123456', '1997-07-07', 'jana', '123456jl', 0, 1, 'usuario'),
(8, 'Isabel', 'Torres', '8901234567', '1982-08-08', 'itorres', 'isabel82', 0, 1, 'usuario'),
(9, 'David', 'Ramirez', '9012345678', '1998-09-09', 'dramirez', 'davidram', 0, 1, 'usuario'),
(10, 'Sofia', 'Gonzalez', '0123456789', '1991-10-10', 'sgonzalez', 'gonzalez10', 0, 0, 'usuario'),
(11, 'Alejandro', 'Castro', '1230123456', '1980-11-11', 'acastro', 'alejandro11', 0, 1, 'usuario'),
(12, 'Andrea', 'Vargas', '2341234567', '1996-12-12', 'avargas', 'andrea96', 0, 1, 'usuario'),
(13, 'Ernesto', 'Morales', '3452345678', '1987-01-13', 'emorales', 'ernesto1987', 0, 1, 'usuario'),
(14, 'Camila', 'Soto', '4563456789', '1999-02-14', 'csoto', 'camila99', 0, 1, 'usuario'),
(15, 'Oscar', 'Jimenez', '5674567890', '1984-03-15', 'ojimenez', 'oscar84', 0, 1, 'usuario'),
(16, 'Paola', 'Vega', '6785678901', '1994-04-16', 'pvega', 'paola1994', 0, 1, 'usuario'),
(17, 'Raul', 'Nuñez', '7896789012', '1989-05-17', 'rnunez', 'rauln89', 0, 1, 'usuario'),
(18, 'Natalia', 'Castillo', '8907890123', '1992-06-18', 'ncastillo', 'natalia92', 0, 1, 'usuario'),
(19, 'Guillermo', 'Paredes', '9018901234', '1983-07-19', 'gparedes', 'guillermo83', 0, 1, 'usuario'),
(20, 'Julia', 'Figueroa', '0129012345', '2001-08-20', 'jfigueroa', 'juliafig', 0, 1, 'usuario');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_empleado`
--

CREATE TABLE `usuario_empleado` (
  `id_us_em` int(11) NOT NULL COMMENT 'Clave Primaria de la tabla puente usuario-empleado.',
  `id_usuario` int(11) NOT NULL COMMENT 'Clave Foránea perteneciente al usuario.',
  `id_empleado` int(11) NOT NULL COMMENT 'Clave Foránea perteneciente al empleado.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_empleado`
--

INSERT INTO `usuario_empleado` (`id_us_em`, `id_usuario`, `id_empleado`) VALUES
(1, 10, 2),
(2, 1, 2),
(3, 3, 1),
(4, 12, 4);

-- --------------------------------------------------------

--
-- Estructura para la vista `autores_libros`
--
DROP TABLE IF EXISTS `autores_libros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `autores_libros`  AS SELECT `autores`.`id_autor` AS `Autor_ID`, `autores`.`nombre_autor` AS `Autor_Nombre`, `autores`.`apellido_autor` AS `Autor_Apellido`, `autores`.`nacionalidad` AS `Autor_Nacionalidad` FROM `autores` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `datos_empleados`
--
DROP TABLE IF EXISTS `datos_empleados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `datos_empleados`  AS SELECT `empleados`.`id_empleado` AS `Empleado_ID`, `empleados`.`nombre_empleado` AS `Empleado_Nombre`, `empleados`.`apellido_empleado` AS `Empleado_Apellido`, `empleados`.`fecha_nacimiento_empleado` AS `Empleado_Nacimiento`, `empleados`.`CI_empleado` AS `Empleado_CI`, `empleados`.`direccion` AS `Empleado_Direccion`, `empleados`.`telefono` AS `Empleado_Telefono`, `empleados`.`email` AS `Empleado_Email`, `empleados`.`state_empleado` AS `Empleado_Estado` FROM `empleados` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `empleado_usuario`
--
DROP TABLE IF EXISTS `empleado_usuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `empleado_usuario`  AS SELECT `usuario_empleado`.`id_us_em` AS `User_Emp_ID`, `usuario_empleado`.`id_usuario` AS `Usuario_ID`, `usuario_empleado`.`id_empleado` AS `Empleado_ID` FROM `usuario_empleado` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `libros_detalles`
--
DROP TABLE IF EXISTS `libros_detalles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `libros_detalles`  AS SELECT `detalles_libros`.`id_detlibro` AS `DetallesLibros_ID`, `detalles_libros`.`genero` AS `Libro_Genero`, `detalles_libros`.`cantidad_ejempl` AS `Cantidad_Ejemplares`, `detalles_libros`.`sinopsis` AS `Libro_Sinopsis`, `detalles_libros`.`idioma` AS `Libro_Idioma`, `detalles_libros`.`fecha_libro` AS `Libro_Fecha`, `detalles_libros`.`id_libro` AS `Libro_ID` FROM `detalles_libros` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `libros_prestamos`
--
DROP TABLE IF EXISTS `libros_prestamos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `libros_prestamos`  AS SELECT `prestamos`.`id_prestamo` AS `Prestamo_ID`, `prestamos`.`fecha` AS `Fecha_Emision`, `prestamos`.`fecha_limite` AS `Fecha_Tope`, `prestamos`.`fecha_entrega` AS `Fecha_Recepcion`, `prestamos`.`state` AS `Prestamo_Estado`, `prestamos`.`id_libro` AS `Libro_ID`, `prestamos`.`id_us_em` AS `User_Emp_ID` FROM `prestamos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tabla_libros`
--
DROP TABLE IF EXISTS `tabla_libros`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `tabla_libros`  AS SELECT `libros`.`id_libro` AS `Libro_ID`, `libros`.`titulo_libro` AS `Libro_Titulo`, `libros`.`editorial` AS `Libro_Editorial`, `libros`.`state_libro` AS `Libro_Estado`, `libros`.`id_autor` AS `Autor_ID` FROM `libros` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `tabla_usuarios`
--
DROP TABLE IF EXISTS `tabla_usuarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hernan`@`localhost` SQL SECURITY DEFINER VIEW `tabla_usuarios`  AS SELECT `usuarios`.`id_usuario` AS `Usuario_ID`, `usuarios`.`nombre_usuario` AS `Usuario_Nombre`, `usuarios`.`apellido_usuario` AS `Usuario_Apellido`, `usuarios`.`fecha_nacimiento_usuario` AS `Usuario_Nacimiento`, `usuarios`.`username` AS `Usuario_Username`, `usuarios`.`penalizacion` AS `Usuario_Penalizacion`, `usuarios`.`state_usuario` AS `Usuario_Estado`, `usuarios`.`rol` AS `Usuario_Rol` FROM `usuarios` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `autores`
--
ALTER TABLE `autores`
  ADD PRIMARY KEY (`id_autor`);

--
-- Indices de la tabla `detalles_libros`
--
ALTER TABLE `detalles_libros`
  ADD PRIMARY KEY (`id_detlibro`),
  ADD KEY `id_libro` (`id_libro`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD UNIQUE KEY `CI_empleado` (`CI_empleado`),
  ADD UNIQUE KEY `telefono` (`telefono`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `libros`
--
ALTER TABLE `libros`
  ADD PRIMARY KEY (`id_libro`),
  ADD UNIQUE KEY `titulo_libro` (`titulo_libro`),
  ADD KEY `id_autor` (`id_autor`);

--
-- Indices de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD PRIMARY KEY (`id_prestamo`),
  ADD KEY `id_libro` (`id_libro`),
  ADD KEY `id_us_em` (`id_us_em`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `ci_usuario` (`ci_usuario`);

--
-- Indices de la tabla `usuario_empleado`
--
ALTER TABLE `usuario_empleado`
  ADD PRIMARY KEY (`id_us_em`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_empleado` (`id_empleado`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `autores`
--
ALTER TABLE `autores`
  MODIFY `id_autor` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del autor.', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `detalles_libros`
--
ALTER TABLE `detalles_libros`
  MODIFY `id_detlibro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria de los detalles del libro.', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del empleado.', AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `libros`
--
ALTER TABLE `libros`
  MODIFY `id_libro` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del libro.', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `prestamos`
--
ALTER TABLE `prestamos`
  MODIFY `id_prestamo` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del préstamo.', AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria del usuario.', AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT de la tabla `usuario_empleado`
--
ALTER TABLE `usuario_empleado`
  MODIFY `id_us_em` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Clave Primaria de la tabla puente usuario-empleado.', AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `detalles_libros`
--
ALTER TABLE `detalles_libros`
  ADD CONSTRAINT `detalles_libros_ibfk_1` FOREIGN KEY (`id_libro`) REFERENCES `libros` (`id_libro`);

--
-- Filtros para la tabla `libros`
--
ALTER TABLE `libros`
  ADD CONSTRAINT `libros_ibfk_1` FOREIGN KEY (`id_autor`) REFERENCES `autores` (`id_autor`) ON DELETE CASCADE;

--
-- Filtros para la tabla `prestamos`
--
ALTER TABLE `prestamos`
  ADD CONSTRAINT `prestamos_ibfk_1` FOREIGN KEY (`id_libro`) REFERENCES `libros` (`id_libro`),
  ADD CONSTRAINT `prestamos_ibfk_2` FOREIGN KEY (`id_us_em`) REFERENCES `usuario_empleado` (`id_us_em`);

--
-- Filtros para la tabla `usuario_empleado`
--
ALTER TABLE `usuario_empleado`
  ADD CONSTRAINT `usuario_empleado_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `usuario_empleado_ibfk_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
