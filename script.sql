drop table svfunc;
drop table servico;
drop table peca;
drop table carro;
drop table fabricante;
drop table telefone;
drop table cliente;
drop table funcionario;


create table cliente (
	cpf varchar(15) not null,
	rg varchar(14) not null,
	nome varchar(45) not null,
	ender varchar(25) null,
	constraint pk_cpf primary key (cpf)
);

create table telefone (
	idtel integer not null,
	tel integer not null,
	clicod varchar(15) not null,
	constraint pk_tel primary key(idtel),
	constraint  fk_cliente foreign key (clicod) references cliente(cpf)
);

create table fabricante (
	idfab integer not null,
	cnpj varchar(20) not null,
	nome varchar(50) not null,
	constraint pk_fab primary key(idfab)
);

create table carro (
	chassi varchar(20) not null,
	idfab integer not null,
	anofab integer not null,
	modelo varchar(20) not null,
	dono varchar(15) not null,
	constraint pk_carro primary key (chassi),
	constraint fk_cliente_car foreign key(dono) references cliente(cpf),
	constraint fk_fab_car foreign key(idfab) references fabricante(idfab)
); 

create table funcionario (
	cpf varchar(15) not null,
	nome varchar(45) not null,
	funcao varchar(25) not null,
	constraint pk_func primary key(cpf)
);
create table peca (
	codpeca integer not null,
	idfab integer not null,
	descr varchar(50) not null,
	qtd integer not null,
	preco varchar(10) not null,
	categoria varchar(20) not null,
	constraint pk_peca primary key(codpeca),
	constraint fk_fab foreign key(idfab) references fabricante(idfab)
);
create table servico(
	idsv integer not null,
	codpeca integer not null,
	chassi varchar(20) not null,
	tipo varchar(20) not null,
	preco varchar(10) not null,
	dthorag timestamp not null,
	constraint pk_servico primary key(idsv,dthorag),
	constraint fk_peca foreign key(codpeca) references peca(codpeca),
	constraint fk_car foreign key(chassi) references carro(chassi)
);
create table svfunc(
		cpf varchar(15) not null,
		idsv integer not null,
		dthorag timestamp not null,
		constraint pk_svfunc primary key(cpf,idsv),
		constraint fk_func foreign key(cpf) references funcionario(cpf),
		constraint fk_servico foreign key(idsv,dthorag) references servico(idsv,dthorag)
);

insert into cliente ( cpf,rg,nome,ender) values 
			('111111','2222','Marcos A.',null),
			('222222','3333','Jose M.','Joinville SC'),
			('333333','4444','Carlos C.','Curitiba PR'),
			('444444','5555','Ana F.','Chapeco SC'),
			('555555','6666','Matheus','Chapeco SC'),
			('666666','7777','Jose P.','Porto Alegre RS'),
			('777777','8888','Juliana','Xaxim SC'),
			('888888','9999','Adao V.','Curitiba PR'),
			('999999','9915','Marcela','Chapeco SC'),
			('819211','5523','Pedro','Cascavel PR');

insert into telefone (idtel,tel,clicod) values
			(1,88554555,'111111'),
			(2,88442222,'111111'),
			(3,88664258,'111111'),
			(4,99554482,'333333'),
			(5,91554823,'333333'),
			(6,81558542,'222222'),
			(7,81522236,'222222'),
			(8,99112548,'555555'),
			(9,91915586,'666666'),
			(10,99335841,'777777'),
			(11,85654852,'999999'),
			(12,9202123,'819211');

insert into fabricante (idfab,cnpj,nome) values
			(1,'001546623','Volkswagen'),
			(2,'221155554','Chevrolet'),
			(3,'223111447','Citroen'),
			(4,'222344456','Toyota'),
			(5,'111222566','Ford'),
			(6,'778232145','Honda'),
			(7,'445634856','Fiat'),
			(8,'231245698','Renault'),
			(9,'664525874','Hyundai'),
			(10,'33212448','Nissan');
			
insert into carro (chassi,idfab,anofab,modelo,dono) values
			('555nh33534ff2',1,2013,'Gol G4','111111'),
			('66ddf555www62',1,2010,'Golf','111111'),
			('22ds1223ffvb1',7,2008,'Uno','111111'),
			('23125la55vo11',2,2013,'Classic','222222'),
			('ll55458ffa212',2,2007,'Corsa','333333'),
			('nn65df555512s',5,2010,'Ka', '444444'),
			('kk8080dfww101',8,2013,'Sandero','444444'),
			('oo2021vb26741',4,2012,'Corolla','666666'),
			('mon65dd202758',9,2013,'Hb20', '819211'),
			('2255gh3qw22rt',6,2012,'Civic','999999'),
			('koo556468fgvs',6,2012,'Civic','777777'),
			('77jjqw554x258',8,2010,'Clio','819211');

insert into funcionario (cpf,nome,funcao) values
			('112211','Maria','Vendedor(a)'),
			('214155','Julia','Secretaria'),
			('314522','Carlos','Mecanico'),
			('221587','Marcos','Mecanico'),
			('552184','Luiz','Montador'),
			('331548','Pedro F','Vendedor(a)'),
			('668452','Marcio','Pintor Automotivo'),
			('991232','Joao','Pintor Automotivo'),
			('115483','Clara','Manobrista'),
			('775217','Marcelo','Manobrista');
			
insert into peca (codpeca,idfab,descr,qtd,preco,categoria) values
			(12,1,'Roda Aluminio 17',20,'450,00','Acessorios'),
			(13,1,'Parabrisa',17,'300,00','Acessorios'),
			(14,1,'Volante esportivo',40,'100,00','Acessorios'),
			(15,2,'Oleo Dexos',55,'70,00','Peca'),
			(16,2,'Kit embreagem',25,'250,00','Peca'),
			(17,3,'Tinta',10,'500,00','Peca'),
			(18,4,'Oleo p motor',20,'150,00','Peca'),
			(19,5,'Protetor Carter',50,'60,00','Peca'),
			(20,6,'Filtro combustivel',23,'200,00','Peca'),
			(21,8,'Defletor Carter',5,'190,00','Peca'),
			(22,7,'Caixa de Cambio',10,'700,00','Peca');

insert into servico (idsv,codpeca,chassi,tipo,preco,dthorag) values
			(1,12,'555nh33534ff2','Instalacao','500,00','05-11-2013 10:00'),
			(2,12,'66ddf555www62','Instalacao','500,00','05-12-2013 15:00'),
			(3,13,'66ddf555www62','Reposicao','400,00','05-12-2013 15:00'),
			(4,14,'66ddf555www62','Reposicao','200,00','05-12-2013 15:00'),
			(5,15,'23125la55vo11','Reposicao','100,00','07-07-2013 08:00'),
			(6,15,'23125la55vo11','Reposicao','100,00','02-09-2013 09:00'),
			(7,16,'ll55458ffa212','Reposicao','250,00','05-04-2012 11:00'),
			(8,16,'ll55458ffa212','Reposicao','350,00','09-02-2013 16:00'),
			(9,18,'oo2021vb26741','Reposicao','200,00','12-11-2013 15:00'),
			(10,19,'nn65df555512s','Instalacao','100,00','10-04-2013 17:00'),
			(11,21,'kk8080dfww101','Reposicao','250,00','02-01-2014 13:00'),
			(12,22,'22ds1223ffvb1','Reposicao','1000,00','03-01-2014 14:00');
			
insert into svfunc(cpf,idsv,dthorag) values
			('112211',1,'05-11-2013 10:00'),('112211',2,'05-12-2013 15:00'),
			('112211',3,'05-12-2013 15:00'),('331548',4,'05-12-2013 15:00'),
			('331548',5,'07-07-2013 08:00'),('331548',6,'02-09-2013 09:00'),
			('331548',7,'05-04-2012 11:00'),('112211',8,'09-02-2013 16:00'),
			('112211',9,'12-11-2013 15:00'),('112211',10,'10-04-2013 17:00'),
			('331548',11,'02-01-2014 13:00'),('331548',12,'03-01-2014 14:00'),
			('314522',7,'05-04-2012 11:00'),('314522',8,'09-02-2013 16:00'),
			('221587',11,'02-01-2014 13:00'),('221587',12,'03-01-2014 14:00'),
			('221587',9,'12-11-2013 15:00'),('221587',5,'07-07-2013 08:00'),
			('221587',6,'02-09-2013 09:00'),('552184',1,'05-11-2013 10:00'),
			('552184',2,'05-12-2013 15:00'),('552184',10,'10-04-2013 17:00');
			
