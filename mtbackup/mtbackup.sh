#!/usr/bin/env bash
## script by daro1337
## To run this script you have to create backup user on mikrotik, allow for: ssh,ftp,read,write
## Insert sshkey for this user on mikrotik
## Insert Mikrotik name, Mikrotik IP and mikrotik port on each array in right order.
## MT-1 - IP  10.10.0.50, ssh port 2022

##CONFIG
#mikrotik backup account
user=backup
#email for notification
email=daro113377@gmail.com
#backup directory
bckdir=/backup/mikrotik-backup/

#Mikrotik name
client=(
"MT-1" "MT-2" "MT-3"
	)
####
#### Mikrotik IP
host=(
"10.10.0.50" "10.20.0.50" "10.21.0.50"
	)
####
####SSH ports
port=(
"2022" "2001" "2002"
        )

output=$(

for ((i=0;i<${#client[@]};++i));
	do
 		export name=${client[$i]}
                bfile=$name-`date +%Y%m%d`
                echo -e "\n\n<html></br></br><b>BACKUP $name</b> 
mikrotik configuration</br></br></html>\n\n"
                ssh -oStrictHostKeyChecking=no $user@${host[i]} -p ${port[i]} export 
file=$bfile;er1=$?

		if  [ $er1 != 0 ]; then
		echo -e "\n\n<html></br></br><b>BACKUP $name ERROR</b> 
while making backup on router</br></br></html>\n\n"
		fi

                sftp -P ${port[i]} $user@${host[i]}:$bfile.rsc;er2=$?

		if  [ $er2 != 0 ]; then
                echo -e "\n\n<html></br></br><b>BACKUP $name ERROR</b> 
while downloading file</br></br></html>\n\n"
       		fi

                ssh  -oStrictHostKeyChecking=no $user@${host[i]} -p ${port[i]} file remove 
$bfile.rsc;er3=$?

		if  [ $er3 != 0 ]; then
                echo -e "\n\n<html></br></br><b>BACKUP $name ERROR 
while</b> removing file</br></br></html>\n\n"
	        fi
	done
)


if [[ $output ==  *ERROR* ]]; then
	echo -e "\n$output\n" |mail  -a "Content-type: text/html;" -s 
"MT backups: PROBLEM" $email;
	#stop cleaning
	mv *.rsc $bckdir;

else
	 echo -e "\n$output\n" |mail -a "Content-type: text/html;" -s 
"MT backups: OK" $email;
	# cleaning...
	mv *.rsc $bckdir;
	find $bckdir*.rsc -type f -mmin +8320 -delete;
fi
