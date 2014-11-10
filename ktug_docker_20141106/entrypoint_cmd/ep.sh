#!/usr/bin/env bash

# Need to trap so we can handle ctrl-c and exit, so container can stop
trap "echo EXITING !!; exit 0" SIGINT SIGHUP SIGTERM

seq=1
while true 
do
	message="$(date) Running $0 args are [$@] seq $seq"
	echo $message 
	
	seq=$((seq+1))
	sleep 2
done

