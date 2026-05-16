resource "aws_db_subnet_group" "db_sub" {
  name       = "db-sub-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "db" {
  identifier             = "ciberguard-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db_sub.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}
