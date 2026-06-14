
module "ecr" {
  source = "./modules/ecr"

  aws_account = var.aws_account
  aws_region  = var.aws_region
}
