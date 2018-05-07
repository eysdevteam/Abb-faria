#!/bin/sh

echo "Enter the IP address of the instance"
read IP

if 
 ping -c 1 $IP &> /dev/null
 then
      echo "Copiando script de modelo"
      sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem model.sh centos@$IP:/home/centos
      echo "Copiando Dependencias de Modelo"
      sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem DataIPS.tar.gz centos@$IP:/home/centos
      sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem DashBoardIPS.tar.gz centos@$IP:/home/centos
      echo "Conectado Mediante SSH - Descomprimiendo Archivos"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "tar -xzvf DataIPS.tar.gz"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "tar -xzvf DashBoardIPS.tar.gz"
      echo "Conectado Mediante SSH - Moviendo Archivos Necesarios para Ejecución"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo mv /home/centos/home/centos/DataIPS /home/centos"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo mv /home/centos/DashBoardIPS /var/www/html/"
      echo "Conectado Mediante SSH - Borrando Archivos Innecesarios"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo rm -r /home/centos/home"     
      echo "Permisos de carpeta"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "chown apache:apache -R /var/www/html/DashBoardIPS"     
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "chmod 777 -R /var/www/html/DashBoardIPS"     
      echo "Conectado Mediante SSH - Ejecutando Script"
      sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "bash /home/centos/model.sh"  
      
          
      #salir shell
      echo "terminado"       
 else
 echo "IP invalida"
 exit
fi

exit