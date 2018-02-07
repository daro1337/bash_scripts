#!/usr/bin/env bash
#sciagamy ip range
if [[ $# -eq 0 ]] ; then
    echo 'Enter country like: cn us pl etc.'
    exit 0
fi

dir=/tmp/ipset

	if [ ! -d "$dir" ]; then
		mkdir -p  $dir;
		chmod 700 $dir;
		umask 077 $dir;

		echo "$dir created"
	fi

country=$1

ipset create $country hash:net

cd $dir;

       wget -P . http://www.ipdeny.com/ipblocks/data/countries/$country.zone


       for i in $(cat $dir/$country.zone ); do ipset -A $country $i; done

#dodajemy regulkę w iptables na początek
       iptables -I INPUT -p tcp -m set --match-set $country src -j DROP
#patrzymy jak giną
       watch "iptables -vL |grep $country"
