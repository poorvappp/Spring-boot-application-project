data "aws_caller_identity" "current" {}

locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  account_id   = data.aws_caller_identity.current.account_id
  ecr_base_url = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

# ─── ECR REPOSITORIES (one per service) ──────────────────────────────────────

resource "aws_ecr_repository" "services" {
  for_each = var.services

  name                 = "${local.name_prefix}/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  }
}

# ─── LIFECYCLE POLICY (keep last N images, expire untagged after 1 day) ──────

resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the last ${var.ecr_image_retention_count} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "latest"]
          countType     = "imageCountMoreThan"
          countNumber   = var.ecr_image_retention_count
        }
        action = { type = "expire" }
      }
    ]
  })
}

# ─── ECR REPOSITORY POLICY (allow EKS node role to pull) ─────────────────────

resource "aws_ecr_repository_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEKSNodePull"
        Effect = "Allow"
        Principal = {
          AWS = var.eks_node_role_arn
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}
