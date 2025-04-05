create database if not exists bogotaCityFC;

use bogotaCityFC;

create table if not exists usuario (
	nombreUsuario varchar(50) Not null,
	idUsuario varchar(16) primary key,
    contrasenia text(50) not null,
	tipoUsuario varchar(20) not null,
	telefonoUsuario varchar(10) not null unique,
    estadoUsuario bit not null
 );
 

create table if not exists rendimientoJugador (
	idRendimiento varchar(20) primary key,
	idUsuarioFK varchar(16) not null,
    asistencia bit not null,
    idEventoFK varchar(20) not null,
    metrosRecorridos int not null,
    pasesRealizados int not null,
    golesRealizados int not null,
    pasesFallidos int not null,
    golesFallidos int not null,
    comentarios varchar(100) null,
    foreign key (idUsuarioFK) references usuario(idUsuario) on delete cascade
);


create table if not exists categoria(
	idRendimientoFK varchar(20) primary key,
    edadMinima tinyint not null,
    edadMaxima tinyint not null,
    foreign key (idRendimientoFK) references rendimientoJugador(idRendimiento) on delete cascade
);


create table if not exists evento(
	idEvento varchar(20) primary key,
    idRendimientoFK varchar(20) not null,
    fechaEvento date not null,
    tipoEvento varchar(50),
    resumenEvento varchar(100),
    foreign key (idrendimientoFK) references rendimientoJugador(idRendimiento) on delete cascade
);

create table if not exists actividadBD(
	idActividad int primary key auto_increment,
    registro varchar(100) not null
)