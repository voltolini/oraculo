--# DETALHES DO JOB COLETA DE ESTATISTICAS
SET LINES 190 PAGES 1000 LONG 100000
COL RUNS         FOR 999999
COL OWNER        FOR A20
COL JOB_NOME     FOR A30
COL JOB_TIPO     FOR A10
COL JOB_ACAO     FOR A169
COL STATE        FOR A10
COL CRIADO       FOR A18
COL ULT_EXEC     FOR A18
COL PROX_EXEC    FOR A18
COL INTERVALO    FOR A25
COL LOG          FOR A4
COL FALHAS       FOR 999999
COL ENABLE       FOR A6
select j.owner, j.job_name as JOB_NOME
    , decode(j.job_type,'PLSQL_BLOCK','PLSQL     BLOCK     ','STORED_PROCEDURE','STORED    PROCEDURE ',
          'EXECUTABLE','EXECUTABLE','CHAIN','CHAIN     ',j.job_type) as JOB_TIPO, j.state
    , j.start_date as CRIADO, j.last_start_date as ULT_EXEC, j.next_run_date as PROX_EXEC
    ,j.run_count as RUNS, j.repeat_interval as INTERVALO, j.logging_level as log, j.failure_count as falhas, j.enabled as enable
    , case when j.job_action is null then 'Prog. "'||j.program_owner||'"."'||j.program_name||'"'
           else j.job_action end as JOB_ACAO
from  dba_scheduler_jobs J
where j.owner    in ('LUZADM')
  and j.job_name in ('LUMINA_GATHER_STATS')
--  and j.state != 'DISABLED'
order by j.owner, j.job_name, j.state desc ;




--# VERIFICAR HISTORICO DE EXECUCOES - ultimas 10
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL SID_SERIAL   FOR A14
COL JOB_NAME     FOR A30
COL OWNER        FOR A15
COL STATUS       FOR A10
COL DURACAO      FOR A13
COL DT_INICIO    FOR A12
COL DT_FIM       FOR A12
COL INFO         FOR A56
select * from (
select rd.session_id||',@'||rd.instance_id as SID_SERIAL, rd.owner, rd.job_name, rd.status
    , to_char(rd.actual_start_date, 'DD/MM HH24:MI') as DT_INICIO
    , to_char(rd.actual_start_date + rd.run_duration, 'DD/MM HH24:MI') as DT_FIM
    , rd.run_duration as DURACAO, rd.additional_info as INFO
from  dba_scheduler_job_run_details RD
where rd.actual_start_date is NOT null
  and rd.owner    in ('LUZADM')
  and rd.job_name in ('LUMINA_GATHER_STATS')
--  and substr(rd.run_duration,6,2) > '12'  -- > 12h
order by rd.actual_start_date desc
) where rownum <= 10 ;



--# HISTORICO DE EXECUCOES DA ROTINA (LOG)
------------------------------------------
SET LINES 169 PAGES 1000 LONG 100000 FEED 1 ECHO ON TI ON TIMI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL OWNER       FOR A30
COL INICIO      FOR A20
COL FIM         FOR A20
COL STATUS      FOR A15
COL DURACAO     FOR A10
COL METHOD_OPT  FOR A30
COL OPTIONS     FOR A13
select l.owner, to_char(l.begin_collection, 'YYYY-MM-DD HH24:MI') as INICIO
    , to_char(l.end_collection, 'YYYY-MM-DD HH24:MI') as FIM
    , to_char(to_date(mod(ceil((l.end_collection-l.begin_collection)*86400), 86400), 'sssss'),'HH24":"MI":"SS') as DURACAO
    , l.status_collection as STATUS, l.method_opt, l.options
from  luzadm.gather_stats_logs L
where l.begin_collection between (sysdate-2) and (sysdate)
order by INICIO ;





--# VER PARAMETROS CONFIGURADOS NA ROTINA
COL ITEMID                 FOR 99999
COL ORDEM                  FOR 99999
COL OWNER                  FOR A20
COL TABLE_NAME             FOR A25
COL INDEX_NAME             FOR A20
COL OPTIONS                FOR A10
COL METHOD_OPT             FOR A30
COL DIAS_SEM_COLETA_FORCE  FOR 999
COL SEMANA_COLETA          FOR 999
COL ESTIMATE_PERCENT       FOR 999
COL BLK                    FOR A03
BREAK ON BLK SKIP 1 DUPLICATE
select P.itemid, P.orderby as ORDEM, P.owner, P.table_name--, P.index_name
    , decode(P.dia_coleta_force,1,'DOMINGO',2,'SEGUNDA',3,'TERCA',4,'QUARTA',5,'QUINTA',6,'SEXTA',7,'SABADO') as COLETA
    , P.dias_sem_coleta_force, P.semana_coleta, P.blocked as BLK
    , decode(P.options,'GATHER','FULL','GATHER STALE','PARCIAL') as OPTIONS
    , P.estimate_percent, P.method_opt
from luzadm.param_gather_stats P
where P.itemid is NOT null
--  and P.blocked = 'N'
--  and P.owner = 'OWNER'
--  and P.dia_coleta_force is null
order by P.blocked, P.orderby, P.owner, P.table_name, P.index_name ;






--# VERIFICAR O ALERT.LOG - no caso de rac verificar nos dois nós.
vi /caminho/alert.log


--#PROCURAR POR MENSAGENS RELACIONADAS A COLETA
/GATHER


--#VERIFICAR OS ARQUIVOS DE TRACE NO MESMO DIR DO ALERT.LOG PROXIMO AO HORARIO DA FALHA
cd /caminho/trace


--#PROCESSOS DE USUARIO
ls -lhtr base_ora*.trc


--# PROCESSOS DE JOBS/SCHEDULERS
ls -lhtr base_j*.trc


--# PROCURAR POR INFORMAÇÕES LIGADAS A COLETA DE ESTATISTICAS
*comando sql
*informações da sessão
*(session)


--# NO CASO DE NÃO OBTER INFORMAÇÕES PROCURAR NO MONITORAMENTO SE HOUVE LOCK OU SESSÃO ATIVA POR LONGO PERIODO

*LOCK = bloq
*ATIVA = maior tempo



'------------------------------------------------------------------------------'
'--- OCASIOES PARA RODAR ESTATISTICAS --- '
'-------------------------------------------------------------------------------'


--#QUANDO HA ALTERACOES DE ESTRUTURA FREQUENTES, NOVOS OWNERS, UPGRADE
exec dbms_stats.gather_dictionary_stats;



--#QUANDO HA MUDANCA DE HARDWARE
exec dbms_stats.gather_system_stats;


--#APOS ALTERACOES EM PARAMETROS DE INICIALIZACAO, RMAN LENTO
exec dbms_stats.gather_fixed_objects_stats;



------------------------------------
--#COLETA DE ESTATISTICAS STATS.SQL
------------------------------------
conn / as sysdba
SET ECHO ON TIME ON TIMING ON FEED OFF SERVEROUTPUT OFF VERIFY OFF
--# COLETA DE ESTATISTICAS DO USUARIO "OWNER"
DEFINE V_USUARIO = "HANDITDSV"
select 'COLETA ESTATISTICAS - "&V_USUARIO" - DATA INICIO: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') as "." from dual ;
exec DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>'&V_USUARIO', estimate_percent=>100, block_sample=>FALSE, method_opt=>'FOR ALL COLUMNS SIZE AUTO', degree=>null, granularity=>'ALL', cascade=>TRUE, stattab=>null, statid=>null, options=>'GATHER', statown=>null, no_invalidate=>FALSE, gather_temp=>TRUE, gather_fixed=>FALSE) ;
select 'COLETA ESTATISTICAS - "&V_USUARIO" - DATA FIM...: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') as "." from dual ;
exit



--# COLETA DE UMA TABELA ESPECIFICA
exec dbms_stats.gather_table_stats(ownname=>'SAPIENS',tabname=>'E210MVP',cascade=>true,estimate_percent=>100,method_opt=>'for all columns size auto',no_invalidate=>false);

-----------------
--#STATS.SH
-----------------
. /etc/parametros_oracle
export ORACLE_SID=dbprod
sqlplus -s /nolog @stats.sql




-----------------------------------------------
--#COLETA DE ESTATISTICAS STATS.SQL COM PDB
-----------------------------------------------

--# ALTERAR PARA CONTAINER/SERVICO: HENNDSV
conn / as sysdba
alter session set container = henndsv ;

--# DEFINIR OPCOES DA SESSAO SQLPLUS
SET ECHO ON TIMING ON FEED OFF SERVEROUT OFF VERIFY OFF

--# INFORMAR USUARIO PARA COLETA DE ESTATISTICAS
DEFINE V_USUARIO = "HANDITDSV"
select 'COLETA ESTATISTICAS - "&V_USUARIO" - DATA INICIO: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') as "." from dual ;
exec DBMS_STATS.GATHER_SCHEMA_STATS(ownname=>'&V_USUARIO', estimate_percent=>100, block_sample=>FALSE, method_opt=>'FOR ALL COLUMNS SIZE AUTO', degree=>null, granularity=>'ALL', cascade=>TRUE, stattab=>null, statid=>null, options=>'GATHER', statown=>null, no_invalidate=>FALSE, gather_temp=>TRUE, gather_fixed=>FALSE) ;
select 'COLETA ESTATISTICAS - "&V_USUARIO" - DATA FIM...: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') as "." from dual ;
exit
