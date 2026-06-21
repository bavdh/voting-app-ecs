resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow Postgres access from ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "${var.project_name}-rds-egress-all"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  for_each                     = toset(var.allowed_security_group_ids)
  security_group_id            = aws_security_group.rds.id
  description                  = "Allow Postgres from ECS instance SG"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = each.value

  tags = {
    Name = "${var.project_name}-rds-ingress-${each.key}"
  }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-postgres"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.master_username

  # AWS generates + stores the password in Secrets Manager automatically.
  # No plaintext password anywhere in this config or state diff.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false # single-AZ, matches your tear-down-after plan

  skip_final_snapshot = true # so `terraform destroy` doesn't hang waiting for a snapshot
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
