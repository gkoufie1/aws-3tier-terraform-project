terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Before first apply: create this S3 bucket and DynamoDB table manually (or via bootstrap script)
  # State paths: envs/<workspace>/3tier/terraform.tfstate
  backend "s3" {
    bucket               = "your-terraform-state-bucket"
    key                  = "3tier/terraform.tfstate"
    region               = "us-east-1"
    dynamodb_table       = "terraform-locks"
    encrypt              = true
    workspace_key_prefix = "envs"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Repository  = "aws-3tier-terraform"
    }
  }
}
