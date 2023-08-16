provider "aws" {
  region = "eu-west-2"
}

module "vpc" {
  source  = "./modules/vpc"
  project = var.project
}

module "elb" {
  source                 = "./modules/elb"
  load_balancer_sg       = module.vpc.load_balancer_sg
  load_balancer_subnet_a = module.vpc.load_balancer_subnet_a
  load_balancer_subnet_b = module.vpc.load_balancer_subnet_b
  load_balancer_subnet_c = module.vpc.load_balancer_subnet_c
  vpc                    = module.vpc.vpc
  project                = var.project
}

module "iam" {
  source = "./modules/iam"
  elb    = module.elb.elb
}

module "ecs" {
  source           = "./modules/ecs"
  ecs_role         = module.iam.ecs_role
  ecs_sg           = module.vpc.ecs_sg
  ecs_subnet_a     = module.vpc.ecs_subnet_a
  ecs_subnet_b     = module.vpc.ecs_subnet_b
  ecs_subnet_c     = module.vpc.ecs_subnet_c
  ecs_target_group = module.elb.ecs_target_group
  repository_url = module.ecr.repository_url
  ecr_repository = module.ecr.ecr_repository
  project          = var.project
  }

module "auto_scaling" {
  source      = "./modules/auto-scaling"
  ecs_cluster = module.ecs.ecs_cluster
  ecs_service = module.ecs.ecs_service
}

module "ecr" {
  source                 = "./modules/ecr"
  project                = var.project
}
