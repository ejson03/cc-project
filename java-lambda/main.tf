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

module "iam" {
  source = "./.terraform/modules/remote/iam"
  role_name = "lambda_apigateway_iam_role"
  role_file_name = "lambda_role.json"
  policy_name = "lambda_apigateway"
  policy_file_name = "lambda_policy.json"
}

module "lambda" {
  source = "./.terraform/modules/remote/lambda"
  lambda_payload_filename = var.lambda_payload_filename
  lambda_function_handler = var.lambda_function_handler
  lambda_runtime = var.lambda_runtime 
  lambda_role = module.iam.arn
  lambda_grant_permission = true
  lambda_statement_id = "AllowExceutionFromApiGateway"
  lambda_principal = "apigateway.amazonaws.com"
  lambda_source_arn = "${aws_api_gateway_rest_api.handler_api.execution_arn}/*/*"
}

