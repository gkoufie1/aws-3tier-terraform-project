variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "app_name" {
  description = "Application name — used as a prefix for all resource names"
  type        = string
  default     = "threetier"
}

variable "container_port" {
  description = "Port the Node.js container listens on"
  type        = number
  default     = 3000
}

variable "container_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)"
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

variable "db_name" {
  description = "Initial Aurora database name"
  type        = string
  default     = "appdb"
}
