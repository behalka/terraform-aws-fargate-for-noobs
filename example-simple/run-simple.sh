#!/usr/bin/env bash

# This set of commands demonstrates simple usage of workspaces

# create environments/workspaces
terraform workspace new development
terraform workspace new staging
# start with the development
terraform workspace select development
# apply changes, with correct env overrides
# execute the .tf files located in the ./first-example subfolder, nothing else
terraform apply -var-file="./example-first/envs/development.tfvars" ./example-first
# then, we can proceed to the second environment
terraform workspace select staging
terraform apply -var-file="./example-first/envs/staging.tfvars" ./example-first
# I guess we're starting to see a pattern here, right?

# if we want to destroy, we need to switch between environments and then
terraform destroy
# it will only delete things in the given environment
