--#FOREING KEYS DESTA TABELA
set pages 1000 lines 169 long 10000
col owner format a30
col r_owner format a30
col TABLE_NAME format a30
col constraint_name format a30
col r_constraint_name format a30
col tipo format a4
SELECT c.owner, c.table_name, c.constraint_type AS tipo, c.constraint_name, c.r_owner, c.r_constraint_name
FROM dba_constraints c
WHERE c.owner = 'OWNER'
  AND c.table_name IN ('TABELA')
  --and c.constraint_type = 'R'
  --and c.constraint_name = 'FK3E7E1CE83956BEB'
ORDER BY 1,2,3;


--#FOREING KEYS DE OUTRA TABELA PARA ESTA
set pages 1000 lines 169 long 10000
col owner format a25
col tabela format a45
col pk_constraint format a30
col fk_constraint format a30
SELECT d.owner, b.table_name AS tabela, d.constraint_name AS pk_constraint, b.constraint_name AS fk_constraint
FROM dba_constraints d,
(SELECT c.constraint_name, c.r_constraint_name, c.table_name
 FROM dba_constraints c
 WHERE NOT c.table_name IN ('TABELA')
   AND c.constraint_type = 'R') b
WHERE d.constraint_name = b.r_constraint_name
  AND d.owner = 'OWNER'
  AND d.table_name IN ('TABELA')
ORDER BY d.owner, d.table_name;


--# encontrar as tabelas/indices da tabela
set pages 1000
set lines 190
select a.table_name, a.column_name, a.constraint_name, c.owner, c.r_owner, c_pk.table_name as r_table_name, c_pk.constraint_name r_pk, cc_pk.column_name as r_column_name
from all_cons_columns a
 join all_constraints c
  on (a.owner = c.owner and a.constraint_name = c.constraint_name)
 join all_constraints c_pk
  on (c.r_owner = c_pk.owner and c.r_constraint_name = c_pk.constraint_name)
 join all_cons_columns cc_pk
  on (cc_pk.constraint_name = c_pk.constraint_name and cc_pk.owner = c_pk.owner)
where a.owner = 'owner'
and a.table_name in ('tabela');
