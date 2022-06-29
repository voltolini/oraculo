--#CRIAR DB LINK
CREATE DATABASE nome_db_link
CONNECT TO usuario IDENTIFIED BY senha
USING 'banco';


CREATE DATABASE LINK SURICATO
CONNECT TO SURICATO IDENTIFIED BY suricato
USING 'SURICATO' ;



/*O usuario especificado na criação do dblink deve existir no banco "remoto" e se caso a senha do usuário de
conexão ao banco "remoto" for alterada o dblink deve ser excluído e recriado com a nova senha do usuario*/

--# DROPAR DB LINK
DROP DATABASE LINK

--#VER DB_LINKS DA BASE
SET PAGES 1000 LINES 169 LONG 10000
COL OWNER FOR A20
COL DB_LINK FOR A30
COL USUARIO FOR A20
COL HOST FOR A25
COL CRIADO FOR A18
select owner,
db_link,
username as usuario,
host,
to_char (created,'YYYY-MM-DD HH24:MI') as criado from dba_db_links;
