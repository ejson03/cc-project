locals {
    app_name="nginx"
}
variable "subnet_id" {
    type = string
}

source "amazon-ebs" "nginx"{
    profile = "devops-cloud"
    ami_name = "packer-${local.app_name}"
    instance_type = "t2.micro"
    region = "ap-south-1"
    subnet_id = var.subnet_id
    source_ami_filter {
        filters = {
            name = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
            root-device-type = "ebs"
            virtualization-type = "hvm" 
        }
        most_recent = true
        owners = ["099720109477"]
    }
    ssh_username = "ubuntu"
    associate_public_ip_address = true
    tags = {
        Name = "packer-nginx"
    }
}

build {
    sources = ["source.amazon-ebs.nginx"]

    provisioner "ansible" {
        playbook_file = "./ansible/deploy.yaml"
    }
}