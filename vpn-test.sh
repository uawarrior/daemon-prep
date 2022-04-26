#!/bin/bash
#Test script for vpn automatic succesful reconnection

#This is the option with the use of temporary file:
#tail /home/admuser/cg-vpn/moscow_servers.txt -n+4 | head -n-1 | awk -F '|' '{print $4}' > /home/admuser/daemon-prep/tmpfile
#readarray -t a < /home/admuser/daemon-prep/tmpfile

#This is shorthand notation option:
#head -n-6 is used to leave 414th cluster of servers untouched (5 servers)
readarray -t a < <(tail /home/admuser/cg-vpn/moscow_servers.txt -n+4 | head -n-6 | awk -F '|' '{gsub(" ", "", $4); print $4}')

#This is the main loop
for serv in "${a[@]}"
do
	sudo cyberghostvpn --stop
	check=$(sudo cyberghostvpn --traffic --country-code RU --city Moscow --server $serv --connect | tail -n-1)
	if [[ "$check" == "VPN connection established." ]]; then
		echo "this is $serv and $check"
	else
		echo "something bad happened"
	fi
	sleep 30s
done
