resource "aws_cloudwatch_log_group" "vote" {
  name              = "/ecs/${var.project_name}/vote"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "result" {
  name              = "/ecs/${var.project_name}/result"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.project_name}/worker"
  retention_in_days = 7
}

# --- Vote task definition ---
resource "aws_ecs_task_definition" "vote" {
  family                   = "${var.project_name}-vote"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([{
    name   = "vote"
    image  = var.vote_image
    cpu    = 256
    memory = 512

    portMappings = [{
      containerPort = 80
      hostPort      = 8080
      protocol      = "tcp"
    }]

    environment = [
      { name = "REDIS_HOST", value = var.redis_endpoint },
      { name = "REDIS_PORT", value = tostring(var.redis_port) }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.vote.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "vote"
      }
    }

    essential = true
  }])
}

# --- Result task definition ---
resource "aws_ecs_task_definition" "result" {
  family                   = "${var.project_name}-result"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([{
    name   = "result"
    image  = var.result_image
    cpu    = 256
    memory = 512

    portMappings = [{
      containerPort = 4000
      hostPort      = 8081
      protocol      = "tcp"
    }]

    environment = [
      { name = "POSTGRES_HOST", value = var.db_endpoint },
      { name = "POSTGRES_PORT", value = "5432" },
      { name = "POSTGRES_USER", value = var.db_username },
      { name = "POSTGRES_DB", value = var.db_name }
    ]

    secrets = [{
      name      = "POSTGRES_PASSWORD"
      valueFrom = "${var.rds_secret_arn}:password::"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.result.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "result"
      }
    }

    essential = true
  }])
}

# --- Worker task definition ---
resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.project_name}-worker"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([{
    name   = "worker"
    image  = var.worker_image
    cpu    = 256
    memory = 512

    environment = [
      { name = "REDIS_HOST", value = var.redis_endpoint },
      { name = "REDIS_PORT", value = tostring(var.redis_port) },
      { name = "POSTGRES_HOST", value = var.db_endpoint },
      { name = "POSTGRES_PORT", value = "5432" },
      { name = "POSTGRES_USER", value = var.db_username },
      { name = "POSTGRES_DB", value = var.db_name }
    ]

    secrets = [{
      name      = "POSTGRES_PASSWORD"
      valueFrom = "${var.rds_secret_arn}:password::"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.worker.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "worker"
      }
    }

    essential = true
  }])
}

# --- ECS Services ---
resource "aws_ecs_service" "vote" {
  name            = "${var.project_name}-vote"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.vote.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
  }

  load_balancer {
    target_group_arn = var.vote_target_group_arn
    container_name   = "vote"
    container_port   = 80
  }

  depends_on = [var.vote_target_group_arn]
}

resource "aws_ecs_service" "result" {
  name            = "${var.project_name}-result"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.result.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
  }

  load_balancer {
    target_group_arn = var.result_target_group_arn
    container_name   = "result"
    container_port   = 4000
  }

  depends_on = [var.result_target_group_arn]
}

resource "aws_ecs_service" "worker" {
  name            = "${var.project_name}-worker"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 1
  }
}
