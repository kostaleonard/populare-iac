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
