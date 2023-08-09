# create a new VPC 
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "DEV VPC"
  }
}
# create a new subnet
resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"
  tags = {
    Name = "DEV SUBNET"
  }
}
# create an internet gateway for the VPC
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "DEV IGW"
  }
}
# Create a routing table
resource "aws_route_table" "dev_routing_table" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "DEV Routing Table"
  }
}
resource "aws_route" "dev_default_route" {
  route_table_id         = aws_route_table.dev_routing_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_igw.id
}
resource "aws_route_table_association" "dev_route_asoc" {
  route_table_id = aws_route_table.dev_routing_table.id
  subnet_id      = aws_subnet.dev_subnet.id
}

# create a new security group
resource "aws_security_group" "dev_sg" {
  name        = "DEV Security Group"
  description = "Allow all egress, Allow ingress ssh form specific IPs"
  vpc_id      = aws_vpc.dev_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.dev_addrs[0]}"]
  }
}
