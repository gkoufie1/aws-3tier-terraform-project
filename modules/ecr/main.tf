resource "aws_ecr_repository" "app" {
  name                 = "${var.app_name}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  # dev is destroyed/recreated on demand for interview demos — force_delete
  # lets that work even with images still in the repo. prod keeps the safety
  # net (matches deletion_protection on the ALB/RDS for this environment).
  force_delete = var.environment != "prod"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Retain only the 10 most recent images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}
