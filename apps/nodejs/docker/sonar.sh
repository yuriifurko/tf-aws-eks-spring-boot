#!/bin/bash

sonar-scanner \
    -Dsonar.projectName=nodejs \
    -Dsonar.projectKey=nodejs \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.token="sqa_9f0e93e359e962e7cff82b4617eafd61387b5890"