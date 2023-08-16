output "elb" {
  value = aws_lb.elb
}

output "ecs_target_group" {
  value = aws_lb_target_group.ecs
}

output "dns_name" {
  value = aws_lb.elb.dns_name
}