terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
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
  source = "../modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  public_cidr = "10.0.1.0/24"
  region = var.region
}

resource "aws_instance" "project-instance" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = "t2.micro"
  availability_zone = "${var.region}a"
  key_name          = aws_key_pair.ec2_key.key_name
  subnet_id = module.vpc.subnet_id 
  vpc_security_group_ids = [  module.vpc.vpc_security_group_id ] 
  associate_public_ip_address = true



 provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file(local_file.private_key.filename)
        host        = aws_instance.project-instance.public_ip
    }
}
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.project-instance.public_ip}, --private-key ${local_file.private_key.filename} ansible/nginx.yaml"
  }
  
  tags = {
    Name = "project-instance"
  }
}

output "public_dns" {
  value = aws_instance.project-instance.public_dns
}