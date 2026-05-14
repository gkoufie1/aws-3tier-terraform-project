module "vpc" {
  source = "./modules/vpc"

  app_name    = var.app_name
  environment = terraform.workspace
}

module "security_groups" {
  source = "./modules/security_groups"

  app_name       = var.app_name
  environment    = terraform.workspace
  vpc_id         = module.vpc.vpc_id
  container_port = var.container_port
}

module "ecr" {
  source = "./modules/ecr"

  app_name    = var.app_name
  environment = terraform.workspace
}

module "rds" {
  source = "./modules/rds"

  app_name                   = var.app_name
  environment                = terraform.workspace
  db_name                    = var.db_name
  database_subnet_group_name = module.vpc.database_subnet_group_name
  rds_sg_id                  = module.security_groups.rds_sg_id
}

module "iam" {
  source = "./modules/iam"

  app_name      = var.app_name
  environment   = terraform.workspace
  db_secret_arn = module.rds.secret_arn
}

module "alb" {
  source = "./modules/alb"

  app_name          = var.app_name
  environment       = terraform.workspace
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  container_port    = var.container_port
}

module "ecs" {
  source = "./modules/ecs"

  app_name           = var.app_name
  environment        = terraform.workspace
  aws_region         = var.aws_region
  container_port     = var.container_port
  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  app_count          = var.app_count
  ecr_repository_url = module.ecr.repository_url
  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_sg_id          = module.security_groups.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  db_secret_arn      = module.rds.secret_arn
}
