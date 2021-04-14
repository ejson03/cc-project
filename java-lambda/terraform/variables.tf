variable "access_key" {
  description = "Access key of IAM user"
}
variable "secret_key" {
  description = "Secret key of IAM user"
}

variable "region" {}

variable "account_id" {}

variable "lambda_payload_filename" {
  default = "../target/java-lambda-1.0-SNAPSHOT.jar"
}

variable "lambda_function_handler" {
  default = "com.elvis.devops.Handler"
}

variable "lambda_runtime" {
  default = "java8"
}

