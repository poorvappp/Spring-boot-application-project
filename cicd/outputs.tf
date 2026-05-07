output "github_connection_arn" {
  description = "CodeStar connection ARN — must be activated manually in the AWS Console before pipelines run"
  value       = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  description = "Status of the GitHub CodeStar connection (PENDING until activated)"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "artifact_bucket_name" {
  description = "S3 bucket used to store pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the pipeline artifact S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "ecr_repository_urls" {
  description = "Map of service name to ECR repository URL"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "ecr_repository_arns" {
  description = "Map of service name to ECR repository ARN"
  value       = { for k, v in aws_ecr_repository.services : k => v.arn }
}

output "codebuild_project_arns" {
  description = "Map of service name to CodeBuild project ARN"
  value       = { for k, v in aws_codebuild_project.services : k => v.arn }
}

output "codepipeline_arns" {
  description = "Map of service name to CodePipeline ARN"
  value       = { for k, v in aws_codepipeline.services : k => v.arn }
}

output "codebuild_role_arn" {
  description = "IAM role ARN used by CodeBuild projects"
  value       = aws_iam_role.codebuild.arn
}

output "codepipeline_role_arn" {
  description = "IAM role ARN used by CodePipeline"
  value       = aws_iam_role.codepipeline.arn
}
