-------------------------
--# Modo Archivelog
-------------------------

Primordial para recuperação point-in-time do database Oracle.

Onde podemos definir uma área especifica para o armazenamento dos archives, os archives são as informações arquivadas pelos redo logs
(online redolog files).


A "coleção" destes archives, permite que a restauração seja efetuada em um ponto especifico no tempo.




--------------------------
--# Conceitos backup RMAN
--------------------------

-> Consistente: Ocorre quando o banco de dados está em estado consistente. O backup é realizado com o banco em modo mount,
após a instância ter sido desativada com shutdown normal/immediate/transactional.


-> Inconsistente: Ocorre quando o backup do banco de dados é realizado com o banco aberto e em utilização ou se o banco foi desativado
com shutdown abort.



----------------------
--# Fast Recovery Area
----------------------

É uma localização de armazenamento que detém todos os arquivos de recuperação do database.

Durante o RMAN, os arquivos são gerados nesta área e o Oracle gerencia estes arquivos.

Caso não seja mencionada a localização do backup durante a execução do RMAN e Fast Recovery Area estiver configurada, os backups
serão gerados automaticamente na área de FRA.


Arquivos que podem estar presentes na Fast Recovery Area:

-> Image Copies
-> RMAN Backup Set
-> Datafiles
-> Archivelogs
-> Online Redo Logs
-> Flashback Logs
-> Control files
-> Control file e spfile autobackups


--# Configurando a FRA

-> Verificar os parametros antes da configuração:

show parameter db_recovery_file


-> Configure os parâmetros abaixo de acordo com o tamanho do seu ambiente:


--# definir o tamanho do destino (precisa ser suficiente para armazenar os archives) ele permite por um valor maior que a area do disco
alter system set db_recovery_file_dest_size=10G scope=both;


--# local que vai ser gerado
alter system set db_recovery_file_dest='/u02/fast_recovery_area' scope both;


--# local que irá ser gerado os archives (aqui estou apontando para o diretorio que foi definido acima)
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST' scope both;



-------------------------------------------
--# Modo archivelog e noarchivelog
-------------------------------------------

-> Noarchivelog

  Desabilita o arquivamento dos redo log files
  Protege o database contra falha da instância, mas não da falha de mídia
  Não permite backup online


-> Archivelog
  Habilita o arquivamento dos redo log files (no 19c valor default para redo é 200M)
  A combinação do backup do database com o online redo log files e archives permite um restore point-in-time do banco
  Permite ter um banco standby aplicando continuamente os redos e archives originais




----------------------------------
--# Habilitando o modo archivelog
----------------------------------

shutdown immediate;


startup mount;


alter database archivelog;


alter database open;


archive log list;


alter system switch logfile;


set lines 1000 pages 1000
select *from v$flash_recovery_area_usage;
