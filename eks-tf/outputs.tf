output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.populare.address
  sensitive   = true
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "db_name" {
  description = "RDS database name"
  value       = aws_db_instance.populare.db_name
}

output "db_username" {
  description = "Database administrator username"
  value       = aws_db_instance.populare.username
}

output "db_password" {
  description = "Database administrator password"
  value       = aws_db_instance.populare.password
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "VPC public subnets"
  value       = module.vpc.public_subnets
}

output "bulwark_ip" {
  description = "The public ip for bulwark"
  value       = aws_instance.bulwark.public_ip
}
