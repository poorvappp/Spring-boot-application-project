variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "spring-petclinic"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ─── Source repository ────────────────────────────────────────────────────────

variable "github_repo" {
  description = "GitHub repository in owner/repo format"
  type        = string
  default     = "spring-petclinic/spring-petclinic-microservices"
}

variable "github_branch" {
  description = "Branch to trigger the pipeline on"
  type        = string
  default     = "main"
}

# ─── EKS inputs (from eks module outputs) ────────────────────────────────────

variable "eks_cluster_name" {
  description = "EKS cluster name (from eks module output)"
  type        = string
}

variable "eks_cluster_arn" {
  description = "EKS cluster ARN (from eks module output)"
  type        = string
}

variable "eks_node_role_arn" {
  description = "IAM role ARN used by EKS node groups (from eks module output)"
  type        = string
}

# ─── Build config ─────────────────────────────────────────────────────────────

variable "java_version" {
  description = "Java version for the CodeBuild environment"
  type        = string
  default     = "17"
}

variable "maven_opts" {
  description = "Extra MAVEN_OPTS passed to all CodeBuild builds"
  type        = string
  default     = "-Xmx1536m"
}

variable "image_tag" {
  description = "Docker image tag applied on every build (latest or a semver)"
  type        = string
  default     = "latest"
}

variable "ecr_image_retention_count" {
  description = "Number of images to keep per ECR repository"
  type        = number
  default     = 10
}

# ─── Services ────────────────────────────────────────────────────────────────

variable "services" {
  description = "Map of service key to Maven module directory name"
  type        = map(string)
  default = {
    config-server    = "spring-petclinic-config-server"
    discovery-server = "spring-petclinic-discovery-server"
    api-gateway      = "spring-petclinic-api-gateway"
    customers        = "spring-petclinic-customers-service"
    visits           = "spring-petclinic-visits-service"
    vets             = "spring-petclinic-vets-service"
    genai            = "spring-petclinic-genai-service"
    admin-server     = "spring-petclinic-admin-server"
  }
}
