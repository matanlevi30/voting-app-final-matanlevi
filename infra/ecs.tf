# ECS cluster, environment variables and secrets of the services, the three calls to the service module

resource "aws_ecs_cluster" "main" {
  name = "${local.name}-cluster"
}

data "aws_region" "current" {}

locals {
  redis_host = aws_elasticache_cluster.redis.cache_nodes[0].address

  db_environment = {
    DB_HOST = aws_db_instance.main.address
    DB_PORT = tostring(aws_db_instance.main.port)
    DB_USER = aws_db_instance.main.username
    DB_NAME = aws_db_instance.main.db_name
    DB_SSL  = "true"
  }

  db_secrets = {
    DB_PASSWORD = aws_secretsmanager_secret.db_password.arn
  }

  task_subnet_ids = [for s in aws_subnet.public : s.id]
}

module "vote" {
  source = "./modules/service"

  name               = "${local.name}-vote"
  container_name     = "vote"
  image              = "${data.aws_ecr_repository.service["vote"].repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = local.task_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count
  region             = data.aws_region.current.name

  container_port   = 80
  target_group_arn = aws_lb_target_group.app["vote"].arn

  environment = {
    REDIS_HOST = local.redis_host
    OPTION_A   = var.option_a
    OPTION_B   = var.option_b
  }

  depends_on = [
    aws_lb_listener.app,
    aws_iam_role_policy_attachment.exec,
    aws_iam_role_policy.read_db_secret,
    aws_secretsmanager_secret_version.db_password,
  ]
}

module "result" {
  source = "./modules/service"

  name               = "${local.name}-result"
  container_name     = "result"
  image              = "${data.aws_ecr_repository.service["result"].repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = local.task_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count
  region             = data.aws_region.current.name

  container_port   = 80
  target_group_arn = aws_lb_target_group.app["result"].arn

  environment = local.db_environment
  secrets     = local.db_secrets

  depends_on = [
    aws_lb_listener.app,
    aws_iam_role_policy_attachment.exec,
    aws_iam_role_policy.read_db_secret,
    aws_secretsmanager_secret_version.db_password,
  ]
}

module "worker" {
  source = "./modules/service"

  name               = "${local.name}-worker"
  container_name     = "worker"
  image              = "${data.aws_ecr_repository.service["worker"].repository_url}:${var.image_tag}"
  cluster_id         = aws_ecs_cluster.main.id
  execution_role_arn = aws_iam_role.exec.arn
  subnet_ids         = local.task_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  desired_count      = var.desired_count
  region             = data.aws_region.current.name

  # No container_port and no target_group_arn: the worker is not behind the ALB

  environment = merge(local.db_environment, { REDIS_HOST = local.redis_host })
  secrets     = local.db_secrets

  depends_on = [
    aws_iam_role_policy_attachment.exec,
    aws_iam_role_policy.read_db_secret,
    aws_secretsmanager_secret_version.db_password,
  ]
}