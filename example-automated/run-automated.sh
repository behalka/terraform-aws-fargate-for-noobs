#!/usr/bin/env bash

# Determine the workspace

# GITHUB_REF or the resolved git .. command
# the :- thing is like ?? operator in JS
CURRENT_BRANCH=${GITHUB_REF:-"$(git symbolic-ref --short HEAD)"}
# again, the CURRENT_BRANCH is a default value, if MY_WORKSPACE is set, it would override it
MY_WORKSPACE=${MY_WORKSPACE:-"${CURRENT_BRANCH}"}

# allowed values for the workspace are just those
# we will want to build the infrastructure for just a couple of important branches, right?
case "${MY_WORKSPACE}" in
  "development" | "staging" | "production" )
    ;;
  * )
  # if the value is different, it will fall back to development instead
  TERRAFORM_WORKSPACE="development"
  ;;
esac

echo "Gonna use the ${MY_WORKSPACE} workspace"

# Switch to it - might crash if it does not exist
terraform workspace select $MY_WORKSPACE

# Set the environment .tfvars folder
varfile="example-automated/envs/${MY_WORKSPACE}.tfvars"
echo -e "Using var file: ${varfile}"
# the "-var-file=..." will be appended to every terraform [something] command
# in this script !
export TF_CLI_ARGS="-var-file=${varfile}"

terraform apply ./example-automated