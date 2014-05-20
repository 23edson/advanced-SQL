INSTRUÇÕES DE EXECUÇÃO:

Acessar psql como usuário root;
.O script cria 3 usuários :
	master : todos privilegios (senha : master123)
	comum1 : privilegio SELECT (senha : 123)
	comum2 : privilegio SELECT,UPDATE (senha : 456)

.São criadas duas tablespace, t_user e tel_use, ambas de proprietário usuário master.
as tablespace são criadas no diretório '/var/lib/postgresql/' no linux;

.Criação do banco de dados chamado autopecas, com tablespace t_user;
.Criação de um esquema;
.O SCRIPt Altera o searc_path para o esquema criado;
.Após, da aos usuários master,comum1 e comum2 permissão de acesso ao esquema;

.DROPS TABLES caso existam;
.em seguinda, SCRIPT de criação das tabelas. Todas são criadas no esquema (esquema);

Criação da trigger:
	ESSA TRIGGER adiciona novo registro em svfunc quando um novo serviço é inserido.
	exemplo : um produto é  vendido, logo um vendedor será armazenada em svfunc;
	Quando o produto é vendido, ele pode ser instalado, então será armazenado em svfunc ,
	o profissional que realizou o serviço.

.Altera a tabela telefone para a tablespace tel_use

.Criação de 3 views:
	1:SELECIONA TODOS OS CARROS POR MARCA( CARROS DOS CLIENTES); 
	2:INFORMAÇÕES DE CLIENTES E FUNCIONÁRIOS;
	3:SELECIONA E CONTA OS CARROS POR CLIENTES;

A APLICAÇÃO:
	
	A base de dados escolhida refere-se a uma aplicação para uma autopecas;

	DESCRIÇÕES DE ALGUMAS TABELAS:

	TABELA servico  : ARMAZENA as ordens de serviços referentes aos carros dos clientes,
	Tabela svfunc : ARmazena a relação de serviço com funcionário, quando um serviço é lançado
	a trigger func_service cria uma nova tupla em svfunc

	*no script a tabela servico possui dois comandos inserts ( com formato de datas diferentes, uma está documentada). 

