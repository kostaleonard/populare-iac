variable "db_name" {
  description = "RDS database name"
  type        = string
  default     = "populare_db"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "rds_hostname" {
  description = "RDS instance hostname"
  type        = string
  sensitive   = true
}
