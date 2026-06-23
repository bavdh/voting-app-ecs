resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound traffic to ALB on vote and result ports"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# Allow internet → ALB on port 8080 (vote)
resource "aws_vpc_security_group_ingress_rule" "alb_vote" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow internet traffic to vote UI"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-alb-ingress-vote"
  }
}

# Allow internet → ALB on port 8081 (result)
resource "aws_vpc_security_group_ingress_rule" "alb_result" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow internet traffic to result UI"
  ip_protocol       = "tcp"
  from_port         = 8081
  to_port           = 8081
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-alb-ingress-result"
  }
}

# Allow ALB → ECS instances (all outbound from ALB)
resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound from ALB"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-alb-egress-all"
  }
}

# Allow ALB → ECS instances on dynamic bridge port range
resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = var.ecs_instance_security_group_id
  description                  = "Allow traffic from ALB on dynamic port range"
  ip_protocol                  = "tcp"
  from_port                    = 32768
  to_port                      = 65535
  referenced_security_group_id = aws_security_group.alb.id

  tags = {
    Name = "${var.project_name}-ecs-ingress-from-alb"
  }
}

# --- ALB ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# --- Target groups ---
resource "aws_lb_target_group" "vote" {
  name        = "${var.project_name}-vote-tg"
  port        = 80 # container port for vote
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # bridge mode uses instance, not ip

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-vote-tg"
  }
}

resource "aws_lb_target_group" "result" {
  name        = "${var.project_name}-result-tg"
  port        = 4000 # container port for result (what server.js actually listens on)
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-result-tg"
  }
}

# --- Listeners ---
resource "aws_lb_listener" "vote" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vote.arn
  }
}

resource "aws_lb_listener" "result" {
  load_balancer_arn = aws_lb.main.arn
  port              = 8081
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.result.arn
  }
}
