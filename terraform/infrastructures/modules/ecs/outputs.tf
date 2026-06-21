output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.main.name
}

output "instance_security_group_id" {
  value = aws_security_group.ecs_instances.id
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
