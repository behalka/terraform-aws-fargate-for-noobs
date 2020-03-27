#!/usr/bin/env bash

# get the docker login command from aws cli
aws ecr get-login --no-include-email --profile tf-learn --region eu-central-1 > ./docker-login-cmd
# Then, I just ran the output from above command

# make sure that after login, the region matches what you wanted
# check the auth entry in ~/.docker/config.json
