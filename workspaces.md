# Leveraging Terraform workspaces

## Objective

We want to simulate different deployment environments, the same thing as the Heroku pipeline basically. The environments would match "main" git branches - `development`, `staging` and `production`.

There are two examples in `example-simple` and `example-automated` folders. Make sure that every terraform command you run will be pointing to the given subfolder like this 👇

```bash
$ terraform plan ./example-simple
```

## First example

Let's create a different s3 bucket (name will have the workspace in it). We assume we are gonna start with fresh AWS environment. Basically we need to do these steps:

1. Create separate workspaces that will simulate git branches (`development`, `staging`)
2. Then we need to make sure we are located in the environment we want
3. Then we apply `./example-first/main.tf` with corresponding `./example-first/envs/[workspace-name].tfvars`.

We should end up with two S3 buckets (in AWS Console), but each Terraform workspace will only have access to one of them. If we for example run `terraform destroy`, only one S3 bucket is deleted. Maybe this is obvious, but I found myself lost quite early (like, what's created where, is it deleted etc) so I wanted to point this out.

The naming could be easily automated via a couple of shell scripts, we will get to that. If you're a shell noob like me, maybe you'd appreciate to try this out manually, first 🙃.

**Important things to note in `main.tf`**

- `terraform.workspace` gives us the name of current workspace. Also, if no workspace was created, we are actually in `default` workspace.
- we define `variable foo` - the name `foo` corresponds to what we have in `.tfvars` files. We should provide a default value to this variable.
- then, we use both of those workspace-dependent variables (`terraform.workspace` and `foo`) to create consistent names of our S3 resources. Pretty easy, right?

## A bit more automated example 😏

The point here is to retrieve the branch/workspace name somehow, load the .tfvars with this name and run `apply`. The script falls back to `development` workspace, look into it for details.

```bash
$ ENV GITHUB_REF=development ./example-automated/run-automated.sh
```

Note that the script will crash if the workspace does not exist or the vars file does not exist.

The important part is the `TF_CLI_ARGS` env var trick. Terraform will just glue the value stored in this env var to most of its commands. So, instead of setting the envs file explicitly as in the first example, we store it into `TF_CLI_ARGS` and it will be then used repeately.

Pretty dumb, right? Let's move to the CI as a next step in building our pipeline 😁.
