resource "aws_db_subnet_group" "populare" {
  name       = "populare"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "populare"
  }
}

resource "aws_db_instance" "populare" {
  identifier             = "populare"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "8.0"
  username               = var.db_username
  password               = var.db_password
  db_name                = "populare_db"
  db_subnet_group_name   = aws_db_subnet_group.populare.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.populare.name
  publicly_accessible    = false
  skip_final_snapshot    = true
}

resource "aws_db_parameter_group" "populare" {
  name   = "populare"
  family = "mysql8.0"

  # No custom parameters currently defined, so this block is empty.
}

resource "aws_security_group" "rds" {
  name   = "populare"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "populare_rds"
  }
}
