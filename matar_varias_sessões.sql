--#MATAR VARIAS SESSÕES
set pages 1000
set lines 190
select 'alter system kill session '''||SID||','||SERIAL#||',@'||inst_id||''' immediate;' as comando
from gv$session
where not sid is null
  --and (upper(username) like '%PIMS%' or upper(username) like '%IFROTA%')
  and username in ('TEXTIL5')
  --and osuser in ('Alexandre')
  --and not upper(machine) in ('HBR\UPDATE_SYSTEM','IMWORKLIST')
  --and upper(program) in ('ERP.EXE')
  --and module IN ('JDBC Thin Client')
--  and status in ('INACTIVE')
order by last_call_et desc;


--#MATAR VARIAS SESSÕES
select 'ALTER SYSTEM KILL SESSION '''||s.sid||','||s.serial#||',@'||s.inst_id||''' IMMEDIATE ;' as KILL_SESSION
from  gv$session S where s.type = 'USER'
  and s.last_call_et > 86400  -- > 1 dia
  and upper(s.status)   in ('INACTIVE')
  and upper(s.username) in ('VIASOFTMCP')
  and upper(s.osuser)   in ('VIASOFT')
  and upper(s.machine)  in ('MCAGUASCLARAS\SRV-SISTEMA')
  and upper(s.program)  in ('VIASOFTSERVERMCP.EXE')
order by s.last_call_et desc ;




--#MATAR VARIAS SESSÕES EM UMA TABELA
set pages 1000 lines 169 long 10000
COL OS_PID         FOR 999999
COL INST           FOR 999
COL SID_SESSAO     FOR A12
COL STATUS         FOR A7
COL OWNER          FOR A15
COL USUARIO        FOR A20
COL ESTACAO        FOR A25
COL TABELAS        FOR A35 HEA "TABELA_BLOQUEADA"
COL MODO_BLOQUEIO  FOR A20
COL LOGON          FOR A20
select s.inst_id as INST, l.session_id||','||s.serial# as SID_SESSAO, to_number(p.spid) as OS_PID
    , decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , substr(l.oracle_username,1,100)           as OWNER
    , substr(l.os_user_name,1,100)              as USUARIO
    , substr(s.machine,1,100)                   as ESTACAO
    , substr(o.owner||'.'||o.object_name,1,100) as TABELAS
    , decode(l.locked_mode, 1,'NO LOCK', 2,'(SS) Row Share', 3,'(SX) Row Exclusive', 4,'(S) Share',
        5,'(SSX) Share Row Exc', 6,'Exclusive', null) as MODO_BLOQUEIO, s.sql_id
--    , to_char(s.logon_time,'YYYY-MM-DD HH24:MI:SS') as LOGON
--select 'alter system kill session '''||l.session_id||','||s.SERIAL#||',@'||s.inst_id||''' immediate;' as comando
from  gv$locked_object L
inner join dba_objects O on o.object_id = l.object_id
inner join gv$session S on s.inst_id = l.inst_id and s.sid = l.session_id
inner join v$process P on p.addr = s.paddr
--where l.session_id = 596
--  and l.inst_id = 99999999
--  and o.owner       in ('OWNER')
  where o.object_name in ('EMPR_013')
order by 1 ;
