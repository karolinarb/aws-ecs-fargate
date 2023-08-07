# VPC in which containers will be networked.
  # It has two public subnets, and two private subnets.
  # We distribute the subnets across the first two available subnets
  # for the region, for high availability.

resource "aws_vpc" "ecr_fargate" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.project
  }
}
  
resource "aws_subnet" "public_one" {
  vpc_id     = aws_vpc.ecr_fargate.id
  cidr_block = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"

  tags = {
    Name = var.project
  }
}

resource "aws_subnet" "public_two" {
  vpc_id     = aws_vpc.ecr_fargate.id
  cidr_block = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"

  tags = {
    Name = var.project
  }
}

resource "aws_subnet" "private_one" {
  vpc_id     = aws_vpc.ecr_fargate.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = var.project
  }
}

resource "aws_subnet" "private_two" {
  vpc_id     = aws_vpc.ecr_fargate.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = var.project
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecr_fargate.id

  tags = {
    Name = var.project
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_one.id

  tags = {
    Name = var.project
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "nat_route_table" {
  vpc_id = aws_vpc.ecr_fargate.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = var.project
  }
}

resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.ecr_fargate.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.project
  }
}

resource "aws_route_table_association" "internet_route_table_association_public_one" {
  subnet_id      = aws_subnet.public_one.id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_route_table_association" "internet_route_table_association_public_two" {
  subnet_id      = aws_subnet.public_two.id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_route_table_association" "nat_route_table_association_private_one" {
  subnet_id      = aws_subnet.private_one.id
  route_table_id = aws_route_table.nat_route_table.id
}

resource "aws_route_table_association" "nat_route_table_association_private_two" {
  subnet_id      = aws_subnet.private_two.id
  route_table_id = aws_route_table.nat_route_table.id
}