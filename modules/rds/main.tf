resource "random_password" "master" {
  length           = 24
  special          = true
  override_special = "!#$%&*-_=+?"
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.app_name}-${var.environment}-db-credentials"

  # Immediate deletion in non-prod; 30-day recovery window in prod
  recovery_window_in_days = var.environment == "prod" ? 30 : 0

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "${var.app_name}-${var.environment}-aurora"
  engine                 = "aurora-postgresql"
  engine_version         = "15.4"
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = random_password.master.result
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  storage_encrypted      = true
  backup_retention_period = var.environment == "prod" ? 7 : 1

  skip_final_snapshot       = var.environment != "prod"
  final_snapshot_identifier = "${var.app_name}-${var.environment}-final"
  deletion_protection       = var.environment == "prod" ? true : false

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_rds_cluster_instance" "aurora" {
  count              = var.instance_count
  identifier         = "${var.app_name}-${var.environment}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version

  tags = {
    Environment = var.environment
    Application = var.app_name
  }
}

# Stored as JSON so the app can parse a single secret for all connection params
resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    host     = aws_rds_cluster.aurora.endpoint
    port     = 5432
    dbname   = var.db_name
  })
}
