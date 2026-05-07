terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "petclinic-tfstate"
  #   key            = "cicd/terraform.tfstate"
  #   region         = "eu-north-1"
  #   dynamodb_table = "petclinic-tfstate-lock"
  #   encrypt        = true
  # }
}

