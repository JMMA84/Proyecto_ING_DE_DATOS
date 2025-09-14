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
DROP PROCEDURE rendimientoHistorico;
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

