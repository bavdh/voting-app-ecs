
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

  allowed_security_group_id = module.ecs.instance_security_group_id

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

  allowed_security_group_id = module.ecs.instance_security_group_id

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

module "alb" {
  source = "./modules/alb"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  vpc_id                         = module.vpc.vpc_id
  public_subnet_ids              = module.vpc.public_subnet_ids
  private_subnet_ids             = module.vpc.private_subnet_ids
  ecs_instance_security_group_id = module.ecs.instance_security_group_id
}

locals {
  ecr_base = "${var.aws_account}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

module "services" {
  source = "./modules/services"

  aws_account  = var.aws_account
  aws_region   = var.aws_region
  project_name = var.project_name

  ecs_cluster_id          = module.ecs.cluster_id
  capacity_provider_name  = module.ecs.capacity_provider_name
  task_execution_role_arn = module.ecs.task_execution_role_arn
  vote_target_group_arn   = module.alb.vote_target_group_arn
  result_target_group_arn = module.alb.result_target_group_arn
  redis_endpoint          = module.elasticache.endpoint
  redis_port              = module.elasticache.port
  db_endpoint             = module.rds.endpoint
  db_name                 = module.rds.db_name
  db_username             = "postgres"
  rds_secret_arn          = module.rds.master_user_secret_arn

  # manually given the image tag for now. This should be handled other ways
  vote_image   = "${local.ecr_base}/voting-app/vote:v1.0"
  result_image = "${local.ecr_base}/voting-app/result:v1.0"
  worker_image = "${local.ecr_base}/voting-app/worker:v1.0"
}
