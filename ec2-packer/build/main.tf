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

module "remote" {
  source = "github.com/ejson03/terraform-basic-modules"
}

module "vpc" {
  source      = "./.terraform/modules/remote/vpc"
  vpc_cidr    = "10.0.0.0/16"
  public_cidr = ["10.0.1.0/24"]
  region      = var.region
  subnet_azs  = ["${var.region}a"]
}

resource "null_resource" "packer" {
  provisioner "local-exec" {
    command = "packer build -var subnet_id=${module.vpc.public_subnets.0} vm.pkr.hcl"
  }
}
