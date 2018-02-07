#!/usr/bin/env bash
#paste output to /etc/network/interfaces (debian/ubuntu)
#iface eth0:1 inet static
#        address 10.10.4.X
#        netmask 255.255.255.255
#auto eth0:1

if [[ $# -eq 0 ]] ; then
    echo 'Enter path to file as a argument'
    exit 0
fi

i=1

while read line;
do
	echo " "
	echo "iface eth0:$i inet static";
	echo "        address $line";
	echo "        netmask 255.255.255.255";
	echo "auto eth0:$i";
	((i++))
done < $1

