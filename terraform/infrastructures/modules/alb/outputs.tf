output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "vote_target_group_arn" {
  value = aws_lb_target_group.vote.arn
}

output "result_target_group_arn" {
  value = aws_lb_target_group.result.arn
}

output "security_group_id" {
  value = aws_security_group.alb.id
}
