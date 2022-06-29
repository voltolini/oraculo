--# ALTERAR NUMERO DE PROCESSOS DO BANCO



--# ANTES DE ALTERAR O PARAMETRO
create pfile from spfile;



--#ALTERAR O PARAMETRO DE PROCESSOS
alter system set processes=850 scope=both;



--# BAIXAR O BANCO
shutdown immediate;



--# SUBIR O BANCO
startup;



--# SE CASO DER ERRO
erro!!!



--# SUBIR O BANCO COM O CAMINHO COMPLETO DO PFILE CRIADO NO INICIO
startup pfile=/oracle/product/19.3/db_p1/dbs/initdbteste.ora



--# CRIAR EM MEMORIA
create spfile from memory;



--# BAIXAR O BANCO
shutdown immediate;



--# SUBIR O BANCO NORMALMENTE
startup;   --normal
