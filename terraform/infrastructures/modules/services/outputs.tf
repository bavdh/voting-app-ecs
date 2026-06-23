output "vote_service_name" {
  value = aws_ecs_service.vote.name
}

output "result_service_name" {
  value = aws_ecs_service.result.name
}

output "worker_service_name" {
  value = aws_ecs_service.worker.name
}
