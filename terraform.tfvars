# ─── Global ───────────────────────────────────────────────────────────────────
aws_region   = "eu-north-1"
project_name = "spring-petclinic"
environment  = "dev"

# ─── Networking ───────────────────────────────────────────────────────────────
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-north-1a", "eu-north-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
db_subnet_cidrs      = ["10.0.20.0/24", "10.0.21.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true   # set to false in prod for per-AZ NAT

# ─── EKS ──────────────────────────────────────────────────────────────────────
kubernetes_version             = "1.30"
cluster_endpoint_public_access = true   # set to false in prod
infra_node_instance_types      = ["t3.micro"]
app_node_instance_types        = ["t3.micro"]
monitoring_node_instance_types = ["t3.micro"]
app_node_desired               = 2
app_node_min                   = 2
app_node_max                   = 6

# ─── RDS ──────────────────────────────────────────────────────────────────────
mysql_version            = "8.4.3"
db_instance_class        = "db.t3.micro"   # free tier eligible
db_multi_az              = false   # set to true in prod
db_backup_retention_days = 0   # free tier does not support automated backups
db_deletion_protection   = false   # set to true in prod
db_skip_final_snapshot   = true    # set to false in prod

# ─── CI/CD ────────────────────────────────────────────────────────────────────
github_repo   = "spring-petclinic/spring-petclinic-microservices"
github_branch = "main"
image_tag     = "latest"
