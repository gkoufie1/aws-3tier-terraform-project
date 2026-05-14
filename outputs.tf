output "environment" {
  description = "Active Terraform workspace / environment"
  value       = terraform.workspace
}

output "alb_dns_name" {
  description = "Application entry point — paste into a browser or curl"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "Tag and push your Docker image here before the first ECS deploy"
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for container stdout/stderr"
  value       = module.ecs.log_group_name
}

output "db_cluster_endpoint" {
  description = "Aurora writer endpoint (internal — not exposed publicly)"
  value       = module.rds.cluster_endpoint
}

output "db_secret_arn" {
  description = "Secrets Manager ARN — contains JSON with host/port/dbname/username/password"
  value       = module.rds.secret_arn
  sensitive   = true
}
