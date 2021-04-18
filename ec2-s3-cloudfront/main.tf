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

module "ec2-apache-git" {
  source = "../ec2-git-apache"
}

module "s3" {
  source = "../modules/s3"
  bucket_name = "devops-cloud"
}

output "dns" {
  value = module.ec2-apache-git.dns
}
