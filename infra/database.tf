# RDS: subnet group and instance, the generated password and its Secrets Manager secret

# ---------- Password ----------

# No special characters: ; and = break the .NET connection string of the worker
resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.name}-db-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

# ---------- RDS Postgres ----------

resource "aws_db_subnet_group" "main" {
  name       = "${local.name}-db"
  subnet_ids = [for s in aws_subnet.private : s.id]

  tags = { Name = "${local.name}-db" }
}

resource "aws_db_instance" "main" {
  identifier        = "${local.name}-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "votes"
  username = "voteadmin"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}