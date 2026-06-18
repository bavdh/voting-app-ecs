variable "aws_account" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Projct name"
  type        = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "allowed_security_group_ids" {
  description = "SGs allowed to reach Postgres on 5432 (e.g. the ECS instance SG)"
  type        = list(string)
  default     = []
}


variable "engine_version" {
  type    = string
  default = "16" # major-version only; Terraform/AWS resolve to the latest minor
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "postgres"
}

variable "master_username" {
  type    = string
  default = "postgres"
}
