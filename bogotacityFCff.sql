CREATE DATABASE IF NOT EXISTS bogotaCityFC;
-- DROP DATABASE bogotacityfc;
USE bogotaCityFC;

CREATE TABLE IF NOT EXISTS usuario (
    nombreUsuario VARCHAR(50) NOT NULL,
    idUsuario INT PRIMARY KEY auto_increment,
    contrasenia TEXT(50) NOT NULL,
    tipoUsuario VARCHAR(20) NOT NULL,
    telefonoUsuario VARCHAR(10) NOT NULL UNIQUE,
    estadoUsuario BIT NOT NULL
);

CREATE TABLE IF NOT EXISTS categoria (
    idCategoria int PRIMARY KEY auto_increment,
    nombreCategoria VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS evento (
    idEvento int PRIMARY KEY auto_increment,
    fechaEvento DATE NOT NULL,
    tipoEvento VARCHAR(50),
    resumenEvento VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS rendimientoJugador (
    idRendimiento int PRIMARY KEY AUTO_INCREMENT,
    idUsuarioFK int NOT NULL,
    idEventoFK int NOT NULL,
    asistencia BIT NOT NULL,
	metrosRecorridos INT NOT NULL,
    pasesRealizados INT NOT NULL,
    golesRealizados INT NOT NULL,
    pasesFallidos INT NOT NULL,
    golesFallidos INT NOT NULL,
    comentarios VARCHAR(100) NULL,
    FOREIGN KEY (idUsuarioFK) REFERENCES usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idRendimiento) REFERENCES categoria(idCategoria) ON DELETE CASCADE,
    FOREIGN KEY (idEventoFK) REFERENCES evento(idEvento) ON DELETE CASCADE
);

-- DROP TABLE actividadBD;
CREATE TABLE IF NOT EXISTS actividadBD (
    idActividad INT PRIMARY KEY AUTO_INCREMENT,
    registro VARCHAR(100) NOT NULL,
    fechaActividad DATETIME NOT NULL
);


/* Procedimientos para insertar datos */

use bogotacityfc;
-- usuarios
 DELIMITER //
	
	CREATE PROCEDURE registrarUsuario(IN nombre VARCHAR (50),id VARCHAR(16),contrasenia TINYTEXT,tipo VARCHAR(20),telefono VARCHAR(10),estado BIT)
	BEGIN
		INSERT INTO usuario VALUES (nombre, id, contrasenia, tipo, telefono, estado);
    END

// DELIMITER ;


-- eventos
 DELIMITER //
	
	CREATE PROCEDURE registrarEvento(IN fechaEvento DATE,tipoEvento VARCHAR(50),resumen VARCHAR(100))
	BEGIN
		INSERT INTO evento VALUES (fechaEvento, tipoEvento, resumen);
    END

// DELIMITER ;

 DELIMITER //
	
	CREATE PROCEDURE registrarEventoRapido(IN tipoEvento VARCHAR(50),resumen VARCHAR(100))
	BEGIN
		INSERT INTO evento VALUES (CURDATE(), tipoEvento, resumen);
    END

// DELIMITER ;



-- Rendimientojugador
-- Debido a la forma en que opera la tabla, el procedimiento para insertar datos ala tabla incluye insertar los datos de evento y categoria 
DELIMITER //
	CREATE PROCEDURE registrarRendimiento(IN idUsuarioFK INT(11), asistencia BIT, metrosRecorridos INT(11), pasesRealizados INT(11), golesRealizados INT(11), pasesFallidos INT(11), golesFallidos INT(11), comentarios VARCHAR(100), nombreCategoria varchar(50), idEvento int(11))
	BEGIN
		INSERT INTO categoria(nombreCategoria) VALUES (nombreCategoria);
        INSERT INTO rendimientoJugador(idUsuarioFK,idEventoFK,asistencia,metrosRecorridos,pasesRealizados,golesRealizados,pasesFallidos,golesFallidos,comentarios) VALUES (idUsuarioFK, idEvento, asistencia, metrosRecorridos, pasesRealizados, golesRealizados, pasesFallidos, golesFallidos, comentarios);
    END
// DELIMITER ;

-- DROP PROCEDURE registrarRendimiento;



/* Procedimientos y Vistas para consulta de datos */

-- Filtrar Jugadores por evento
DELIMITER // 
	CREATE PROCEDURE consultarJugadorEvento(IN idEventoRef int(11))
    BEGIN
     SELECT idEvento, tipoEvento, fechaEvento, resumenEvento, nombreUsuario, metrosRecorridos, pasesRealizados, golesRealizados, pasesFallidos, golesFallidos FROM 
evento e INNER JOIN rendimientoJugador rj ON idEventoRef = e.idEvento = rj.idEventoFK INNER JOIN usuario u ON u.idUsuario = rj.idUsuarioFK;
    END
// DELIMITER ;

-- Filtrar jugadores por nombre
DELIMITER //
	CREATE PROCEDURE consultarJugadorNombre(IN nombreJugadorRef VARCHAR(50))
    BEGIN
		SELECT idUsuario, nombreUsuario, tipoUsuario, telefonoUsuario, estadoUsuario FROM usuario WHERE nombreUsuario LIKE  CONCAT('%', nombreJugadorRef, '%');
    END
// DELIMITER ;

-- Filtrar jugadores por telefono
DELIMITER //
	CREATE PROCEDURE consultarJugadorTel(IN telefonoUsuarioRef VARCHAR(10))
    BEGIN
		SELECT idUsuario, nombreUsuario, tipoUsuario, telefonoUsuario, estadoUsuario FROM usuario WHERE telefonoUsuario LIKE  CONCAT('%', telefonoUsuarioRef, '%');
    END
// DELIMITER ;

-- Filtrar jugadores por categoria 
DELIMITER //
	CREATE PROCEDURE consultarJugadorCategoria(IN nombreCategoriaRef VARCHAR(50))
    BEGIN
		SELECT idUsuario, nombreUsuario, nombreCategoria FROM categoria c INNER JOIN rendimientoJugador rj ON c.idCategoria = rj.idRendimiento INNER JOIN usuario u ON rj.idUsuarioFK = u.idUsuario  WHERE c.nombreCategoria = nombreCategoriaRef GROUP BY c.nombreCategoria;
    END
// DELIMITER ;

-- Reporte de usuario por categoria
DELIMITER //
	CREATE PROCEDURE reporteJugadorCategoria(IN idUsuarioRef int, nombreCategoriaRed VARCHAR(50))
    BEGIN 
		SELECT idUsuario, nombreUsuario, nombreCategoria, SUM(rj.metrosRecorridos), SUM(rj.pasesRealizados), SUM(rj.golesRealizados), SUM(rj.pasesFallidos), SUM(rj.golesFallidos) FROM usuario u INNER JOIN rendimientoJugador rj ON u.idUsuario = rj.idUsuarioFK INNER JOIN categoria c ON rj.idRendimiento = c.idCategoria WHERE u.idUsuario = idUsuarioRef GROUP BY idRendimiento;
    END
// DELIMITER ;

-- Rendimiento historico de jugador especifico
DELIMITER //
	CREATE PROCEDURE rendimientoHistorico(IN idJugadorRef int)
    BEGIN 
		SELECT idUsuario, nombreUsuario, idRendimiento, metrosRecorridos, pasesRealizados, golesRealizados, pasesFallidos, golesFallidos FROM usuario u INNER JOIN rendimientoJugador rj ON idJugadorRef = rj.idUsuarioFK INNER JOIN categoria c ON rj.idRendimiento = c.idCategoria GROUP BY rj.idRendimiento;
    END
// DELIMITER ;

-- asistencia de jugador a eventos
DELIMITER //
	CREATE PROCEDURE asistenciasJugador(IN idJugadorRef int)
    BEGIN
		SELECT idUsuario, nombreUsuario, nombreCategoria, asistencia, fechaEvento, tipoEvento, nombreCategoria, resumenEvento FROM usuario u INNER JOIN rendimientoJugador rj ON u.idUsuario = rj.idUsuarioFK INNER JOIN evento e ON e.idEvento = rj.idEventoFK INNER JOIN categoria c ON rj.idRendimiento = c.idCategoria WHERE u.idUsuario = idJugadorRef GROUP BY fechaEvento ORDER BY fechaEvento DESC ;
    END 
// DELIMITER ;

CALL asistenciasJugador(1);
-- Crear Ranking de rendimiento
DELIMITER //
	CREATE PROCEDURE crearRankingJugadores()
    BEGIN
		CREATE VIEW rankingJugadores AS SELECT idUsuario,nombreUsuario, SUM(metrosRecorridos) AS metrosRecorridos, SUM(pasesRealizados) AS pasesRealizados, SUM(golesRealizados) AS golesRealizados, SUM(pasesFallidos) AS pasesFallidos, SUM(golesFallidos) AS golesFallidos, SUM((metrosRecorridos * 0.1 + pasesRealizados * 1 + golesRealizados * 3) - (pasesFallidos * 0.5 + golesFallidos*2)) AS puntaje FROM
        rendimientoJugador rj INNER JOIN usuario u ON u.idUsuario = rj.idUsuarioFK 
		GROUP BY u.idUsuario, u.nombreUsuario
		ORDER BY puntaje DESC;
    END
// DELIMITER ;

CALL crearRankingJugadores();


/* Triggers e Historial de cambios */

-- delete Triggers
DELIMITER //
CREATE TRIGGER deleteCategoria AFTER DELETE ON categoria for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Eliminado valor en tabla categoria', NOW());
	END;
// DELIMITER ;

DELIMITER //
CREATE TRIGGER deleteEvento AFTER DELETE ON evento for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Eliminado valor en tabla evento', NOW());
	END;
// DELIMITER ;

DELIMITER //
CREATE TRIGGER deleteUsuario AFTER DELETE ON usuario for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Eliminado valor en tabla usuario', NOW());
	END;
// DELIMITER ;

DELIMITER //
CREATE TRIGGER deleteRendimiento AFTER DELETE ON rendimientoJugador for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Eliminado valor en tabla rendimientoJugador', NOW());
	END;
// DELIMITER ;


-- Insert Trigger
DELIMITER //
CREATE TRIGGER insertCategoria AFTER INSERT ON categoria for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Insertado valor en tabla categoria', NOW());
	END;
// DELIMITER ;

DELIMITER //
CREATE TRIGGER insertEvento AFTER INSERT ON evento for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Insertado valor en tabla evento', NOW());
	END;
// DELIMITER ;


DELIMITER //
CREATE TRIGGER insertUsuario AFTER INSERT ON usuario for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Insertado valor en tabla usuario', NOW());
	END;
// DELIMITER ;


DELIMITER //
CREATE TRIGGER insertRendimiento AFTER INSERT ON rendimientoJugador for each row
	BEGIN
		INSERT INTO actividadBD(registro,fechaActividad) VALUES ('Insertado valor en tabla RendimientoJugador', NOW());
	END;
// DELIMITER ;

-- Inserciones en la tabla usuario
INSERT INTO usuario (nombreUsuario, contrasenia, tipoUsuario, telefonoUsuario, estadoUsuario) VALUES 
('BELTRAN ROMERO, DYLAN SMITH', 'Pass6320', 'jugador', '3223070191', 1),
('CUEVAS ORDOÑEZ, MIGUEL ANGEL', 'Pass9569', 'jugador', '3658934589', 1),
('FAJARDO BECERRIA, KAMIL', 'Pass9504', 'jugador', '3953359246', 1),
('GARCIA VELASQUEZ, NICOLAS', 'Pass1896', 'jugador', '3183342691', 1),
('HERNANDEZ MORALES, ANDREY DAVID', 'Pass9879', 'jugador', '3293199154', 1),
('LEON CARVAJAL, JORGE ELIECER', 'Pass3287', 'jugador', '3017678529', 1),
('LOPEZ DIAZ, JUAN DIEGO', 'Pass9851', 'jugador', '3881058958', 1),
('MADRIGAL BARRERA, TERRY STEVAN', 'Pass8463', 'jugador', '3292693790', 1),
('MATIZ LINARES, JUSTIEN MATIAS', 'Pass1548', 'jugador', '3334701432', 1),
('PUERTO GONZALEZ, DANIEL ESTEBAN', 'Pass9361', 'jugador', '3261156963', 1),
('RENDON ALOMIA, IVAN DANIEL', 'Pass1303', 'jugador', '3134028906', 1),
('REYES MONTES, JOHAN SEBASTIAN', 'Pass9645', 'jugador', '3934657936', 1),
('VALENCIA HERNANDEZ, LUIS EDUARDO', 'Pass2057', 'jugador', '3202155967', 1),
('VARGAS SUAREZ, NICOLAS', 'Pass3943', 'jugador', '3337905242', 1),
('ACOSTA RAMOS, BREINER NICOLAS', 'Pass7531', 'jugador', '3842163868', 1),
('AGUIRRE FONSECA, SANTIAGO ALBERTO', 'Pass9396', 'jugador', '3537528679', 1),
('AHUMADA JAIMES, DEIVID SANTIAGO', 'Pass4136', 'jugador', '3018254913', 1),
('ALVIS CABUYA, EDUAR DANIEL', 'Pass4540', 'jugador', '3317687510', 1),
('ANGULO RAMIREZ, JUAN STEVAN', 'Pass2179', 'jugador', '3748645160', 1),
('ARDILA JIMENO, DIEGO BANDERLEY', 'Pass5550', 'jugador', '3047859139', 1),
('ARIAS LOPEZ, DIEGO FERNANDO', 'Pass7607', 'jugador', '3054442875', 1),
('ARIAS CABUYA, JUAN SEBASTIAN', 'Pass5523', 'jugador', '3052691147', 1),
('AVILA ARIAS, JERONIMO ANDRES', 'Pass5311', 'jugador', '3835149244', 1),
('AVILA HENAO, SANTIAGO', 'Pass3735', 'jugador', '3226334263', 1),
('BEJARANO GONZALEZ, JUAN FELIPE', 'Pass2181', 'jugador', '3257755698', 1),
('BELTRAN MALAGON, JUAN SEBASTIAN', 'Pass5061', 'jugador', '3079116292', 1),
('BOCANEGRA CAPERA, OSCAR DAVID', 'Pass5080', 'jugador', '3619284780', 1),
('BONILLA MUTIS, SANTIAGO', 'Pass9518', 'jugador', '3538148496', 1),
('BORJA PORTELA, DAVID JERONIMO', 'Pass5098', 'jugador', '3507649051', 1),
('BRAVO TURRIAGO, JHONNY ALEJANDRO', 'Pass2887', 'jugador', '3105545676', 1),
('BUSTOS PARDO, NICOLAS DANIEL', 'Pass2952', 'jugador', '3597541557', 1),
('CALVO ALVAREZ, SEBASTIAN ANDRES', 'Pass9240', 'jugador', '3287559215', 1),
('CANTOR REYES, JHON ALEXANDER', 'Pass6418', 'jugador', '3764892164', 1),
('CAPERA ANGULO, DAVID ESTEBAN', 'Pass3701', 'jugador', '3033014194', 1),
('CASTAÑEDA VARGAS, JHOJAN ESTEBAN', 'Pass6762', 'jugador', '3805845048', 1),
('CASTAÑEDA RODRIGUEZ, SAMUEL FELIPE', 'Pass3478', 'jugador', '3528958029', 1),
('CASTIBLANCO OSORIO, JUAN SEBASTIAN', 'Pass4808', 'jugador', '3713577238', 1),
('CASTRO GUIZA, JUAN DAVID', 'Pass1224', 'jugador', '3452566170', 1),
('CLAVIJO LOPEZ, MATEO', 'Pass4943', 'jugador', '3744481120', 1),
('CORONADO PACHON, JHONATAN DAVID', 'Pass2077', 'jugador', '3681222868', 1),
('CRISTANCHO CAINABA, LUIS ALEJANDRO', 'Pass7196', 'jugador', '3996497509', 1),
('CRUZ DIAZ, KEVIN ANDRES', 'Pass5346', 'jugador', '3462703791', 1),
('DIAZ LOPEZ, DAVID SAMUEL', 'Pass8952', 'jugador', '3516590824', 1),
('DIAZ CRUZ, ESTEBAN', 'Pass9225', 'jugador', '3499006631', 1),
('DIAZ, JUAN DANIEL', 'Pass7101', 'jugador', '3085786132', 1),
('ESCOBAR BOYACA, JUAN PABLO', 'Pass3799', 'jugador', '3139406709', 1),
('ESPITIA GAMBA, JUAN DAVID', 'Pass2878', 'jugador', '3182352494', 1),
('FARFAN CABUYA, ANDREY SANTIAGO', 'Pass1424', 'jugador', '3198455234', 1),
('GALINDO RUBIANO, JHON STEVAN', 'Pass5399', 'jugador', '3031472704', 1),
('GARCIA RODRIGUEZ, JOHAN ESTEBAN', 'Pass4455', 'jugador', '3911614049', 1),
('GARZON HORTA, JOSE MANUEL', 'Pass3437', 'jugador', '3052717862', 1),
('GOMEZ VELANDIA, JORGE NICOLAS', 'Pass9826', 'jugador', '3081323193', 1),
('GOMEZ RINCON, KEVIN FELIPE', 'Pass8011', 'jugador', '3807478821', 1),
('GONZALEZ RODRIGUEZ, DAMIAN ANDRES', 'Pass9631', 'jugador', '3187444589', 1),
('GONZALEZ FORERO, JUAN FELIPE', 'Pass5586', 'jugador', '3562632658', 1),
('GUTIERREZ RODRIGUEZ, EDINSON', 'Pass6631', 'jugador', '3616808777', 1),
('GUZMAN LIEVANO, DEIBYD STHEVENN', 'Pass4320', 'jugador', '3003623461', 1),
('IGUAVITA TERRIOS, JUAN ESTEBAN', 'Pass3218', 'jugador', '3349923824', 1),
('JUTINICO CASTELLANOS, SAMUEL', 'Pass4120', 'jugador', '3611774862', 1),
('LOPEZ DIAZ, JULIAN ESTEBAN', 'Pass3502', 'jugador', '3692897364', 1),
('MARTINEZ MARTINEZ, EIDER SANTIAGO', 'Pass5168', 'jugador', '3896591003', 1),
('MENDEZ RODRIGUEZ, SANTIAGO', 'Pass4555', 'jugador', '3983235021', 1),
('MERCHAN FLORIDO, CRISTHIAN FELIPE', 'Pass3841', 'jugador', '3028748091', 1),
('MONTOYA TIBADUIZA, WALTER ANDRES', 'Pass4256', 'jugador', '3472389684', 1),
('MORALES LOPEZ, JUAN SEBASTIAN', 'Pass4456', 'jugador', '3637791343', 1),
('MUÑOZ SEDANO, CARLOS SEBASTIAN', 'Pass5820', 'jugador', '3669765453', 1),
('OROZCO PEDRAZA, DANIEL', 'Pass4836', 'jugador', '3446013705', 1),
('ORTIZ GUZMAN, NICOLAS FELIPE', 'Pass8332', 'jugador', '3009723000', 1),
('PAEZ GARZON, MIGUEL ADOLFO', 'Pass9386', 'jugador', '3552094639', 1),
('PALACIOS HILARION, NICOLAS', 'Pass7790', 'jugador', '3197905325', 1),
('PARRA RIVEROS, DAVID FELIPE', 'Pass2049', 'jugador', '3065729501', 1),
('PARRA RIVEROS, SANTIAGO', 'Pass2584', 'jugador', '3216766090', 1),
('PEREZ MOJICA, JUAN PABLO', 'Pass5929', 'jugador', '3623571838', 1),
('PICO BOJACA, JHOEL ALEXANDER', 'Pass3037', 'jugador', '3951604756', 1),
('PICO BOJACA, SANTIAGO', 'Pass1258', 'jugador', '3925140817', 1),
('PINEDA MILLAN, DAVID SAMUEL', 'Pass1915', 'jugador', '3799682287', 1),
('PINZON SEGURA, ERICK SEBASTIAN', 'Pass7409', 'jugador', '3684095143', 1),
('PINZON TEJEDOR, EVER ANTONIO', 'Pass2319', 'jugador', '3879975908', 1),
('PINZON HERNANDEZ, JUAN DAVID', 'Pass9949', 'jugador', '3814645454', 1),
('POLOCHE MOGOLLON, JUAN SEBASTIAN', 'Pass3168', 'jugador', '3196007964', 1),
('PUENTES POVEDA, VAIRON JAVIER', 'Pass3829', 'jugador', '3082830038', 1),
('QUINTANA OSPINA, MIGUEL ANGEL', 'Pass3607', 'jugador', '3535880657', 1),
('QUINTERO BERNAL, JUAN SEBATIAN', 'Pass8146', 'jugador', '3298303236', 1),
('RAMIREZ RAMOS, CARLOS ANDRES', 'Pass4452', 'jugador', '3609731898', 1),
('RAMIREZ CRISTIANO, JUAN ANGEL', 'Pass3229', 'jugador', '3113479906', 1),
('RAMIREZ SIVA, SEBASTIAN', 'Pass3560', 'jugador', '3768412386', 1),
('RENDON MENDOZA, DAVID SANTIAGO', 'Pass5457', 'jugador', '3594726429', 1),
('RENDON MENDOZA, KEVIN ANTONIO', 'Pass2833', 'jugador', '3638550875', 1),
('REYES LIZARAZO, ARTURO', 'Pass8053', 'jugador', '3119868516', 1),
('REYES GALINDO, JESUS CAMILO', 'Pass8740', 'jugador', '3711478317', 1),
('RIAÑO ORJUELA, SAMUEL', 'Pass2623', 'jugador', '3288548712', 1),
('RINCON HOYOS, SEBASTIAN', 'Pass7661', 'jugador', '3699123055', 1),
('RIVERA ANGULO, CRISTOBAL', 'Pass3962', 'jugador', '3194874979', 1),
('RIVERA ALVAREZ, JORGE IVAN', 'Pass3049', 'jugador', '3137965646', 1),
('ROBLES DUARTE, JULIO CESAR', 'Pass4158', 'jugador', '3997946155', 1),
('RODRIGUEZ PADILLA, JUAN DAVID', 'Pass1142', 'jugador', '3827850917', 1),
('RODRIGUEZ MORA, MIGUEL ANGEL', 'Pass6252', 'jugador', '3871771415', 1),
('RODRIGUEZ DUQUE, SANTIAGO', 'Pass4691', 'jugador', '3613905247', 1),
('ROJAS GONZALEZ, ERICK SANTIAGO', 'Pass6843', 'jugador', '3884386416', 1),
('ROJAS SALAZAR, JUAN PABLO', 'Pass7605', 'jugador', '3397846296', 1),
('ROMERO SILVA, JOEL MAURICIO', 'Pass5804', 'jugador', '3083334110', 1),
('RONDON ESQUIVEL, JUAN SEBASTIAN', 'Pass8318', 'jugador', '3253333880', 1),
('RUBIANO CRUZ, FABIAN ALEJANDRO', 'Pass2685', 'jugador', '3585742884', 1),
('SAENZ GUZMAN, ANDRES JOSUETH', 'Pass9648', 'jugador', '3439081486', 1),
('SANCHEZ SILVA, JUAN CAMILO', 'Pass2213', 'jugador', '3847732922', 1),
('SANDOVAL GARCES, YOHAN ESTIVEN', 'Pass1490', 'jugador', '3595379973', 1),
('SASTOQUE JARAMILLO, JOHAN ESTIC', 'Pass2824', 'jugador', '3574509605', 1),
('SEÑA SOLANO, BRIAN MAURICIO', 'Pass9733', 'jugador', '3449548225', 1),
('SIATOYA RAMIREZ, BRAYAN STEVEN', 'Pass4876', 'jugador', '3841432613', 1),
('SIERRA MARTINEZ, JUAN DIEGO', 'Pass8662', 'jugador', '3793455031', 1),
('SILVA PEREZ, GEOVANNY', 'Pass3248', 'jugador', '3524942798', 1),
('SOTO GUZMAN, JOHAN SANTIAGO', 'Pass1874', 'jugador', '3126305193', 1),
('SUAREZ OSPINA, BRAYAN ESNEIDER', 'Pass5177', 'jugador', '3718183311', 1),
('TORRES APARICIO, LENNY ESTEBAN', 'Pass7812', 'jugador', '3224132229', 1),
('TRIANA PORRAS, DIEGO ALEXANDER', 'Pass8500', 'jugador', '3907041599', 1),
('URIBE OZUNA, JUAN DIEGO', 'Pass1767', 'jugador', '3419489721', 1),
('VASQUEZ GONZALEZ, THOMAS', 'Pass2749', 'jugador', '3381301038', 1),
('VEGA PEDRAZA, HAROLD STEVEN', 'Pass9597', 'jugador', '3899378771', 1),
('VELASQUEZ SANCHEZ, DAVID SANTIAGO', 'Pass5980', 'jugador', '3154587348', 1),
('VELEZ SAMBONI, DANIEL STEVEN', 'Pass1011', 'jugador', '3041732542', 1),
('VERGARA BARAJAS, JEFFERSON ANDREI', 'Pass9973', 'jugador', '3225204973', 1),
('VERGARA SANABRIA, JUAN ESTEBAN', 'Pass9239', 'jugador', '3841991972', 1),
('VERGARA SANABRIA, THOMAS SANTIAGO', 'Pass1896', 'jugador', '3196464823', 1),
('VERTEL GONZALEZ, NAIRO CAMILO', 'Pass2013', 'jugador', '3131346274', 1),
('VILLALBA FALLA, DUVAN ALEXANDER', 'Pass3523', 'jugador', '3061239326', 1),
('WILCHES CRISTANCHO, SERGIO NICOLAS', 'Pass3296', 'jugador', '3699554786', 1),
('ZULUAGA PEREZ, DANIEL ESTEBAN', 'Pass9107', 'jugador', '3242917035', 1);

-- isnerciones de evento
INSERT INTO evento (fechaEvento, tipoEvento, resumenEvento) VALUES 
('2024-12-04', 'Amistoso', 'Resumen del evento 1'),
('2024-05-10', 'Entrenamiento', 'Resumen del evento 2'),
('2024-04-24', 'Amistoso', 'Resumen del evento 3'),
('2024-09-06', 'Torneo regional', 'Resumen del evento 4'),
('2024-08-28', 'Entrenamiento', 'Resumen del evento 5'),
('2024-09-27', 'Amistoso', 'Resumen del evento 6'),
('2024-02-10', 'Partido de liga', 'Resumen del evento 7'),
('2024-03-14', 'Partido de liga', 'Resumen del evento 8'),
('2024-03-02', 'Torneo regional', 'Resumen del evento 9'),
('2024-02-25', 'Amistoso', 'Resumen del evento 10');

-- Inserciones en la tabla rendimientoJugador
CALL registrarRendimiento(1, 1, 5000, 30, 2, 5, 1, 'Buen desempeño', 'Juvenil', 1);
CALL registrarRendimiento(1, 1, 5000, 30, 2, 5, 1, 'Buen desempeño', 'Juvenil', 2);
CALL registrarRendimiento(1, 1, 5000, 30, 2, 5, 1, 'Buen desempeño', 'Juvenil', 3);
CALL registrarRendimiento(1, 1, 5000, 30, 2, 5, 1, 'Buen desempeño', 'Juvenil', 4);
CALL registrarRendimiento(2, 1, 7000, 40, 1, 3, 0, 'Excelente resistencia', 'Profesional', 2);
CALL registrarRendimiento(3, 0, 3000, 20, 0, 2, 1, 'No asistió, pero buen registro', 'Amateur', 3);
CALL registrarRendimiento(4, 1, 8000, 50, 4, 6, 2, 'Liderazgo destacado', 'Profesional', 4);
CALL registrarRendimiento(5, 1, 4500, 25, 3, 4, 1, 'Buen manejo del balón', 'Juvenil', 5);


SELECT * FROM usuario;
SELECT * FROM categoria;
SELECT * FROM evento;
SELECT * FROM rendimientoJugador;

DESCRIBE evento;
DESCRIBE categoria;
DESCRIBE rendimientoJugador;
DESCRIBE usuario;

CALL registrarRendimiento(91,1, 100,  20, 2,  10,  1,'comentario de prueba', 'Juvenil',1);
CALL registrarRendimiento(90,1, 50,  10, 1,  5,  1,'comentario de prueba', 'Juvenil',1);
CALL registrarRendimiento(89,1, 200,  20, 3,  20,  1,'comentario de prueba', 'Juvenil',1);
CALL registrarRendimiento(88,1, 100,  20, 2,  10,  1,'comentario de prueba', 'Juvenil',1);
CALL registrarRendimiento(87,1, 0,  0, 0,  0,  0,'comentario de prueba', 'Juvenil',1);
CALL registrarRendimiento(86,1, 1,  1, 1,  1,  1,'comentario de prueba', 'Juvenil',1);




/* una consulta basica */
SELECT * FROM actividadBD;
SELECT * FROM rendimientoJugador;
SELECT * FROM usuario;

/* 7 consultas especificas */
-- 1: crear ranking de jugador
	SELECT idUsuario,nombreUsuario, SUM(metrosRecorridos) AS metrosRecorridos, SUM(pasesRealizados) AS pasesRealizados, SUM(golesRealizados) AS golesRealizados, SUM(pasesFallidos) AS pasesFallidos, SUM(golesFallidos) AS golesFallidos, SUM((metrosRecorridos * 0.1 + pasesRealizados * 1 + golesRealizados * 3) - (pasesFallidos * 0.5 + golesFallidos*2)) AS puntaje FROM
        rendimientoJugador rj INNER JOIN usuario u ON u.idUsuario = rj.idUsuarioFK 
		GROUP BY u.idUsuario, u.nombreUsuario
		ORDER BY puntaje DESC;
        
-- 2: consultar jugadores por evento especifico
     SELECT idEvento, tipoEvento, fechaEvento, resumenEvento, nombreUsuario, metrosRecorridos, pasesRealizados, golesRealizados, pasesFallidos, golesFallidos FROM 
		evento e INNER JOIN rendimientoJugador rj ON 1 = e.idEvento = rj.idEventoFK INNER JOIN usuario u ON u.idUsuario = rj.idUsuarioFK;
        
-- 3: consultar eventos por categoria especifica
     SELECT idCategoria, nombreCategoria, fechaEvento, resumenEvento FROM 
		categoria c INNER JOIN rendimientoJugador rj ON c.idCategoria = 2 INNER JOIN evento e ON e.idEvento = rj.idEventoFK;
        
-- 4: consultar categorias de jugador
	 SELECT idUsuario, nombreUsuario, nombreCategoria FROM categoria c INNER JOIN rendimientoJugador rj ON c.idCategoria = rj.idRendimiento INNER JOIN usuario u ON rj.idUsuarioFK = u.idUsuario GROUP BY idUsuario;
-- 5: consultar jugadores activos
	SELECT nombreUsuario FROM usuario WHERE estadoUsuario = 1;
    
-- 6: consultar rendimiento de un jugador en un evento especifico
	SELECT u.nombreUsuario, e.idEvento, e.tipoEvento, r.metrosRecorridos, r.pasesRealizados, r.golesRealizados FROM rendimientojugador r JOIN usuario u ON r.idUsuarioFK = u.idUsuario JOIN evento e ON r.idEventoFK = e.idEvento WHERE e.idEvento = 1;

-- 7: consultar jugadores por asistencia a un evento especifico
	SELECT u.nombreUsuario, e.idEvento, e.tipoEvento, r.asistencia FROM rendimientojugador r JOIN usuario u ON r.idUsuarioFK = u.idUsuario JOIN evento e ON r.idEventoFK = e.idEvento WHERE e.idEvento = 1 AND r.asistencia = 1;
        
/* una eliminacion */
DELETE FROM categoria WHERE idCategoria =12;
DELETE FROM rendimientoJugador WHERE idRendimiento = 8;

/* DROP DATABASE bogotaCityFC; */