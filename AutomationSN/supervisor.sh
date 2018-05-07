#!/bin/sh
#    echo "Accessing to Hue folder"
#	cd hue-4.1.0
#	echo "Installing Hue"
#	sudo PREFIX=/home/hue/usr/share make install
#	echo "Changing owner for Hue directory"
#	sudo chown hue:hue -R /home/hue/usr/
#	echo "Configuring properties for Hue service"
#	sudo sed -e '68i\\n<property>\n\t<name>dfs.webhdfs.enabled</name>\n\t<value>true</value>\n</property>\n' -i /etc/hadoop/conf/hdfs-site.xml
	echo "Starting Hue service shell"	   
	sudo su hue -c '/home/hue/usr/share/hue/build/env/bin/supervisor'
	echo "ok"
exit
exit
