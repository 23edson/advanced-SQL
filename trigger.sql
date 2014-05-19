--ESSA TRIGGER adiciona novo registro em svfunc quando um novo servico é inserido
	--exemplo : um produto é  vendido, logo um vendedor será armazenada em svfunc;
		-- Quando o produto é vendido, ele pode ser instalado, então será armazenado em svfunc ,
		-- o profissional que realizou o serviço

drop trigger func_service on servico;
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


				SELECT * INTO vend1 FROM funcionario WHERE funcionario.funcao = 'Vendedor(a)' LIMIT 1; --PEGA UM VENDEDOR (NO CASO 																O PRIMEIRO)
				SELECT * INTO pintor FROM funcionario WHERE funcionario.funcao = 'Pintor Automotivo' LIMIT 1;--um PINTOR
				SELECT * INTO mec FROM  funcionario WHERE funcionario.funcao = 'Mecanico' LIMIT  1; --UM MECANICO
				SELECT * INTO mont FROM funcionario WHERE funcionario.funcao = 'Montador' LIMIT 1; -- UM MONTADOR





				SELECT * INTO allpeca FROM peca WHERE peca.codpeca = NEW.codpeca LIMIT  1; --VERIFICA O CODIGO DA PECA

				
				--SELECT INTO * tipo1 FROM servico;

				--RAISE NOTICE '% ', allpeca.categoria;
				

				if(NEW.tipo = 'Instalacao')then
					INSERT INTO svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag; --INSERE EM SVFUNC O VENDEDOR que realizou a venda
					
					if(allpeca.categoria = 'Acessorios')then
						INSERT INTO svfunc SELECT mont.cpf,NEW.idsv,NEW.dthorag; --INSERE EM SVFUNC quem participou do 															servico
					elsif(allpeca.categoria = 'Peca') then
						INSERT INTO svfunc SELECT mec.cpf,NEW.idsv,NEW.dthorag;
					else
						RAISE EXCEPTION 'Tipo % invalido', NEW.tipo;
						RETURN NULL;
					end if;
					RETURN NEW;

				elsif (NEW.tipo = 'Reposicao') then  --mesma coisa que para tipo INSTALACAO
					
					INSERT INTO svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag;

					if(allpeca.descr = 'Tinta')then
						INSERT INTO svfunc SELECT pintor.cpf,NEW.idsv,NEW.dthorag;
					else
						INSERT INTO svfunc SELECT mec.cpf,NEW.idsv,NEW.dthorag;
					end if;
					RETURN NEW;
				elsif(NEW.tipo = 'Venda') then  --SE FOR FEITA APENAS A VENDA  e não instalação ou reparação
					INSERT INTO svfunc SELECT vend1.cpf,NEW.idsv,NEW.dthorag;
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
AFTER INSERT on servico FOR EACH ROW EXECUTE PROCEDURE func_service();
