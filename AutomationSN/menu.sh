#!/bin/bash
# Bash Menu Script Example
echo "***NOTE***: For options 3 *, 4 * and 5 *, it is necessary to have the instance with the Selinux disabled, note that it is necessary to perform a reboot in the instance after disabling"

PS3='Select the item: '

options=("Deploy instance" "Disable Selinux" "Install dependencies"  "Run model*" "QuickStart*" "Snapshot" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Deploy instance")
            bash /home/centos/despliegue.sh
            ;;
	"Disable Selinux")
	echo "Enter the IP address of the instance"
            read IP

            if
             ping -c 1 $IP &> /dev/null
             then

		sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo sed 's/SELINUX=enforcing/SELINUX=disabled/g' -i /etc/selinux/config"
	 	echo "Disabled Selinux"
		sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo reboot"
	 	echo "Restarting instance, please wait..."
		sleep 2m

	     else
                 echo "Invalid IP"
             exit
             fi
       	   
 	    ;;
        "Install dependencies")
            sudo bash /home/centos/dependecias.sh
            ;;
        "Run model*")
            sudo bash /home/centos/modeloexec.sh
            ;;
        "QuickStart*")
        
            echo "Enter the IP address of the instance"
            read IP
            
            if 
             ping -c 1 $IP &> /dev/null
             then
                 sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem cluster_test_biba.pem centos@$IP:/home/centos
                     
                 sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem supervisor.sh centos@$IP:/home/centos
                 sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo chown root:root /home/centos/supervisor.sh"     
                 sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo chmod +x /home/centos/supervisor.sh"    
             
                 sudo scp -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem quickstart.sh centos@$IP:/home/centos
                 sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo chown root:root /home/centos/quickstart.sh"     
                 sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo chmod +x /home/centos/quickstart.sh"    
                 sudo ssh -oStrictHostKeyChecking=no -i /home/centos/cluster_test_biba.pem centos@$IP "sudo bash /home/centos/quickstart.sh"  
                   
                 
             else
                 echo "Invalid IP"
             exit
             fi
           ;;
	"Snapshot")
		bash /home/centos/snapshot.sh
	   ;;

        "Exit")
            break
            ;;
        *) echo invalid option;;
    esac
done
