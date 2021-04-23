terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "devops-cloud"
}

resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
    depends_on = [
      tls_private_key.ec2_key
    ]
    content = tls_private_key.ec2_key.private_key_pem
    filename = "webserver.pem"
}

resource "aws_key_pair" "ec2_key" {
    depends_on = [
      tls_private_key.ec2_key
    ]
    key_name = "webserver"
    public_key = tls_private_key.ec2_key.public_key_openssh
}

module "remote" {
  source = "github.com/ejson03/terraform-basic-modules"
}


module "vpc" {
  source = "./.terraform/modules/remote/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = ["10.0.1.0/24", "10.0.2.0/24"]
  region = var.region
  subnet_azs = ["${var.region}a", "${var.region}b"]
}

module "security-group" {
  source = "./.terraform/modules/remote/security-group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./.terraform/modules/remote/ec2"
  instance_type = "t2.micro"
  region = var.region
  subnets = module.vpc.public_subnets
  vpc_security_group_id = module.security-group.security_group_id
  create_user_data = true
  key_name = aws_key_pair.ec2_key.key_name
  template_file = "userdata.tpl"
  instance_count = 2
}

module "alb" {
  source = "./.terraform/modules/remote/alb"
  subnet = module.vpc.public_subnets
  security_group_id = module.security-group.security_group_id
  vpc_id = module.vpc.vpc_id
}

output "dns" {
  value = module.ec2.public_dns
}

output "alb-dns" {
  value = module.alb.alb_dns_name
}