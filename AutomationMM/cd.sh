#!/bin/sh
# redirect stdout/stderr to a file
exec &> logfile.log

#variables
KEY_ACCESS=/home/centos/cluster_test_biba.pem
SQL_HOST=localhost
SQL_USUARIO=root
SQL_PASSWORD=1234567
FILEHOST=/etc/hosts
FILESYS=/etc/sysctl.conf
FILESELI=/etc/selinux/config
FILERC=/etc/rc.local
FILECLO=/etc/yum.repos.d/cloudera-manager.repo
FILEJAVA=/home/centos/mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar
FILEFSYSTEM=/home/centos/filesystem.sh
# Instalar las actualizaciones del sistema
yum -y update
echo "Paquetes Actualizados"
#Instalar paquetes wget,ntp,nscd
yum -y install wget ntp nscd
echo "Instalación de paquetes wget ntp nscd"
#Habilita, inicia y verifica el estado de los paquetes instalados
systemctl enable ntpd nscd
echo "nscd habilitado"
systemctl start ntpd nscd
echo "nscd iniciado"

systemctl status ntpd nscd
echo "Estado  ntpd y nscd"

sleep 4

# Descarga de JDBC de MySQL

wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz

echo "JDBC bajado"
tar zxvf mysql-connector-java-5.1.42.tar.gz
echo "JDBC descomprimido"

#Configura demonios para iniciar con el SO 
chkconfig ntpd on
chkconfig nscd on
echo "demonios ntpd y nscd activados al inicio del sistema"
#Configura swap en 1
echo "vm.swappiness = 1" >> /etc/sysctl.conf
echo "vm.swappiness configurado"
#Inhabilita transparent_hugepage
echo "never" > /sys/kernel/mm/transparent_hugepage/defrag
echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
echo 'echo "never" > /sys/kernel/mm/transparent_hugepage/defrag' >> /etc/rc.local
echo "Transparent hugepage configurado"
#Instalacion de repo MariaDB 10.0
> /etc/yum.repos.d/MariaDB.repo
echo "Creación de  archivo  MariaDB"
echo "
# MariaDB 10.0 CentOS repository list - created 2017-08-04 03:32 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
" >> /etc/yum.repos.d/MariaDB.repo

echo "Configuración de repo MariaDB"

cat /etc/yum.repos.d/MariaDB.repo

sleep 4

#Instalación de cloudera-manager repo

> /etc/yum.repos.d/cloudera-manager.repo

echo "Creación de  archio cloudera manager"

echo "
[cloudera-manager]
# Packages for Cloudera Manager, Version 5, on RedHat or CentOS 7 x86_64
name=Cloudera Manager
baseurl=https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/5.11.1/
gpgkey =https://archive.cloudera.com/cm5/redhat/7/x86_64/cm/RPM-GPG-KEY-cloudera
gpgcheck = 1
" >> /etc/yum.repos.d/cloudera-manager.repo

echo "Configuración de repo Cloudera manager"

cat /etc/yum.repos.d/cloudera-manager.repo

sleep 4

#Configuracion de hosts

chmod 600  $KEY_ACCESS

echo "Cambio de permisos de usuario llave privada"


file="/home/centos/nodos.properties"

echo "Carga de nodos properties"

if [ -f "$file" ];

then
    echo "$file found"
. $file
else
    echo "$file not found"
fi

k=0
while [ $k -lt ${#hosts[@]} ];
do
    echo ${hosts[$k]} ${dns[$k]}  >> /etc/hosts

let k=k+1

done

echo "Archivo /etc/host listo"
 
k=2 

while [ $k -lt ${#hosts[@]} ];do
scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILEFSYSTEM" centos@${hosts[$k]}:/home/centos
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo chmod 766 /home/centos/filesystem.sh"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo chown root:root /home/centos/filesystem.sh"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo  bash /home/centos/filesystem.sh"



let k=k+1

done

k=1

while [ $k -lt ${#hosts[@]} ];do

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILEHOST" centos@${hosts[$k]}:/home/centos

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILESYS" centos@${hosts[$k]}:/home/centos

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILESELI" centos@${hosts[$k]}:/home/centos

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILERC" centos@${hosts[$k]}:/home/centos

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILECLO" centos@${hosts[$k]}:/home/centos

scp -oStrictHostKeyChecking=no -i "cluster_test_biba.pem" "$FILEJAVA" centos@${hosts[$k]}:/home/centos

ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo echo "never" > /sys/kernel/mm/transparent_hugepage/defrag | sudo echo "never" > /sys/kernel/mm/transparent_hugepage/enabled"

ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo cp /home/centos/hosts /etc | sudo cp /home/centos/sysctl.conf /etc | sudo cp /home/centos/config /etc/selinux | sudo cp /home/centos/rc.local /etc | sudo cp /home/centos/cloudera-manager.repo /etc/yum.repos.d |sudo mkdir /usr/share/java | sudo cp /home/centos/mysql-connector-java-5.1.42-bin.jar /usr/share/java/mysql-connector-java.jar"

ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo yum -y update"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo yum -y install ntp nscd wget"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo systemctl enable ntpd nscd"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo systemctl start ntpd nscd"


ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo yum -y install  cloudera-manager-daemons cloudera-manager-agent"
ssh -oStrictHostKeyChecking=no -i "cluster_test_biba.pem"  centos@${hosts[$k]} "sudo service cloudera-scm-agent enable | sudo service cloudera-scm-agent start"

let k=k+1

done

#Instalacion de MariaDB-server y MariaDB-client
sleep 4

yum -y update

sleep 4

yum -y install MariaDB-server MariaDB-client

systemctl enable mysql
systemctl start mysql
systemctl status mysql

#mysql_secure_installation configuración
mysql --user=root <<_EOF
UPDATE mysql.user SET Password=PASSWORD("$SQL_PASSWORD") WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
create database scm DEFAULT CHARACTER SET utf8;
create user 'scm'@'localhost' IDENTIFIED BY 'scm';
grant all on scm.* TO 'scm'@'%' IDENTIFIED BY 'scm';
create database amon DEFAULT CHARACTER SET utf8;
create user 'amon'@'localhost' IDENTIFIED BY 'amon';
grant all on amon.* TO 'amon'@'%' IDENTIFIED BY 'amon';
create database rman DEFAULT CHARACTER SET utf8;
create user 'rman'@'localhost' IDENTIFIED BY 'rman';
grant all on rman.* TO 'rman'@'%' IDENTIFIED BY 'rman';
create database metastore DEFAULT CHARACTER SET utf8;
create user 'metastore'@'localhost' IDENTIFIED BY 'metastore';
grant all on metastore.* TO 'metastore'@'%' IDENTIFIED BY 'metastore';
create database sentry DEFAULT CHARACTER SET utf8;
create user 'sentry'@'localhost' IDENTIFIED BY 'sentry';
grant all on sentry.* TO 'sentry'@'%' IDENTIFIED BY 'sentry';
create database nav DEFAULT CHARACTER SET utf8;
create user 'nav'@'localhost' IDENTIFIED BY 'nav';
grant all on nav.* TO 'nav'@'%' IDENTIFIED BY 'nav';
create database navms DEFAULT CHARACTER SET utf8;
create user 'navms'@'localhost' IDENTIFIED BY 'navms';
grant all on navms.* TO 'navms'@'%' IDENTIFIED BY 'navms';
create database hue DEFAULT CHARACTER SET utf8;
create user 'hue'@'localhost' IDENTIFIED BY 'hue';
grant all on hue.* to 'hue'@'localhost' identified by 'hue';
create database oozie;
create user 'oozie'@'localhost' IDENTIFIED BY 'oozie';
grant all privileges on oozie.* to 'oozie'@'localhost' identified by 'oozie';
grant all privileges on oozie.* to 'oozie'@'%' identified by 'oozie';
create database sqoop;
create user 'sqoop'@'localhost' IDENTIFIED BY 'sqoop';
grant all privileges on sqoop.* to 'sqoop'@'localhost' identified by 'sqoop';
grant all privileges on sqoop.* to 'sqoop'@'%' identified by 'sqoop';
_EOF

sleep 3
#Instalacion de java 1.7
sudo yum -y install java-1.7.0-openjdk

java -version

cp mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /usr/share/java/mysql-connector-java.jar

sleep 1

sudo yum -y install cloudera-manager-daemons cloudera-manager-server

sudo yum -y install cloudera-manager-agent cloudera-manager-daemons

cd /usr/share/cmf/schema

./scm_prepare_database.sh mysql scm scm scm  

sleep 4

sudo service cloudera-scm-server enable

sleep 1

sudo service cloudera-scm-server start

sleep 1

sudo service cloudera-scm-server status

sleep 1

sudo service cloudera-scm-agent enable

sleep 1

sudo service cloudera-scm-agent-start



