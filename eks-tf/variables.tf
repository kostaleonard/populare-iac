variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "populare-cluster"
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
