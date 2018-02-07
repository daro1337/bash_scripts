#!/usr/bin/env bash
# wersja jeśli jest więcej niz 60 procesów apache (line 25)
count=` whereis iotop tcpdump vmstat netstat gzip tar uptime ps  2>/dev/null | wc -l`
                if [ $count != 8 ]; then
		echo "Some soft missing ";
		echo "iotop tcpdump vmstat netstat gzip tar uptime ps  "
		 extit 0
		fi

avgload="99"
logdir=/var/log/linux_debuger

#robimy miejsce do zapisu logów:
#tcpdump  zapisywany jest w /tmp

	if [ ! -d "$logdir" ]; then
		mkdir -p  $logdir;
		chmod 700 $logdir;
		umask 077 $logdir;

		echo "$logdir created"
	fi

while true; do
  if [ $(echo "$(uptime | cut -d " " -f 14 | cut -d "," -f 1) >= $avgload" | bc) = 1 ] || [ $(echo "$(ps aux |grep apache2 |wc -l) >= 60" | bc) = 1 ]; then


# brzydko killujemy ostatniego tcpdumpa i przenosimy do logdir

	ps aux | awk '/tcpdump/{print $2}'  |while read line; do kill -9 $line; done
		mv /tmp/tcpdump_* $logdir;

#zipujemy

	count=`ls -1 $logdir/*.{log,cap} 2>/dev/null | wc -l`
		if [ $count != 0 ]; then
				gzip $logdir/*.{log,cap}
		fi

#zapisujemy tcpdumpa w tle + zipujemy i lecimy dalej! :)

	( tcpdump -vv -x -AX -s 0 -i any -w /tmp/tcpdump_$(date +\%H\%M\%S_\%d\%m\%Y).cap -z gzip &)

#netstat all tcp / udp
	#timestamp
	 echo "=== $(date) ===">> $logdir/netstat_$(date +\%H\%M\%S_\%d\%m\%Y).log;
	 netstat -anp |grep 'tcp\|udp' | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn >> $logdir/netstat_$(date +\%H\%M\%S_\%d\%m\%Y).log;

# sprawdzamy netstat  DOS/ DDOS na 80 /443 
	#timestamp
	echo "=== $(date) ===">> $logdir/netstat_www_$(date +\%H\%M\%S_\%d\%m\%Y).log;
	netstat -an | egrep ':80|:443|:7081|:7080' | grep ESTABLISHED | awk '{print $5}' | grep -o -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}" | sort -n | uniq -c | sort -nr | head -n 20 >> /var/log/netstat_www_$(date +\%H\%M\%S_\%d\%m\%Y).log

#sprawdzamy procesy per user
	#timestamp
	echo "=== $(date) ===">> $logdir/processes_$(date +\%H\%M\%S_\%d\%m\%Y).log;
	ps -eo user=|sort|uniq -c |sort -rn |tail -n 30 >>$logdir/processes_$(date +\%H\%M\%S_\%d\%m\%Y).log

#ps auxf
	#timestamp
	echo "=== $(date) ===">>$logdir/ps_aux_$(date +\%H\%M\%S_\%d\%m\%Y).log
	ps -auxf >>$logdir/ps_aux_$(date +\%H\%M\%S_\%d\%m\%Y).log

 #vmstat
	echo "=== $(date) ===">>$logdir/vmstat_$(date +\%H\%M\%S_\%d\%m\%Y).log
	(vmstat -td 5 4 >>$logdir/vmstat_$(date +\%H\%M\%S_\%d\%m\%Y).log &)



#iotop
	( iotop -botqqqk --iter=19 | grep -P "\d\d\.\d\d K/s" >>$logdir/iotop_$(date +\%H\%M\%S_\%d\%m\%Y).log &)


  else
    echo "Load is ok"
    	#killujemy tcpdumpa  po spadzie uploada
   	 ps aux | awk '/tcpdump/{print $2}'  |while read line; do kill -9 $line; done

        #sprzątamy syf
	count=`ls -1 $logdir/*.{log,cap}.gz 2>/dev/null | wc -l`
                if [ $count != 0 ]; then
			#przenosimy ostani  plik tcpdumpa do logdira
			 mv /tmp/tcpdump_* $logdir;
			tar zcfv $logdir/linux_debug_$(date +\%H\%M\_\%d\%m\%Y).tar.gz $logdir/*.{log,cap}* &&  rm $logdir/*.{log,cap}*
                fi
  fi
  #sprawdzamy co 20s!
  sleep 20
done
