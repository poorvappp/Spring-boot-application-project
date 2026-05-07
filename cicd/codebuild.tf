# ─── CODEBUILD PROJECTS (one per service) ────────────────────────────────────

resource "aws_codebuild_project" "services" {
  for_each = var.services

  name          = "${local.name_prefix}-build-${each.key}"
  description   = "Build and push ${each.key} Docker image to ECR"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 20

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.artifacts.bucket}/maven-cache/${each.key}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "ECR_REPO_URI"
      value = aws_ecr_repository.services[each.key].repository_url
    }

    environment_variable {
      name  = "SERVICE_MODULE"
      value = each.value
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = var.image_tag
    }

    environment_variable {
      name  = "MAVEN_OPTS"
      value = var.maven_opts
    }

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec.yml.tpl", {
      service_module = each.value
    })
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${local.name_prefix}"
      stream_name = each.key
    }
  }

  tags = {
    Name    = "${local.name_prefix}-build-${each.key}"
    Service = each.key
  }
}

# ─── CLOUDWATCH LOG GROUP ─────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${local.name_prefix}"
  retention_in_days = 14

  tags = {
    Name = "${local.name_prefix}-codebuild-logs"
  }
}
