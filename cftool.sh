#!/usr/bin/env bash

if [ "$#" == 0 ] ; then
	echo -e "Usage:\n [on|off] to turn on/off development mode \n purge - to purge cache"
exit 0
fi

apikey=123apikey456
email=mail@example.com
array=( zoneID1 zoneID2 zoneID2 zoneID3 )

case "$1" in
        on)
for i in "${array[@]}"
do
#Turn on DEVELOPMENT MODE
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$i/settings/development_mode" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $apikey" \
     -H "Content-Type: application/json" \
     --data '{"value":"on"}'
done
echo -e "Develop mode ON";
;;
 off)
for i in "${array[@]}"
do

#Turn off devel mode
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$i/settings/development_mode" \
     -H "X-Auth-Email: $email" \
     -H "X-Auth-Key: $apikey" \
     -H "Content-Type: application/json" \
     --data '{"value":"off"}'
done
echo -e "Develop mode ON. Caching..";
	;;
purge)
	for i in "${array[@]}"
		do
		echo  "Cache purging on  $i\n"

		curl -X POST "https://api.cloudflare.com/client/v4/zones/$i/purge_cache" \
			-H "X-Auth-Email: $email" \
			-H "X-Auth-Key: $apikey" \
			-H "Content-Type: application/json" \
			--data '{"purge_everything":true}'
		done
	echo -e "Cache purged.";
;;
*)
            echo -e $"Usage: $0 \e[39m[\e[32mon\e[39m|\e[32moff\e[39m]"
            exit 1

esac