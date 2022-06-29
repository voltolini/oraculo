podemos tirar o  +tam.expansivel



--# VISUALIZAR TABLESPACES - LIVRE USADO ALOCADO THRESHOLDS SEM MONITORAMENTO
----------------------------------------------------------------------------------------
SET LINES 190 PAGES 1000 LONG 100000 FEED 1 ECHO ON TI ON TIMI ON TRIM ON TERM ON SERVEROUT ON VER ON TAB OFF DESC LINENUM ON
COL TABLESPACE  FOR A30
COL CONTEUDO    FOR A10
COL BLK         FOR A3
COL BIGFILE     FOR A3
COL FORCE_LOG   FOR A5
COL STATUS      FOR A9
COL LIVRE_MB    FOR 9,999,990
COL USADO_MB    FOR 9,999,990
COL ALOCADO_MB  FOR 9,999,990
COL EXPAND_MB   FOR 9,999,990
COL LIVRE_PCT   FOR 9990.00  HEA "LIVRE_%"
COL USADO_PCT   FOR 9990.00  HEA "USADO_%"
COL ALERTA      FOR 9990.00
COL CRITICO     FOR 9990.00
COL AL_LIVRE    FOR 9990.00  HEA "AL_LIVRE_%"
select dts.tablespace_name as TABLESPACE
    , dts.contents as CONTEUDO, dts.block_size / 1024 || 'k' as BLK
    , dts.bigfile as BIG
    , dts.force_logging as FORCE_LOG
    , dts.status
    ,round(decode(nvl2(cresc.tablespace, 0, sign(tam.expansivel))
        , 1, (tam.livre + tam.expansivel), tam.livre), 2) as LIVRE_MB
    , round(tam.usado, 2) as USADO_MB
    , round(tam.alocado, 2) as ALOCADO_MB
    , nvl2(cresc.limite, -1, round(tam.expansivel, 2)) as EXPAND_MB
    , 100 - round(decode(nvl2(cresc.tablespace, 0, sign(tam.expansivel))
        , 1, tam.usado / (tam.total + tam.expansivel), (tam.usado / tam.total)) * 100, 2) as LIVRE_PCT
    , round(decode(nvl2(cresc.tablespace, 0, sign(tam.expansivel))
        , 1, tam.usado / (tam.total + tam.expansivel), (tam.usado / tam.total)) * 100, 2) as USADO_PCT
 from  dba_tablespaces DTS
      , (select ddf.tablespace_name as TABLESPACE
            , sum(nvl(ddf.user_bytes,0)) / 1024 / 1024 as ALOCADO
            , (sum(ddf.bytes) - sum(nvl(dfs.bytes, 0))) / 1024 / 1024 as USADO
            , sum(nvl(dfs.bytes,0)) / 1024 / 1024 as LIVRE
            , sum(decode(ddf.autoextensible, 'YES', decode(sign(ddf.maxbytes - ddf.bytes)
                , 1, ddf.maxbytes - ddf.bytes, 0), 0)) / 1024 / 1024 as EXPANSIVEL
            , sum(ddf.bytes) / 1024 / 1024 as TOTAL
        from  dba_data_files DDF
            , (select f.tablespace_name, f.file_id, sum(f.bytes) as BYTES
               from  dba_free_space F
               group by f.tablespace_name, f.file_id) DFS
        where ddf.tablespace_name = dfs.tablespace_name(+)
          and ddf.file_id = dfs.file_id(+)
        group by ddf.tablespace_name
        union
        select dtf.tablespace_name as TABLESPACE
            , sum(nvl(dtf.user_bytes,0)) / 1024 / 1024 as ALOCADO
            , sum(vtmp.bytes_used) / 1024 / 1024 as USADO
            , sum(vtmp.bytes_free) / 1024 / 1024 as LIVRE
            , sum(decode(dtf.autoextensible, 'YES', decode(sign(dtf.maxbytes - dtf.bytes)
                , 1, dtf.maxbytes - dtf.bytes, 0), 0)) / 1024 / 1024 as EXPANSIVEL
            , sum(dtf.bytes) / 1024 / 1024 as TOTAL
        from  dba_temp_files DTF, v$temp_space_header VTMP
        where dtf.tablespace_name = vtmp.tablespace_name
          and dtf.file_id = vtmp.file_id
        group by dtf.tablespace_name) TAM  -- tamanho
      , (select ddf.tablespace_name as TABLESPACE, 'ILIMITADO' as LIMITE
        from  dba_data_files DDF
        where ddf.maxbytes / 1024 / 1024 / 1024 > 32
          and ddf.autoextensible = 'YES'
        group by ddf.tablespace_name
        union
        select dtf.tablespace_name as TABLESPACE, 'ILIMITADO' as LIMITE
        from  dba_temp_files DTF
        where dtf.maxbytes / 1024 / 1024 / 1024 > 32
          and dtf.autoextensible = 'YES'
        group by dtf.tablespace_name) CRESC  -- crescimento
where cresc.tablespace(+) = dts.tablespace_name
  and tam.tablespace(+) = dts.tablespace_name;
--and dts.tablespace_name in ('TEMP','SAPIENS_DATA','SAPIENS_INDEX');
--  and dts.contents in ('PERMANENT')--, 'UNDO', 'TEMPORARY')
--  and nvl((select alerta  from luzadm.luz_tablespaces where upper(nome) = upper(dts.tablespace_name))
--        , (select alerta  from luzadm.luz_tablespaces where upper(nome) = 'LUZ_TBLDEF')) -
--      round(decode(nvl2(cresc.tablespace,0,sign(tam.expansivel))
--        , 1, tam.usado / (tam.total + tam.expansivel), (tam.usado / tam.total)) * 100, 2) < 5  -- < 5% livre
