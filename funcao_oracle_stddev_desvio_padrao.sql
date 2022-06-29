----------------------------
--# Funções ORACLE STDDEV
----------------------------


-> Essa função é útil para verificação de dados, parte + analítica, essa função calcula o desvio padrão


   -> Desvio padrão indica o quanto um conjunto de dados é uniforme. Quanto mais próximo de 0 for o desvio padrão, mais homogêneo são os dados.


Trabalha sobre parâmetros.


Vai calcular o desvio padrão baseado nos parâmetros que estou passando.



----------------
--# Exemplo 1:
----------------

Calcular o devio padrão dos salarios levando em consideração as datas do departamento 60.


SELECT DEPARTMENT_ID AS DPTO,
HIRE_DATE,
LAST_NAME,
SALARY,
STDDEV(salary) OVER (ORDER BY hire_date) AS STDDEV
FROM hr_employees
WHERE department_id IN (60);




---------------
--# Exemplo 2:
---------------

Calcular o desvio padrão dos salarios, em consideração a data e o salario e particionando por departamento.


SELECT DEPARTMENT_ID AS DPTO,
HIRE_DATE,
LAST_NAME,
SALARY,
STDDEV(salary)
OVER (PARTITION BY DEPARTMENT_ID ORDER BY HIRE_DATE) AS STDDEV
FROM HR.EMPLOYEES
WHERE DEPARTMENT_ID IN (60,30,40);
