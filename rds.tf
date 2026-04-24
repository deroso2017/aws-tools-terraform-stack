resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = { Name = "${var.db_identifier}-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier                 = var.db_identifier
  db_name                    = var.db_name
  engine                     = "postgres"
  engine_version             = "15"
  instance_class             = var.db_instance_class
  username                   = var.db_username
  password                   = var.db_password
  allocated_storage          = 20
  storage_type               = "gp2"
  storage_encrypted          = true
  port                       = 5432
  db_subnet_group_name       = aws_db_subnet_group.main.name
  vpc_security_group_ids     = [aws_security_group.rds.id]
  publicly_accessible        = false
  multi_az                   = false
  backup_retention_period    = 7
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = { Name = var.db_identifier }
}
