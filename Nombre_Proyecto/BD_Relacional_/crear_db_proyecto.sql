create database if not exists bogotaCityFC;

use bogotaCityFC;

create table if not exists usuario (
	nombreUsuario varchar(50) Not null,
	idUsuario varchar(16) primary key,
	tipoUsuario varchar(20) not null,
	telefonoUsuario varchar(10) not null
);

create table if not exists rendimientoJugador (
	idUsuarioFK varchar(16) not null,
    idRendimiento varchar(20) primary key,
    metrosRecorridos int not null,
    pasesRealizados int not null,
    pasesFallidos int not null,
    golesFallidos int not null,
    
    foreign key (idUsuarioFK) references usuario(idUsuario) on delete cascade
);


create table if not exists evento(
	idEvento varchar(20) primary key,
    fechaEvento date not null,
    categoria varchar(6), /* ejemplo: sub16F | sub(3 caracteres) | 16 (2 caracteres) | F(1 caracter) | */
    tipoEvento varchar(50)
);

create table if not exists categoria(
	idCategoria varchar(20) primary key,
    edadMinima tinyint not null,
    edadMaxima tinyint not null
);