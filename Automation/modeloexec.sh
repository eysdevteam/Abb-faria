#!/bin/sh

echo "Ingrese la dirección IP de la instancia"
read IP

if 
 ping -c 1 $IP &> /dev/null
 then
      echo "Copiando script de modelo"
      sudo scp -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem model.sh centos@$IP:/home/centos
      echo "Copiando Dependencias de Modelo"
      sudo scp -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem DataIPS.tar.gz centos@$IP:/home/centos
      sudo scp -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem Dashboard.tar.gz centos@$IP:/home/centos
      echo "Conectado Mediante SSH - Descomprimiendo Archivos"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "tar -xzvf DataIPS.tar.gz"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "tar -xzvf Dashboard.tar.gz"
      echo "Conectado Mediante SSH - Moviendo Archivos Necesarios para Ejecución"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "sudo mv /home/centos/home/ed/DataIPS /home/centos"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "sudo mv /home/centos/Dashboard /var/www/html/"
      echo "Conectado Mediante SSH - Borrando Archivos Innecesarios"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "sudo rm -r /home/centos/home"     
      echo "Permisos de carpeta"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "chown apache:apache -R /var/www/html/Dashboard"     
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "chmod 777 -R /var/www/html/Dashboard"     
      echo "Conectado Mediante SSH - Ejecutando Script"
      sudo ssh -oStrictHostKeyChecking=no -i /home/ed/cluster_test_biba.pem centos@$IP "bash /home/centos/model.sh"  
      
          
      #salir shell
      echo "terminado"       
 else
 echo "IP invalida"
 exit
fi

exit