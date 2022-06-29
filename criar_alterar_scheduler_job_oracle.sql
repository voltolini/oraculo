-----------------------------------------------------
--# Criar/alterar um scheduler job
-----------------------------------------------------



**********************
-> Tipos de job type
**********************

-> 'PLSQL_BLOCK' - Bloco PL/SQL explicito

-> 'STORED_PROCEDURE' - Nome de uma procedure / function

-> 'EXECUTABLE' - É definido um executável externo via linha de comando do sistema operacional, e argumentos nao são suportados.

-> 'CHAIN' - É para definir uma cadeia de execução de jobs, e não é permitido parametros para esse tipo.

-> 'EXTERNAL_SCRIPT' - É usado comandos shell do computador como cmd.exe no windows ou sh shell do linux.

-> 'SQL_SCRIPT' - É uma chamada para um arquivo .sql igual usado via sqlplus @script.sql, sem necessidade de informar usuário e senha para se conectar com o script.

-> 'BACKUP_SCRIPT' - é usado para backup RMAN, a sua chamada será pelo job_action para um script .rman



-----------------------------------------
--# Criar um scheduler job / PLSQL_BLOCK
-----------------------------------------


-> Criação de um job que executa semanalmente nos sábados com inicio as 15:00 que executa um bloco PL/SQL


BEGIN
 dbms_scheduler.create_job(
 job_name => 'COLETA_STATS_CUST_TABLE',
 job_type => 'PLSQL_BLOCK',
 job_action => '
   BEGIN
     DBMS_STATS.GATHER_TABLE_STATS(OWNNAME => ''OWNER'', TABNAME => ''NOME_DA_TABELA'', estimate_percent => 100,CASCADE => TRUE, method_opt => ''FOR ALL COLUMNS SIZE AUTO'');
  END;
  ',
 start_date => to_date('27/11/2021 15:00:00','dd/mm/yyyy hh24:mi:ss'),
 repeat_interval => 'freq=WEEKLY; BYDAY=SAT; BYHOUR=15'
 );
 END;




------------------------------------------------
--# Criar um scheduler job / Usando um programa
------------------------------------------------



-> Ao utilizar um programa e um SCHEDULE_NAME as definições de execução e o que executa estão em fora do job:

    -> SCHEDULE_NAME - Esse é o schedule que irá definir a execução do job, bem como horario de start, frequencia.
    -> PROGRAM_NAME - Esse é o nome do scheduler com o tipo de programa ou que for executar, PL/SQL, store procedure, executavel entre outros.
    -> JOB_CLASS - Este parametro irá definir em qual serviço(service_name) será executado


DBMS_SCHEDULER.create_job (
    job_name      => 'NOME_DO_JOB',
    program_name  => 'NOME_PROGRAMA',
    schedule_name => 'NOME_DO_SCHEDULE',
    job_class     => 'NOME_DA_CLASSE',
    enabled       => TRUE,
    comments      => 'Aqui fica um comentario para posteridade.');




--------------------------------
--# Alterar um atributo do job
--------------------------------


-> Desta forma se altera um atributo como a frequência / intervalo de sua execução
   que no caso de todo sabado as 15 para todos os dias da semana de segunda a sexta iniciando exatamente as 20hs.


BEGIN
dbms_scheduler.set_attribute(
name => '"LUZADM"."COLETA_STATS_CUST_TABLE"',
attribute => 'repeat_interval',
VALUE => 'FREQ=weekly; BYDAY=MON,TUE,WED,THU,FRI; byhour=20; byminute=0; bysecond=0;';
END;
/




-----------------------------------
--# Definição de Classe / Services
-----------------------------------


-> Criação de uma definição de classe que pode ser informado no job para executar a partir de um service especifico


EXEC DBMS_SCHEDULER.create_job_class(job_class_name => 'job_class_service_custom01',service => 'service_custom01');




---------------------------------
--# Executar o job manualmente
---------------------------------


-> Comando para executar job manualmente.


--# Run job synchronously

EXEC DBMS_SCHEDULER.run_job (job_name => 'NOME_DO_JOB',use_current_session => FALSE);


 -> USE_CURRENT_SESSION = false, o job será executado em segundo plano com permissões de um processo em segundo plano do proprietário da conta.

 -> USE_CURRENT_SESSION = true - sua sessão, as permissões de sua conta.




--------------------
--# Parar um job
--------------------


EXEC DBMS_SCHEDULER.stop_job (job_name => 'NOME_DO_JOB, NOME_DE_OUTRO_JOB');





----------------------
--# Criar um programa
----------------------


BEGIN
 DBMS_SCHEDULER.create_program (
    program_name        => 'EXEC_PROC_CHAMADA01',
    program_type        => 'STORED_PROCEDURE',
    program_action      => 'proc_chamada01',
    number_of_arguments => 0,
    enabled             => TRUE,
    comments            => 'Programa de Backup RMAN FULL do Database ORASUP.');
END;
/



-> 'number_of_arguments' - O número de argumentos exigidos pelo procedimento armazenado ou outro executável que o programa invoca.

-> 'program_action' - A ação que o programa executa, indicada pelo atributo program_type. Por exemplo, se program_type for 'STORED_PROCEDURE', program_action conterá o nome do procedimento armazenado.

-> 'program_type' - O tipo de programa. Deve ser um dos tipos de programa suportados: 'PLSQL_BLOCK', 'STORED_PROCEDURE' ou 'EXECUTABLE'.





-------------------------------
--# Criação de uma credencial
-------------------------------



-> É usado para credenciais de programas do tipo 'BACKUP_SCRIPT' e 'EXTERNAL_SCRIPT' que necessitam de um usuário do sistema operacional



BEGIN
  dbms_credential.create_credential(credential_name => 'oracle_bkpuser',username => 'oracle',password => 'orclpswd');
END;
/



-> Use para jobs de banco de dados remoto e jobs externos remotos apenas. Deve ser NULL para jobs em execução no banco de dados local ou para jobs externos locais (executáveis).


---------------------------
--# Consultar um programa
---------------------------

SELECT owner, program_name, enabled FROM dba_scheduler_programs;



-----------------------
--# Desabilitar um job
-----------------------

EXEC dbms_scheduler.disable ('OWNER.NOME_DO_JOB');



-------------------
--# Excluir um job
-------------------

EXEC DBMS_SCHEDULER.drop_schedule (schedule_name => 'NOME_DO_JOB');



--------------------------------------------
--# Consultas de janelas de execução de job
--------------------------------------------

SELECT window_name,start_time,duration FROM dba_autotask_schedule;
