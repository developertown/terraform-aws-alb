output "security_groups" {
  value = [one(aws_security_group.alb[*].id)]
}

output "target_group_arn" {
  value = one(aws_alb_target_group.alb[*].id)
}

output "load_balancer_arn" {
  value = one(aws_lb.alb[*].id)
}

output "http_listener_arn" {
  value = one(aws_alb_listener.http[*].arn)
}

output "https_listener_arn" {
  value = one(aws_alb_listener.https[*].arn)
}