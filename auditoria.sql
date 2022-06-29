--# VER CONFIG AUDITORIA DE OBJETOS
COL OWNER        FOR A30
COL OBJECT_NAME  FOR A30
COL OBJECT_TYPE  FOR A11
select A.* from dba_obj_audit_opts A
where A.owner='SAPIENS'
and A.object_name='E210EST'
order by A.owner, A.object_type, A.object_name ;









--# USUÁRIOS COM FALHA DE LOGON
COLUMN filename new_val filename
SELECT 'unsuccessfully_logon_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename  FROM dual;

SET colsep ';'
SET pagesize 1000
SET trimspool ON
SET headsep ON
SET linesize 2000
SET LINES 200
COL TS FOR A25
COL USUARIO FOR A30
COL ESTACAO FOR A30
SELECT to_char(TIMESTAMP,'yyyy/mm/dd hh24:mm:ss') ts,
username as owner,
os_username as usuario,
userhost as estacao,
returncode, COUNT(1) as qtde
FROM dba_audit_trail
WHERE RETURNCODE != 0
AND TIMESTAMP BETWEEN TRUNC(SYSDATE-30,'MONTH') AND LAST_DAY(SYSDATE-30)
and username = 'CONSULTA'
GROUP BY to_char(TIMESTAMP,'yyyy/mm/dd hh24:mm:ss'), os_username, username, userhost, returncode
ORDER BY 1;

spool &filename
/
spool off





--# USUARIOS COM FALHA DE LOGIN LOGON
set pages 1000
set lines 1000
set time on
set timing on
col horario for a20
col username for a25
col os_username for a20
col action_name for a20
col userhost for a30
col terminal for a25
col owner for a20
col obj_name for a25
col scn for 9999999999999
--spool auditoria.log
select to_char(timestamp,'yyyy/mm/dd hh24:mi:ss') as horario, username, os_username, userhost, terminal,
 action_name, obj_name, /*scn, */returncode--, sql_text, sql_bind, owner
from dba_audit_trail
where timestamp >= to_date('2021/08/01 00:00','yyyy/mm/dd hh24:mi')
  --and timestamp <= to_date('2021/05/06 09:20','yyyy/mm/dd hh24:mi')
  and username in ('CONSULTA')
  --and username in ('SYS','LUZADM','LUZADMM')
  --and os_username in ('zabbix')
  --and owner = ''
  --and obj_name in ('VENDAS_2020')
  --and not action in (100,101,102) -- logon/logoff
  --and action in (49,43) -- alter system, alter user
  --and returncode in (1017) -- falha de logon
  --and not action_name in ('SELECT','INSERT','UPDATE','DELETE','TRUNCATE TABLE','DROP TABLE','CREATE TABLE','DROP INDEX','CREATE INDEX','CREATE TRIGGER','CREATE PACKAGE','CREATE PACKAGE BODY','EXECUTE PROCEDURE')
order by timestamp;






--# LISTAGEM DE USUÁRIOS DO BANCO DE DADOS
COLUMN filename new_val filename
SELECT 'lista_owners_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename  FROM dual;

SET LINES 300
SELECT * FROM dba_users ORDER BY 1

spool &filename
/
spool off




--# LISTA COMPLETA DE OWNERS DA BASE
COLUMN filename new_val filename
SELECT 'lista_owners_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename  FROM dual;

SET LINES 300
SELECT * FROM dba_users ORDER BY 1

spool &filename
/
spool off



--# LISTA DE USUÁRIOS COM PRIVILÉGIOS ANY
COLUMN filename new_val filename
SELECT 'select_any_table_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename FROM dual;

SET colsep ';'
SET pages 999
SET LINES 300
SELECT *
FROM dba_sys_privs
WHERE privilege LIKE '%ANY%'
ORDER BY 1

spool &filename
/
spool off




--# LISTA USUÁRIOS COM ROLE ANY TABLE
COLUMN filename new_val filename
SELECT 'role_privs_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename FROM dual;

SET colsep ';'
SET pages 999
SET LINES 300

SELECT A.*
FROM dba_role_privs A ,dba_users B
WHERE A.GRANTED_ROLE IN (SELECT grantee FROM dba_sys_privs WHERE privilege LIKE '%ANY TABLE' GROUP BY grantee)
  AND A.grantee = B.USERNAME
ORDER BY 1,2

spool &filename
/
spool off




--# SABER SE UM OWNER TEM ACESSO A OUTRO OWNER (RESUMO)
COLUMN filename new_val filename
SELECT 'auditoria_' || SYS_CONTEXT ('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'yyyymmdd' )||'.csv' filename  FROM dual;

SET colsep ';'
SET pages 999
SET LINES 999
SET SERVEROUTPUT ON
DECLARE
  -- Local variables here
  VCOUNT INTEGER;
  VLISTA CLOB;
  VCOLUNAS CLOB;
  TYPE my_lista_rec IS record(usuario varchar2(30));
  TYPE a_lista IS TABLE OF my_lista_rec INDEX BY binary_integer;
  lista a_lista;
  contador NUMBER := 0;
BEGIN
  -- Test statements here
  VCOLUNAS := 'USUARIO';
  FOR usu IN ( SELECT username FROM dba_users WHERE account_status ='OPEN' ORDER BY 1) LOOP
    lista(contador).usuario := usu.username;
    VCOLUNAS := VCOLUNAS ||';' || usu.username;
    contador := contador + 1;
  END LOOP;
  contador := 0;
  FOR i IN lista.first .. lista.last loop
      VLISTA := VLISTA || lista(i).usuario ||';';
      FOR usu IN ( SELECT username FROM dba_users WHERE account_status ='OPEN' ORDER BY 1) LOOP
        VCOUNT := 0;
        IF ( USU.USERNAME = lista(i).usuario ) THEN
          VLISTA := VLISTA || 'SIM;';
        ELSE
          SELECT COUNT(1) INTO VCOUNT FROM dba_tab_privs WHERE GRANTEE=USU.USERNAME AND OWNER = lista(i).usuario;
          IF ( VCOUNT > 0 ) THEN
            VLISTA := VLISTA || 'SIM;';
            VCOUNT:=0;
          ELSE
            SELECT COUNT(1) INTO VCOUNT FROM dba_sys_privs WHERE GRANTEE=USU.USERNAME AND PRIVILEGE LIKE '%ANY%';
            IF ( VCOUNT > 0 ) THEN
              VLISTA := VLISTA || 'SIM;';
              VCOUNT:=0;
            ELSE
              SELECT COUNT(1) INTO VCOUNT FROM dba_role_privs A WHERE grantee =USU.USERNAME AND EXISTS (SELECT 1 FROM DBA_SYS_PRIVS B WHERE PRIVILEGE LIKE '%ANY%' AND GRANTEE = A.GRANTED_ROLE);
              IF ( VCOUNT > 0 ) THEN
                VLISTA := VLISTA || 'SIM;';
              ELSE
                VLISTA := VLISTA || 'NAO;';
              END IF;
            END IF;
          END IF;
        END IF;
      END LOOP;
      VLISTA := VLISTA || CHR(10);
  END loop;
  /* Limpando tabelas de memória */
  lista.DELETE;
  DBMS_OUTPUT.PUT_LINE(VCOLUNAS);
  DBMS_OUTPUT.PUT_LINE(VLISTA);
END;
/
spool &filename
/
spool off
