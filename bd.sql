 --caso ja existam estes usuario vamos dropalos
drop user master;
drop user comum1;
drop user comum2;
--primeiramente criar os usuarios
create USER master with password 'master123';  --Cria usuários
create user comum1 with password '123';
create user comum2 with password '456';
--apos criar as tablespaces
create tablespace "t_user" OWNER  master LOCATION  'c:\var';  --Cria tablespace no local ''/var/lib/postgresql/9.1/main''
create tablespace "tel_use" OWNER master LOCATION 'c:\var\1';
--o database
create database autopecas tablespace t_user;
--conectar ao banco autopecas como super usuario
CREATE SCHEMA esquema;  --cria esquema
alter database autopecas set search_path to esquema;
GRANT USAGE on SCHEMA esquema to master;  --habilita uso do esquema
SET search_path to esquema;  --seta search_path
GRANT ALL privileges on 
	all tables in schema esquema to master;   --altera privilegios para os usuários

GRANT SELECT on
	all tables in schema esquema  to comum1;

GRANT SELECT,UPDATE on
	all tables in schema esquema to comum2;
	
alter USER master set search_path to esquema;   --Define esquema padrão para os usuários
alter USER comum1 set search_path to esquema;
alter USER comum2 set search_path to esquema;

\c autopecas master; --conecta como usuario master

drop table esquema.svfunc cascade;
drop table esquema.servico cascade;
drop table esquema.peca cascade;
drop table esquema.carro cascade;
drop table esquema.fabricante cascade;
drop table esquema.telefone cascade;
drop table esquema.cliente cascade;
drop table esquema.funcionario cascade;


create table esquema.cliente (
	cpf varchar(15) not null,
	rg varchar(14) not null,
	nome varchar(45) not null,
	ender varchar(25) null,
	constraint pk_cpf primary key (cpf)
);

create table esquema.telefone (
	idtel integer not null,
	tel integer not null,
	clicod varchar(15) not null,
	constraint pk_tel primary key(idtel),
	constraint  fk_cliente foreign key (clicod) references cliente(cpf)
);

create table esquema.fabricante (
	idfab integer not null,
	cnpj varchar(20) not null,
	nome varchar(50) not null,
	constraint pk_fab primary key(idfab)
);

create table esquema.carro (
	chassi varchar(20) not null,
	idfab integer not null,
	anofab integer not null,
	modelo varchar(20) not null,
	dono varchar(15) not null,
	constraint pk_carro primary key (chassi),
	constraint fk_cliente_car foreign key(dono) references cliente(cpf),
	constraint fk_fab_car foreign key(idfab) references fabricante(idfab)
); 

create table esquema.funcionario (
	cpf varchar(15) not null,
	nome varchar(45) not null,
	funcao varchar(25) not null,
	constraint pk_func primary key(cpf)
);
create table esquema.peca (
	codpeca integer not null,
	idfab integer not null,
	descr varchar(50) not null,
	qtd integer not null,
	preco varchar(10) not null,
	categoria varchar(20) not null,
	constraint pk_peca primary key(codpeca),
	constraint fk_fab foreign key(idfab) references fabricante(idfab)
);
create table esquema.servico(
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
create table esquema.svfunc(
		cpf varchar(15) not null,
		idsv integer not null,
		dthorag timestamp not null,
		constraint pk_svfunc primary key(cpf,idsv),
		constraint fk_func foreign key(cpf) references funcionario(cpf),
		constraint fk_servico foreign key(idsv,dthorag) references servico(idsv,dthorag)
);
--ESSA TRIGGER adiciona novo registro em svfunc quando um novo servico é inserido
	--exemplo : um produto é  vendido, logo um vendedor será armazenada em svfunc;
		-- Quando o produto é vendido, ele pode ser instalado, então será armazenado em svfunc ,
		-- o profissional que realizou o serviço

drop trigger func_service on esquema.servico cascade;
create or replace function func_service() returns trigger as 
	$func_service$
		DECLARE
			mont funcionario%ROWTYPE;
			vend1 funcionario%ROWTYPE; 
			--vend2 funcionario%ROWTYPE; 
			pintor funcionario%ROWTYPE;
			mec funcionario%ROWTYPE;
			allpeca peca%ROWTYPE;
			--cp funcionario.cpf%type; 
			
		BEGIN

			if(TG_OP = 'INSERT') then


				SELECT * INTO vend1 FROM esquema.funcionario WHERE esquema.funcionario.funcao = 'Vendedor(a)' LIMIT 1; --PEGA UM VENDEDOR (NO CASO 																O PRIMEIRO)
				SELECT * INTO pintor FROM esquema.funcionario WHERE esquema.funcionario.funcao = 'Pintor Automotivo' LIMIT 1;--um PINTOR
				SELECT * INTO mec FROM  esquema.funcionario WHERE esquema.funcionario.funcao = 'Mecanico' LIMIT  1; --UM MECANICO
				SELECT * INTO mont FROM esquema.funcionario WHERE esquema.funcionario.funcao = 'Montador' LIMIT 1; -- UM MONTADOR





				SELECT * INTO allpeca FROM esquema.peca WHERE esquema.peca.codpeca = NEW.codpeca LIMIT  1; --VERIFICA O CODIGO DA PECA

				
				--SELECT INTO * tipo1 FROM servico;

				--RAISE NOTICE '% ', allpeca.categoria;
				

				if(NEW.tipo = 'Instalacao')then
					INSERT INTO esquema.svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag; --INSERE EM SVFUNC O VENDEDOR que realizou a venda
					
					if(allpeca.categoria = 'Acessorios')then
						INSERT INTO esquema.svfunc SELECT mont.cpf,NEW.idsv,NEW.dthorag; --INSERE EM SVFUNC quem participou do 															servico
					elsif(allpeca.categoria = 'Peca') then
						INSERT INTO esquema.svfunc SELECT mec.cpf,NEW.idsv,NEW.dthorag;
					else
						RAISE EXCEPTION 'Tipo % invalido', NEW.tipo;
						RETURN NULL;
					end if;
					RETURN NEW;

				elsif (NEW.tipo = 'Reposicao') then  --mesma coisa que para tipo INSTALACAO
					
					INSERT INTO esquema.svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag;

					if(allpeca.descr = 'Tinta')then
						INSERT INTO esquema.svfunc SELECT pintor.cpf,NEW.idsv,NEW.dthorag;
					else
						INSERT INTO esquema.svfunc SELECT mec.cpf,NEW.idsv,NEW.dthorag;
					end if;
					RETURN NEW;
				elsif(NEW.tipo = 'Venda') then  --SE FOR FEITA APENAS A VENDA  e não instalação ou reparação
					INSERT INTO esquema.svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag;
					RETURN NEW;
				else  --CASO PARA ERROS
					RAISE EXCEPTIOn 'tipo % de servico invalido', NEW.tipo;
					RETURN NULL;
				end if; 
			end if;
			RETURN NULL;
		END
	$func_service$ LANGUAGE plpgsql;

create trigger func_service
AFTER INSERT on esquema.servico FOR EACH ROW EXECUTE PROCEDURE func_service();

ALTER table esquema.telefone SET TABLESPACE tel_use;  --Altera tabela telefone para tablespace criada


create view esquema.car_marca( marca, qtd) as
	select nome, count(*) from esquema.fabricante natural join esquema.carro group by nome;

create view esquema.funporcli (nome_funci,cpf_func,tipo_serv,preco,horario,chassi_car,nome_cli,cpf_cli) as 
select s.nome,s.cpf,s.tipo,s.preco,s.dthorag,s.chassi,c.nome,c.cpf from 
(esquema.funcionario f natural join esquema.svfunc natural join esquema.servico natural join esquema.carro)s 
join esquema.cliente c on (s.dono=c.cpf);

create view esquema.carporcli(nome_cliente,cpf_cli,qt_caros) as 
select nome,cpf,count(chassi) from esquema.carro r join esquema.cliente c on dono=cpf 
group by nome,cpf;

insert into esquema.cliente ( cpf,rg,nome,ender) values 
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

insert into esquema.telefone (idtel,tel,clicod) values
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

insert into esquema.fabricante (idfab,cnpj,nome) values
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
			
insert into esquema.carro (chassi,idfab,anofab,modelo,dono) values
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

insert into esquema.funcionario (cpf,nome,funcao) values
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
			
insert into esquema.peca (codpeca,idfab,descr,qtd,preco,categoria) values
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

insert into esquema.servico (idsv,codpeca,chassi,tipo,preco,dthorag) values
			(1,12,'555nh33534ff2','Instalacao','500,00','2013-05-11 10:00'),
			(2,12,'66ddf555www62','Instalacao','500,00','2013-05-12 15:00'),
			(3,13,'66ddf555www62','Reposicao','400,00','2013-05-12 15:00'),
			(4,14,'66ddf555www62','Reposicao','200,00','2013-05-12 15:00'),
			(5,15,'23125la55vo11','Reposicao','100,00','2013-07-07 08:00'),
			(6,15,'23125la55vo11','Reposicao','100,00','2013-02-09 09:00'),
			(7,16,'ll55458ffa212','Reposicao','250,00','2012-05-04 11:00'),
			(8,16,'ll55458ffa212','Reposicao','350,00','2013-09-02 16:00'),
			(9,18,'oo2021vb26741','Reposicao','200,00','2013-12-11 15:00'),
			(10,19,'nn65df555512s','Instalacao','100,00','2013-10-04 17:00'),
			(11,21,'kk8080dfww101','Reposicao','250,00','2014-02-01 13:00'),
			(12,22,'22ds1223ffvb1','Reposicao','1000,00','2014-03-01 14:00');
insert into esquema.svfunc(cpf,idsv,dthorag) values
			('112211',1,'2013-05-11 10:00'),('112211',2,'2013-05-12 15:00'),
			('112211',3,'2013-05-12 15:00'),('331548',4,'2013-05-12 15:00'),
			('331548',5,'2013-07-07 08:00'),('331548',6,'2013-02-09 09:00'),
			('331548',7,'2012-05-04 11:00'),('112211',8,'2013-09-02 16:00'),
			('112211',9,'2013-12-11 15:00'),('112211',10,'2013-10-04 17:00'),
			('331548',11,'2014-02-01 13:00'),('331548',12,'2014-03-01 14:00'),
			('314522',7,'2012-05-04 11:00'),('314522',8,'2013-09-02 16:00'),
			('221587',11,'2014-02-01 13:00'),('221587',12,'2014-03-01 14:00'),
			('221587',9,'2013-12-11 15:00'),('221587',5,'2013-07-07 08:00'),
			('221587',6,'2013-02-09 09:00'),('552184',1,'2013-05-11 10:00'),
			('552184',2,'2013-05-12- 15:00'),('552184',10,'2013-10-04 17:00');
