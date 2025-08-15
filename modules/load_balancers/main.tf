# Internal ALB
resource "aws_lb" "internal" {
  name               = "skills-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.app_workload_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "skills-alb"
  }
}

# Internal ALB Listener
resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}

# Target Groups
resource "aws_lb_target_group" "green" {
  name     = "skills-green-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "skills-green-tg"
  }
}

resource "aws_lb_target_group" "red" {
  name     = "skills-red-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "skills-red-tg"
  }
}

# Internal NLB
resource "aws_lb" "internal_nlb" {
  name               = "skills-internal-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.app_workload_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "skills-internal-nlb"
  }
}

# Internal NLB Listener
resource "aws_lb_listener" "internal_nlb" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_nlb.arn
  }
}

# Internal NLB Target Group
resource "aws_lb_target_group" "internal_nlb" {
  name     = "skills-internal-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.app_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    protocol            = "TCP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "skills-internal-nlb-tg"
  }
}

# External NLB
resource "aws_lb" "external" {
  name               = "skills-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.hub_public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "skills-nlb"
  }
}

# External NLB Listener
resource "aws_lb_listener" "external" {
  load_balancer_arn = aws_lb.external.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_nlb.arn
  }
}

# External NLB Target Group
resource "aws_lb_target_group" "external_nlb" {
  name     = "skills-external-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.hub_vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    protocol            = "TCP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "skills-external-nlb-tg"
  }
}

# VPC Endpoint for NLB
resource "aws_vpc_endpoint" "nlb" {
  vpc_id            = var.hub_vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.elasticloadbalancing"
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.hub_public_subnet_ids

  private_dns_enabled = false

  tags = {
    Name = "skills-nlb-endpoint"
  }
}

# VPC Endpoint Service for Internal NLB
resource "aws_vpc_endpoint_service" "internal_nlb" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.internal_nlb.arn]

  tags = {
    Name = "skills-internal-nlb-service"
  }
}

# VPC Endpoint for Internal NLB (Private Link)
resource "aws_vpc_endpoint" "internal_nlb" {
  vpc_id            = var.app_vpc_id
  service_name      = aws_vpc_endpoint_service.internal_nlb.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = var.app_workload_subnet_ids

  private_dns_enabled = false

  tags = {
    Name = "skills-internal-nlb-endpoint"
  }

  depends_on = [aws_vpc_endpoint_service.internal_nlb]
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "skills-alb-sg"
  vpc_id      = var.app_vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "skills-alb-sg"
  }
}

# Data sources
data "aws_region" "current" {} 