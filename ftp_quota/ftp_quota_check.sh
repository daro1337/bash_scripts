#!/usr/bin/env bash

### FTP creditionals
host="ftp.example.com"
ftpuser=user@example.com
ftppass=XXXXXX

#Alarm threshold
ftpspace=85
#e-mail alarm
emailto=user@example.com

#Turn on zabbix integration alarm [yes/no]:
zabbix=no
#IP of zabbix server
zbxserver=127.0.0.1
#zbxhost MUST be equal to host "Host name" in frontend
zbxhost=host1

##FTP Space check

usage2=$(echo 'site quota' | ncftp3 -u"$ftpuser" -p"$ftppass" $host |awk  '/Uploaded Mb/{print "scale=1;"" " $3 "*100"}' |bc -l)

echo "Usage of FTP is $usage2%"

if (( $(bc <<< "$usage2 > $ftpspace") )); then
        echo -e "\nFREE DISK SPACE ON FTP IS LESS THAN $ftpspace%" |mail   -s "$host FTP quota WARNING" $emailto
	if [[ $zabbix = yes ]] ; then
         zabbix_sender -z $zbxserver -s "$zbxhost" -k ftpusage -o "2"
	else
	echo "zabbix integration is off"
	fi
else
	echo "FTP QUOTA OK"
	if [[ $zabbix = yes ]] ; then
		zabbix_sender -z $zbxserver -s "$zbxhost" -k ftpusage -o "1"
	else
	echo "zabbix integration is off"
	fi
exit 0
fi