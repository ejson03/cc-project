variable "access_key" {
  description = "Access key of IAM user"
}
variable "secret_key" {
  description = "Secret key of IAM user"
}
provider "aws" {
    region = "ap-south-1"
    access_key = var.access_key
    secret_key = var.secret_key

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

resource "aws_instance" "web-server-instance" {
  ami               = "ami-0b84c6433cdbe5c3e"
  instance_type     = "t2.micro"
  key_name          = var.key_name

  tags = {
    Name = "web-server"
  }
}

# public ip of your aws server
output "server_ip" {
  value = aws_instance.web-server-instance.public_ip
}

output "public_dns" {
  value = aws_instance.web-server-instance.public_dns
}