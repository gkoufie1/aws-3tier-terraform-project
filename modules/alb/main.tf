resource "aws_lb" "app_alb" {
  name               = "3tier-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = []
  subnets            = []

  enable_deletion_protection = false
}
