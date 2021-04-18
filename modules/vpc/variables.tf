variable "region" {
  default = "ap-south-1"
}
variable "public_cidr" {}
variable "private_cidr" {
  default = ""
}
variable "vpc_cidr" {
}
variable "create_private"{
  default = false
}