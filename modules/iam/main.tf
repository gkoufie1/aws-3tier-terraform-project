data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# --- ECS Task Execution Role ---
# Used by the ECS control plane: pull ECR images, push CloudWatch logs, read secrets at task start
resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.app_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_managed" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_execution_secrets" {
  name        = "${var.app_name}-${var.environment}-execution-secrets-policy"
  description = "Allow ECS execution role to retrieve DB credentials at container start"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadDbSecret"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.db_secret_arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_execution_secrets.arn
}

# --- ECS Task Role ---
# Assumed by the running container — least-privilege application permissions
resource "aws_iam_role" "ecs_task" {
  name               = "${var.app_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_iam_policy" "ecs_task_app" {
  name        = "${var.app_name}-${var.environment}-task-app-policy"
  description = "Application-level permissions: read DB secret at runtime"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadDbSecret"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [var.db_secret_arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_app" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_app.arn
}
