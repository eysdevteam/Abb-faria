#!/bin/sh

sudo $SPARK_HOME/bin/spark-shell -i /home/centos/Vicepr/percentil.java 
sudo $SPARK_HOME/bin/spark-shell -i /home/centos/Jefes/percentil.java 
sudo $SPARK_HOME/bin/spark-shell -i /home/centos/Nacionales/percentil.java 
sudo $SPARK_HOME/bin/spark-shell -i /home/centos/Internacionales/percentil.java 

##Donuts
sudo sed -i -e 's/^/[/' /var/www/html/DashboardProc/web/Vicepr/donut/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/DashboardProc/web/Vicepr/donut/donut.json

sudo sed -i -e 's/^/[/' /var/www/html/DashboardProc/web/Jefes/donut/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/DashboardProc/web/Jefes/donut/donut.json

sudo sed -i -e 's/^/[/' /var/www/html/DashboardProc/web/Nacionales/donut/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/DashboardProc/web/Nacionales/donut/donut.json

sudo sed -i -e 's/^/[/' /var/www/html/DashboardProc/web/Internacionales/donut/donut.json
sudo sed -i -e 's/$/]/' /var/www/html/DashboardProc/web/Internacionales/donut/donut.json

##Bullets
sudo sed -i '$!s/$/,/' /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json
sudo sed -i -e 's|C":5|C":[5]|g' /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json
sudo sed -i -e 's|valor":|valor":[|g' /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json
sudo sed -i -e 's|,"con|],"con|g' /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json
sudo sed -i '1s/^/[/' /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json
sudo sed -i "\$a]" /var/www/html/DashboardProc/web/Vicepr/bullet/bullet.json

sudo sed -i '$!s/$/,/' /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json
sudo sed -i -e 's|C":5|C":[5]|g' /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json
sudo sed -i -e 's|valor":|valor":[|g' /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json
sudo sed -i -e 's|,"con|],"con|g' /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json
sudo sed -i '1s/^/[/' /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json
sudo sed -i "\$a]" /var/www/html/DashboardProc/web/Jefes/bullet/bullet.json

sudo sed -i '$!s/$/,/' /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json
sudo sed -i -e 's|C":5|C":[5]|g' /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json
sudo sed -i -e 's|valor":|valor":[|g' /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json
sudo sed -i -e 's|,"con|],"con|g' /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json
sudo sed -i '1s/^/[/' /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json
sudo sed -i "\$a]" /var/www/html/DashboardProc/web/Nacionales/bullet/bullet.json

sudo sed -i '$!s/$/,/' /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json
sudo sed -i -e 's|C":5|C":[5]|g' /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json
sudo sed -i -e 's|valor":|valor":[|g' /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json
sudo sed -i -e 's|,"con|],"con|g' /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json
sudo sed -i '1s/^/[/' /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json
sudo sed -i "\$a]" /var/www/html/DashboardProc/web/Internacionales/bullet/bullet.json


exit

