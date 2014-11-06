#!/usr/bin/env bash

echo Tag for image
tag=v1
imagetag=pmcgrath/ktug_demo1:$tag

echo Building image 
docker build -t $imagetag .

echo Run local container, tailing the log
docker run -d --name pmcg_ktug_demo1 $imagetag
docker logs -f pmcg_ktug_demo1

