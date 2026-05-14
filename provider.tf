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

  # State paths: envs/<workspace>/3tier/terraform.tfstate
  # use_lockfile replaces dynamodb_table (deprecated in Terraform 1.10+) — uses S3 conditional writes
  backend "s3" {
    bucket               = "kwe3tier"
    key                  = "3tier/terraform.tfstate"
    region               = "eu-west-2"
    encrypt              = true
    workspace_key_prefix = "envs"
    use_lockfile         = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy  = "Terraform"
      Repository = "aws-3tier-terraform"
    }
  }
}
