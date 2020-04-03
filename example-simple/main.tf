terraform {
  required_version = "~> 0.12.24"
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
  profile = "tf-learn"
}

# default variables that map to .tfvars
variable "foo" {
  # this value will be overriden by .tfvars content
  default = "hi"
}

variable "project_prefix" {
  # we can override it, we probably do not need to
  default = "ygl"
}

locals {
  env_name    = "env-${terraform.workspace}"
  bucket_name = "foo-${var.foo}-${terraform.workspace}"
}

resource "aws_s3_bucket" "foo_bucket" {
  bucket = local.bucket_name
  acl    = "private"
}

# run just this with terraform refresh to see the vars are working
output "env_name_test" {
  value = local.env_name
}

output "test_bucket" {
  value = aws_s3_bucket.foo_bucket.id
}
