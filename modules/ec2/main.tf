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

data "template_file" "init" {
  count = var.create_user_data ? 1 : 0
  template = file(var.template_file)
}

resource "aws_instance" "webserver" {

    ami           = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    availability_zone = "${var.region}a"
    key_name = var.key_name 
    subnet_id = var.subnet_id 
    vpc_security_group_ids = [ var.vpc_security_group_id ] 
    associate_public_ip_address = true

    tags = {
        Name = "webserver"
    }

    user_data = var.create_user_data ? data.template_file.init.*.rendered[0] : ""
}