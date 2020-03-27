terraform {
  required_version = "~> 0.12.24"
}

provider "aws" {
  version = "~> 2.0"
  region  = "eu-central-1"
  profile = "tf-learn"
}

module "fargate" {
  source         = "strvcom/fargate/aws"
  version        = "0.17.0"
  name           = "test-ygl" # used as a prefix through the AWS resources
  vpc_create_nat = false

  services = {
    api = {
      task_definition   = "api.json"
      container_port    = 3000 # has to match the port in your Dockerfile
      cpu               = "256"
      memory            = "512"
      replicas          = 2
      health_check_part = "/health-check"
    }
  }
}

# just fetches a correct AMI ~> EC2 image to be used
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "main_db_group"
  subnet_ids = module.fargate.public_subnets
}

# security groups
resource "aws_security_group" "sg_for_db_ssh" {
  name   = "access_db_from_localhost"
  vpc_id = module.fargate.vpc_id

  # only accepts connections on port 22
  ingress {
    description = "ssh for localhost"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# custom security group to assign to databases
resource "aws_security_group" "sg_for_db_access" {
  name   = "access_db"
  vpc_id = module.fargate.vpc_id

  ingress {
    description     = "tcp between servers and dbs"
    from_port       = 80
    to_port         = 5432
    protocol        = "tcp"
    security_groups = concat(module.fargate.services_security_groups_arns, [aws_security_group.sg_for_db_ssh.id]) # both the API instances and the helper EC2 can be a "source of incoming connection"
  }
}

# db-service-helper ec2
resource "aws_instance" "db_tunnel" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "ssh_for_db_test_tf"                  # name of your ssh key (on AWS)
  subnet_id                   = module.fargate.public_subnets[0]      # the id does not really matter here
  vpc_security_group_ids      = [aws_security_group.sg_for_db_ssh.id] # assign our custom security group to it
}

# todo: key pair resource for the ec2

# database
resource "aws_db_instance" "foodb" {
  instance_class         = "db.t2.micro"
  identifier             = "foo-db-identifier"
  name                   = "foo_db"
  username               = "postgres"
  password               = "secretaf" # much security here
  engine                 = "postgres"
  allocated_storage      = "20"
  skip_final_snapshot    = true                                      # -> we can destroy it simply
  vpc_security_group_ids = [aws_security_group.sg_for_db_access.id]  # assign the DB to our custom security group
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.id # db subnet group we created above
}

# outputs
output "db_security_group" {
  value = aws_security_group.sg_for_db_access.id
}

# use this value to connect via a DB client
output "ssh_to_db_dns" {
  value = aws_instance.db_tunnel.public_dns
}

# use this as the db host value in the code and in your DB client
output "db_hostname" {
  value = aws_db_instance.foodb.address
}

# go here and use the API! :D
output "api_dns" {
  value = "${module.fargate.application_load_balancers_dns_names}"
}
