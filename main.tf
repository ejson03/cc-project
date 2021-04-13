variable "access_key" {
  description = "Access key of IAM user"
}
variable "secret_key" {
  description = "Secret key of IAM user"
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

provider "aws" {
    region = "ap-south-1"
    access_key = var.access_key
    secret_key = var.secret_key
}

# 1. Create VPC
resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "project-gateway" {
  vpc_id = aws_vpc.project-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "project-route-table" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project-gateway.id
  }

  tags = {
    Name = "project-route-table"
  }
}

# 4. Create a subnet
resource "aws_subnet" "project-subnet" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "project-subnet"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "project-association" {
  subnet_id      = aws_subnet.project-subnet.id
  route_table_id = aws_route_table.project-route-table.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "project-allowance" {
  name        = "project_allowance_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.project-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
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

  tags = {
    Name = "project-allowance"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "project-nic" {
  subnet_id       = aws_subnet.project-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.project-allowance.id]

}
# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "project-elastic-ip" {
  vpc                       = true
  network_interface         = aws_network_interface.project-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.project-gateway]
}

# 9. Create Ubuntu server 
resource "aws_instance" "project-instance" {
  ami               = "ami-0b84c6433cdbe5c3e"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = var.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.project-nic.id
  }

 provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
        type        = "ssh"
        user        = var.ssh_user
        private_key = file(var.private_key_path)
        host        = aws_instance.project-instance.public_ip
    }
}
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.project-instance.public_ip}, --private-key ${var.private_key_path} nginx.yaml"
  }
  
  tags = {
    Name = "project-instance"
  }
}

# resource "aws_instance" "web-server-instance" {
#   ami               = "ami-0b84c6433cdbe5c3e"
#   instance_type     = "t2.micro"
#   key_name          = var.key_name

#   tags = {
#     Name = "web-server"
#   }
# }

# public ip of your aws server
output "server_ip" {
  value = aws_instance.project-instance.public_ip
}

output "public_dns" {
  value = aws_instance.project-instance.public_dns
}