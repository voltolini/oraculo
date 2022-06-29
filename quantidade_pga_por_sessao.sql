--#QUANTIDADE DE PGA UTILIZADA POR SESSÃO
SET PAGES 1000 LINES 169 LONG 10000
COL username FOR A30
COL osuser FOR A20
COL spid FOR A10
COL service_name FOR A15
COL module FOR A45
COL machine FOR A30
COL logon_time FOR A20
COL pga_used_mem_mb FOR 99990.00
COL pga_alloc_mem_mb FOR 99990.00
COL pga_freeable_mem_mb FOR 99990.00
COL pga_max_mem_mb FOR 99990.00
SELECT NVL(s.username, '') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       p.spid,
       ROUND(p.pga_used_mem/1024/1024,2) AS pga_used_mem_mb,
       ROUND(p.pga_alloc_mem/1024/1024,2) AS pga_alloc_mem_mb,
       ROUND(p.pga_freeable_mem/1024/1024,2) AS pga_freeable_mem_mb,
       ROUND(p.pga_max_mem/1024/1024,2) AS pga_max_mem_mb,
       s.lockwait,
       s.status,
       s.service_name,
       s.module,
       s.machine,
       s.program,
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
       s.last_call_et AS last_call_et_secs
FROM   v$session s,
       v$process p
WHERE  s.paddr = p.addr
ORDER BY s.username, s.osuser;
