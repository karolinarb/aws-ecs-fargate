resource "aws_lb" "mythicalmysfits" {
  name               = "alb-mythicalmysfits"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mythicalmysfits_lb_sg.id]
  subnets            = [aws_subnet.public_one.id, aws_subnet.public_two.id]

  tags = {
    name = var.project
  }
}

resource "aws_lb_target_group" "mythicalmysfits" {
  name     = "ALBtargetgroupmythicalmysfits"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecr_fargate.id
  target_type = "ip"
  health_check {
      protocol = "HTTP"
      healthy_threshold = 3
      unhealthy_threshold = 3
      interval = 10
      path = "/"
  }
}

resource "aws_lb_listener" "mythicalmysfits" {
  load_balancer_arn = aws_lb.mythicalmysfits.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mythicalmysfits.arn
  }
}


resource "aws_security_group" "mythicalmysfits_lb_sg" {
    name        = "sg_mythicalmysfits_lb_sg"
    description = "Allow access to ALB from anywhere on the internet"
    vpc_id      = aws_vpc.ecr_fargate.id

    ingress {
        description      = "Access to the load balancer from internet"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [aws_vpc.ecr_fargate.cidr_block]
    }
    tags = {
        Name = var.project
    }
}