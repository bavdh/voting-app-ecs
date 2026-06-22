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

variable "allowed_security_group_ids" {
  description = "SGs allowed to reach Redis on 6379 (e.g. the ECS instance SG)"
  type        = string
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "engine_version" {
  type    = string
  default = "7.1"
}
