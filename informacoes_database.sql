--# DBTIMEZONE DO DATABASE
SELECT dbtimezone FROM dual;



--# DATA AGORA
select to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') from dual;




--# INFORMACOES DO DATABASE
DEFINE _EDITOR=vi
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
SET SQLPROMPT '&_USER:&_CONNECT_IDENTIFIER > '
COL COUNT(*)  FOR 999,999,999
COL INFO2     FOR A50  HEA "INFO_DATETIME_HOSTNAME"
COL NAMES     FOR A40  HEA "INSTANCE_DATABASE_NAMES"
COL SVARC     FOR A50  HEA "STARTUP_VERSION_ARCHIVES"
select 'DATETIME: '||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') as INFO2,'DATABASE: '||d.name as NAMES,'STARTUP: '||to_char(i.startup_time,'YYYY-MM-DD HH24:MI:SS')||' -'||to_char(sysdate-i.startup_time, '999')||' dias' as SVARC from v$database D, v$instance I union
select 'HOSTNAME: '||i.host_name,'INSTANCE: '||i.instance_name,'VERSION: '||i.version||' - '||i.status||' - '||'ARCHIVES '||decode(i.archiver,'STARTED','[ON]','STOPPED','[OFF]') from v$instance I ;




--# INFORMACOES DO DATABASE / INSTANCIA (NOVO)
---------------------------------------
DEFINE _EDITOR=vi
COL V_SERVICE_NAME NEW_V V_SERVICE_NAME
select decode(upper(SYS_CONTEXT('USERENV', 'SERVICE_NAME')),'SYS$USERS',upper(SYS_CONTEXT('USERENV', 'DB_NAME')),upper(SYS_CONTEXT('USERENV', 'SERVICE_NAME'))) as V_SERVICE_NAME from dual ;
SET SQLPROMPT '&_USER:&V_SERVICE_NAME > '
SET LINES 237 PAGES 10000 LONG 100000 FEED 1 ECHO ON TI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL COUNT(*)  FOR 999,999,999
COL INFO2     FOR A45  HEA "INFO_DATETIME_HOSTNAME"
COL NAMES     FOR A30  HEA "DATABASE_INSTANCE_NAME"
COL SVARC     FOR A44  HEA "STARTUP_VERSION_ARCHIVES"
COL UPTIME    FOR A13  HEA "UPTIME DHMS"
select 'DATETIME: '||to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') as INFO2,'DATABASE: '||d.name as NAMES,'STARTUP: '||to_char(i.startup_time,'YYYY-MM-DD HH24:MI:SS') as SVARC, cast(interval '1' second * ((sysdate-i.startup_time)*86400) as interval day(0) to second(0)) as UPTIME from v$database D, v$instance I union
select 'HOSTNAME: '||i.host_name,'INSTANCE: '||i.instance_name,'VERSION: '||i.version||' - '||i.status||' - '||'ARCHIVES '||decode(i.archiver,'STARTED','[ON]','STOPPED','[OFF]'), null from v$instance I ;





--# EVIDENCIAR O NOME DO SERVIDOR
COL V_HOSTNAME NEW_V V_HOSTNAME
select upper(SYS_CONTEXT('USERENV', 'SERVER_HOST')) as V_HOSTNAME from dual ;
SET SQLPROMPT '&_USER:&V_HOSTNAME > '




--# SIMPLES
SET LINES 237 PAGES 10000 LONG 1000000 FEED 2 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') as DATE_TIME_NOW, substr(I.host_name,1,30) as HOSTNAME, d.dbid, D.name as DATABASE, I.instance_name as INSTANCE,
I.version, I.status, I.archiver, to_char(I.startup_time, 'YYYY-MM-DD HH24:MI:SS') as STARTUP, trunc(sysdate-I.startup_time) as DAYS_UP from v$database D, v$instance I ;
