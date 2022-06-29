--#MUDAR a senha e DESBLOQUEAR USUARIO AO MESMO TEMPO
ALTER USER LOGONE14 identified by logone14 ACCOUNT UNLOCK;


--#DESBLOQUEAR USUARIO
ALTER USER CONSULTA ACCOUNT UNLOCK;


--#BLOQUEAR USUARIO
ALTER USER TEXTIL5 ACCOUNT LOCK;


--# VERIFICAR STATUS DA CONTA SIMPLES
SET PAGES 1000 LINES 169 LONG 10000
COL USUARIO FOR A30
COL STATUS FOR A20
COL LOCK_DATE FOR A16
COL EXPIRY_DATE FOR A18
COL TABLESPACE FOR A20
COL TEMP FOR A15
COL PASSWORD FOR A30
select u.username as usuario ,
u.account_status as status,
to_char (u.lock_date,'YYYY-MM-DD HH24:MI:SS') as LOCK_DATE,
to_char (u.expiry_date,'YYYY-MM-DD HH24:MI:SS') as EXPIRY_DATE,
u.default_tablespace as tablespace,
u.temporary_tablespace as temp
from dba_users u
where u.username like'PROCESS%';



--# STATUS DA CONTA COMPLETO
SET PAGES 1000 LINES 190 LONG 10000
COL USUARIO FOR A30
COL STATUS FOR A20
COL VERSAO FOR A13
COL PROFILE FOR A15
COL TS_PADRAO FOR A30
COL TS_TEMP FOR A15
COL CRIACAO FOR A17
COL VALIDADE FOR A17
COL BLOQUEIO FOR A17
select u.username as USUARIO,
u.account_status as STATUS,
u.password_versions as VERSAO,
-- u.common -- 12c usuário comum a todos PDBs,
u.profile as PROFILE,
u.default_tablespace as TS_PADRAO,
u.temporary_tablespace as TS_TEMP,
to_char(u.created,'YYYY-MM-DD HH24:MI') as CRIACAO,
to_char(u.expiry_date,'YYYY-MM-DD HH24:MI') as VALIDADE,
to_char(u.lock_date,'YYYY-MM-DD HH24:MI') as BLOQUEIO
from dba_users u
where u.username is NOT null
and u.username in ('ATRIAWVWEB')
-- and u.account_status = 'OPEN'
--and u.created between (sysdate-1) and (sysdate)
order by USUARIO;




--# QTD DE FALHAS DE LOGON ANTES DE BLOQUEAR O USUARIO
alter profile default limit failed_login_attempts unlimited ;



--#TIRAR O LIMITE DE EXPIRAÇÃO DE SENHA
alter profile default limit password_life_time unlimited ;



/* --# DESCRICAO DO CAMPO 'STATUS' DA VIEW 'DBA_USERS'
                            OPEN <-- DISPONÍVEL PARA USO
                          LOCKED <-- USUARIO BLOQUEADO PELO DBA
                         EXPIRED <-- SENHA EXPIRADA, DEVE SER TROCADA
                EXPIRED & LOCKED <-- SENHA EXPIRADA, USUARIO BLOQUEADO
                 EXPIRED (GRACE) <-- SENHA EXPIRADA, DENTRO DA CARÊNCIA
                  LOCKED (TIMED) <-- USUARIO BLOQUEADO APOS INFORMAR SENHA INCORRETA
        EXPIRED & LOCKED (TIMED) <-- SENHA EXPIRADA, USUARIO BLOQUEADO APOS INFORMAR SENHA INCORRETA
        EXPIRED (GRACE) & LOCKED <-- SENHA EXPIRADA, DENTRO DA CARÊNCIA, USUARIO BLOQUEADO PELO DBA
EXPIRED (GRACE) & LOCKED (TIMED) <-- SENHA EXPIRADA, DENTRO DA CARÊNCIA, USUARIO BLOQUEADO APÓS INFORMAR SENHA INCORRETA
*/
