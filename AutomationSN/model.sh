#!/bin/bash
timedatectl set-timezone America/Bogota

DIA=$(date +%d-%m-%Y-%H:%M)
echo "Día y fecha de ejecución: $DIA"
if [ -d /home/centos/fecha];
then
echo "Sí, sí existe."
else
echo "No, no existe"

fi

#FECHA EN ARCHIVO

> /home/centos/fecha

echo "$DIA" >> /home/centos/fecha

#sudo mkdir /var/www/html/Dashboard/
#sudo mkdir /var/www/html/Dashboard/web
#sudo mkdir /var/www/html/Dashboard/web/donut1
#sudo mkdir /var/www/html/Dashboard/web/donut2
#sudo mkdir /var/www/html/Dashboard/web/scatter
#sudo mkdir /var/www/html/Dashboard/web/tablebest
#sudo mkdir /var/www/html/Dashboard/web/tableworst
#sudo mkdir /var/www/html/Dashboard/web/bars-whisker
#sudo mkdir /var/www/html/Dashboard/web/name-var

sudo /home/centos/spark-2.2.0-bin-hadoop2.7/bin/spark-shell -i /home/centos/DataIPS/pca.java

echo "The end"


###Donuts
sudo sed -i -e 's/^/[/' /var/www/html/Dashboard/web/donut1/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/Dashboard/web/donut1/donut.json

sudo sed -i -e 's/^/[/' /var/www/html/Dashboard/web/donut2/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/Dashboard/web/donut2/donut.json 

##Scatter



sudo sed -i -e "s/\[/'/g" /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i -e "s/\]/'/g" /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i -e 's/['\'']/["\]/g'  /var/www/html/Dashboard/web/scatter/scatter.json

sudo sed -i -e "s/\]//g" /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i -e "s/\[//g" /var/www/html/Dashboard/web/scatter/scatter.json

sudo sed -i -e 's/"ArrayBuffer(/[/' /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i -e 's/)"}/]}/' /var/www/html/Dashboard/web/scatter/scatter.json

sudo sed -i -e '$!s/$/,/' /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i '1s/^/[\n/' /var/www/html/Dashboard/web/scatter/scatter.json
sudo sed -i "\$a ] \n" /var/www/html/Dashboard/web/scatter/scatter.json



##Tables
sudo sed -i -e '$!s/$/,/' /var/www/html/Dashboard/web/tablebest/table.json
sudo sed -i '1s/^/[ /' /var/www/html/Dashboard/web/tablebest/table.json
sudo sed -i "\$a]" /var/www/html/Dashboard/web/tablebest/table.json

sudo sed -i -e '$!s/$/,/' /var/www/html/Dashboard/web/tableworst/table.json
sudo sed -i '1s/^/[ \n/' /var/www/html/Dashboard/web/tableworst/table.json
sudo sed -i "\$a]" /var/www/html/Dashboard/web/tableworst/table.json

##Bar-Whisker
sudo sed -i -e '$!s/$/,/' /var/www/html/Dashboard/web/bars-whisker/table.json
sudo sed -i '1s/^/[ \n/' /var/www/html/Dashboard/web/bars-whisker/table.json
sudo sed -i "\$a]" /var/www/html/Dashboard/web/bars-whisker/table.json

##Name-var
sudo sed -i -e '$!s/$/,/' /var/www/html/Dashboard/web/name-var/name.json
sudo sed -i '1s/^/[ \n/' /var/www/html/Dashboard/web/name-var/name.json
sudo sed -i "\$a]" /var/www/html/Dashboard/web/name-var/name.json


exit
