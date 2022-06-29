--# VERIFICAR SESSAO COM MAIS ALTERACOES
SET LINES 190 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL SID_SERIAL             FOR A13
COL OS_PID                 FOR 999999
COL STATUS                 FOR A7
COL LOGON                  FOR A13
COL TEMPO                  FOR A11 TRU
COL EVENTO                 FOR A18 TRU
COL LEITURAS               FOR 999,999,990
COL BLK_ALTERADOS          FOR 999,999,990
COL OWNER_USUARIO_ESTACAO  FOR A45
COL PROGRAMA_MODULO_ACAO   FOR A30
select s.inst_id||','||s.sid||','||s.serial# as SID_SERIAL, to_number(p.spid) as OS_PID
    , decode(s.status,'ACTIVE','ATIVA','INACTIVE','INATIVA',status) as STATUS
    , substr(decode(trunc(s.last_call_et/86400),0,'', to_char(trunc(s.last_call_et/86400),'9')||'d ')||
        to_char(to_date(mod(s.last_call_et, 86400), 'sssss'),'HH24"h "MI"m "SS"s"'),1,20) as TEMPO
    , to_char(s.logon_time, 'DD/MM HH24:MI"h"') as LOGON
    , substr(s.username,1,100)||','||substr(s.osuser,1,100)||','||substr(s.machine,1,100)||','||
        substr(s.client_info,1,100)||','||substr(s.client_identifier,1,100) as OWNER_USUARIO_ESTACAO
    , substr(s.program,1,100)||case when s.program != s.module then ','||
        substr(s.module,1,100) else '' end ||','||substr(s.action,1,100) as PROGRAMA_MODULO_ACAO
    , decode(s.event, 'SQL*Net message from client','SQL*Msg fr client','SQL*Net message to client','SQL*Msg TO client'
        , 'SQL*Net more data from client','SQL+Data fr client', 'SQL*Net more data to client','SQL+Data TO client'
        , s.event) as EVENTO, case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID
    , io.block_changes as BLK_ALTERADOS
--    , io.physical_reads as LEITURAS
from gv$session S
inner join gv$sess_io IO on s.sid = io.sid
inner join gv$process P on s.inst_id = p.inst_id and s.paddr = p.addr
where s.type = 'USER'
  and io.block_changes  > 2000000  -- > 2 milhoes
--  and io.physical_reads > 2000000  -- > 2 milhoes
--    and s.status = 'ACTIVE'
--    and upper(s.username) in ('OWNER')
--    and upper(s.osuser)   in ('USUARIO')
--    and upper(s.estacao)  in ('ESTACAO')
--    and upper(s.program)  in ('PROGRAMA')
--    and upper(s.module)   in ('MODULO')
--    and s.sid  in (99999999)
--    and p.spid in (99999999)
order by io.block_changes desc ;



--# VERIFICAR O COMANDO SQL DA SESSAO
COL COMANDO_SQL FOR A169
select 'Ultimo comando SQL executado pela sessao:' as ULTIMO_CMD, x.sql_id, x.sql_fulltext as COMANDO_SQL
from v$sql X where rownum = 1 and x.sql_id = '2wyybyhwg3g1y';



--# VERIFICAR TAMANHO DE ARCHIVES GERADOS POR TEMPO
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL NAME             FOR A60
COL TEMPO            FOR A8
COL FIRST_TIME       FOR A20
COL COMPLETION_TIME  FOR A20
COL SIZE_MB          FOR 9,999,990
select ceil(sum((al.blocks*al.block_size)/1024/1024)) as SIZE_MB
from  v$archived_log AL
where dest_id = 1  -- (1) producao (2) multiplex ou standby
--  and al.completion_time >= sysdate-1/24
  and to_char(al.completion_time, 'YYYY-MM-DD HH24:MI') >= '2021-01-26 15:00'
  and to_char(al.completion_time, 'YYYY-MM-DD HH24:MI') <= '2021-01-26 15:00' ;



--# VERIFICAR SESSAO COM MAIS ALTERACOES
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL SID_SERIAL_     FOR A169
COL OS_PID_         FOR A169
COL OWNER_          FOR A169
COL USUARIO_        FOR A169
COL ESTACAO_        FOR A169
COL CLIENT_ID_      FOR A169
COL CLIENT_INFO_    FOR A169
COL PROGRAMA_       FOR A169
COL MODULO_         FOR A169
COL ACAO_           FOR A169
COL EVENTO_         FOR A169
COL STATUS_         FOR A169
COL LOGON_          FOR A169
COL SQL_ID_         FOR A169
COL BLK_ALTERADOS_  FOR A169
COL LEITURAS_  FOR A169
select 'SID/Serial: '||s.sid||','||s.serial#||',@'||s.inst_id as SID_SERIAL_
,'OS_PID: '  ||p.spid              as OS_PID_
,'Owner: '   ||s.username          as OWNER_
,'Usuario: ' ||s.osuser            as USUARIO_
,'Estacao: ' ||s.machine           as ESTACAO_
,'Cliente: ' ||s.client_identifier as CLIENT_ID_
,'Info: '    ||s.client_info       as CLIENT_INFO_
,'Programa: '||s.program           as PROGRAMA_
,'Modulo: '  ||s.module            as MODULO_
,'Acao: '    ||s.action            as ACAO_
,'Evento: '  ||s.event             as EVENTO_
,'Status: '  ||decode(s.status, 'ACTIVE', 'Ativa', 'INACTIVE', 'Inativa', s.status)||
    ' por '  ||substr(decode(trunc(s.last_call_et/86400),0,'',to_char(trunc(s.last_call_et/86400),'9')||'d ')||
                 to_char(to_date(mod(s.last_call_et,86400),'sssss'),'HH24"h "MI"min "SS"s"'),1,20) as STATUS_
,'Logon: '   ||to_char(s.logon_time, 'DD/MM/YYYY "as" HH24":"MI"h"') as LOGON_
,'SQL_ID: '  ||case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID_
,'Blocos Alterados: '||to_char(ceil(io.block_changes), '999G999G999') as BLK_ALTERADOS_
,'Leituras Fisicas: '||to_char(ceil(io.physical_reads), '999G999G999') as LEITURAS_
from gv$session S
inner join gv$sess_io IO on s.sid = io.sid
inner join gv$process P on s.inst_id = p.inst_id and s.paddr = p.addr
where s.sid  in (99999999)
order by io.block_changes desc ;



--# CRIAR UM REDO LOG (NOVO GRUPO) SINGLE INSTANCE
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
alter database add logfile group 5 ('/caminho/dados/redo01.log') size 500M ;


--# CRIAR GRUPO DE REDO LOG MULTIPLEXADO SINGLE INSTANCE
ALTER DATABASE ADD logfile GROUP 5
('/ora01/app/orateste/oradata/SEGTEST/redo05.log','/ora02/app/orateste/flash_recovery_area/SEGTEST/redo05.log') SIZE 512M;



--# CRIAR GRUPO DE REDO LOG MULTIPLEXADO RAC
ALTER DATABASE ADD logfile thread 1 GROUP 5 ('+DGDATA/cdbprd1/redo105a.log','+DGRECO/cdbprd1/redo105b.log') SIZE 512M;


--# FORCAR TROCA DO REDO LOGFILE
alter system switch logfile ;


--# DESCARREGAR OS GRUPOS DE REDO LOG
alter system checkpoint;


--# GERAR ARCHIVE (descarregar redo log)
----------------------------------------
alter system archive log all ;



--# VERIFICAR TAMANHO DO REDO
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL TAMANHO_MB  FOR 999,990
select sum(l.bytes)/1024/1024 as TAMANHO_MB
from  v$log L
inner join v$logfile F on l.group# = f.group# ;



--# VERIFICAR OS REDO LOGS
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL STATUS       FOR A10
COL MEMBER       FOR A50
COL FIRST_TIME   FOR A20
select l.thread#, l.group#, l.sequence#, f.member, l.bytes/1024/1024 as SIZE_MB
    , l.archived, l.status, to_char(l.first_time,'YYYY-MM-DD HH24:MI:SS') as FIRST_TIME
from  v$log L
inner join v$logfile F on l.group# = f.group#
order by 1, FIRST_TIME ;


--# IDENTIFICAR REDO LOGS COM BLOCK SIZE
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
col archived format a9
col group# format 999
col mem format 999
col thread# format 999
col tamanho format 9999999
col member format a55
col status format a8
col first_time format a17
select a.thread#, a.group#, a.members as mem, a.sequence#, b.member, a.blocksize, a.bytes/1024/1024 as tamanho_mb,
 a.archived, a.status, to_char(a.first_time,'YYYY/MM/DD HH24:MI') as first_time
from v$log a
 inner join v$logfile b
  on a.group# = b.group#
order by first_time, a.thread#, a.group#, b.member;
