#!/usr/bin/env bash

# assuming you have already logged in ($ docker login ... )
# build
docker build -t api-default .

# You will need to replace these urls with yours.
# You can find these commands in AWS Console -> ECR -> View push commands
# tag
docker tag api-default:latest 519984932148.dkr.ecr.eu-central-1.amazonaws.com/api-default:latest
# the host name is copied from the ECR dashboard helper

# push
docker push 519984932148.dkr.ecr.eu-central-1.amazonaws.com/api-default:latest
# again, the host name == my account id