----------------------------------------------------------------
--# Oracle 12c aceitar conexoes de clients antigos (9i,10g,11g)
----------------------------------------------------------------


Adicionar no sqlnet.ora do $ORACLE_HOME/network/admin/

SQLNET.ALLOWED_LOGON_VERSION_CLIENT=10


SQLNET.ALLOWED_LOGON_VERSION_SERVER=11
SQLNET.ALLOWED_LOGON_VERSION_CLIENT=11
