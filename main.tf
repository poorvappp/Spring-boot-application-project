# ─────────────────────────────────────────────────────────────────────────────
# Root module — Spring PetClinic Microservices
#
# Dependency graph:
#   networking ──► eks  ──► cicd
#              └──► rds
# ─────────────────────────────────────────────────────────────────────────────

# ─── MODULE 1: NETWORKING ────────────────────────────────────────────────────
# VPC, public/private/db subnets, IGW, NAT Gateway, route tables,
# and all service-tier security groups.

module "networking" {
  source = "./networking"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  db_subnet_cidrs      = var.db_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
}

# ─── MODULE 2: EKS ───────────────────────────────────────────────────────────
# EKS cluster, three node groups (infra / app / monitoring),
# IAM roles, OIDC provider, and core add-ons.

module "eks" {
  source = "./eks"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  # Networking inputs
  vpc_id               = module.networking.vpc_id
  private_subnet_ids   = module.networking.private_subnet_ids
  public_subnet_ids    = module.networking.public_subnet_ids
  sg_app_services_id   = module.networking.sg_app_services_id
  sg_infra_services_id = module.networking.sg_infra_services_id

  kubernetes_version             = var.kubernetes_version
  cluster_endpoint_public_access = var.cluster_endpoint_public_access

  infra_node_instance_types      = var.infra_node_instance_types
  app_node_instance_types        = var.app_node_instance_types
  monitoring_node_instance_types = var.monitoring_node_instance_types
  app_node_desired               = var.app_node_desired
  app_node_min                   = var.app_node_min
  app_node_max                   = var.app_node_max

}

# ─── MODULE 3: RDS ───────────────────────────────────────────────────────────
# MySQL 8.4 RDS instance, parameter group, per-service Secrets Manager
# secrets for customers, visits, and vets services.

module "rds" {
  source = "./rds"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  # Networking inputs
  vpc_id         = module.networking.vpc_id
  db_subnet_ids  = module.networking.db_subnet_ids
  sg_database_id = module.networking.sg_database_id

  mysql_version            = var.mysql_version
  instance_class           = var.db_instance_class
  multi_az                 = var.db_multi_az
  backup_retention_days    = var.db_backup_retention_days
  deletion_protection      = var.db_deletion_protection
  skip_final_snapshot      = var.db_skip_final_snapshot

}

# ─── MODULE 4: CI/CD ─────────────────────────────────────────────────────────
# ECR repositories, CodeBuild projects, CodePipeline pipelines,
# GitHub CodeStar connection, and S3 artifact bucket.

module "cicd" {
  source = "./cicd"

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  # EKS inputs
  eks_cluster_name  = module.eks.cluster_name
  eks_cluster_arn   = module.eks.cluster_arn
  eks_node_role_arn = module.eks.node_group_role_arn

  github_repo   = var.github_repo
  github_branch = var.github_branch
  image_tag     = var.image_tag

}
