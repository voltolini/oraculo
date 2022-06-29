--# VERIFICAR O COMANDO SQL DA SESSAO
set pages 1000 lines 169 long 10000
COL COMANDO_SQL FOR A160
select x.sql_id, x.sql_fulltext as COMANDO_SQL from v$sql X where rownum = 1 and x.sql_id = '1n9m4wuaw8a5w';


-- LISTAR SESSOES ATIVAS --
set pages 1000 lines 190 long 10000;
col sid for 999;
col serial# for 999999;
col status for a8;
col  logon_time for a16;
col usuario_osuser_estacao for a40;
col sql_id  for a13;
col event for a35;
col programa_modulo for a45;
select sid, serial#, status,
to_char(logon_time,'yyyy/mm/dd hh24:mi') as logon_time,
username ||','||osuser ||','|| machine as usuario_osuser_estacao,
sql_id, --event,
program ||','|| module as programa_modulo from v$session;
--where type='USER' AND sid in(786,1347);


--# VERIFICAR SESSOES+
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL OS_PID                 FOR 999999
COL SID_SESSAO             FOR A13
COL BLK_BY                 FOR A7
COL STATUS                 FOR A7
COL TEMPO                  FOR A12 TRU
COL LOGON                  FOR A13
COL EVENTO                 FOR A18 TRU
COL SQL_ID                 FOR A14
COL OWNER_USUARIO_ESTACAO  FOR A75
COL PROGRAMA_MODULO_ACAO   FOR A75
select s.sid||','||s.serial#||','||s.inst_id as SID_SESSAO
    , to_number(p.spid) as OS_PID, s.inst_id||','||s.blocking_session as BLK_BY
    , decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , substr(decode(trunc(s.last_call_et/86400), 0, '', to_char(trunc(s.last_call_et/86400), '9')||'d ')||
        to_char(to_date(mod(s.last_call_et, 86400), 'sssss'),'HH24"h "MI"m "SS"s"'),1,20) as TEMPO
--    , to_char(s.logon_time, 'DD/MM HH24:MI"h"') as LOGON
    , substr(s.username,1,100)||','||substr(s.osuser,1,100)||','||substr(s.machine,1,100)||','||
        substr(s.client_info,1,100)||','||substr(s.client_identifier,1,100) as OWNER_USUARIO_ESTACAO
    , case when s.program like '%(J%)' then (
           case when s.module is null then (select 'Job "'||j.job||' - '||j.schema_user||'"' from dba_jobs_running R
              inner join dba_jobs J on r.job = j.job inner join gv$session SI on si.sid = r.sid
              where si.inst_id||','||si.sid = s.inst_id||','||s.sid)
           else (select 'Sched. "'||sr.owner||'"."'||sr.job_name||'"'
              from  dba_scheduler_running_jobs SR
              inner join gv$session SI on si.sid = sr.session_id and si.inst_id = sr.running_instance
              where si.inst_id||','||si.sid = s.inst_id||','||s.sid) end)
      else substr(s.program,1,100)||case when s.program != s.module then ','||substr(s.module,1,100)
           else '' end ||','||substr(s.action,1,100) end as PROGRAMA_MODULO_ACAO
    , decode(s.event, 'SQL*Net message from client','SQL*Msg fr client','SQL*Net message to client','SQL*Msg TO client'
        , 'SQL*Net more data from client','SQL+Data fr client', 'SQL*Net more data to client','SQL+Data TO client'
        , s.event) as EVENTO, case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID
from gv$session S
left outer join gv$process P on p.inst_id = s.inst_id and p.addr = s.paddr
where s.type = 'USER'
  and upper(s.status) in ('ACTIVE', 'KILLED', 'SNIPED')
order by s.status, s.last_call_et desc ;
--and upper(s.username) in ('SPACEMAN_USER') --OWNER
--and s.osuser like 'USUARIO%' -- USUARIO
--  and upper(s.machine)  in ('ESTACAO') ESTACAO
--  and upper(s.program)  in ('PROGRAMA')
--  and s.last_call_et > 60  -- +1h
--  and upper(s.module)   in ('MODULO')
--  and upper(s.action)   in ('ACAO')
--  and upper(s.client_identifier in ('INFO')
--   and s.sid  in (1561)
--  and p.spid in (99999999)
--and (s.status in ('ACTIVE','KILLED','SNIPED') or not s.blocking_session is null) complemento





--#SESSÕES ATIVAS (TIPO WHOIS_ACTIVE)
set pages 1000
set lines 190
set timing on
set time on
set long 10
col username format a15
col ospid format 999999
col sid_sessao format a13
col block format a7
col type format a4
col owner_usuario_maquina_programa format a70
col ult_cmd format 99999999
col wait_time format 99999999
col status format a6
col sql_id format a15
col evento format a30
col cursor format 999999
col logon_time format a16
select s.sid || ',' || s.serial# || ',@' || s.inst_id as sid_sessao,
 s.blocking_session || '@' || s.blocking_instance as block,
 to_number(p.spid) as ospid,
 decode(s.type,'USER','USER','BACKGROUND','BACK',status) as type,
 decode(s.status,'ACTIVE','ATIVA','INACTIVE','INAT',status) as status,
 to_char(s.logon_time,'yyyy/mm/dd hh24:mi') as logon_time,
 s.last_call_et as ult_cmd,
 replace(replace(s.username||','||s.osuser||','||s.machine||','||s.client_identifier||','||s.client_info||','||s.action||','||substr(s.program||case when s.program != s.module then ','||s.module else '' end,1,150),',,,',','),',,',',') as owner_usuario_maquina_programa,
 s.sql_id,
 substr(s.event,1,50) as evento
from gv$session s
 left outer join gv$process p
  on s.inst_id = p.inst_id
  and s.paddr = p.addr
where not s.paddr is null
and s.type = 'USER'
and (s.status in ('ACTIVE','KILLED','SNIPED') or not s.blocking_session is null)
union all
select s.sid || ',' || s.serial# || ',@' || s.inst_id as sid_sessao,
 s.blocking_session || '@' || s.blocking_instance as block,
 to_number(p.spid) as ospid,
 decode(s.type,'USER','USER','BACKGROUND','BACK',status) as type,
 decode(s.status,'ACTIVE','ATIVA','INACTIVE','INAT',status) as status,
 to_char(s.logon_time,'yyyy/mm/dd hh24:mi') as logon_time,
 s.last_call_et as ult_cmd,
 replace(replace(s.username||','||s.osuser||','||s.machine||','||s.client_identifier||','||s.client_info||','||s.action||','||substr(s.program||case when s.program != s.module then ','||s.module else '' end,1,150),',,,',','),',,',',') as owner_usuario_maquina_programa,
 s.sql_id,
 substr(s.event,1,50) as evento
from gv$session s
 left outer join gv$process p
  on s.inst_id = p.inst_id
  and s.paddr = p.addr
where not s.paddr is null
  and (s.inst_id, s.sid) in (select s2.blocking_instance, s2.blocking_session from gv$session s2 where s2.blocking_session > 0)
order by ult_cmd desc, logon_time;






--# SESSÕES POR USUARIO GROUP BY "AGRUPAR"
set pages 1000 lines 190 long 10000
col owner for a20
col usuario for a20
col status for a10
col maquina for a25
col programa for a75
select username as owner,
osuser as usuario,
status,
machine as maquina,
program as programa, count(*) as sessoes
from  gv$session
--where username='SIMULADO'   --#owner
--and osuser=''               --#usuário
--and status=''               --#status
--and machine=''              --#maquina
--and program=''              --#programa
group by username, osuser, status, machine, program
having count(*) >2
order by sessoes desc;



--# QUANTIDADE DE SESSOES NO BANCO
BREAK ON INSTANCIA SKIP 1
COMP SUM LABEL 'TOTAL' OF USUARIOS BANCO TOTAL ON INSTANCIA
select (select i.instance_name from v$instance I) as INSTANCIA, b.inst_id
, (select count(*) from gv$session A where type = 'USER' and a.inst_id = b.inst_id) as USUARIOS
, (select count(*) from gv$session A where type = 'BACKGROUND' and a.inst_id = b.inst_id) as BANCO
, (select count(*) from gv$session A where a.inst_id = b.inst_id) as TOTAL from gv$session B group by b.inst_id ;


--LISTAR USUARIOS CADASTRADOS--
 set pages 1000 lines 190 long 10000;
col user_id for 9999999999;
col usuario for a21;
col criado_valido for a22;
col edicao_ativa for a12;
col account_status for a16;
col perfil for a18;
select user_id,
username as usuario,
created ||','|| expiry_date as criado_valido,
editions_enabled as edicao_ativa,
account_status,
profile as perfil from dba_users;


-- JUNÇAO DBA_TABLESPACES E DBA_DATA_FILES--
set pages 1000 lines 190 long 10000;
col tablespace_name for a15;
col file_name for a45;
col block_size for 9999;
col bytes for 9999999999;
col status for a6;
col contents for a10;
select dt.tablespace_name,
df.file_name,
dt.block_size,
df.bytes,
dt.status,
dt.contents from dba_tablespaces dt inner join dba_data_files df on dt.tablespace_name = df.tablespace_name;




-- DATA ATUAL DO SERVIDOR--
select sysdate from dual;



--NUMERO DE SESSOES--
select count(*) from v$session;



--NOME DA INSTANCIA OU BANCO--
select * from global_name;




--VERSAO DO ORACLE--
select version from v$instance;



-- ESTOU USANDO PARALELISMO?--
select parallel from v$instance;



-- DICIONARIO DE DADOS--
select * from dict;



--VERIFICAR AMBIENTE--
select metadata from sys.kopm$;
B023= 32BITS
B047= 64BITS



--ESTRUTURAS DE MEMORIA VAI VERIFICAR QUANTO TEM NA MEMORIA--
SELECT COMPONENT, CURRENT_SIZE, MIN_SIZE , MAX_SIZE FROM V$SGA_DYNAMIC_COMPONENTS;



--CONECTANDO A OUTRO BANCO DE DADOS--

SQLPLUS SYSTEM/SENHA@NOMEDOBANCO




-- VERIFICAR PRIVILEGIOS DO USUARIO--
select * from user_sys_privs;



--TABELAS DO USUARIO--
select table_name from user_tables group by table_name;



--#DATAFILES DE TODAS AS TABLESPACES
COL TABLESPACE FOR A15
COL FILE_NAME FOR A45
select tablespace_name as tablespace, file_name from dba_data_files;

select tablespace_name from dba_tablespaces;



--VERIFICACAO DE CONTA BLOQUEADA--
select username, account_status from dba_users where username ='LUCASG';



--NOME DE TODAS AS TABELAS DO OWNER--
  select owner,table_name from all_tables where owner='LUCASM';



--VERIFICAR QUAIS ROLES ESTAO HABILITADAS PARA O USUARIO--
select * from session_roles;
