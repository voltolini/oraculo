--# FUNCOES ORACLE RTRIM

'----------------------------------------------------
--# RTRIM = RIGTH VAI CORTAR TUDO QUE VEM DA DIREITA
----------------------------------------------------'

--# OBS: PODEM RECEBER ATÉ 2 CARACTERES DE PARAMETRO (RTRIM E LTRIM)

1º A VARIAVEL DEVE SER DO TIPO CHAR
2º A VARIAVEL DEVE SER DO TIPO CHAR NÃO É OBRIGATÓRIO


-----------------------------------------------------
--# EXEMPLO TIRANDO ESPAÇO EM BRANCO:
-----------------------------------------------------

SELECT RTRIM (' APRENDA PL/SQL ') FROM DUAL;

RESULTADO: ' APRENDA PL/SQL'

'OBS:' QUANDO NÃO SETADO O ORACLE ENTENDE QUE TA RETIRANDO O ESPAÇO EM BRANCO
'OBS:' NÃO SERVE SOMENTE PARA RETIRAR ESPAÇO EM BRANCO.. TAMBEM TIRA CARACTERES



-----------------------------------------------------
--# EXEMPLO TIRANDO CARACTERES:
-----------------------------------------------------

SELECT RTRIM('APRENDA PL/SQL', 'PL/SQL') FROM DUAL


RESULTADO: 'APRENDA'


-----------------------------------------------------
--# ELE IRÁ RETIRAR MESMO SE ESTIVER FORA DE ORDEM
-----------------------------------------------------

SELECT RTRIM('APRENDA ORACLE_PL/SQL', 'SQL_ORACLE_PL') FROM DUAL;


RESULTADO: 'APRENDA'




'----------------------------------------------------
--# LTRIM = LEFT VAI CORTAR TUDO QUE VEM DA ESQUERDA
----------------------------------------------------'




-----------------------------------------------------
--# EXEMPLO TIRANDO ESPAÇO EM BRANCO:
-----------------------------------------------------

SELECT LTRIM ('      APRENDA PL/SQL ') FROM DUAL;

RESULTADO: 'APRENDA PL/SQL '

'OBS:' QUANDO NÃO SETADO O ORACLE ENTENDE QUE TA RETIRANDO O ESPAÇO EM BRANCO
'OBS:' NÃO SERVE SOMENTE PARA RETIRAR ESPAÇO EM BRANCO.. TAMBEM TIRA CARACTERES



-----------------------------------------------------
--# ELE IRÁ RETIRAR MESMO SE ESTIVER FORA DE ORDEM
-----------------------------------------------------

SELECT LTRIM('APRENDA ORACLE_PL/SQL', 'APRENDA') FROM DUAL;


RESULTADO: 'ORACLE_PL/SQL'




'----------------------------------------------------
--# TRIM = VAI CORTAR TUDO
----------------------------------------------------'


SELECT TRIM ('    APRENDA PL/SQL   ') FROM DUAL;


RESULTADO: 'APRENDA PL/SQL'



--# RETIRE 'BRANCO' DE ...
SELECT TRIM (' ' from '    APRENDA PL/SQL  ') FROM DUAL;

RESULTADO: 'APRENDA PL/SQL'





--# TIRA DA ESQUERDA PARA DIREITA
select trim (leading '0' from '0001230') FROM dual;


--# TIRA DA DIREITA PARA ESQUERDA
select trim (trailling 'x' from 'Aprendax') FROM dual;


--# RETIRA DE TODOS OS CARACTERES

select trim (both 'x' from 'xxxAprendaxxx') FROM DUAL;

