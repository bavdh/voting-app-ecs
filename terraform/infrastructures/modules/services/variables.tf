variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account" {
  description = "AWs Account"
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "task_execution_role_arn" {
  type = string
}

variable "vote_target_group_arn" {
  type = string
}

variable "result_target_group_arn" {
  type = string
}

variable "redis_endpoint" {
  type = string
}

variable "redis_port" {
  type = number
}

variable "db_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "rds_secret_arn" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "vote_image" {
  type = string
}

variable "result_image" {
  type = string
}

variable "worker_image" {
  type = string
}
