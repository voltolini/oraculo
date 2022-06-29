----------------------------------
--#AUMENTAR O NÚMERO DE PROCESSOS
---------------------------------


--#VERIFICAR VALOR ATUAL
show parameter processes


--#BAIXAR A BASE
shutdown immediate;


--#SUBIR EM MODO MOUNT
startup mount;


--#ALTERAR O PARAMETRO
alter system set processes=1100 scope=spfile;


--#ABRIR O BANCO
alter database open;


--#VERIFICAR SE A ALTERAÇÃO FICOU OK
show parameter processes;
