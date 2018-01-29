#!/usr/bin/env bash
#Configuration:
#synology ip
host=192.168.1.80
user=admin
#TimeMachine directory on synology
tmdir=/volume1/timemachine/
port=22
#older than tmtime [in days]
tmtime=14
#zabbix conf
zbxserver=192.168.1.2
#synology hostname in zabbix
hostname=TM-Synology


####script:
CHECK=`ssh  -oStrictHostKeyChecking=no $user@$host -p $port "find  $tmdir -name 
"com.apple.TimeMachine.Results.plist" -mtime +$tmtime" | awk -F "/" '//{print $4}' | cut -d '.' -f1`
count=0
echo -e "$CHECK" | while read line
do
zabbix_sender -z $zbxserver -s "$hostname" -k timemachine_outdated.$count -o "${line}"
#comment line with 'zabbix_sender ...' and uncomment "echo $line" to check once.
#echo $line
(( count++ ))
done
