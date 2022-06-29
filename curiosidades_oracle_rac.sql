'-----------------------------
--# Conhecendo o Oracle RAC
-----------------------------'

# Processos

-> ACMS: Arquivo de controle atomico para memoria
-> GTX [0-J]: processo global transaction
-> LMON: monitor de serviço de enfileiramento global
-> LMB: Deamon de serviço de enfileiramento global
-> LCK0: Processo instance enqueue backgroup
-> MLHB: Monitor de heartbeat do serviço de enfileiramento/cache global
-> PING: Processo de interconnect latency measurement
-> RCBG: Result cache backgroud
-> RMSn: Oracle RAC management
-> RSMN: Remote slave monitor


--# Verificar definições do cluster
srvctl config database -db orcl


--------
--# VIP
--------
O vip não é atrelado a nenhuma placa de rede, ele é um ip que ta definido no dns e no etc/hosts.


---------------
--# Redo log
---------------

Cada node tem seus redo logd especificos.
O que diferencia são as thread

----------
--# Undo
----------

Cada instancia tem sua tablespace de UNDO

Example: alter system set undo_tablespace=undotbs2 SID='RAC01';

As duas tablespaces de undo, precisam se enchergar



-------------------------
--# srvctl: start & stop
-------------------------

- Várias instâncias podem iniciar simultaneamente
- Shutdown em uma instância não afeta a outra
- Shutdown transactional local não espera outras instâncias finalizarem suas tarefas
- Instâncias RAC, podem ser iniciadas e paradas com:
- Enterprise Manager
- Server Control Utility (srvctl)
- SQL*Plus
- Shutdown em um banco significa baixar todas as instâncias ao mesmo tempo


srvctl start | stop instance -d db_name -i inst_name_list
[ - open|mount|nomount|normal|transactional|immediate|abort]

srvctl start | stop database -d db_name
[ - open|mount|nomount|normal|transactional|immediate|abort]


srvctl start instance -d RACDB -i RACDB1, RACDB2

srvctl stop instance -d RACDB -i RACDB1, RACDB2

srvctl start database -d RACDB -o open


