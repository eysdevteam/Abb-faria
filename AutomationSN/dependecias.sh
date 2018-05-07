#!/bin/sh
#exec &> dependencias.log

echo "Enter the IP address of the instance"
read IP

if 
 ping -c 1 $IP &> /dev/null
 then
       sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo yum install -y java-1.8.0"
      echo "Conectando mediante SSH"
      ## Instalación Scala
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo yum install -y wget"
      echo "Conectando mediante SSH"
      #sudo wget www.scala-lang.org/files/archive/scala-2.10.6.rpm
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo rpm -Uvh scala-2.10.6.rpm"
      echo "Conectando mediante SSH"
      ## Instalación Spark 2.2.0
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo wget http://apache.uniminuto.edu/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo tar xvf spark-2.2.0-bin-hadoop2.7.tgz"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "export 'SPARK_HOME=/home/centos/spark-2.2.0-bin-hadoop2.7' | export PATH=$PATH:$SPARK_HOME/bin"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo echo 'export PATH=$PATH:/usr/lib/scala/bin' >> .bashrc"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo echo 'export SPARK_HOME=/home/centos/spark-2.2.0-bin-hadoop2.7' >> .bashrc"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo echo 'export PATH=$PATH:$SPARK_HOME/bin' >> .bashrc"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo yum install -y httpd"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo systemctl enable httpd"
      echo "Conectando mediante SSH"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo systemctl start httpd"
      
      #salir shell
      echo "terminado"       
 else
 echo "IP invalida"
 exit
fi

exit