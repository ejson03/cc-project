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
  source = "../../terraform-basic-modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = ["10.0.1.0/24"]
  region = var.region
  subnet_azs = ["${var.region}a"]
}

module "security-group" {
  source = "../../terraform-basic-modules/security-group"
  vpc_id = module.vpc.vpc_id
  manage_security_group = true
  security_group_name = "test-sg"
  security_group_ingress = [
    {
      description = "HTTP"
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "SSH"
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  security_group_egress = [
    {
      from_port   = "0"
      to_port     = "0"
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Owner = "user"
    Environment = "dev"
  }
}

module "ec2" {
  source = "../../terraform-basic-modules/ec2"
  instance_type = "t2.micro"
  region = var.region
  subnets = module.vpc.public_subnets
  vpc_security_group_id = module.security-group.security_group_id
  create_user_data = true
  key_name = aws_key_pair.ec2_key.key_name
  template_file = "userdata.tpl"
  instance_count = 1
}

output "dns" {
  value = module.ec2.public_dns
}