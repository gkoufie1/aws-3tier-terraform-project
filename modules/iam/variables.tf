variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials — scopes the secretsmanager:GetSecretValue policy"
  type        = string
}
