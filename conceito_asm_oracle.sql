----------------
--# Oracle ASM
----------------


***************************
-> Arquitetura e Internals
***************************

É denominado Oracle Database, todos os arquivos necessários para o funcionamento do banco de dados, exceto binário de instalação,
são os arquivos abaixo:

-> Datafiles
-> Controlfiles
-> Redo Log File
-> Archive
-> Parameter File (spfile e/ou pfile)



Os arquivos que compoem o Oracle Database são armazenados no ASM como ASM File, ou seja, qualquer arquivo que compoe o Database Oracle
é transformado em ASM File.

ASM File pertence a um ASM Disk Group que é uma coleção de discos oriundos do S.O, onde é considerado pelo ASM uma unidade de armazenamento.


->> ASM Disk Group é composto por 1 ou mais discos oriundos do S.O, o intuito da estrutura é permitir o funcionamento do mecanismo de
'Stripe e Mirror', nas documentações é citado como método 'SAME'.


--# Conclusões até o momento:

-> Oracle ASM Extents são pedaçoes uniformes que formam um ASM File, ele (ASM Extents) está espalhado sobre todos os ASM Disk que fazem parte
de um ASM Disk Group.

-> A existência do ASM Extents que permite o mecanismo de 'Stripe e Mirror'.



'---------------------
--# Stripe and Mirror
----------------------'

O Diskgroup (DG) é a unidade de armazenamento do ASM. No momento da criação do ambiente ASM é mandatório o realizar a escolha
de um tipo de redundancia (Redundancy), que pode ser: EXTERNAL, NORMAL, HIGH.

Essas opções controlam a quantidade de "cópias" que os ASM Files terão distribuídos pelos discos.


Uma outra entidade é o Virtual Extent, que são "cópias fieis" de um Physical Extend, ou seja, um espelho e por isso é chamado de Mirror.

A existência do Virtual extent permite que o ASM file seja capaz de se reconstruir em caso de perda de um dos Physical Extend.


--# Importante:


-> External

Se o tipo de redundância for EXTERNAL, o ASM não fará o "Mirror" do Physical extent (pois acredita que exista redundância a nível de hardware),
e por isso a perda de um disco neste tipo de redundância, não é tão fatal


-> Normal

Neste tipo de redundância 1 cópia do file extent original(Physical extent) é mantida no Failure Group oposto ao que ospeda o file extent espelho
(Virtual extent). Esse tipo de redundância é para a implementação de RAC estendido (Oracle RAC on Extended Distance Clusters)



-> High

Nessa redundância 2 cópias do file extent original (Physical extent) é mantida em 3 Failure Group, 1 para o file extent original,
1 para o file extent mirror primário e 1 para o mirror secundário.








----------------------------------
--# Automatic Storage Management.
----------------------------------

O ASM é um software que gerencia os discos que serão utilizados pelo banco de dados Oracle.

Instalações básicas não fazem uso do ASM, pois é um recurso a mais que precisa ser instalado, configurado e administrado.

Pera instala-lo é necessário fazer download das mídias do Grid Infrastructure (GI) que contém os componentes do ASM e dos Clusterware.
Depois de instalar o GI e ter o ASM operando podemos instalar o sofware do banco.



O ASM é um volume manager (gerenciador de volumes) e também um filesystem (sistema de arquivos) para os arquivos do banco de dados Oracle.

Suporta Single-instance e RAC.


O Oracle ASM é a solução de gerenciamento de armazenamento recomendada pela Oracle que fornece uma solução alternativa aos volume managers,
filesystems e raw devices convencionais.


# É utilizado diskgroups para armazenar os datafiles, um diskgroup é uma coleção de discos que o ASM gerencia como uma única unidade;

'
No diskgroup é exposta uma interface de filesystem para arquivos do banco de dados, o conteúdo dos arquivos são armazenados em um diskgroup,
são distribuídos uniformemente para eliminar hos-spots e fornecer um desempenho uniforme entre todos os discos'



