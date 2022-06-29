------------------------------------------------------------------------
-- DOCUMENTO DESTINADO PARA INFORMAÇÕES REF. A PARAMETROS DO ORACLE --
------------------------------------------------------------------------


--# VER PARAMETROS DA BASE
DATABASE_PROPERTIES - lists permanent database properties.
COL PROPERTY_VALUE FOR A40
COL DESCRIPTION    FOR A100
select * from database_properties order by 1 ;



-------------------------------------------------------
--# VER PARAMETROS DO NLS (LINGUAGEM/TERRITORIO/DATA)
-------------------------------------------------------

SELECT * FROM NLS_DATABASE_PARAMETERS;


OBS: FORMATO DE DATA DEFAULT ORACLE É MES/DIA/ANO


-----------------------------------------------------
--# CARACTER SET DEFAULT INSTALATION ORACLE FLUIDATA
-----------------------------------------------------

CHARACTER SET = WE8MSWIN1252


-------------------------------------------------------------------------------------------------------------------
--# VERIFICAR O IDIOMA E TERRITORIO QUE ESTÁ CONFIGURADO NO SERVIDOR QUE IRÁ SER FEITO O BACKUP PARA IMPORTAÇÃO
-------------------------------------------------------------------------------------------------------------------

SELECT * FROM NLS_DATABASE_PARAMETERS;


IDIOMA PADRÃO: INGLÊS (ENGLISH)
TERRITORIO: ESTADOS UNIDOS (UNITED STATES)


--# VER CHARACTER SET DO BANCO
COL DATABASE  FOR A10
COL VALUE     FOR A20
select upper(SYS_CONTEXT('USERENV', 'DB_NAME')) as DATABASE, P.value from nls_database_parameters P where P.parameter = 'NLS_CHARACTERSET';
