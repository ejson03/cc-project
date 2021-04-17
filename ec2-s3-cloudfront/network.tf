resource "aws_vpc" "project-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "project-vpc"
  }
}

resource "aws_internet_gateway" "project-gateway" {
  vpc_id = aws_vpc.project-vpc.id
}

resource "aws_route_table" "project-route-table" {
  vpc_id = aws_vpc.project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project-gateway.id
  }

  tags = {
    Name = "project-route-table"
  }
}

resource "aws_subnet" "project-subnet" {
  vpc_id            = aws_vpc.project-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "project-subnet"
  }
}

resource "aws_route_table_association" "project-association" {
  subnet_id      = aws_subnet.project-subnet.id
  route_table_id = aws_route_table.project-route-table.id
}

