# ─── GITHUB CONNECTION (CodeStar) ────────────────────────────────────────────
# After terraform apply, activate this connection manually in the AWS Console:
# Developer Tools → Settings → Connections

resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name_prefix}-github"
  provider_type = "GitHub"

  tags = {
    Name = "${local.name_prefix}-github-connection"
  }
}

# ─── S3 ARTIFACT BUCKET ──────────────────────────────────────────────────────

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-cicd-artifacts-${local.account_id}"
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-cicd-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "expire-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# ─── CODEPIPELINE (one pipeline per service) ──────────────────────────────────

resource "aws_codepipeline" "services" {
  for_each = var.services

  name     = "${local.name_prefix}-pipeline-${each.key}"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  # Stage 1 — Source: pull from GitHub on push to the target branch
  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn        = aws_codestarconnections_connection.github.arn
        FullRepositoryId     = var.github_repo
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = "true"
      }
    }
  }

  # Stage 2 — Build: Maven build → Docker build → ECR push → kubectl rollout
  stage {
    name = "Build_and_Deploy"

    action {
      name             = "Build_${each.key}"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output_${each.key}"]

      configuration = {
        ProjectName = aws_codebuild_project.services[each.key].name
      }
    }
  }

  tags = {
    Name    = "${local.name_prefix}-pipeline-${each.key}"
    Service = each.key
  }
}
