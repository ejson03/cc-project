locals {
  environment = "default"
  aws_region  = "ap-south-1"
}

resource "random_password" "random" {
  length = 28
}

module "vpc" {
  source = "git::https://github.com/philips-software/terraform-aws-vpc.git?ref=2.2.0"

  environment                = local.environment
  aws_region                 = local.aws_region
  availability_zones        = ["ap-south-1a"]
  create_private_hosted_zone = false
}

module "github-runner" {
  source  = "philips-labs/github-runner/aws"
  version = "0.1.0"

  aws_region = local.aws_region
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  environment = local.environment
  tags = {
    Project = "ProjectX"
  }

  github_app = {
    key_base64     = var.github_app_key_base64
    id             = var.github_app_id
    client_id      = var.github_app_client_id
    client_secret  = var.github_app_client_secret
    webhook_secret = random_password.random.result
  }

  webhook_lambda_zip                = "lambdas-download/webhook.zip"
  runner_binaries_syncer_lambda_zip = "lambdas-download/runner-binaries-syncer.zip"
  runners_lambda_zip                = "lambdas-download/runners.zip"
  enable_organization_runners       = false
  runner_extra_labels               = "default,example"

  # enable access to the runners via SSM
  enable_ssm_on_runners = true
}