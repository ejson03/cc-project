resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "project-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "project-gw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "project-route-table"
  }
}

resource "aws_default_route_table" "private_route" {
    count = var.create_private ? 1 : 0
    default_route_table_id = aws_vpc.main.default_route_table_id
    route {
        nat_gateway_id = aws_nat_gateway.ngw[count.index]
        cidr_block = "0.0.0.0/0"
    }
    tags = {
        Name = "private-project-route-table"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "project-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  count = var.create_private ? 1 : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr
  availability_zone = "${var.region}a"
  tags = {
    Name = "private-project-subnet"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "private_association" {
  count = var.create_private ? 1 : 0
  subnet_id      = aws_subnet.private_subnet[count.index]
  route_table_id = aws_default_route_table.private_route[count.index]
}

resource "aws_security_group" "sg" {
  name        = "project_allowance_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "project-allowance"
  }
}

resource "aws_eip" "eip" {
    vpc = true
}

resource "aws_nat_gateway" "ngw" {
    count = var.create_private ? 1 : 0
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.public_subnet
}

