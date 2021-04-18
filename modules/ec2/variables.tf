variable "instance_type" {
  default = "t2.micro"
}

variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
}

variable "subnet_id" {
}

variable "vpc_security_group_id" {
}

variable "template_file" {
  default = ""
}

variable "create_user_data" {
  default = false
}

