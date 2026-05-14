output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs (ALB tier)"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs (ECS tier)"
  value       = module.vpc.private_subnets
}

output "database_subnet_ids" {
  description = "List of database subnet IDs (RDS tier)"
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "Name of the RDS DB subnet group"
  value       = module.vpc.database_subnet_group_name
}
