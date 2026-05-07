# ─── NETWORKING ──────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private app subnets"
  value       = module.networking.private_subnet_ids
}

output "db_subnet_ids" {
  description = "IDs of the isolated database subnets"
  value       = module.networking.db_subnet_ids
}

# ─── EKS ─────────────────────────────────────────────────────────────────────

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA service account bindings"
  value       = module.eks.oidc_provider_arn
}

output "kubeconfig_command" {
  description = "Run this command to configure kubectl for the cluster"
  value       = module.eks.kubeconfig_command
}

# ─── RDS ─────────────────────────────────────────────────────────────────────

output "db_endpoint" {
  description = "RDS connection endpoint (host:port)"
  value       = module.rds.db_endpoint
}

output "db_address" {
  description = "RDS hostname"
  value       = module.rds.db_address
}

output "db_secret_arns" {
  description = "Secrets Manager ARNs for each service's database credentials"
  value       = module.rds.secret_arns
}

output "customers_secret_arn" {
  description = "Secrets Manager ARN for customers-service DB credentials"
  value       = module.rds.customers_secret_arn
}

output "visits_secret_arn" {
  description = "Secrets Manager ARN for visits-service DB credentials"
  value       = module.rds.visits_secret_arn
}

output "vets_secret_arn" {
  description = "Secrets Manager ARN for vets-service DB credentials"
  value       = module.rds.vets_secret_arn
}

# ─── CI/CD ───────────────────────────────────────────────────────────────────

output "ecr_repository_urls" {
  description = "ECR repository URLs keyed by service name"
  value       = module.cicd.ecr_repository_urls
}

output "artifact_bucket_name" {
  description = "S3 bucket storing CodePipeline artifacts"
  value       = module.cicd.artifact_bucket_name
}

output "github_connection_arn" {
  description = "CodeStar GitHub connection ARN — activate manually in AWS Console before first run"
  value       = module.cicd.github_connection_arn
}

output "github_connection_status" {
  description = "Status of the GitHub CodeStar connection (PENDING until activated)"
  value       = module.cicd.github_connection_status
}

output "codepipeline_arns" {
  description = "CodePipeline ARNs keyed by service name"
  value       = module.cicd.codepipeline_arns
}
