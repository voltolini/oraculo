-----------------------------------------------------------------
--# Oracle ACFS (automatic storage management cluster filesystem)
-----------------------------------------------------------------

Foi introduzido na segunda release do Oracle 11g em 2009 e inicialmente não havia custo de licenciamento, assim como os demais
componentes do produto Grid Infrastructure. Na versão 11.2.0.2 passou a se chamar CloudFS e junto a isso veio a ter um custo de
licenciamento.

Nas versões mais recentes do Oracle Database Appliance o CloudFS (ACFS) passou a ser o sistema de arquivos padrão.

O ACFS amplia as capacidades de uso do ASM e passa a oferecer um sistema de arquivos multi-plataforma e escalável com a finalidade
de armazenar qualquer tipo de arquivo.


Para o funcionamento do ACFS é necessário configurar o ADVM (ASM Dinamyc Volume Manager) que é responsável por entregar e
gerenciar os volumes. Este volumes podem ser parte de um cluster e também podem ser formatados em outros sistemas de arquivos,
além do ACFS como EXT4, EXT3, etc.


# Passo a passo para ter um ACFS

 -> Instalar o Grid Infrastructure;
 -> Configurar o ASM;
 -> Criar os diskgroups;
 -> Criar os volumes do ADVM;
 -> Formatar os volumes como ACFS;
 -> Criar os diretórios que serão usados pelos filesystems;
 -> Montar os filesystems.


Inicialmente tem-se um novo disco adicionado aos servidores linux sr1 e sr2 (a operação deve ser realizada a partir a partir de um dos nós somente)


--# Criar partição
fsdik /dev/sdf

Device contains neither a valid DOS partition  table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk  identifier 0x7f9518b1.
Changes will remain in memory only, until you  decide to write them.
After that, of course, the previous content  won't be recoverable.
Warning: invalid flag 0x0000 of partition  table 4 will be corrected by w(rite)
WARNING: DOS-compatible mode is deprecated.  It's strongly recommended to
switch off the mode (command 'c') and change display units to
sectors (command 'u').
Command (m for help): n
Command action
e   extended
p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-130, default 1):
Using default value 1
Last cylinder, +cylinders or +size{K,M,G}  (1-130, default 130):
Using default value 130
Command (m for help): w
The partition table has been altered!
Calling ioctl() to re-read partition table.
Syncing disks.


--# Verificar se a partiçaõ foi criada
fdisk -l /dev/sdf

Disk /dev/sdf: 1073 MB, 1073741824 bytes
255 heads, 63 sectors/track, 130 cylinders
Units = cylinders of 16065 * 512 = 8225280  bytes
Sector size (logical/physical): 512 bytes /  512 bytes
I/O size (minimum/optimal): 512 bytes / 512  bytes
Disk identifier: 0x7f9518b1

Device Boot      Start         End      Blocks    Id  System
/dev/sdf1            1         130      1044193+  83  Linux


--# Criar o disco no ASM com o nome de ADVMVOL1:
oracleasm createdisk ADVMVOL1 /dev/sdf1
Writing disk header: done
Instantiating disk: done


--# Listar os discos
oracleasm listdisk


--# Trocar para o usuario oracle para acessar o ASM
[root@srv1 ~]# su -  oracle
[oracle@srv1 ~]$ .  oraenv
ORACLE_SID = [oracle] ? +ASM1
The Oracle base has been set to  /u01/app/oracle


--# Acessar a instancia do ASM
sqlplus / as sysasm
SQL*Plus: Release 12.1.0.2.0 Production on  Sat Oct 15 16:10:04 2016
Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Connected to:
Oracle Database 12c Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Real Application Clusters and Automatic Storage Management options
SQL>


--# Listar os discos para criar o diskgroup
SET LINES 237 PAGES 1000 LONG 100000 TERM ON TRIM ON TI ON SERVEROUT ON FEED 1 ECHO ON TAB OFF VER ON DESC LINENUM ON
COL NAME      FOR A15
COL LABEL     FOR A15
COL PATH      FOR A15
COL FREE_MB   FOR 9,999,990
COL USED_MB   FOR 9,999,990
COL TOTAL_MB  FOR 9,999,990
select ad.group_number as GROUP#, ad.disk_number as DISK#, ad.name, ad.label, ad.path, ad.header_status
    , ad.mode_status as STATUS, ad.state, ad.free_mb, ad.total_mb-ad.free_mb as USED_MB, ad.total_mb
from  v$asm_disk AD
order by group#, disk#, ad.name ;


--# Criar o diskgroup (chamando ele de ADVM)
create diskgroup ADVM external redundancy disk '/dev/oracleasm/disk/ADVMVOL1' attribute 'au_size''=''1M';



--# Criar um volume utilizando o ASMCMD, para criar o volume temos que mudar os atributos do diskgroup
SQL> exit
Disconnected from Oracle Database 12c  Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Real Application Clusters and Automatic  Storage Management options

[oracle@srv1 ~]$ asmcmd -p
ASMCMD [+] > volcreate -G ADVM -s 500M  ADVMVOL1
ORA-15032: not all alterations performed
ORA-15221: ASM operation requires  compatible.asm of 11.2.0.0.0 or higher (DBD ERROR: OCIStmtExecute)


# voltar ao SQL*Plus e alterar alguns atributos do nosso diskgroup para podermos utilizar o ADVM.
# O Oracle por padrão volta a compatibilidade para uma versão anterior, no nosso caso como queremos ter todos os novos recursos do 12c vamos definir tudo para 12.1.0.2

ASMCMD [+] > exit  [oracle@srv1 ~]$ sqlplus / as sysasm

SQL*Plus: Release 12.1.0.2.0 Production on  Sat Oct 15 16:47:29 2016
Copyright (c) 1982, 2014, Oracle.  All rights reserved.

Connected to:  Oracle Database 12c Enterprise Edition Release  12.1.0.2.0 - 64bit Production  With the Real Application Clusters and  Automatic Storage Management options

SQL> alter diskgroup ADVM set attribute  'compatible.asm'='12.1.0.2';
Diskgroup altered.

SQL> alter diskgroup ADVM set attribute  'compatible.advm'='12.1.0.2';
Diskgroup altered.

SQL> alter diskgroup ADVM set attribute  'compatible.rdbms'='12.1.0.2';
Diskgroup altered.

# Agora sim vamos criar nosso volume:

SQL> exit
Disconnected from Oracle Database 12c  Enterprise Edition Release 12.1.0.2.0 - 64bit Production
 With the Real Application Clusters and  Automatic Storage Management options

 [oracle@srv1 ~]$ asmcmd -p
 ASMCMD [+] > volcreate -G ADVM -s 500M  ADVMVOL1


--# Ver os volumes criados no diskgroup ADVM
ASMCMD [+] > volinfo -G ADVM -a

Diskgroup Name: ADVM
Volume Name: ADVMVOL1
Volume Device: /dev/asm/advmvol1-301
State: ENABLED
Size (MB): 512
Resize Unit (MB): 64
Redundancy: UNPROT
Stripe Columns: 8
Stripe Width (K): 1024
Usage:
Mountpath:


# Voltar ao SQL*Plus para mostrar que por ele também é possível criar volumes

ASMCMD [+] > exit  [oracle@srv1 ~]$ sqlplus / as sysasm
SQL*Plus: Release 12.1.0.2.0 Production on  Sat Oct 15 17:09:34 2016
Copyright (c) 1982, 2014, Oracle. All rights reserved.

Connected to:
 Oracle Database 12c Enterprise Edition  Release 12.1.0.2.0 - 64bit Production
 With the Real Application Clusters and  Automatic Storage Management options

SQL> alter diskgroup ADVM add volume ADVMVOL2  size 100M;
Diskgroup altered.


# SQL*Plus também conseguimos consultar informações dos nossos volumes na view V$ASM_VOLUME

SQL>select group_number, volume_number,  size_mb, usage, state from v$asm_volume;

GROUP_NUMBER VOLUME_NUMBER SIZE_MB    USAGE                      STATE
------------ ------------- ---------- -------------------------- --------
3            1             512                                   REMOTE
3            2             128                                   REMOTE


# Agora pelo sistema operacional vamos conseguir visualizar os volumes criados

SQL> exit
Disconnected from Oracle Database 12c  Enterprise Edition Release 12.1.0.2.0 - 64bit Production
With the Real Application Clusters and  Automatic Storage Management options

[oracle@srv1 ~]$ ls -lh /dev/asm/
total 0
brwxrwx--- 1 root oinstall 251, 154113 Oct 15  16:59 advmvol1-301
brwxrwx--- 1 root oinstall 251, 154114 Oct 15  17:35 advmvol2-301


--# Formatar os volumes
[oracle@srv1 ~]$ su -

Password:

[root@srv1 ~]# mkfs  -t acfs /dev/asm/advmvol1-301
mkfs.acfs: version                   = 12.1.0.2.0
mkfs.acfs: on-disk version           = 39.0
mkfs.acfs: volume                    = /dev/asm/advmvol1-301
mkfs.acfs: volume size               = 536870912  ( 512.00 MB )
mkfs.acfs: Format  complete.


--# O outro volume foi formatado com ext4

[root@srv1 ~]# mkfs -t ext4  /dev/asm/advmvol2-301
mke2fs 1.41.12 (17-May-2010)

Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=0 blocks, Stripe width=0 blocks
32768 inodes, 131072 blocks
6553 blocks (5.00%) reserved for the super  user
First data block=1
Maximum filesystem blocks=67371008
16 block groups
8192 blocks per group, 8192 fragments per  group
2048 inodes per group
Superblock backups stored on blocks:
8193,  24577, 40961, 57345, 73729
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting  information: done
This filesystem will be automatically checked  every 23 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.


--# montar esses filesystems em algum diretorio

[root@srv1 ~]# mkdir -p /mnt/advm/fs1

[root@srv1 ~]# mount -t acfs  /dev/asm/advmvol1-301 /mnt/advm/fs1/

[root@srv1 ~]# mkdir -p /mnt/advm/fs2

[root@srv1 ~]# mount -t acfs  /dev/asm/advmvol2-301 /mnt/advm/fs2/
mount.acfs: ACFS-00591: error found in volume  disk header
mount.acfs: ACFS-02037: File system not  created on a Linux system. Cannot  mount.



# tentei montar o advmvol2 não foi possível, pois este está formatado para EXT4 e tentei montá-lo como ACFS. Vou montá-lo agora como EXT4

[root@srv1 ~]# mount  -t ext4 /dev/asm/advmvol2-301 /mnt/advm/fs2/


# Listar os pontos de montagem

[root@srv1 ~]# df -hP

Filesystem                     Size  Used Avail Use% Mounted on
/dev/mapper/vg_srv1-lv_root     50G   21G    27G  44% /
tmpfs                          2.0G  1.2G   759M  62% /dev/shm
/dev/sda1                      485M   78M   382M  17% /boot
/dev/mapper/vg_srv1-lv_home     45G  199M    43G   1% /home
/dev/asm/advmvol1-301          512M   40M   473M   8% /mnt/advm/fs1
/dev/asm/advmvol2-301          124M  5.6M   113M   5% /mnt/advm/fs2


# E como será que ficou no servidor srv2? Vamos conferir
[oracle@srv2 ~]$ df  -h
Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/vg_srv1-lv_root   50G   22G    26G  46% /
tmpfs                        2.0G  1.3G   743M  63% /dev/shm
/dev/sda1                    485M   78M   382M  17% /boot
/dev/mapper/vg_srv1-lv_home  45G  181M   43G    1% /home



# Não há nenhum dos volumes montados. Vamos criar os diretórios e montá-los
[oracle@srv2 ~]$ su -
Password:
[root@srv2 ~]# mkdir  -p /mnt/advm/fs1
[root@srv2 ~]# mkdir -p /mnt/advm/fs2
[root@srv2 ~]# mount -t acfs  /dev/asm/advmvol1-301 /mnt/advm/fs1/
[root@srv2 ~]# mount -t ext4 /dev/asm/advmvol2-301  /mnt/advm/fs2/
[root@srv2 ~]# df -h
Filesystem                    Size  Used Avail Use% Mounted on
/dev/mapper/vg_srv1-lv_root    50G   22G    26G  46%  /
tmpfs                         2.0G  1.3G   743M  63%  /dev/shm
/dev/sda1                     485M   78M   382M  17%  /boot
/dev/mapper/vg_srv1-lv_home    45G  181M    43G   1%  /home
/dev/asm/advmvol1-301          512M   78M   435M  16% /mnt/advm/fs1
/dev/asm/advmvol2-301          124M  5.6M   113M   5% /mnt/advm/fs2




# Vamos fazer um teste gerando um arquivo no servidor srv1

[root@srv1 ~]# touch /mnt/advm/fs1/teste_advm

[root@srv1 ~]# ls -lh /mnt/advm/fs1/
total 64K
drwx------ 2 root root 64K Oct 15 18:09  lost+found
-rw-r--r-- 1 root root   0 Oct 15 18:13 teste_advm



# Como o /mnt/advm/fs1 é um filesystem ACFS esse diretório está no cluster e o arquivo criado deve também estar visível a partir do srv2

[root@srv2 ~]# ls -lh /mnt/advm/fs1
total 64K
drwx------ 2 root root 64K Oct 15 18:09  lost+found
-rw-r--r-- 1 root root   0 Oct 15 18:13 teste_advm
