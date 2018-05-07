#!/bin/sh
      > /home/centos/log.txt
       echo "Installing java 1.8.0-openjdk"
     #Installing jdk
       echo "Installing wget"
       sudo yum -y install wget
       echo "Installing java 1.8.0"
       sudo yum -y install java-1.8.0-openjdk        
       JAVA_VERIFY=`sudo yum list installed | grep java-1.8.0-openjdk.x86_64`
       if test ${#JAVA_VERIFY} -gt 0 
       then	
       		echo "Version java" >> log.txt
       		java -version >> log.txt 
       		echo "Java 1.8.0-openjdk installed" >> log.txt

	else 
		echo "Failed  java installation " >> log.txt
		sleep 2
		exit
	fi
       echo "export JAVA_HOME"
       sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64/jre' >> .bashrc
       JAVA_VERIFY=`cat .bashrc | grep "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-0.b14.el7_4.x86_64/jre"`      
       if test ${#JAVA_VERIFY} -gt 0
       then
		echo "$JAVA_HOME" >> log.txt
		echo -ne '#            (7%)\r' >> log.txt
	else
                echo "Failed  JAVA HOME" >> log.txt
                sleep 2
                exit
        fi
    
     #Installing CDH 5 with YARN on a Single Linux Host in Pseudo-distributed mode 
       echo "Installing CDH 5 with YARN on a Single Linux Host in Pseudo-distributed mode "
       #Download the CDH 5 Package
       echo "Downloading the CDH 5 Package"
       sudo wget https://archive.cloudera.com/cdh5/one-click-install/redhat/7/x86_64/cloudera-cdh-5-0.x86_64.rpm
       if test -e /home/centos/cloudera-cdh-5-0.x86_64.rpm
        then
                echo "Rpm downloaded" >> log.txt
        else
                echo "Failed rpm download" >> log.txt
		sleep 2
		exit
        fi
	
     #Install the RPM.
       echo "Installing  Cloudera RPM"  
       sudo yum -y --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm
       CDH_VERIFY=`sudo yum list installed | grep cloudera-cdh.x86_64`
       if test ${#CDH_VERIFY} -gt 0
       then
                echo "Cloudera CDH installed" >> log.txt
       else
                echo "Failed  Cloudera CDH installation " >> log.txt
                sleep 2
                exit
        fi
      #Install CDH 5
       echo "Installing hadoop-conf-pseudo"
       sudo yum -y install hadoop-conf-pseudo
       CDH_VERIFY=`sudo yum list installed | grep hadoop-conf-pseudo`
       if test ${#CDH_VERIFY} -gt 0
       then
                echo "Hadoop installed" >> log.txt
       else
                echo "Failed Hadoop installation " >> log.txt
                sleep 2
                exit
        fi

       echo "Starting Hadoop and Verifying it is Working Properly" 
       
       echo "Formatting the NameNode"
       > /home/centos/validate.txt
       sudo -u hdfs hdfs namenode -format > validate.txt
       FORMAT_VERIFY=`sudo cat validate.txt | grep "Formatting using clusterid"`
       if test ${#FORMAT_VERIFY} -gt 0
       then
                echo "NameNode formatted succesfully" >> log.txt
		sudo rm -r /home/centos/validate.txt 
       else
                echo "Failed  NameNode format" >> log.txt
                sleep 2
                exit
       fi
       echo "Starting HDFS"
       for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done  
       #Step 3: Create the directories needed for Hadoop processes.
       echo "Creating the directories needed for Hadoop processes"
       sudo /usr/lib/hadoop/libexec/init-hdfs.sh
       #Step 5: Start YARN
       echo "Starting yarn-resourcemanager"
       sudo service hadoop-yarn-resourcemanager start
       echo "Starting yarn-nodemanager"		
       sudo service hadoop-yarn-nodemanager start 
       echo "Starting hadoop-mapreduce-historyserver"
       sudo service hadoop-mapreduce-historyserver start	
       #Step 6: Create User Directories
       echo "Creating User Directories"
       sudo -u hdfs hadoop fs -mkdir /user/centos
       sudo -u hdfs hadoop fs -chown centos:centos /user/centos
       echo "Safe mode is off"
       sudo -u hdfs hdfs dfsadmin -safemode leave
       > /home/centos/valHDFSYARN.txt
       sudo service hadoop-yarn-resourcemanager status >> valHDFSYARN.txt
       sudo service hadoop-yarn-nodemanager status >> valHDFSYARN.txt
       sudo service hadoop-mapreduce-historyserver status >> valHDFSYARN.txt
       COUNT_S1=`sudo grep -o 'OK' valHDFSYARN.txt  | wc --w`
       if test "$COUNT_S1" -eq 3
       then
                 echo "HDFS and YARN installed and started" >> log.txt
                echo -ne '##           (14.2%)\r' >> log.txt
                sudo rm -r /home/centos/valHDFSYARN.txt 
       else
                echo "Failed  YARN and HDFS" >> log.txt
                sleep 2
                exit
        fi
     #Installing the ZooKeeper Packages
       echo "Installing the ZooKeeper Packages"
       #Installing the ZooKeeper Base Package
       sudo yum -y install zookeeper
       sudo yum -y install zookeeper-server
       #To create /var/lib/zookeeper and set permissions:
       echo "Creating /var/lib/zookeeper and setting permissions"
       mkdir -p /var/lib/zookeeper
       chown -R zookeeper /var/lib/zookeeper/      
       #To start ZooKeeper after a first-time install:
       echo "Starting ZooKeeper after a first-time installed"
       sudo service zookeeper-server init
       sudo service zookeeper-server start
       > /home/centos/zookeeper.txt
       sudo service zookeeper-server status >> zookeeper.txt
       COUNT_S1=`sudo cat zookeeper.txt | grep "zookeeper-server is running"`
       if test ${#COUNT_S1} -gt 0
       then
                echo "Zookeeper-server installed" >> log.txt
                echo -ne '###          (21.4%)\r' >> log.txt
		sudo rm -r /home/centos/zookeeper.txt
       else
                echo "Failed Zookeeper" >> log.txt
                sleep 2
                exit
        fi
     #Installing Hive Packages
       echo "Installing Hive Packages"
       sudo yum -y install hive hive-metastore hive-server2
       echo "Starting hive-server2"  
       sudo service hive-server2 start
       sudo service hive-server2 status
       > /home/centos/hive.txt
       sudo service hive-server2 status >> hive.txt
       COUNT_S1=`sudo grep  -o 'OK' hive.txt`
       if test ${#COUNT_S1} -gt 0
       then
                echo "Hive server2 installed" >> log.txt
                echo -ne '####         (28.5%)\r' >> log.txt
                sudo rm -r /home/centos/hive.txt
       else
                echo "Failed Hive server2" >> log.txt
                sleep 2
                exit
        fi
     #Installing Sqoop2 Packages
       echo "Installing Sqoop2-server Packages"
       sudo yum -y install sqoop2-server
       echo "Installing Sqoop2-client Packages"
       sudo yum -y install sqoop2-client
       echo "Starting sqoop2-server"
       sudo /sbin/service sqoop2-server start
       > /home/centos/sqoop2-server.txt
       sudo service sqoop2-server status >> sqoop2-server.txt
       COUNT_S1=`sudo grep  -o 'OK' sqoop2-server.txt`
       if test ${#COUNT_S1} -gt 0
       then
                echo "Sqoop server2 is working" >> log.txt
                echo -ne '#####        (35.7%)\r' >> log.txt 
		sudo rm -r /home/centos/sqoop2-server.txt
       else
                echo "Failed Scoop server2" >> log.txt
                sleep 2
                exit
        fi
       echo "Configuring Hadoop version to use"
       #Configuring which Hadoop Version to Use
       sudo alternatives --set sqoop2-tomcat-conf /etc/sqoop2/tomcat-conf.dist
       echo "Sqoop2 installed, configured and started"

#     #Installing Spark Packages
       sudo wget https://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.6.tgz
       tar zxvf spark-2.2.0-bin-hadoop2.6.tgz
       sudo echo 'export SPARK_HOME=/home/centos/spark-2.2.0-bin-hadoop2.6/' >> .bashrc
       sudo chmod -R 777 /tmp/hive/
#       echo "Installing Spark Packages"
#       sudo yum -y install spark-core spark-history-server spark-python
#       echo "Starting Spark Packages"
#       sudo systemctl start spark-history-server 
#       
#       > /home/centos/spark-history-server.txt
#       sudo service spark-history-server status >> spark-history-server.txt
#       COUNT_S1=`sudo grep  -o 'OK' spark-history-server.txt`
#       if test ${#COUNT_S1} -gt 0
#       then
#                echo "Spark-history-server installed  and started" >> log.txt
#                echo -ne '######       (42.8%)\r' >> log.txt
#                sudo rm -r /home/centos/spark-history-server.txt
#       else
#                echo "Failed Spark history server" >> log.txt
#                sleep 2
#                exit
#        fi
##  
     #Installing Kudu Packages
       echo "Installing Kudu Packages"
       sudo yum -y install kudu kudu-master kudu-tserver
       echo "Starting Kudu-master Package"
       sudo service kudu-master start
       echo "Starting Kudu-tserver Package"
       sudo service kudu-tserver start 
	
        > /home/centos/valKUDU.txt
	sudo service kudu-master status >> valKUDU.txt
	sudo service kudu-tserver status >> valKUDU.txt

	COUNT_S1=`sudo grep -o 'OK' valKUDU.txt  | wc --w`
        if test "$COUNT_S1" -eq 2
        then
                echo "KUDU started succesfully" >> log.txt
		echo -ne '#######      (50%)\r' >> log.txt
                sudo rm -r /home/centos/valKUDU.txt
        else
                echo "Failed  KUDU" >> log.txt
                sleep 2
                exit
        fi


     #Installing Kafka Packages
        echo "Downloading Kafka Packages"
        sudo wget http://archive.cloudera.com/kafka/redhat/7/x86_64/kafka/3.0.0/RPMS/noarch/kafka-0.11.0+kafka3.0.0-1.3.0.0.p0.50.el7.noarch.rpm
        sudo wget http://archive.cloudera.com/kafka/redhat/7/x86_64/kafka/3.0.0/RPMS/noarch/kafka-server-0.11.0+kafka3.0.0-1.3.0.0.p0.50.el7.noarch.rpm
        echo "Installing Kafka Packages rpm"
	sudo rpm -ivh kafka-0.11.0+kafka3.0.0-1.3.0.0.p0.50.el7.noarch.rpm
        sudo rpm -ivh kafka-server-0.11.0+kafka3.0.0-1.3.0.0.p0.50.el7.noarch.rpm
        echo "Installing kafka-server"
	sudo yum -y install kafka kafka-server
        echo "Starting kafka-service"
        sudo systemctl start kafka-server
	echo "Removing kafka-rpm downloaded"
	sudo rm -r kafka-server-0.11.0+kafka3.0.0-1.3.0.0.p0.50.el7.noarch.rpm


	> /home/centos/kafka-server.txt
	sudo service kafka-server status >> kafka-server.txt
	COUNT_S1=`sudo grep  -o 'OK' kafka-server.txt`


        if test ${#COUNT_S1} -gt 0
        then
                echo "Kafka server is working" >> log.txt
                echo -ne '########     (57.1%)\r' >> log.txt
                sudo rm -r /home/centos/kafka-server.txt
        else
                echo "Failed in Kafka server" >> log.txt
                sleep 2
                exit
        fi


     #Installing Impala Packages
	echo "Installing Impala Package"
	sudo yum -y install impala
	echo "Installing Impala-server Package"
        sudo yum -y install impala-server
	echo "Installing Impala-state-store Package"
	sudo yum -y install impala-state-store
        echo "Installing Impala-catalog Package"
	sudo yum -y install impala-catalog
	#Copy configuration files
        echo "Copying core-site.xml file"
	sudo cp /etc/hadoop/conf/core-site.xml /etc/impala/conf/
        echo "Copying hdfs-site.xml file"
	sudo cp /etc/hadoop/conf/hdfs-site.xml /etc/impala/conf/
	echo "Changing owner of hadoop-hdfs directory"
	sudo chown root:root -R /var/run/hadoop-hdfs/
	#Install Impala Shell
        echo "Installing Impala-shell Package"		
	sudo yum -y install impala-shell
	#Start services
	echo "Starting impala-state-store service"
	sudo service impala-state-store start
        echo "Starting impala-catalog service"
	sudo service impala-catalog start
        echo "Starting impala-server service"
	sudo service impala-server start
	
	> /home/centos/impalaSer.txt
	sudo service impala-state-store status >> impalaSer.txt
	sudo service impala-catalog status >> impalaSer.txt
	sudo service impala-server status >> impalaSer.txt
	COUNT_S1=`sudo grep -o 'OK' impalaSer.txt  | wc --w`
        if test "$COUNT_S1" -eq 3
       	then
               echo "Impala service installed, configured and started" >> log.txt
               echo -ne '#########    (64.2%)\r' >> log.txt
	       sudo rm -r /home/centos/impalaSer.txt
       	else
                echo "Failed  Impala" >> log.txt
                sleep 2
                exit
        fi
    
      #Installing Oozie			
	echo "Installing mariadb server"
	sudo yum -y install mariadb-server mariadb-client
	echo "Enabling mariadb service"	
	sudo systemctl enable mariadb
	echo "Starting mariadb service"
	sudo systemctl start mariadb
	> /home/centos/mysql.txt
	sudo systemctl status mariadb >> mysql.txt
	COUNT_S1=`sudo grep  -o 'active (running)' mysql.txt`
       	if test ${#COUNT_S1} -gt 0
       	then
                echo "Mysql server is working" >> log.txt
                echo -ne '##########   (71.4%)\r' >> log.txt 
		sudo rm -r /home/centos/mysql.txt
      	else
                echo "Failed Mysql server" >> log.txt
                sleep 2
                exit
        fi
	echo "mysql_secure_installation configuration"
	#mysql_secure_installation configuración
	echo "Updating user root"
  	mysql --user=root --execute="UPDATE mysql.user SET Password=PASSWORD('admin') WHERE User='root';"
	echo "Removing anonymous users"
	mysql --user=root --execute="DELETE FROM mysql.user WHERE User='';"
	echo "Delete test database"
	mysql --user=root --execute="DROP DATABASE IF EXISTS test;"
	echo "Delete test database"
	mysql --user=root --execute="DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
	echo "Flushing privileges"
	mysql --user=root --execute="FLUSH PRIVILEGES;"
	echo "Creating Oozie databases"	
	mysql --user=root -padmin --execute="create database oozie DEFAULT CHARACTER SET utf8;"
	echo "Creating local Oozie user"
	mysql --user=root -padmin --execute="create user 'oozie'@'localhost' IDENTIFIED BY 'oozie';"
   	echo "Creating remote Oozie user"
	mysql --user=root -padmin --execute="create user 'oozie'@'%' IDENTIFIED BY 'oozie';"
	echo "Granting all privileges for local Oozie user" 
	mysql --user=root -padmin --execute="grant all privileges on oozie.* to 'oozie'@'localhost' identified by 'oozie';"
	echo "Granting all privileges for remote Oozie user"
	mysql --user=root -padmin --execute="grant all privileges on oozie.* to 'oozie'@'%' identified by 'oozie';" 

	#Oozie  
	echo "Installing Oozie service"
	sudo yum -y install oozie	
        echo "Installing alternatives Oozie configuration"
	sudo alternatives --set oozie-tomcat-deployment /etc/oozie/tomcat-conf.http
	echo "Downloading Mysql java connector"
	sudo wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.45.tar.gz
	echo "Uncompresssing Mysql java connector"
	sudo tar -vxzf /home/centos/mysql-connector-java-5.1.45.tar.gz
	echo "Moving Mysql java connector to /var/lib/oozie/"
	sudo mv /home/centos/mysql-connector-java-5.1.45/mysql-connector-java-5.1.45-bin.jar /var/lib/oozie/
	echo "Configuring Oozie properties"
	sudo sed -e '77i\\n<property>\n\t<name>oozie.service.JPAService.jdbc.driver</name>\n\t<value>com.mysql.jdbc.Driver</value>\n</property>\n<property>\n\t<name>oozie.service.JPAService.jdbc.url</name>\n\t<value>jdbc:mysql://localhost:3306/oozie</value>\n</property>\n<property>\n\t<name>oozie.service.JPAService.jdbc.username</name>\n\t<value>oozie</value>\n</property>\n<property>\n\t<name>oozie.service.JPAService.jdbc.password</name>\n\t <value>oozie</value>\n</property>\n<property>\n\t<name>oozie.action.mapreduce.uber.jar.enable</name>\n\t<value>true</value>\n\t</property>\n' -i /etc/oozie/conf.dist/oozie-site.xml
 	
	echo "Creating tables in Oozie databases"
	sudo -u oozie /usr/lib/oozie/bin/ooziedb.sh create -run
        echo "Downloading web files needed for Oozie"
	sudo wget https://archive.cloudera.com/gplextras/misc/ext-2.2.zip
	echo "Installing unzip"
	sudo yum -y install unzip
	echo "Uncompresssing web files needed for Oozie"
	sudo unzip /home/centos/ext-2.2.zip
	echo "Moving  web files needed for Oozie to /var/lib/oozie/"
	sudo mv ext-2.2 /var/lib/oozie
  ##Download configuration file 
  sudo wget https://raw.githubusercontent.com/eysdevteam/Abbefaria/master/AutomationSN/oozie-site.xml
  sudo mv oozie-site.xml /etc/oozie/conf/oozie-site.xml
  sudo chmod +x /etc/oozie/conf/oozie-site.xml
  #echo "anadir"
  sudo oozie-setup sharelib create -fs hdfs://localhost:8020 -locallib /usr/lib/oozie/oozie-sharelib-yarn
	echo "Enabling Oozie service"
	sudo systemctl enable oozie
	echo "Starting Oozie service"
	sudo service  oozie start

	> /home/centos/oozie.txt
	sudo sudo service oozie status >> oozie.txt
	COUNT_S1=`sudo grep  -o 'is not running.' oozie.txt`
       	if test ${#COUNT_S1} -gt 0
       	then
                echo "Failed Oozie server" >> log.txt
                sleep 2
                exit
      	else
                echo "Oozie is working" >> log.txt
                echo -ne '###########  (78.5%)\r' >> log.txt
                sudo rm -r /home/centos/oozie.txt
        fi
	echo "Removing Mysql java connector package"
	sudo rm -r /home/centos/mysql-connector-java-5.1.45.tar.gz
	echo "Oozie service installed and configured"

    #Installing Flume
	echo "Installing Flume-ng package"
	sudo yum -y install flume-ng
	echo "Installing Flume-ng-agent package"
	sudo yum -y install flume-ng-agent
	echo "Installing Flume-ng-doc package"
	sudo yum -y install flume-ng-doc
	echo "Coping configuration files to /etc/flume-ng/conf/"
	sudo cp /etc/flume-ng/conf/flume-conf.properties.template /etc/flume-ng/conf/flume.conf
  	echo "Starting flume-ng-agent service"
	sudo service flume-ng-agent start
	echo "Flume service installed and configured"
	> /home/centos/flume.txt
	sudo sudo service flume-ng-agent status >> flume.txt
	COUNT_S1=`sudo grep  -o 'OK' flume.txt`
       if test ${#COUNT_S1} -gt 0
       then 
                echo "flume is working" >> log.txt
                echo -ne '############ (85.7%)\r' >> log.txt

                sudo rm -r /home/centos/flume.txt
       else 
                echo "Failed flume server" >> log.txt
                sleep 2
                exit
        fi

    #Installing Solr (Apache)
	echo "Downloading Solr package"
	sudo wget http://apache.org/dist/lucene/solr/7.2.1/solr-7.2.1.tgz
 	echo "Uncompresssing Solr package"
	sudo tar xzf solr-7.2.1.tgz solr-7.2.1/bin/install_solr_service.sh --strip-components=2
	echo "Installing Solr package"
	sudo yum install -y lsof
	echo "Installing Solr service"
	sudo bash ./install_solr_service.sh solr-7.2.1.tgz
	echo "Enabling login for Solr user"  
	sudo chsh -s /bin/bash solr
	echo "Creating /home/solr directory for Solr user"
	sudo mkdir /home/solr
	echo "Changing owner of Solr directory"
	sudo chown -R solr:solr /home/solr
	echo "Giving /bin/bash/ executing" 
	sudo chmod +x /etc/init.d/solr
	echo "Daemon configure"
	sudo chkconfig --add solr
	echo "Starting Solr service"
        sudo service solr start

	> /home/centos/solr.txt

	sudo sudo service solr status >> solr.txt
	
	COUNT_S1=`sudo grep  -o 'running on port' solr.txt`

        if test ${#COUNT_S1} -gt 0
        then
                echo "solr is working" >> log.txt
                echo -ne '#############(92.8%)\r' >> log.txt
                sudo rm -r /home/centos/solr.txt
        else
                echo "Failed solr server" >> log.txt
                sleep 2
                exit
        fi


	echo "Removing Solr package"
	sudo rm -r solr-7.2.1.tgz
	echo "Solr service installed and configured" 

    #Installing Hue
		echo "Downloading Hue package"
		sudo wget https://www.dropbox.com/s/auwpqygqgdvu1wj/hue-4.1.0.tgz
		echo "Uncompresssing Hue package"
		sudo tar -vxzf hue-4.1.0.tgz
		echo "Installing pre-requirements for Hue service"
		sudo yum -y install ant asciidoc cyrus-sasl-devel cyrus-sasl-gssapi cyrus-sasl-plain gcc gcc-c++ krb5-devel libffi-devel libxml2-devel libxslt-devel make mysql mysql-devel openldap-devel python-devel sqlite-devel gmp-devel -y	
		echo "Downloading pre-requirements packages for Hue service" 
		sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
		echo "Configuring epel-apache-maven.repo" 
		sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
		echo "Installing pre-requirements for Hue service"
		sudo yum install -y apache-maven
		sudo yum install -y openssl-devel
		echo "Creating Hue user"
		sudo useradd hue
  	echo "Accessing to Hue folder"
		cd hue-4.1.0
		echo "Installing Hue"
    sudo PREFIX=/home/hue/usr/share make install
		echo "Changing owner for Hue directory"
		sudo chown hue:hue -R /home/hue/usr/
		echo "Configuring properties for Hue service"
    sudo sed -e '68i\\n<property>\n\t<name>dfs.webhdfs.enabled</name>\n\t<value>true</value>\n</property>\n' -i /etc/hadoop/conf/hdfs-site.xml
		echo "Starting Hue service"
   
   
   IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
   
   sudo nohup bash /home/centos/supervisor.sh &
   #sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo nohup bash /home/centos/supervisor.sh &"  

   sleep 60		
	 cd /home/centos/

	 > /home/centos/hue.txt
	 sudo ps -aux | grep supervisor > hue.txt
	 COUNT_S1=`sudo grep  -o 'hue' hue.txt`
       		if test ${#COUNT_S1} -gt 0
       		then
               	      echo "hue is working" >> log.txt
          	      sudo rm -r /home/centos/hue.txt
       		else
               	      echo "Failed hue server" >> log.txt
                      sleep 2
                      exit
        	fi
		
		echo "Removing Hue package"
		sudo rm -r /home/centos/hue-4.1.0.tgz	
		
  		 #salir shell
    echo "////////////////////////////////////////////////////"  >> log.txt
    echo "Process succesfully completed (100%)\r" >> log.txt
    echo "Join in to:" >> log.txt		
    echo $IP
    echo "// $IP:50070 -> Hadoop                        //" >> log.txt
    echo "// $IP:8088 -> Haddop                        //" >> log.txt
    echo "// $IP:11000 -> Oozie                       //" >> log.txt
    echo "// $IP:8983 -> Solr                        //" >> log.txt
    echo "// $IP:8888 -> Hue                        //" >> log.txt
    echo "// $IP:10002 -> Hive server2             //" >> log.txt
    echo "// $IP:10002 -> Spark  master           //" >> log.txt
    echo "// $IP:12000 -> Sqoop2		 //" >> log.txt
    echo "////////////////////////////////////////"  >> log.txt

		echo "Ok"
exit
exit
  
