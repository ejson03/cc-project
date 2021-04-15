terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "vault" {
    address = var.vault_address
    token = var.vault_token
}

resource "vault_aws_secret_backend" "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    path = "${var.name}-path"
    default_lease_ttl_seconds = "1200"
    max_lease_ttl_seconds     = "2400"
}

resource "vault_aws_secret_backend_role" "admin" {
    backend = vault_aws_secret_backend.aws.path
    name = "${var.name}-role"
    credential_type = "iam_user"
    policy_document = file("./policy.json")
}

output "backend" {
  value = vault_aws_secret_backend.aws.path
}

output "role" {
  value = vault_aws_secret_backend_role.admin.name
}