variable "vault_address" {}
variable "vault_token" {}
variable "name" { default = "dynamic-aws-creds-operator" }
variable "region" { default = "ap-south-1" }
variable "path" { default = "../admin/terraform.tfstate" }
variable "ttl" { default = "1" }