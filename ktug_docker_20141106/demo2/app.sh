#!/usr/bin/env bash

# Cater for running in a container and outside a container, could have used http://stackoverflow.com/questions/23513045/how-to-check-if-a-process-is-running-inside-docker-container
logDirectoryPath=log; [ -d /log ] && logDirectoryPath=/log

seq=1
while [ true ]
do
	message="$(date) on $(hostname) seq $seq"
	logFilePath="$logDirectoryPath/$(date +"%Y%m%d_%H%M").log"
 
	echo $message | tee -a $logFilePath
	
	seq=$((seq+1))
	sleep 2
done

