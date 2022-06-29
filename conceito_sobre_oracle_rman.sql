------------------------------------
--# Conceito RMAN Oracle
------------------------------------


Para que seja possível realizar o backup do banco de forma onlien, primeiramente é necessário ativas o "archivelog mode" para que
os redologs sejam armazenados e nenhuma transação seja perdida durante a execução do backup.


   -> Caso contrário, será possível efetuar apenas backups com o servidor desligado.



--# Configurações do rman

Essas configurações sçao persistentes, ou seja, uma vez atribuido um deteminado valor ele nao precisa ser reconfigurado a cada execução.


-> Para exibir a configuração atual da ferramenta execute:

show all;


-> Todos os comandos que são listados podem ser reexecutados com outros valores para que a alteração seja feita.


-> Para realizar um backup, basta executar um simples comando

    BACKUP DATABASE;


Este backup será dividido em um ou mais "backups sets", que são conjuntos de datafiles, archivelogs, etc. por padrão cada "backupset" é
formado por 1 "backup piece" que consiste em um formato proprietário de arquivo. A grosso modo, tendo o backupset e os archivelogs é possível
restaurar o banco para qualquer "ponto no tempo".





O comando "delete noprompt obsolete" é para remover qualquer backup e archivelog que não se enquadre na política de retenção.


O "alter database backup controlfile to trace" gera uma versão em texto, caso o controlfile precise ser recriado manualmente.





----------------------------------------------------------------
--# Verificar se temos backup de todos os arquivos do database
----------------------------------------------------------------

REPORT NEED BACKUP;



--------------------------------------
--# Listagem com caminho dos arquivos
--------------------------------------

LIST BACKUP;





------------------------------
--# TESTAR SE O RMAN ESTÁ OK
------------------------------

RESTORE DATABASE VALIDATE ;

-> Irá realizar a leitura completa dos backupsets necessários para retaurar todos os datafiles controlfiles e spfiles do banco
"sem escreve-los no disco".




--# Restore do controlfile

RESTORE CONTROLFILE FROM AUTOBACKUP ;


Dentro do controlfile está o repositório do RMAN que contém o catalogo de todos os backups, sem ele o RMAN não saberia quais
backupsets precisam ser restaurados, ou onde se encontram.



--# Montar o banco de dados

ALTER DATABASE MOUNT ;


Com a montagem do banco (leitura do controlfile) permitimos que o RMAN tome conhecimento do repositório de catalogo dos backups.



--# Listar backupsets utilizados para o restore

RESTORES DATABASE PREVIEW ;



--# Efetuar o restore em si

RESTORE DATABASE ;



--# Sincronização dos datafiles para manter a integridade

RECOVER DATABASE UNTIL CANCEL ;


--# Abrir o banco apos restauração

ALTER DATABASE OPEN RESETLOGS ;
