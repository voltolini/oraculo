--# ALTERAR NÚMERO DE CURSORES NA BASE (QUANDO FOR MENOR QUE 5.000 MIL)
alter system set open_cursors= 5000 scope=both;

ou

alter system set open_cursors= 5000;


--#VERIFICAR QUANTIDADE MAXIMA DE CURSORES
show parameter open_cursor



--# VERIFICAR QUANTIDADE DE CURSORES AGORA (TOP 10)
set pages 1000 lines 190 long 10000
COL OS_PID           FOR 999999
COL SID_SESSAO       FOR A13
COL STATUS           FOR A7
COL TEMPO            FOR A12 TRU
COL OWNER            FOR A15
COL USUARIO          FOR A20
COL ESTACAO          FOR A22
COL ACAO             FOR A22
COL QTDE             FOR 9,990
COL PROGRAMA_MODULO  FOR A20
select * from (
select c.sid||','||s.serial#||',@'||s.inst_id as SID_SESSAO
    , to_number(p.spid) as OS_PID, decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , to_char(to_date(mod(s.last_call_et, 86400),'sssss'),'HH24"h "MI"m "SS"s"') as TEMPO
    , c.user_name as OWNER, s.osuser as USUARIO, s.machine as ESTACAO
    , s.program||case when s.program != s.module then ','||s.module else '' end as PROGRAMA_MODULO, s.action as ACAO
    , case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID, count(*) as QTDE
from gv$open_cursor C
left join gv$session S on c.sid = s.sid and c.inst_id = s.inst_id
left join gv$process P on p.inst_id = s.inst_id and p.addr = s.paddr
group by c.sid, s.serial#, s.inst_id, p.spid, s.status, s.last_call_et, c.user_name
    , s.osuser, s.machine, s.program, s.module, s.action, s.sql_id, s.prev_sql_id
order by QTDE desc
) where rownum <= 10 ;


--# VERIFICAR QUANTIDADE DE CURSORES ABERTOS DESDE INICIO DA SESSAO > 1000
set pages 1000 lines 190 long 10000
COL OS_PID           FOR 999999
COL SID_SESSAO       FOR A13
COL STATUS           FOR A7
COL TEMPO            FOR A12 TRU
COL OWNER            FOR A15
COL USUARIO          FOR A20
COL ESTACAO          FOR A22
COL ACAO             FOR A22
COL QTDE             FOR 9,990
COL PROGRAMA_MODULO  FOR A20
select s.sid||','||s.serial#||',@'||s.inst_id as SID_SESSAO
    , to_number(p.spid) as OS_PID, decode(s.status, 'ACTIVE', 'ATIVA', 'INACTIVE', 'INATIVA', s.status) as STATUS
    , to_char(to_date(mod(s.last_call_et, 86400),'sssss'),'HH24"h "MI"m "SS"s"') as TEMPO
    , s.username as OWNER, s.osuser as USUARIO, s.machine as ESTACAO
    , s.program||case when s.program != s.module then ','||s.module else '' end as PROGRAMA_MODULO, s.action as ACAO
    , case when s.sql_id is null then '*'||s.prev_sql_id else s.sql_id end as SQL_ID, t.value as QTDE
from  gv$session S
left outer join gv$process P on p.inst_id = s.inst_id and p.addr = s.paddr
inner join gv$sesstat T on t.sid = s.sid
inner join gv$statname N on n.statistic# = t.statistic#
where upper(n.name) = 'OPENED CURSORS CURRENT'
  and t.value > 1000
order by QTDE desc ;



--# VERIFICAR POSSÍVEL COMANDO QUE GEROU O EVENTO
set pages 1000 lines 190 long 10000
COL INST        FOR 999
COL SID_SERIAL  FOR A10
COL USER_NAME   FOR A15
COL SQL_TEXT    FOR A60
COL CURSORES    FOR 9990
select C.inst_id as INST, C.sid||','||S.serial# as SID_SERIAL, C.user_name, C.sql_id, C.sql_text, count(*) as CURSORES
from  gv$open_cursor C inner join gv$session S on C.sid = S.sid and C.inst_id = S.inst_id
where C.sid = 2101  -- sempre filtrar a sessao
  and C.inst_id = 1
group by C.inst_id, C.sid||','||S.serial#, C.user_name, C.sql_id, C.sql_text
having count(*) > 1
order by CURSORES desc ;




--# UTILIZAÇÃO DE MEMORIA POR SESSÃO
set pagesize 1000
set linesize 190
set long 10
col username format a15
col status format a10
col type format a4
col os_pid format 999999
col sid_sessao format a13
col programa format a25
col usuario_estacao format a50
col hlogin format a10
col ult_cmd format 99999999
col module format a20
col stat format a6
col i format 9
col evento format a30
col curs format 9999
col mem_mb format '999,999,990'
select s.sid || ',' || s.serial# || ',@' || s.inst_id as sid_sessao,
 decode(status,'ACTIVE','ATIV','INACTIVE','INAT',status) as status,
 last_call_et as ult_cmd,
 decode(s.type,'USER','USER','BACKGROUND','BACK',status) as type,
 substr(s.username,1,25)||','||substr(s.osuser,1,25)||','||substr(s.machine,1,25) as usuario_estacao,
 substr(substr(s.program,instr(s.program,'\',-1)+1),1,25) as programa,
 substr(s.event,1,30) as evento,
 s.sql_id,
 (select count(*) from gv$open_cursor where inst_id = s.inst_id and sid = s.sid) as cursor,
 round(sum(st.value)/1024/1024,2) as mem_mb
from gv$session s, gv$sesstat st, gv$statname sn
where s.sid = st.sid
  and st.statistic# = sn.statistic#
  and sn.name like 'session % memory'
  and s.type = 'USER'
  and s.sid in (982)
group by s.sid, s.serial#, s.inst_id, status, last_call_et, s.username, s.osuser, decode(s.type,'USER','USER','BACKGROUND','BACK',status), s.machine, s.program, s.event, s.sql_id
--having round(sum(st.value)/1024/1024,2) >= 64
order by mem_mb desc;


