
module "ecr" {
  source = "./modules/ecr"

  aws_account = var.aws_account
  aws_region  = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  vpc_cidr = "10.0.0.0/16"
  az_count = 2
}

module "rds" {
  source = "./modules/rds"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  db_name           = "postgres"
  master_username   = "postgres"
  instance_class    = "db.t4g.micro"
  engine_version    = "18.3"
  allocated_storage = 20

  allowed_security_group_ids = [module.ecs.instance_security_group_id]

}

module "elasticache" {
  source = "./modules/elasticache"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_type      = "cache.t4g.micro" # for demo
  engine_version = "7.1"

  allowed_security_group_ids = [module.ecs.instance_security_group_id]

}

module "ecs" {
  source = "./modules/ecs"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_type    = "t3.micro"
  min_size         = 2
  max_size         = 2
  desired_capacity = 2
}
