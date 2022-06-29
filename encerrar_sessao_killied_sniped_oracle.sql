-------------------------------------
--# Encerrar sessões killed/sniped
-------------------------------------


local script: /home/oracle/suporte/sniped.sh


--------
# script
--------


#!/bin/sh
. /etc/parametros_oracle
tmpfile=/tmp/tmp.$$
$ORACLE_HOME/bin/sqlplus -S /nolog > /dev/null 2>&1 <<EOF
conn / as sysdba
set head off ver off feed off
spool $tmpfile
select p.spid
from v\$process p, v\$session s
where s.paddr = p.addr
  --and s.username is not null
  --and s.type = 'USER'
  and s.status = 'SNIPED';
spool off
EOF
for x in `cat $tmpfile | grep "^[0123456789]"`
do
kill -9 $x
done
rm $tmpfile



------------
--# killed
------------


local script: /home/oracle/suporte/killed.sh:

#!/bin/sh
. /etc/parametros_oracle
tmpfile=/tmp/tmp.$$
$ORACLE_HOME/bin/sqlplus -S /nolog > /dev/null 2>&1 <<EOF
conn / as sysdba
set head off ver off feed off
spool $tmpfile
select p.spid
from v\$process p, v\$session s
where s.paddr = p.addr
  --and s.username is not null
  --and s.type = 'USER'
  and s.status = 'KILLED';
spool off
EOF
for x in `cat $tmpfile | grep "^[0123456789]"`
do
kill -9 $x
done
rm $tmpfile



# Agendamento crontab
*/15 * * * * root su - oracle -c /home/oracle/suporte/killed.sh
