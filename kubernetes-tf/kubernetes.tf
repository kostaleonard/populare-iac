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
              "image" = "kostaleonard/populare:1.0.7"
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
              "image" = "kostaleonard/populare_db_proxy:0.0.10"
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

resource "kubernetes_manifest" "wireguard-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "wireguard"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "wireguard"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "wireguard"
          }
          "name" = "wireguard"
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "PUID"
                  "value" = "1000"
                },
                {
                  "name" = "PGID"
                  "value" = "1000"
                },
                {
                  "name" = "TZ"
                  "value" = "America/Los_Angeles"
                },
                {
                  "name" = "SERVERURL"
                  "value" = "wireguard" # TODO can we make this the load balancer IP?
                },
                {
                  "name" = "INTERNAL_SUBNET"
                  "value" = "10.13.13.0"
                },
                {
                  "name" = "PEERS"
                  "value" = "leo_mac"
                },
                {
                  "name" = "PEERDNS"
                  "value" = "auto"
                },
                {
                  "name" = "ALLOWEDIPS"
                  "value" = "10.13.13.0/24"
                },
              ]
              "image" = "linuxserver/wireguard"
              "name" = "wireguard"
              "ports" = [
                {
                  "containerPort" = 51820
                  "protocol" = "UDP"
                },
              ]
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_ADMIN",
                    "SYS_MODULE",
                  ]
                }
              }
              "volumeMounts" = [ # TODO add persistent volume
                {
                  "mountPath" = "/config"
                  "name" = "dockerdata"
                  "subPath" = "wireguard" # TODO will the subpath be automatically created?
                },
                {
                  "mountPath" = "/lib/modules"
                  "name" = "host"
                  "subPath" = "lib/modules"
                },
              ]
            },
          ]
          "securityContext" = {
            "sysctls" = [
              {
                "name" = "net.ipv4.ip_forward"
                "value" = "1"
              },
            ]
          }
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/tmp"
                "type" = "Directory"
              }
              "name" = "dockerdata"
            },
            {
              "hostPath" = {
                "path" = "/"
                "type" = "Directory"
              }
              "name" = "host"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "wireguard-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "labels" = {
        "app" = "wireguard"
      }
      "name" = "wireguard"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port" = 51820
          "protocol" = "UDP"
          "targetPort" = 51820
        },
      ]
      "selector" = {
        "app" = "wireguard"
      }
      "type" = "LoadBalancer"
    }
  }
}
