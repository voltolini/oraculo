------------------------
--# Funcao FLOOR Oracle
------------------------

-> Essa função vai transformar o tipo number em um tipo inteiro, convertendo ele para o menor inteiro mais proximo do valor especificado.


'------------
--# Exemplo:
------------'

--# ARREDONDAR PARA 10
SELECT FLOOR (TO_NUMBER('10.2')) AS FLOOR FROM DUAL;


--# ARREDONDAR PARA -5
SELECT FLOOR (TO_NUMBER(-4.7)) AS FLOOR FROM DUAL;

