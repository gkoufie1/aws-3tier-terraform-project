variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for CloudWatch log group"
  type        = string
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
}

variable "container_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "app_count" {
  description = "Desired number of running ECS tasks"
  type        = number
  default     = 1
}

variable "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS task execution role ARN (pulls image, writes logs)"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN (application-level AWS permissions)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN to register tasks with"
  type        = string
}

variable "db_secret_arn" {
  description = "Secrets Manager ARN for DB credentials (passed to container as env var)"
  type        = string
}
