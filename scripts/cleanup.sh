#!/bin/bash

find . -type d -name ".terraform" -exec rm -rf {} +;
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;