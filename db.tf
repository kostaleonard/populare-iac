#
#
#resource "aws_db_subnet_group" "populare" {
#  name       = "populare"
#  subnet_ids = module.vpc.public_subnets
#
#  tags = {
#    Name = "populare"
#  }
#}
#
#resource "aws_db_instance" "populare" {
#  identifier             = "populare"
#  instance_class         = "db.t3.micro"
#  allocated_storage      = 5
#  engine                 = "mysql"
#  engine_version         = "8.0"
#  username               = var.db_username
#  password               = var.db_password
#  db_subnet_group_name   = aws_db_subnet_group.populare.name
#  vpc_security_group_ids = [aws_security_group.rds.id]
#  parameter_group_name   = aws_db_parameter_group.populare.name
#  publicly_accessible    = true
#  skip_final_snapshot    = true
#}
#
#resource "aws_db_parameter_group" "populare" {
#  name   = "populare"
#  family = "mysql8"
#
#  parameter {
#    name  = "log_connections"
#    value = "1"
#  }
#}
