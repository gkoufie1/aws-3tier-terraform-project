variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "adminuser"
}

variable "database_subnet_group_name" {
  description = "Name of the DB subnet group (from VPC module)"
  type        = string
}

variable "rds_sg_id" {
  description = "Security group ID for the Aurora cluster"
  type        = string
}

variable "instance_count" {
  description = "Number of Aurora cluster instances"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "Aurora instance class"
  type        = string
  default     = "db.t3.medium"
}
