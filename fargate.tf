 # The security group for our service containers to be hosted in Fargate.
  # Even though traffic from users will pass through a Network Load Balancer,
  # that traffic is purely TCP passthrough, without security group inspection.
  # Therefore, we will allow for traffic from the Internet to be accepted by our
  # containers.  But, because the containers will only have Private IP addresses,
  # the only traffic that will reach the containers is traffic that is routed
  # to them by the public load balancer on the specific ports that we configure.

resource "aws_security_group" "fargate" {
  name        = "allow_tls"
  description = "Access to the fargate containers from the Internet"
  vpc_id      = aws_vpc.ecr_fargate.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project
  }
}