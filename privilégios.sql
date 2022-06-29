--#VERIFICAR OS PRIVILEGIOS QUE O USUARIO POSSUI
SET LINES 169 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL TIPO      FOR A5
COL USUARIO   FOR A30
COL PRIVS     FOR A80  HEA "PRIVILEGIO OWNER.TABELA.COLUNA"
COL ADM_GR    FOR A12  HEA "RS_ADMIN_OPT|TC_GRANT_OPT"
COL DEF_ROLE  FOR A12  HEA "R_DEF_ROLE|T_HIERARCHY"
DEFINE USUARIO = 'ATRIAWVAPPPRD'
select 'ROLE' as TIPO, r.grantee as USUARIO
    , r.granted_role as PRIVS, r.admin_option as ADM_GR, r.default_role as DEF_ROLE
from  dba_role_privs R where r.grantee = '&USUARIO'
union
select 'SYS'  as TIPO, s.grantee as USUARIO
    , s.privilege as PRIVS, s.admin_option as ADM_GR, '' as DEF_ROLE
from  dba_sys_privs S where s.grantee = '&USUARIO'
union
select 'TAB'  as TIPO, t.grantee as USUARIO
    , t.privilege || ' ON ' || t.owner || '.' || t.table_name as PRIVS
    , t.grantable as ADM_GR, t.hierarchy as DEF_ROLE
from  dba_tab_privs T where t.grantee = '&USUARIO'
union
select 'zCOL' as TIPO, c.grantee as USUARIO
    , c.privilege || ' ON ' || c.owner || '.' || c.table_name || '.' || c.column_name as PRIVS
    , c.grantable as ADM_GR, '' as DEF_ROLE
from  dba_col_privs C where c.grantee = '&USUARIO'
order by 1, 3 ;




----------------------------------------------------------------------------------------
--# LISTAR PERMISSOES(VAI GERAR UM SCRIPT NO DIRETÓRIO QUE VOCÊ ESTÁ CONECTADO)

--# VAI GERAR UM SCRIPT NO DIRETÓRIO QUE VOCÊ ESTÁ CONECTADO

--# COPIAR VIA SCP PARA A MÁQUINA DESEJADA/LOCAL

--# CONECTAR NA BASE E EXECUTAR O SCRIPT COMO @NOMEARQUIVO
----------------------------------------------------------------------------------------
set pages 20000
set lines 190
col privilegio format a120
col privilege format a20
col table_name format a30
col owner format a20
col grantable format a10
col grantee format a30
spool permissoes_SAPIENS553.sql

select distinct 'grant '||granted_role||' to '||grantee||''||decode(admin_option,'YES',' with admin option')||';' as privilegio
--select granted_role, grantee, admin_option, DEFAULT_ROLE
from sys.dba_role_privs
where grantee in ('BETONMIX')
order by 1;

select distinct 'grant '||privilege||' to '||grantee||''||decode(admin_option,'YES',' with admin option')||';' as privilegio
from sys.dba_sys_privs
where grantee in ('BETONMIX')
order by 1;
union all
select 'grant '||privilege||' to '||grantee||''||decode(admin_option,'YES',' with admin option')||';' as privilegio
from sys.dba_sys_privs
where grantee in ('RESOURCE')
order by 1;

select distinct 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||''||decode(grantable,'YES',' with grant option')||';' as privilegio
--select privilege, owner, table_name, grantee, grantable
from sys.dba_tab_privs
where not owner is null
  and (owner in ('HANDIT') or grantee in ('HANDIT'))
  --and not grantee in ('PUBLIC','DBA','ORDSYS','SYS','SYSTEM','ORACLE_OCM','DBA','SELECT_CATALOG_ROLE','EXECUTE_CATALOG_ROLE','DELETE_CATALOG_ROLE','OEM_MONITOR','AQ_ADMINISTRATOR_ROLE','AQ_USER_ROLE','EXP_FULL_DATABASE','IMP_FULL_DATABASE','WM_ADMIN_ROLE','GATHER_SYSTEM_STATISTICS','AQ_ADMINISTRATOR_ROLE','XDBADMIN','DBSNMP','XDB','ORDPLUGINS','WMSYS','CTXSYS','CTXAPP','EXECUTE_CATALOG_ROLE','OUTLN','OEM_MONITOR','DELETE_CATALOG_ROLE','DBFS_ROLE','ORDADMIN','AQ_USER_ROLE','DATAPUMP_IMP_FULL_DATABASE','LOGSTDBY_ADMINISTRATOR','EXFSYS','APPQOSSYS','MDSYS','CTXSYS','OUTLN')
  --and privilege IN ('UPDATE')
  --and table_name in ('DIR_SIATU_ARQUIVOS','DIR_SIATU_SIMPLES_NACIONAL')
  --and table_name like 'DBMS%'
order by 1;






--# DCL SALVAR PRIVILEGIOS USUARIO
----------------------------------
SET LINES 237 PAGES 10000 LONG 1000000 FEED 2 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
DEFINE V_USUARIO = "SIMULADO"
COL DCL_PRIVS FOR A200 HEA "DCL_PRIVS_&V_USUARIO"
--COL V_SPOOL NEW_V V_SPOOL
--select lower(SYS_CONTEXT('USERENV', 'DB_NAME'))||'_privs_&V_USUARIO..sql' as V_SPOOL from dual ;
--spool &V_SPOOL
select * from (
    select 'GRANT '||R.granted_role||' TO "&V_USUARIO" '||decode(R.admin_option,'YES','WITH ADMIN OPTION ','')||';' as DCL_PRIVS
     from  dba_role_privs R where R.grantee in ('&V_USUARIO')
     union
    select 'GRANT '||S.privilege||' TO "&V_USUARIO" '||decode(S.admin_option,'YES','WITH ADMIN OPTION ','')||';'
      from dba_sys_privs S where S.grantee in ('&V_USUARIO','RESOURCE')  -- pegar role RESOUCE, pode ter outros privs
     union
    select 'GRANT '||T.privilege||' ON "'||T.owner||'"."'||T.table_name||'" TO "&V_USUARIO" '||decode(T.grantable,'YES','WITH GRANT OPTION ','')||';'
      from dba_tab_privs T where T.grantee in ('&V_USUARIO')
     union
    select 'GRANT '||C.privilege||' ("'||C.column_name||'") ON "'||C.owner||'"."'||C.table_name||'" TO "&V_USUARIO" '||decode(C.grantable,'YES','WITH GRANT OPTION ','')||';'
      from dba_col_privs C where C.grantee in ('&V_USUARIO')
) order by 1 ;
--spool off






--# CONCEDER AO USUARIO X PRIVILEGIO Y NO OWNER Z
SET LINES 237 PAGES 10000 LONG 1000000 FEED 2 ECHO ON TI ON TRIM ON TRIMS ON TERM ON SERVEROUT ON TAB OFF VER OFF DESC LINENUM ON
DEFINE V_OWNER    = "SIMULADO"                     -- dono do objeto
DEFINE V_USUARIO  = "NovoUsuario"                  -- usuario recebe priv
DEFINE V_PRIV     = "SELECT,INSERT,UPDATE,DELETE"  -- privilegio
DEFINE V_TIPO_OBJ = "TABLE"                        -- tipo objeto
COL DCL_PRIVS FOR A200
COL V_SPOOL NEW_V V_SPOOL
select lower(SYS_CONTEXT('USERENV', 'DB_NAME'))||'_privs_&V_USUARIO..sql' as V_SPOOL from dual ;
spool &V_SPOOL
select 'GRANT &V_PRIV ON "' || O.owner || '"."' || O.object_name || '" TO "&V_USUARIO" ;' as DCL_PRIVS
from dba_objects O where O.owner = '&V_OWNER' and O.object_type in ('&V_TIPO_OBJ') and O.status = 'VALID' order by O.object_type, O.object_name ;
spool off







--# COLETAR OS PRIVILÉGIOS DE TODOS OS USUÁRIOS
SET COLSEP ';'
begin
    dbms_output.put_line('USUARIO'||';'||'TIPO'||';'||'PRIVILEGIO'||';'||'OWNER'||';'||'TABELA'||';'||'COLUNA'||';'||'GRANT OPTION'||';'||'DEF_ROLE');
    for C1 in (select U.username from dba_users U where U.username in ('LISTA DE USUARIOS') ) loop
--    for C1 in (select R.role from dba_roles R where R.role in ('LISTA DE ROLES') ) loop
        -- roles
        for C2 in (select R.grantee as USUARIO, 'ROLE' as TIPO, R.granted_role as PRIVS, '' as OWNER, '' as TABELA, '' as COLUNA , R.admin_option as OPTIONN, R.default_role as DEF_ROLE
                   from dba_role_privs R where R.grantee in (C1.username) ) loop
            dbms_output.put_line(C2.usuario||';'||C2.tipo||';'||C2.privs||';'||C2.owner||';'||C2.tabela||';'||C2.coluna||';'||C2.optionn||';'||C2.def_role);
        end loop;
        -- privilegios de sistema
        for C3 in (select S.grantee as USUARIO, 'SYS' as TIPO, S.privilege as PRIVS, '' as OWNER, '' as TABELA, ''  as COLUNA, S.admin_option as OPTIONN, '' as DEF_ROLE
                   from dba_sys_privs  S where S.grantee in (C1.username) ) loop
            dbms_output.put_line(C3.usuario||';'||C3.tipo||';'||C3.privs||';'||C3.owner||';'||C3.tabela||';'||C3.coluna||';'||C3.optionn||';'||C3.def_role);
        end loop;
        -- privilegios em tabelas/objetos
        for C4 in (select T.grantee as USUARIO, 'TAB' as TIPO, T.privilege as PRIVS, T.owner as OWNER, T.table_name as TABELA, '' as COLUNA, T.grantable as OPTIONN, T.hierarchy as DEF_ROLE
                   from dba_tab_privs  T where T.grantee in (C1.username) ) loop
            dbms_output.put_line(C4.usuario||';'||C4.tipo||';'||C4.privs||';'||C4.owner||';'||C4.tabela||';'||C4.coluna||';'||C4.optionn||';'||C4.def_role);
        end loop;
        -- privilegios em colunas
        for C4 in (select C.grantee as USUARIO, 'COL' as TIPO, C.privilege as PRIVS, C.owner as OWNER, C.table_name as TABELA, C.column_name as COLUNA, C.grantable as OPTIONN, '' as DEF_ROLE
                   from dba_col_privs  C where C.grantee in (C1.username) ) loop
            dbms_output.put_line(C4.usuario||';'||C4.tipo||';'||C4.privs||';'||C4.owner||';'||C4.tabela||';'||C4.coluna||';'||C4.optionn||';'||C4.def_role);
        end loop;
    end loop;
end;
/









----------------------------
--# INSERIR USUÁRIO EM ROLE
----------------------------
GRANT DELETE ownerdarole.nomerole to usuario;
GRANT INSERT ownerdarole.nomerole to usuario;
GRANT SELECT ownerdarole.nomerole to usuario;
GRANT UPDATE ownerdarole.nomerole to usuario;

GRANT NOME_ROLE TO USUÁRIO;




------------------------------------------
--# USUÁRIO COM PRIVILÉGIO (CRIPTOGRAFIA)
------------------------------------------
GRANT EXECUTE ON SYS.DBMS_CRYPTO TO ENGEMAN;




--------------------------------------------
--# EXEMPLO SCP (ORIGEM PARA DESTINO) LINUX
--------------------------------------------
scp permissoes.sql root@10.100.1.233:/hmg-orabases-4800/backup











--# REVOGAR PRIVILÉGIO DE EXECUTE
revoke execute on ctxsys.ctx_ddl from owner;


--# REVOGAR PRIVILÉGIO DE SELECT EM TABELAS ESPECIFICAS
REVOKE SELECT ON TABLE t FROM maria,harry


--# REVOGAR PRIVILÉGIO DE USO EM UMA SEQUENCE
REVOKE USAGE ON SEQUENCE order_id FROM sales_role;





----------------------------
--# SELECT ANY DICTIONARY
----------------------------

O usuário pode acessar todos os objetos do SYS, incluindo tabelas que são criadas neste schema.
