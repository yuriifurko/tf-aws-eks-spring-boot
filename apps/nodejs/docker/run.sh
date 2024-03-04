#!/bin/bash

docker run --rm -it -v $PWD:/home/node/app -p "3000:3000" $(docker build -q .) sh