--#HABILITAR RECYCLE BIN
ALTER SESSION SET recyclebin = ON; --#para a sessao
ALTER SYSTEM SET recyclebin = ON;  --#para o banco todo


--#DESABILITAR RECYCLE BIN
ALTER SESSION SET recyclebin = OFF; --#sessao
ALTER SYSTEM SET recyclebin = OFF;  --banco

--# DESATIVAR NA PROXIMA INICIALIZAÇÃO
alter system set recyclebin = off deferred scope = both ;


--# LIMPAR A LIXEIRA
purge dba_recyclebin ;
