--# CONSTRAINTS DESABILITADAS
-----------------------------
COLUMN filename new_val filename

SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST')||'_'||to_char(sysdate, 'YYYYMMDD' )||'_constraints_desabilitadas.csv' filename FROM dual;

SET colsep ';'
SET pagesize 6000
SET trimspool ON
SET headsep ON
SET linesize 2000

COL "USUARIO"            FOR A30
COL "NOME DA TABELA"     FOR A30
COL "TIPO DE CONSTRAINT" FOR A20
COL "NOME DA CONSTRAINT" FOR A30
COL "STATUS"             FOR A10

select distinct owner as "USUARIO"
    , table_name as"NOME DA TABELA"
    , decode(constraint_type,'C','CHECK CONSTRAINT','P','PRIMARY KEY','R','FOREIGN KEY','U','UNIQUE KEY','DESCONHECIDO') as "TIPO DE CONSTRAINT"
    , constraint_name as "NOME DA CONSTRAINT"
    , status
from sys.dba_constraints a
where status = 'DISABLED'
and owner not in ('SYS','WMSYS','EXFSYS','SYSTEM')
and not exists (select 1 from luzadm.luz_constraints l where l.owner=a.owner and l.nome_constraint=a.constraint_name)
order by 1,2,3

spool &filename
/
spool off


--# TRIGGERS DESABILITADAS
--------------------------
COLUMN filename new_val filename

SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST')||'_'||to_char(sysdate, 'YYYYMMDD' )||'_triggers_desabilitadas.csv' filename FROM dual;

SET colsep ';'
SET pagesize 6000
SET trimspool ON
SET headsep off
SET linesize 2000

COL "USUARIO"         FOR A30
COL "NOME DA TRIGGER" FOR A30
COL "STATUS"          FOR A10

select owner as "USUARIO", trigger_name as "NOME DA TRIGGER", status
from dba_triggers a
where status='DISABLED'
and owner not in ('SYS','WMSYS','EXFSYS','SYSTEM')
and not exists (select 1 from luzadm.luz_trigger t where t.owner=a.owner and t.trigger_name=a.trigger_name)
order by 1

spool &filename
/
spool off


--# OBJETOS INVALIDOS
---------------------
COLUMN filename new_val filename

SELECT SYS_CONTEXT('USERENV', 'SERVER_HOST')||'_'||to_char(sysdate, 'YYYYMMDD' )||'_objetos_invalidos.csv' filename FROM dual;

SET colsep ';'
SET pagesize 6000
SET trimspool ON
SET headsep off
SET linesize 2000

COL "USUARIO"       FOR A30
COL "TIPO DO OBJETO" FOR A20
COL "NOME DO OBJETO" FOR A30

select owner as "USUARIO"
    , object_type as "TIPO DO OBJETO"
    , object_name as "NOME DO OBJETO"
    , status
from  sys.dba_objects a
where status <> 'VALID'
  and owner not in ('SYS','WMSYS','EXFSYS','SYSTEM')
  and not exists (select 1 from luzadm.luz_objects_i l where l.owner=a.owner and l.object_name=a.object_name and  l.object_type=a.object_type)
order by 1,2,3,4

spool &filename
/
spool off
