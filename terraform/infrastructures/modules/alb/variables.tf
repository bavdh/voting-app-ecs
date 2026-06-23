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

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ecs_instance_security_group_id" {
  type = string
}
