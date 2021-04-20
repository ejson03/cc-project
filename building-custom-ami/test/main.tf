terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "devops-cloud"
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  depends_on = [
    tls_private_key.ec2_key
  ]
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "webserver.pem"
}

resource "aws_key_pair" "ec2_key" {
  depends_on = [
    tls_private_key.ec2_key
  ]
  key_name   = "webserver"
  public_key = tls_private_key.ec2_key.public_key_openssh
}

data "aws_ami" "packer_ami" {
  filter  {
    name   = "state"
    values = ["available"]
  }
  owners = ["self"]
  filter {
    name   = "tag:Name"
    values = ["packer-nginx"]
  }
  most_recent = true
}

data "terraform_remote_state" "build" {
  backend = "local"
  config = {
    path = "../build/terraform.tfstate"
  }
}

module "remote" {
  source = "github.com/ejson03/terraform-basic-modules"
}

module "security-group" {
  source = "./.terraform/modules/remote/security-group"
  vpc_id = data.terraform_remote_state.build.outputs.vpc_id
}



module "ec2" {
  source                = "./.terraform/modules/remote/ec2"
  ami                   = data.aws_ami.packer_ami
  instance_type         = "t2.micro"
  region                = var.region
  subnets               = data.terraform_remote_state.build.outputs.public_subnets
  vpc_security_group_id = module.security-group.security_group_id
  key_name              = aws_key_pair.ec2_key.key_name
  instance_count        = 1
}

output "public_dns" {
  value = module.ec2.public_dns
}