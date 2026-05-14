module "vpc" {
  source = "./modules/vpc"

  environment = terraform.workspace
}

module "alb" {
  source = "./modules/alb"
}

module "ecs" {
  source = "./modules/ecs"
}

module "rds" {
  source = "./modules/rds"
}

module "iam" {
  source = "./modules/iam"
}
