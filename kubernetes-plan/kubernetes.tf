resource "kubernetes_secret" "db-certs" {
  metadata {
    name = "db-certs"
  }

  data = {
    db-uri = "mysql+pymysql://${var.db_username}:${var.db_password}@${var.rds_hostname}/${var.db_name}"
  }
}
