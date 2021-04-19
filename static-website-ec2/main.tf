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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "vpc" {
  source      = "../../terraform-basic-modules/vpc"
  vpc_cidr    = "10.0.0.0/16"
  public_cidr = ["10.0.1.0/24"]
  region      = var.region
  subnet_azs  = ["${var.region}a"]
}

module "security-group" {
  source = "../../terraform-basic-modules/security-group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "../../terraform-basic-modules/ec2"
  instance_type = "t2.micro"
  region = var.region
  subnets = module.vpc.public_subnets
  vpc_security_group_id = module.security-group.security_group_id
  key_name = aws_key_pair.ec2_key.key_name
  instance_count = 1
}

resource "null_resource" "provison" {

  count = var.if_provisioner ? 1 : 0
  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.private_key.filename)
      host        = module.ec2.public_ip.0
    }
  }
}

# resource "null_resource" "ansible" {
#   count = var.if_provisioner ? 1 : 0
#   provisioner "local-exec" {
#     command = "ansible-playbook  -i ${aws_instance.project-instance.public_ip}, --private-key ${local_file.private_key.filename} ansible/deploy.yaml"
#   }
# }

# output "public_dns" {
#   value = aws_instance.project-instance.public_dns
# }