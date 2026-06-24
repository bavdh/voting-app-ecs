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
  default     = "0bc2ac38f1210a89e6ee873ccb406c2bd1683871"
}

variable "worker_image_tag" {
  description = "Worker image tag"
  type        = string
  default     = "0bc2ac38f1210a89e6ee873ccb406c2bd1683871"
}

variable "result_image_tag" {
  description = "Result image tag"
  type        = string
  default     = "0bc2ac38f1210a89e6ee873ccb406c2bd1683871"
}
