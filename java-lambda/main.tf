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

module "iam" {
  source = "../modules/iam"
  role_name = "lambda_apigateway_iam_role"
  role_file_name = "lambda_role.json"
  policy_name = "lambda_apigateway"
  policy_file_name = "lambda_policy.json"
}

output "" {
  value = 
}