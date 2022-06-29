--# DML RECOMPILAR OBJETOS POR TIPO / OWNER
-------------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL COMANDO_SQL  FOR A169
--spool recompilar.sql
select 'ALTER'|| decode(o.owner,'PUBLIC','PUBLIC','') || ' ' ||
    upper(decode(o.object_type,'PACKAGE BODY','PACKAGE',o.object_type)) || ' ' ||
    decode(o.owner,'PUBLIC',' ','"' || o.owner || '".') || '"' ||
    o.object_name || '" ' || decode(o.object_type,'PACKAGE BODY','COMPILE BODY','COMPILE') || ' ;' as COMANDO_SQL
from dba_objects O
where o.status != 'VALID'
--  and o.owner       in ('REPLICA')
--  and o.object_type in ('SYNONYM')
--  and o.object_name like 'APEX%'
order by 1 ;
--spool off



--#COMPILAR OBJETOS INVÁLIDOS DO OWNER
exec UTL_RECOMP.RECOMP_SERIAL('OWNER') ;


--# RECOMPILAR OBJETO ESPECIFICO
--------------------------------
alter TIPO_OBJETO OWNER.NOME_OBJETO compile ;



--#QUANTIDADE OBJETOS SIMPLES
SET PAGES 1000 LINES 169 LONG 10000
COL QTDE FOR 9999999
COL TIPO FOR A30
SELECT status, COUNT(OBJECT_TYPE) as QTDE, OBJECT_TYPE as TIPO FROM DBA_OBJECTS
--WHERE OWNER LIKE 'LUCASM%'
and status ='INVALID'
GROUP BY OBJECT_TYPE,status;


--#TABELAS DO USUÁRIO
SELECT TABLE_NAME FROM DBA_TABLES WHERE OWNER ='';


--#QUANTIDADE DE OBEJETOS INVÁLIDOS
SELECT COUNT(*) AS QTDE FROM DBA_OBJECTS WHERE STATUS='INVALID' AND OWNER='HANDIT';



--#TABELAS DO OWNER SIMPLES
select owner, table_name from all_tables where owner='LUCASG';



--# VERIFICAR OBJETOS NO BANCO
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER           FOR A22
COL NOME_OBJETO     FOR A40
COL TIPO_OBJETO     FOR A20
COL STATUS          FOR A10
COL CRIADO          FOR A20
COL ULTIMO_DDL_DCL  FOR A20
COL TIMESTAMP       FOR A20
select o.owner, o.object_name AS NOME_OBJETO, o.object_type as TIPO_OBJETO, o.status
    , to_char(o.created,'YYYY-MM-DD HH24:MI:SS') as CRIADO, to_char(o.last_ddl_time,'YYYY-MM-DD HH24:MI:SS') as ULTIMO_DDL_DCL
    , to_char(to_date(o.timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') as TIMESTAMP
from  dba_objects O
where o.owner       in ('VESTIS01')
and o.object_name in ('V_PEDFAT_CLI_1')
order by OWNER, TIPO_OBJETO, NOME_OBJETO ;







--# VERIFICAR SINONIMOS DBA_SYNONYMS
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER_SYNONYM FOR A30
COL SYNONYM_NAME FOR A20
COL REF_OWNER FOR A20
COL REF_TABLE FOR A25
COL DB_LINK FOR A30
COL CONTAINER_ORIG FOR A30
select s.owner as owner_synonym, s.synonym_name,
s.table_owner as ref_owner,
s.table_name as ref_table,
s.db_link, s.origin_con_id as container_orig
from dba_synonyms s
WHERE s.owner in ('PUBLIC')
and s.synonym_name='ABC'
and s.table_owner in ('XPTO')
and s.table_name in ('XPTO');









--# VERIFICAR TABELAS PARTICIONADAS
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER FOR A20
COL TABELA FOR A25
COL PARTITION_TYPE FOR A9
COL QTDE_PARTICOES FOR 99999999
COL STATUS FOR A8
COL DEF_TABLESPACE FOR A30
COL DEF_COMPRESSION FOR A8
COL DEF_COMPRESS_FOR FOR A20
select owner, table_name as tabela,
partitioning_type as partition_type,
partition_count as qtde_particoes,
status,
def_tablespace_name as def_tablespace,
def_pct_free,
def_compression, def_compress_for
FROM DBA_PART_TABLES
WHERE owner IN ('XPTO')
AND table_name IN ('XYZ')
AND status='VALID'
AND def_tablespace_name='SPATQ'
ORDER BY partition_count DESC;






--# VERIFICAR SEQUENCES
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER FOR A20
COL SEQUENCE_NAME FOR A30
COL MIN_VALUE FOR 99999999
COL MAX_VALUE FOR 99999999
COL INCREMENT_BY FOR 99999999
COL LAST_NUMBER FOR 99999999
select sequence_owner as owner,
sequence_name,
min_value, max_value,
increment_by, last_number
from dba_sequences
where sequence_owner in ('XPTO')
and sequence_name='ABCD';









--# VERIFICAR WARNINGS NOS OBJETOS (DBA_WARNING_SETTINGS)
--# PROCEDURE, FUNCTION, PACKAGE, PACKAGE BODY, TRIGGER, TYPE, TYPE BODY
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER FOR A25
COL OBJETO FOR A30
COL OBJECT_ID FOR 999999999
COL TIPO FOR A12
COL WARNING FOR A40
COL SETTING FOR A7
select owner,
object_name as objeto,
object_id, object_type as tipo,
warning, setting
from dba_warning_settings
where owner in ('SYSTEM')
--and object_name='ACMB'
--and object_type='PROCEDURE'
--and warning='PERFORMANCE'
--and setting='ERROR'
order by object_id;







--# VERIFICAR ALERTAS NO PDB
SET LINES 237 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL TIME FOR A17
COL NOME_PDB FOR A25
COL RZ_ALERT FOR 9999999999
COL TP_VIOLATION FOR 99999999
COL MESSAGE FOR A100
COL ACTION FOR A60
SELECT TO_CHAR(TIME,'YYYY-MM-DD HH24:MI:SS') AS TIME,
NAME AS NOME_PDB,
CAUSE_NO AS RZ_ALERT,
TYPE_NO AS TP_VIOLATION,
ERROR AS ORA_ERR,
LINE, MESSAGE,
STATUS, ACTION
FROM PDB_ALERTS;







--# VERIFICAR TRIGGERS DE LOGON OU DDL
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
col owner format a20
col tri_status format a10
col obj_status format a10
col trigger_name format a50
col triggering_event format a50
select a.owner, a.trigger_name, a.status as tri_status, o.status as obj_status, a.triggering_event
from dba_triggers a
inner join dba_objects o
on a.owner = o.owner
and a.trigger_name = o.object_name
where a.triggering_event like '%LOGON%'
or a.triggering_event like '%DDL%'
order by a.owner, a.trigger_name;




-----------------------------
--# CONSULTAR VIEWS CRIADAS
-----------------------------


SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER FOR A20
COL NOME_VIEW FOR A20
COL OWNER_VIEW FOR A20
COL TIPO_VIEW FOR A15
COL USO_FUTURO FOR A10
COL READ_ONLY FOR A9
SELECT dv.owner as owner,
dv.view_name as nome_view,
dv.view_type_owner as owner_view,
dv.view_type as tipo_view,
dv.editioning_view uso_futuro,
dv.read_only as read_only
from dba_views dv
where dv.owner in ('RAFAEL');
--and dv.view_name in ('XPTO');






--# QTDE DE OBJETOS POR TIPO
SET PAGES 1000 LINES 169 LONG 10000
COL OWNER        FOR A30
COL OBJECT_TYPE  FOR A30
COL OBJECT_NAME  FOR A30
COL QTDE         FOR 999999
select o.object_type, o.object_name, count(*) as QTDE
from  dba_objects O
where o.owner in ('LUCASM') --and to_char(o.created,'YYYYMMDDHH24MISS') <= 'BKP_HASH'
--and o.status='INVALID'
group by o.object_type, o.object_name
order by 1, 2 ;





--# VERIFICAR ERROS DE COMPILACAO DO OBJETO
-------------------------------------------
COL OWNER        FOR A20
COL TIPO_OBJETO  FOR A18
COL NOME_OBJETO  FOR A25
COL DESCRICAO    FOR A80
COL LINE         FOR 99999
COL POSITION     FOR 999  HEA "POS"
select e.owner, e.name as NOME_OBJETO, e.type as TIPO_OBJETO, e.line, e.position, e.attribute, e.text as DESCRICAO
from  dba_errors E
where e.owner in ('OWNER')
  and e.name  in ('NOME_OBJETO')
  and e.type  in ('TIPO_OBJETO')
order by 1, 2, 3, 4, 5 ;




--# ULTIMOS OBJETOS ALTERADOS
set pages 1000 lines 190 long 10000
COL OWNER           FOR A20
COL NOME_OBJETO     FOR A25
COL TIPO_OBJETO     FOR A12
COL STATUS          FOR A8
COL CRIADO          FOR A17
COL ULTIMO_DDL_DCL  FOR A17
COL TIMESTAMP       FOR A17
select o.owner, o.object_name AS NOME_OBJETO, o.object_type as TIPO_OBJETO, o.status
    , to_char(o.created,'YYYY-MM-DD HH24:MI') as CRIADO, to_char(o.last_ddl_time,'YYYY-MM-DD HH24:MI') as ULTIMO_DDL_DCL
    , to_char(to_date(o.timestamp,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI') as TIMESTAMP
--select count(*)
from  dba_objects O
where (  o.created       >= sysdate-1
      or o.last_ddl_time >= sysdate-1)
  and o.owner       in ('OPT_01')
--  and o.object_name in ('CDF_CLASINDENIZACAO')
--  and o.object_type in ('TABLE')
order by ULTIMO_DDL_DCL ;





--VER OBJETOS DO OWNER SIMPLES
SET PAGES 1000 LINES 169 LONG 10000
COL OWNER FOR A15
COL OBJECT_NAME FOR A30
COL TIPO FOR A12
select owner,
object_name,
object_type as tipo
from all_objects
where owner='LUCASM';





--# VER TABLESPACES ONDE OWNER TEM OBJETOS / QUAIS OWNERS TEM OBJETOS NA TABLESPACE
SET PAGES 1000 LINES 169 LONG 10000
COL TABLESPACE  FOR A30
COL OWNER       FOR A30
COL SIZE_MB     FOR 999,990
select s.owner as OWNER, s.tablespace_name as TABLESPACE, ceil(sum(s.bytes/1024/1024)) as SIZE_MB
from  dba_segments S
where s.owner in ('LUCASM')
--   or s.tablespace_name in ('TEMP')
group by s.owner, s.tablespace_name
order by 1, 2 ;





--# USUARIOS DO BANCO
COL USUARIO     FOR A30
COL STATUS      FOR A20
COL VERSAO      FOR A13
COL PROFILE     FOR A15
COL TS_PADRAO   FOR A30
COL TS_TEMP     FOR A15
COL CRIACAO     FOR A17
COL VALIDADE    FOR A17
COL BLOQUEIO    FOR A17
select u.username as USUARIO
    , u.account_status as STATUS
--    , u.password_versions as VERSAO
--    , u.common  -- 12c usuario comum a todos os PDBs
    , u.profile as PROFILE
    , u.default_tablespace as TS_PADRAO
    , u.temporary_tablespace as TS_TEMP
    , to_char(u.created,'YYYY-MM-DD HH24:MI') as CRIACAO
    , to_char(u.expiry_date,'YYYY-MM-DD HH24:MI') as VALIDADE
    , to_char(u.lock_date,'YYYY-MM-DD HH24:MI') as BLOQUEIO
from  dba_users U
where u.username is NOT null
  and u.account_status = 'OPEN'
--  and u.username in ('USUARIO')
--  and u.default_tablespace in ('SYSAUX', 'SYSTEM')
--  and u.temporary_tablespace in ('RONDA_TEFTEMP')
order by USUARIO ;



--# TOP 30 - TAMANHO DOS OBJETOS
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER          FOR A18
COL TABELA         FOR A30
COL COLUNA         FOR A16
COL NOME_SEGMENTO  FOR A30
COL TIPO_SEGMENTO  FOR A14
COL LINHAS         FOR 999,999,990
COL SIZE_MB        FOR 999,990  HEA "TAMANHO_MB"
COL TABLESPACE     FOR A20
select * from (
select s.owner
    , case when s.segment_type in ('LOBSEGMENT') then
        (select l.table_name from dba_lobs L where l.owner = s.owner and l.segment_name = s.segment_name)
           when s.segment_type in ('LOBINDEX', 'INDEX') then
        (select i.table_name from dba_indexes I where i.owner = s.owner and i.index_name = s.segment_name)
      else s.segment_name end as TABELA
    , case when s.segment_type in ('LOBSEGMENT') then
        (select l.column_name from dba_lobs L where l.owner = s.owner and l.segment_name = s.segment_name)
      else '' end as COLUNA
    , case when s.segment_type in ('LOBSEGMENT') then
        (select l.segment_name from dba_lobs L where l.owner = s.owner and l.segment_name = s.segment_name)
           when s.segment_type in ('LOBINDEX') then
        (select i.index_name from dba_indexes I where i.owner = s.owner and i.index_name = s.segment_name)
      else s.segment_name end as NOME_SEGMENTO
    , s.segment_type as TIPO_SEGMENTO, s.SIZE_MB, s.LINHAS, s.tablespace_name as TABLESPACE
from (select x.owner, x.segment_type, x.segment_name, x.tablespace_name, sum(x.bytes)/1024/1024 as SIZE_MB
          , (select t.num_rows from dba_tables T where t.owner = x.owner and t.table_name = x.segment_name) as LINHAS
      from  dba_segments X
      where x.segment_type NOT like ('TYPE%')
      group by x.owner, x.segment_type, x.segment_name, x.tablespace_name
      order by 5 desc) S
where s.tablespace_name in ('SGTLOGS')
--and s.owner in ('IFROTA')
--and s.segment_type='TABLE'
--AND s.segment_name='IFROTA_LOG'
order by s.size_mb desc
) where rownum <= 30 ;




--# TOP 30 MAIORES OBJETOS - LOBS (TABELA.CAMPO_LOB)
SET LINES 237 PAGES 10000 LONG 1000000 FEED 2 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL OWNER          FOR A30
COL NOME_SEGMENTO  FOR A60
COL TIPO_SEGMENTO  FOR A15
COL TABLESPACE     FOR A30
COL LINHAS         FOR 999,999,990
COL SIZE_MB        FOR 999,999,990  HEA "TAMANHO_MB"
select * from (
select S.owner
    , case when S.segment_type in ('LOBSEGMENT') then
        (select L.table_name||'.'||L.column_name from dba_lobs L where L.owner = S.owner and L.segment_name = S.segment_name)
      else S.segment_name end as NOME_SEGMENTO
    , S.segment_type as TIPO_SEGMENTO, S.SIZE_MB, S.LINHAS, S.tablespace_name as TABLESPACE
from (select X.owner, X.segment_type, X.segment_name, X.tablespace_name, ceil(sum(X.bytes)/1024/1024) as SIZE_MB
          , (select t.num_rows from dba_tables T where t.owner = X.owner and t.table_name = X.segment_name) as LINHAS
      from  dba_segments X
      where X.segment_type NOT like 'TYPE%'
      group by X.owner, X.segment_type, X.segment_name, X.tablespace_name
      order by size_mb desc) S
where S.owner            in ('OWNER')
  and (   S.segment_name in ('SEGMENTO')
      or (select L.table_name from dba_lobs L    where L.owner = S.owner and L.segment_name = S.segment_name) in ('SEGMENTO')
      or (select I.table_name from dba_indexes I where I.owner = S.owner and I.index_name   = S.segment_name) in ('SEGMENTO') )
  and S.segment_type     in ('TIPO')
  and S.tablespace_name  in ('TABLESPACE')
  and S.size_mb > 1024  -- > 1 GB
  and S.linhas > 1000000  -- > 1 milhao
order by S.size_mb desc
) where rownum <= 30 ;







--# TOP 30 MAIORES OBJETOS (HEALTH CHECK)
-----------------------------------------
SET LINES 169 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL OWNER          FOR A16
COL NOME_SEGMENTO  FOR A30
COL COLUNA         FOR A30
COL TIPO_SEGMENTO  FOR A14
COL LINHAS         FOR 999,999,990
COL SIZE_MB        FOR 999,990  HEA "TAMANHO_MB"
select * from (
select s.owner
    , case when s.segment_type in ('LOBSEGMENT') then
        (select l.table_name||'.'||l.column_name from dba_lobs L where l.owner = s.owner and l.segment_name = s.segment_name)
           when s.segment_type in ('LOBINDEX', 'INDEX') then
        (select i.table_name||'.INDEX' from dba_indexes I where i.owner = s.owner and i.index_name = s.segment_name)
      else s.segment_name end as NOME_SEGMENTO
    , s.segment_type as TIPO_SEGMENTO, s.SIZE_MB, s.LINHAS
from (select x.owner, x.segment_type, x.segment_name, x.tablespace_name, sum(x.bytes)/1024/1024 as SIZE_MB
          , (select t.num_rows from dba_tables T where t.owner = x.owner and t.table_name = x.segment_name) as LINHAS
      from  dba_segments X
      where x.segment_type NOT like 'TYPE%'
      group by x.owner, x.segment_type, x.segment_name, x.tablespace_name
      order by 5 desc) S
order by s.size_mb desc
) where rownum <= 30 ;




--# VERIFICAR TAMANHO DO OWNER
SET LINES 169 PAGES 1000 LONG 100000 FEED 1 ECHO ON TI ON TIMI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL OWNER    FOR A30      HEA "USUARIO"
COL SIZE_MB  FOR 999,990  HEA "TAMANHO_MB"
select s.owner, ceil(sum(s.bytes)/1024/1024) as SIZE_MB
from   dba_segments S group by s.owner
having s.owner in ('SISPRO_UNIF')
order by 2 desc ;




--# CONSTRAINTS
SET LINES 190 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL OWNER FOR A20
COL CONST_NAME FOR A30
COL REF_OWNER FOR A20
COL TABELA FOR A30
COL R_CONST_NAME FOR A30
COL STATUS FOR A10
select dc.owner,
dc.constraint_name as const_name,
dc.r_owner as ref_owner,
dc.table_name as tabela,
dc.r_constraint_name as R_CONST_NAME,
dc.status
from dba_constraints dc
where dc.owner='RAFAEL'
and dc.status='ENABLED'
and dc.table_name like '%XPTO%'
and dc.r_owner!= dc.owner;





--# EXCLUIR OBJETOS NO PUBLIC REF OWNER IMPORTANDO
select 'DROP PUBLIC '||D.type||' "'||D.name||'"'||' ;' as CMD
from  dba_dependencies D where D.owner in ('PUBLIC')
 and  D.referenced_owner in ('OWNER_IMPORTANDO')
order by 1 ;







--# VER DEPENDENCIAS DO OBJETO - QUAIS OBJETOS X COMPOEM O OBJETO Y / QUAIS OBJETOS SAO ACESSADOS PELO OBJETO X
---------------------------------------------------------------------------------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL OWNER      FOR A25
COL NAME       FOR A35
COL TYPE       FOR A20
COL REF_OWNER  FOR A25
COL REF_NAME   FOR A35
COL REF_TYPE   FOR A15
select d.owner, d.name, d.type, d.referenced_owner as REF_OWNER
    , d.referenced_name as REF_NAME, d.referenced_type as REF_TYPE, d.dependency_type
from  dba_dependencies D
where d.owner            in ('RAFAEL' ,'RAFA')
--  and d.name             in ('SAMAE_PREVISAO_RECEITA')
--  and d.type             in ('VIEW')
  and d.owner!= d.referenced_owner
--  and d.referenced_owner in ('REF_OWNER')
--  and d.referenced_name  in ('REF_OBJETO')
--  and d.referenced_type  in ('REF_TIPO')
order by OWNER, TYPE, NAME ;




--# VER DEPENDENCIAS ENTRE OWNERS (DESTE PARA OUTRO / DE OUTRO PARA ESTE)
DEFINE V_OWNER = "LUCASK"
COL USUARIO  FOR A30
select D.owner as USUARIO from dba_dependencies D where D.referenced_owner = '&V_OWNER' and D.owner != D.referenced_owner union
select D.referenced_owner from dba_dependencies D where D.owner = '&V_OWNER' and D.owner != D.referenced_owner order by USUARIO ;






--# VER OS OBJETOS DEPENDENTES NO/DO PUBLIC
DEFINE V_OWNER = "LUCASK"
COL OWNER      FOR A10
COL NAME       FOR A10
COL TYPE       FOR A10
COL REF_OWNER  FOR A10
COL REF_NAME   FOR A30
COL REF_TYPE   FOR A10
select D.owner, D.name, D.type, D.referenced_owner as REF_OWNER
    , D.referenced_name as REF_NAME, D.referenced_type as REF_TYPE, D.dependency_type
from  dba_dependencies D
where D.owner in ('&V_OWNER')
  and D.referenced_owner in ('PUBLIC')
union
select D.owner, D.name, D.type, D.referenced_owner as REF_OWNER
    , D.referenced_name as REF_NAME, D.referenced_type as REF_TYPE, D.dependency_type
from  dba_dependencies D
where D.owner in ('PUBLIC')
  and D.referenced_owner in ('&V_OWNER')
order by OWNER, TYPE, NAME, REF_OWNER, REF_TYPE, REF_NAME ;






--# VER DEPENDENCIAS DOS OBJETOS
DEFINE V_OWNER = "LUCASK"
COL OWNER      FOR A30
COL NAME       FOR A30
COL TYPE       FOR A15
COL REF_OWNER  FOR A30
COL REF_NAME   FOR A30
COL REF_TYPE   FOR A15
select D.owner, D.name, D.type, D.referenced_owner as REF_OWNER
    , D.referenced_name as REF_NAME, D.referenced_type as REF_TYPE, D.dependency_type
from  dba_dependencies D
where (D.owner in ('&V_OWNER') or D.referenced_owner in ('&V_OWNER'))
  and D.owner != D.referenced_owner
order by OWNER, TYPE, NAME, REF_OWNER, REF_TYPE, REF_NAME ;





--# DEPENDENCIAS OWNER/IMPORT E DEPENDENCIAS DE OUTROS OWNERS NO OWNER QUE SERÁ IMPORTADO
SET LINES 237 PAGES 10000 LONG 1000000 FEED 1 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER ON DESC LINENUM ON
DEFINE V_OWNER = "LUCASK"
COL USUARIO  FOR A30
select distinct D.owner as USUARIO from dba_dependencies D where D.referenced_owner = '&V_OWNER' and D.owner != D.referenced_owner union
select distinct D.referenced_owner from dba_dependencies D where D.owner = '&V_OWNER' and D.owner != D.referenced_owner union
select distinct T.grantee from dba_tab_privs T where T.owner in ('&V_OWNER') union
select distinct C.grantee from dba_col_privs C where C.owner in ('&V_OWNER') order by 1 ;




Type of object: FUNCTION, JAVA SOURCE, PACKAGE, PACKAGE BODY, PROCEDURE, TRIGGER, TYPE, TYPE BODY, SYNONYM


--# DDL DE OBJETOS CODIGO FONTE
SET PAGES 0
SET LINES 10000
SET LONG 100000
SET ECHO OFF
SET LONG 90000
SET FEEDBACK OFF
SET VERIFY OFF
SET TRIMSPOOL ON
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',true);
exec dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',true);
select dbms_metadata.get_ddl('PACKAGE','PLS_DEL_CONTA_POS_ESTAB_LOG','TASY') from dual;
select dbms_metadata.get_ddl('FUNCTION','PFCS_GET_TELE_TIME','TASY') from dual;
select dbms_metadata.get_ddl('PROCEDURE','PLS_DEL_CONTA_POS_ESTAB_LOG','TASY') from dual;
select dbms_metadata.get_ddl('TRIGGER','DDL_TRIG','METISADBA') from dual;
select dbms_metadata.get_ddl('VIEW','TBINTAUXPERFILCLIENTE','KARSTENWVINTPRD') from dual;




--# TRIGGERS EM UMA TABELA ESPECIFICA
SET PAGES 1000 LINES 169 LONG 10000
COL NOME FOR A25
COL TIPO FOR A20
COL STATUS FOR A8
SELECT TRIGGER_NAME AS NOME,
TRIGGER_TYPE AS TIPO,
STATUS FROM DBA_TRIGGERS
WHERE TABLE_NAME='PLS_CONTA_POS_ESTAB_LOG';




--# OBJETOS COM ERROS (DBA_ERRORS)
SET PAGES 1000 LINES 169 LONG 10000
COL OWNER FOR A20
COL OBJECT_NAME FOR A30
COL OBJECT_TYPE FOR A12
COL TEXT FOR A60
COL ATTRIBUTE FOR A9
COL ERRO FOR 99999999
select e.owner, e.name as object_name,
e.type as object_type,
e.text,
e.attribute,
e.message_number as erro
from dba_errors e;
where owner='XPTO';



--# OBJETOS COM ERROS2 (DBA_ERRORS)
set pages 1000
set lines 190
set long 90000
col owner format a20
col type format a20
col name format a25
col text format a75
select owner, type, name, line, position, attribute, text
from dba_errors
where owner = 'PRONTO3'
  and name in ('VACINAUPDATE')
order by 1,2,3,4,5;
