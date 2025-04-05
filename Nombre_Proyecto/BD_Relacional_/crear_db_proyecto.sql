CREATE DATABASE IF NOT EXISTS bogotaCityFC;

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
	 SELECT idUsuario, nombreUsuario, nombreCategoria FROM categoria c INNER JOIN rendimientoJugador rj ON c.idCategoria = rj.idRendimiento INNER JOIN usuario u ON rj.idUsuarioFK = u.idUsuario GROUP BY c.nombreCategoria;
     
-- 5: consultar jugadores activos
	SELECT nombreUsuario FROM usuario WHERE estadoUsuario = 1;
    
-- 6: consultar rendimiento de un jugador en un evento especifico
	SELECT u.nombreUsuario, e.tipoEvento, r.metrosRecorridos, r.pasesRealizados, r.golesRealizados FROM rendimientojugador r JOIN usuario u ON r.idUsuarioFK = u.idUsuario JOIN evento e ON r.idEventoFK = e.idEvento WHERE e.idEvento = 1;

-- 7: consultar jugadores por asistencia a un evento especifico
	SELECT u.nombreUsuario, e.tipoEvento, r.asistencia FROM rendimientojugador r JOIN usuario u ON r.idUsuarioFK = u.idUsuario JOIN evento e ON r.idEventoFK = e.idEvento WHERE e.idEvento = 1 AND r.asistencia = 1;
        
/* una eliminacion */
DELETE FROM categoria WHERE idCategoria =12;
DELETE FROM rendimientoJugador WHERE idRendimiento = 8;

/* DROP DATABASE bogotaCityFC; */