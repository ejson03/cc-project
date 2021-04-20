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

module "remote" {
  source = "github.com/ejson03/terraform-basic-modules"
}

module "ec2-apache-git" {
  source = "../ec2-git-apache"
}

module "s3" {
  source = "./.terraform/modules/remote/s3"
  bucket_name = "devops-cloud"
}

output "dns" {
  value = module.ec2-apache-git.dns
}
