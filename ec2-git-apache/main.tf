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

module "vpc" {
  source = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = "10.0.1.0/24"
  region = var.region
}

module "ec2" {
  source = "../modules/ec2"
  instance_type = "t2.micro"
  region = var.region
  subnet_id = module.vpc.subnet_id
  vpc_security_group_id = module.vpc.vpc_security_group_id
  create_user_data = true
  key_name = aws_key_pair.ec2_key.key_name
  template_file = "userdata.tpl"
}

output "dns" {
  value = module.ec2.public_dns
}