variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_account" {
  description = "AWs Account"
  type        = string
  default     = "653236170203"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "voting-app"
}

variable "vote_image_tag" {
  description = "Vote image tag"
  type        = string
  default     = "a8c07e2cb05b3cdf8a95cc3b0345e1610cf93325"
}

variable "worker_image_tag" {
  description = "Worker image tag"
  type        = string
  default     = "a8c07e2cb05b3cdf8a95cc3b0345e1610cf93325"
}

variable "result_image_tag" {
  description = "Result image tag"
  type        = string
  default     = "a8c07e2cb05b3cdf8a95cc3b0345e1610cf93325"
}
