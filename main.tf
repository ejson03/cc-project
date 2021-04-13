provider "aws" {
    region = "ap-south-1"
    access_key = "AKIARH2WA5IAB4HVQMVQ"
    secret_key = "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"

}

variable "ssh_user" {
  description = "SSH user of EC2 instance"
}

variable "key_name" {
  description = "Name of key specified"
}

variable "private_key_path" {
  description = "Path to pem file"
}

resource "aws_vpc" "project-vpc" { 
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "project"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.project-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"

    tags = {
        Name = "subnet"
    }
}

resource "aws_security_group" "server_security" {
    name = "server_security"
    vpc_id = aws_vpc.project-vpc.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { 
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "server_security"
    }
}

resource "aws_instance" "web-server-instance" {
  ami               = "ami-0b84c6433cdbe5c3e"
  subnet_id         = aws_subnet.subnet-1.id
  instance_type     = "t2.micro"
  associate_public_ip_address = true
  availability_zone = "ap-south-1a"
  key_name          = var.key_name
  security_groups = [ aws_security_group.server_security.id]

  tags = {
    Name = "web-server"
  }
}

output "server_ip" {
  value = aws_instance.web-server-instance.public_ip
}