output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.populare.address
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.populare.port
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
  value       = var.db_username
  sensitive   = true
}

output "db_password" {
  description = "Database administrator password"
  value       = var.db_password
  sensitive   = true
}
