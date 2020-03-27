# AWS Fargate Terraform module example usage

This is a playground repository that utilizes [AWS Fargate Terraform module ⭐️](https://github.com/strvcom/terraform-aws-fargate). It is meant for people with zero experience and it hopefully should answer the problems which usually make you stop at the "step 0.1" 🙏🙃. The scripts are extremely simplified ("scripts" is actually a huge exaggeration), they are not supposed to do the work for you, they only serve as examples that are supposed to teach you.

## Prerequisities 👒

- AWS Programmatic account: It will need `AdministratorAccess` 😱
- Terraform installed (I have version 0.12.24)
- Familiar with what Terraform is (going over the [basic tutorial](https://learn.hashicorp.com/terraform/getting-started/intro) perhaps? 🤔)
- Slightly familiar with AWS stack and Docker 🐳
- SSH key uploaded to AWS (or created via AWS wizard). Name it `ssh_for_db_test_tf` if you don't want to change the main.tf (yes I know that's not very reusable 🐒).

## What it does ⚙️

- Sets up Fargate infrastructure that allows to run a very simple API in cloud (details [here](https://github.com/strvcom/terraform-aws-fargate#technical-architecture))
- Creates a Postgres database
- Creates an EC2 instance that solves as a "proxy" to connect to the database from your local machine via SSH
- Creates additional security groups:
  - `sg_for_db_access` allows the ECS cluster to connect with the database
  - `sg_for_db_ssh` allows the auxiliary EC2 to connect to the database
- Provides a dummy API to test the deployment.
- Provides some dummy helper scripts to push your Docker image to the ECR.
- If you (as me) do not understand the AWS internals and all the VPCs, subnets and other things confuse you, check out [this simple analogy](https://stackoverflow.com/a/45235243).

## Run it

Steps needed to take in order to have a running API:

```bash
  # set up the infrastructure
  $ terraform init
  $ terraform apply
  # retrieve some useful info perhaps :smirk:
  $ terraform output

  # Make changes to the src/index.js -> provide correct db host etc

  # resolve the Docker login to the ECR
  $ ./bin/ecr-login.sh # see the script for details
  # build, tag, push to the ECR
  $ ./bin/push-to-registry.sh # see the script first for details

  # when you are done
  $ terraform destroy
  # and deactivate the super powerful admin account :)
```

Then check out the tf output with name `api_dns`. That should be your API's URL. Or go to the AWS Console -> EC2 -> Load balancers -> DNS name. The API should contain 3 endpoints, `/db` should demonstrate that the database VPC connection works.

If you want to connect to the database via SQL client, check out `ssh_to_db_dns` output variable to retrieve the `host`. The user name is `ubuntu` and instead of password use your SSH key (private part hh).

If you perhaps made some changes and you want to restart the cluster, run

```bash
  $ aws ecs update-service --force-new-deploy --service api
```

## A few observations about the Fargate module 👀

- it creates about 50 AWS resources for you, even for such a simple use case 👏. These resources include Cloudwatch logs, bunch of security stuffs, load balancer and the deployment pipeline (-> like, if you push a correctly tagged image, the cluster deploys it automatically).
- because of that, it will need `AdministratorAccess`. This account should be handled very carefully and when you don't need it, you should deactivate it via IAM Console.
- the module creates following security groups 🚧:
  - `<service-name>-services-sg`: used to communicate between services in the VPC
  - `<service-name>-web-sg`: the internet-facing services
- Each new deployment creates a new log stream. If you want to see all the logs from all the deployments combined, use Cloudwatch Insights. It's super cool anyways 🤷‍♀.
- If you wanna keep experimenting, [here](https://github.com/strvcom/terraform-aws-fargate/blob/master/outputs.tf) is the full list of useful output values the module provides.
- Also please note that changes made to the ECS can take some time to propagate 🙄. If you want to have a better idea about what is going on, for example after you pushed a new Docker image and you can't see the changes, go to AWS Console -> ECS -> select cluster -> select service ("api") -> events. And if the API does not work (typically the DB connection is not set up correctly), you can go to good old Cloudwatch and see what happened :)

## Future steps in this repo

- `master` branch: minimal "repo" that is supposed to show how to get started with the module. The solution is naive on purpose so even noobs like me can easily decode what is happening 👶.
- other branches will cover:
  - [ ] Different environments (terraform `workspaces`)
  - [ ] Basic deployment setup
  - [ ] Complete setup with more services (S3, SNS, Alarms)
