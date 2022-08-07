variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "populare-cluster"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "populare_db_admin"
}
