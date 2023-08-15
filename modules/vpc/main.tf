resource "aws_vpc" "vpc" {
  cidr_block = "192.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Project = var.project
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "elb_a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "elb-a"
    Project = var.project
  }
}

resource "aws_subnet" "elb_b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "elb-b"
    Project = var.project
  }
}

resource "aws_subnet" "elb_c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "elb-c"
    Project = var.project
  }
}

resource "aws_subnet" "ecs_a" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-a"
    Project = var.project
  }
}

resource "aws_subnet" "ecs_b" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-b"
    Project = var.project
  }
}

resource "aws_subnet" "ecs_c" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.0.5.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "ecs-c"
    Project = var.project
  }
}

### GATEWAYS

resource "aws_internet_gateway" "internal_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dev-to"
    Project = var.project
    Billing = var.project
  }
}

resource "aws_route_table" "internet_gateway_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internal_gateway.id
  }

  tags = {
    Name = "dev-to"
    Project = var.project
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

#All your public subnets must route to an Internet Gateway
# for non-local addresses. This is what makes the subnet public. 
#The NAT Gateway needs to be deployed into one of these public 
#subnets so it has access to the internet.

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.elb_a.id

  tags = {
    Project = var.project
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.internal_gateway]
}

resource "aws_route_table" "nat_gateway_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Project = var.project
  }
}


#ECS subnets have a route to the internet using the NAt gateway we created. 
#The benefit of a NAT Gateway is they only allow outbound access. 
#In this case outbound access is all we need to get access to DockerHub.

resource "aws_route_table_association" "elb_a" {
  subnet_id = aws_subnet.elb_a.id
  route_table_id = aws_route_table.internet_gateway_route_table.id
}

resource "aws_route_table_association" "elb_b" {
  subnet_id = aws_subnet.elb_b.id
  route_table_id = aws_route_table.internet_gateway_route_table.id
}

resource "aws_route_table_association" "elb_c" {
  subnet_id = aws_subnet.elb_c.id
  route_table_id = aws_route_table.internet_gateway_route_table.id
}

resource "aws_route_table_association" "ecs_a" {
  subnet_id = aws_subnet.ecs_a.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

resource "aws_route_table_association" "ecs_b" {
  subnet_id = aws_subnet.ecs_b.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

resource "aws_route_table_association" "ecs_c" {
  subnet_id = aws_subnet.ecs_c.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}


### SECURITY GROUPS
resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "load-balancer"
    Project = var.project
  }
}

resource "aws_security_group" "ecs_task" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "ecs-task"
    Project = var.project
  }
}

resource "aws_security_group_rule" "ingress_load_balancer_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  to_port = 80
  cidr_blocks = [
    "0.0.0.0/0"]
  type = "ingress"
}

resource "aws_security_group_rule" "ingress_ecs_task_elb" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.ecs_task.id
  to_port = 80
  source_security_group_id = aws_security_group.load_balancer.id
  type = "ingress"
}

resource "aws_security_group_rule" "egress_load_balancer" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "egress_ecs_task" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}

