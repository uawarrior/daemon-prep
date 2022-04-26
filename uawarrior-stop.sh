#!/bin/bash
#Small script for clean-up after uawarrior.service stops
docker rm -f $(docker ps -a -q)
#cyberghostvpn --stop
