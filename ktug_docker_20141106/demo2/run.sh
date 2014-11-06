#!/usr/bin/env bash

echo Tag for image
tag=v1
imagetag=pmcgrath/ktug_demo2:$tag

echo Building image using a repository name suitable for the docker hub registry 
docker build -t $imagetag .

if [ ! -f ~/.dockercfg ]
then
	echo Login to docker hub
	docker login
fi

echo Pushing image to docker hub
docker push $imagetag

echo -e "Connect to AWS and run image there with\n\tdocker run -d --name demo2 $imagetag\n\tdocker logs -f demo2"

