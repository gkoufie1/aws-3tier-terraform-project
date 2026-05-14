resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "aurora-cluster-demo"
  engine             = "aurora-postgresql"
  master_username    = "adminuser"
  master_password    = "ChangeMe123!"
  skip_final_snapshot = true
}
