#!/bin/sh
#exec &> despliegue.log

echo "Process started..."

echo "Define the name of the instance:   "
read NAME

##Shell para centos, ejecutado en la maquina que contenga cloudera manager 
sudo echo "AKIAI6SKZLATQ24B4XXQ\7OniihffIB3aCtgKQt0KJW6WCUAX3snpraKSmUNt\us-east-1\json" | aws configure

  
echo "Deploying instance"

##Generar variable que va a contener el ID que se le asigne a la instancia
##especificando el id de la ami de Centos, el tipo de instancia, la llave, el grupo de seguridad y el id de la subnet
ID=$(aws ec2 run-instances --image-id ami-02e98f78 --count 1 --instance-type t2.xlarge --key-name cluster_test_biba --security-group-ids sg-3930f346 --subnet-id subnet-b54fbd89 --query 'Instances[0].InstanceId' --output text)

echo $ID 

aws ec2 create-tags --resources $ID --tags Key=Name,Value=$NAME


##Generar variable que va a contener la dirección IP que se le asigne a la instancia
IP=$(aws ec2 describe-instances --instance-ids $ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)



echo "Connecting via SSH"
##Conectar por SSH a la maquina con la IP almacenada
sleep 5m

echo "The IP address for the instance is: " 
echo $IP
exit

