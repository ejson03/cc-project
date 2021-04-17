resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
    depends_on = [
      tls_private_key.ec2_key
    ]
    content = tls_private_key.ec2_key.private_key_pem
    filename = "webserver.pem"
}

resource "aws_key_pair" "ec2_key" {
    depends_on = [
      tls_private_key.ec2_key
    ]
    key_name = "webserver"
    public_key = tls_private_key.ec2_key.public_key_openssh
}