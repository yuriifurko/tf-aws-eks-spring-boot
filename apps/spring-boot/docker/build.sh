#!/bin/bash

docker build --platform linux/amd64 -t spring-boot:v$1 .
docker tag spring-boot:v$1 935454902317.dkr.ecr.us-east-1.amazonaws.com/spring-boot:v$1
docker push 935454902317.dkr.ecr.us-east-1.amazonaws.com/spring-boot:v$1

$1