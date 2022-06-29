--# SCRIPT EVIDENCIA (LOG) DE SCRIPTS
-------------------------------------
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
COL HORARIO        FOR A21
COL DATABASE_NAME  FOR A15
COL INSTANCE_NAME  FOR A15
COL HOST_NAME      FOR A40
COL FILENAME NEW_V FILENAME
select 'saida_SRV-' || SYS_CONTEXT('USERENV', 'SERVER_HOST') || '_DB-' || SYS_CONTEXT('USERENV', 'INSTANCE_NAME') ||'_'|| to_char(sysdate, 'YYYYMMDDHHMMSS' )||'.log' as FILENAME from dual ;
spool &filename
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') as HORARIO, i.instance_name, i.host_name from v$instance I ;
select d.dbid, d.name as DATABASE_NAME, d.open_mode, d.log_mode from v$database D ;
SHOW USER ;
-- @script ou comandos para executar
spool off ;
