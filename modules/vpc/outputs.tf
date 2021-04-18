output "subnet_id" {
  value = aws_subnet.public_subnet.id
} 

output "vpc_security_group_id" {
  value = aws_security_group.sg.id
} 
