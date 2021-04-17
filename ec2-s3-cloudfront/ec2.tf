data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "webserver" {

    depends_on = [
      aws_key_pair.ec2_key,
      aws_security_group.project-allowance
    ]

    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    availability_zone = "ap-south-1a"
    key_name = aws_key_pair.ec2_key.key_name
    subnet_id = aws_subnet.project-subnet.id
    vpc_security_group_ids = [ "${aws_security_group.project-allowance.id}" ]
    associate_public_ip_address = true

    tags = {
        Name = "webserver"
    }

    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install apache2 git -y
        sudo rm -rf /var/www/html
        git clone https://github.com/Darlene-Naz/Darlene-Naz.github.io /var/www/html/
        sudo systemctl restart apache2
        EOF
}

output "public_ip" {
  value = aws_instance.webserver.public_dns
}