# Grid Infrastructure installation and upgrade guide for Linux


'----------------------
--# Preparação ambiente
----------------------'

--# Executar o pré install 19c


--# Verificar usuário
id oracle


--# Grupo pro ASM admin por conta da separação de papel
groupadd -g 54331 asmadmin
groupadd -g 54332 asmdba
groupadd -g 54333 asmoper


--# Criar o usuário grid
useradd --home /home/grid -g oinstall -G oinstall,asmadmin,asmdba,asmoper -c 'Grid Owner' grid


--# Verificar se foi criado
id grid


mkdir -p /u01/app/grid


chown grid.oinstall /u02/app/grid


# raiz
mkdir -p /u01/app/19.0.0/grid
