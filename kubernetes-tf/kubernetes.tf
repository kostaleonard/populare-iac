resource "kubernetes_secret" "db-certs" {
  metadata {
    name = "db-certs"
  }

  data = {
    db-uri = "mysql+pymysql://${data.terraform_remote_state.populare_workspace_state.outputs.db_username}:${data.terraform_remote_state.populare_workspace_state.outputs.db_password}@${data.terraform_remote_state.populare_workspace_state.outputs.rds_hostname}/${data.terraform_remote_state.populare_workspace_state.outputs.db_name}"
  }
}

resource "kubernetes_manifest" "populare-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "populare"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "populare"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "populare"
          }
          "name" = "populare"
        }
        "spec" = {
          "containers" = [
            {
              "image" = "kostaleonard/populare:1.0.11"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/version.json"
                  "port" = 80
                }
                "initialDelaySeconds" = 15
              }
              "name" = "populare"
              "ports" = [
                {
                  "containerPort" = 80
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/version.json"
                  "port" = 80
                }
                "periodSeconds" = 1
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "populare-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "populare"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "app" = "populare"
      }
    }
  }
}

resource "kubernetes_manifest" "populare-db-proxy-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "populare-db-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas" = 2
      "selector" = {
        "matchLabels" = {
          "app" = "populare-db-proxy"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "populare-db-proxy"
          }
          "name" = "populare-db-proxy"
        }
        "spec" = {
          "containers" = [
            {
              "image" = "kostaleonard/populare_db_proxy:0.0.11"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 8000
                }
                "initialDelaySeconds" = 15
              }
              "name" = "populare-db-proxy"
              "ports" = [
                {
                  "containerPort" = 8000
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 8000
                }
                "periodSeconds" = 1
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/populare-db-proxy/db-certs/"
                  "name" = "db-certs"
                  "readOnly" = true
                },
              ]
            },
          ]
          "volumes" = [
            {
              "name" = "db-certs"
              "secret" = {
                "secretName" = "db-certs"
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "populare-db-proxy-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "populare-db-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 8000
        },
      ]
      "selector" = {
        "app" = "populare-db-proxy"
      }
    }
  }
}

resource "kubernetes_manifest" "reverse-proxy-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "reverse-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "reverse-proxy"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "reverse-proxy"
          }
          "name" = "reverse-proxy"
        }
        "spec" = {
          "containers" = [
            {
              "image" = "kostaleonard/populare-reverse-proxy:0.0.2"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "initialDelaySeconds" = 15
              }
              "name" = "reverse-proxy"
              "ports" = [
                {
                  "containerPort" = 80
                  "protocol" = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "periodSeconds" = 1
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "reverse-proxy-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "reverse-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 80
          "targetPort" = 80
        },
      ]
      "selector" = {
        "app" = "reverse-proxy"
      }
      "type" = "LoadBalancer"
    }
  }
}
