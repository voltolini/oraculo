--# VER OBJETOS NA LIXEIRA (RECYCLEBIN)
---------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL TIPO_OBJ       FOR A15
COL TABLESPACE     FOR A15
COL SIZE_MB        FOR 999,990
COL ORIGINAL_NAME  FOR A30
select r.droptime, r.owner, r.original_name as NOME_OBJ_ORIGINAL, r.type as TIPO_OBJ, r.ts_name as TABLESPACE
     , r.object_name as NOME_OBJ_LIXEIRA, round((r.space*t.block_size)/1024/1024, 2) as TAMANHO_MB
from  dba_recyclebin R
inner join dba_tablespaces T on r.ts_name = t.tablespace_name
where r.owner         in ('OWNER')
  and r.original_name in ('NOME_OBJETO')
order by r.droptime ;


--# VER UTILIZACAO LIXEIRA - RESUMO
-----------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL OWNER       FOR A20
COL TAMANHO_MB  FOR 999,999,990
BREAK ON REPORT
COMP SUM OF TAMANHO_MB ON REPORT
SELECT s.owner, CEIL(SUM(s.bytes)/1024/1024) AS TAMANHO_MB
FROM  dba_segments S, dba_recyclebin R
WHERE s.segment_name = r.object_name
GROUP BY s.owner
ORDER BY TAMANHO_MB DESC ;



--# VER UTILIZACAO LIXEIRA - DETALHADO
--------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL OWNER              FOR A25
COL TABLESPACE         FOR A20
COL TIPO_OBJETO        FOR A15
COL DROPTIME           FOR A20
COL NOME_OBJ_ORIGINAL  FOR A35
COL NOME_OBJ_LIXEIRA   FOR A35
COL TAMANHO_MB         FOR 999,999
select r.droptime, r.owner, r.original_name as NOME_OBJ_ORIGINAL, r.type as TIPO_OBJETO, r.ts_name as TABLESPACE
     , r.object_name as NOME_OBJ_LIXEIRA, round((r.space*t.block_size)/1024/1024, 2) as TAMANHO_MB
--select r.owner, count(*)
from  dba_recyclebin R
inner join dba_tablespaces T on r.ts_name = t.tablespace_name
--where r.owner in ('ANALYTICS', 'DW-CONSULTORIA', 'DWPMZ', 'BACKUP','ALESSANDRO')
where r.owner in ('PEMAZA')
and r.droptime <= to_char(sysdate-60,'YYYY-MM-DD')
--  and r.type  in ('TABLE')
--  and r.original_name like '%TABELA%'
order by r.droptime desc, r.original_name ;


--# EXPURGAR OBJETOS DA LIXEIRA
-------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL OWNER              FOR A25
COL TABLESPACE         FOR A20
COL TIPO_OBJ           FOR A15
COL DROPTIME           FOR A20
COL NOME_OBJ_ORIGINAL  FOR A35
COL NOME_OBJ_LIXEIRA   FOR A35
COL TAMANHO_MB         FOR 999,999
--SET COLSEP ';'
spool lixeira.sql
select 'PURGE TABLE "' || r.owner || '"."' || r.object_name || '" ;' as CMD
from  dba_recyclebin R
inner join dba_tablespaces T on r.ts_name = t.tablespace_name
--where r.owner in ('ANALYTICS', 'DW-CONSULTORIA', 'DWPMZ', 'BACKUP','ALESSANDRO')
where r.owner in ('PEMAZA')
and r.droptime <= to_char(sysdate-60,'YYYY-MM-DD')
--  and r.type  in ('TABLE')
--  and r.original_name like '%TABELA%'
order by r.droptime desc, r.original_name ;
spool off
