#!/bin/bash

version=$1

docker build -t spring-boot-observability:$version ../app
docker tag spring-boot-observability:$version yuriyf/spring-boot-observability:$version
docker push docker.io/yuriyf/spring-boot-observability:$version