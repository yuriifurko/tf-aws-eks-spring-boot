#!/bin/bash

version=$1

docker build -t nodejs-observability:$version .
docker tag nodejs-observability:$version yuriyf/nodejs-observability:$version
docker push docker.io/yuriyf/nodejs-observability:$version