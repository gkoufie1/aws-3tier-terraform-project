output "execution_role_arn" {
  description = "ECS task execution role ARN (used by ECS control plane to pull images and write logs)"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ECS task role ARN (assumed by the running container for application-level AWS calls)"
  value       = aws_iam_role.ecs_task.arn
}
