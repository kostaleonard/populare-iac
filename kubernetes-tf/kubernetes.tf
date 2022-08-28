resource "kubernetes_secret" "db-certs" {
  metadata {
    name = "db-certs"
  }

  data = {
    db-uri = "mysql+pymysql://${data.terraform_remote_state.populare_workspace_state.outputs.db_username}:${data.terraform_remote_state.populare_workspace_state.outputs.db_password}@${data.terraform_remote_state.populare_workspace_state.outputs.rds_hostname}/${data.terraform_remote_state.populare_workspace_state.outputs.db_name}"
  }
}

resource "kubernetes_config_map" "populare-sns-notifier" {
  metadata {
    name = "populare-sns-notifier"
  }

  data = {
    populare-sns-topic-arn = data.terraform_remote_state.populare_workspace_state.outputs.populare_user_updates_sns_topic_arn
  }
}

resource "kubernetes_manifest" "populare-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "populare"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas"        = 1
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
                  "protocol"      = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/version.json"
                  "port" = 80
                }
                "periodSeconds" = 1
              }
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                }
                "limits" = {
                  "cpu" = "200m"
                }
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "populare-horizontalpodautoscaler" {
  manifest = {
    "apiVersion" = "autoscaling/v2beta2"
    "kind"       = "HorizontalPodAutoscaler"
    "metadata" = {
      "name"      = "populare"
      "namespace" = "default"
    }
    "spec" = {
      "maxReplicas" = 3
      "metrics" = [
        {
          "resource" = {
            "name" = "cpu"
            "target" = {
              "averageUtilization" = 70
              "type"               = "Utilization"
            }
          }
          "type" = "Resource"
        },
      ]
      "minReplicas" = 1
      "scaleTargetRef" = {
        "apiVersion" = "apps/v1"
        "kind"       = "Deployment"
        "name"       = "populare"
      }
    }
  }
}

resource "kubernetes_manifest" "populare-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "populare"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 80
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
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "populare-db-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas"        = 2
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
                  "protocol"      = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 8000
                }
                "periodSeconds" = 1
              }
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                }
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/populare-db-proxy/db-certs/"
                  "name"      = "db-certs"
                  "readOnly"  = true
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

resource "kubernetes_manifest" "populare-db-proxy-horizontalpodautoscaler" {
  manifest = {
    "apiVersion" = "autoscaling/v2beta2"
    "kind"       = "HorizontalPodAutoscaler"
    "metadata" = {
      "name"      = "populare-db-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "maxReplicas" = 3
      "metrics" = [
        {
          "resource" = {
            "name" = "cpu"
            "target" = {
              "averageUtilization" = 70
              "type"               = "Utilization"
            }
          }
          "type" = "Resource"
        },
      ]
      "minReplicas" = 2
      "scaleTargetRef" = {
        "apiVersion" = "apps/v1"
        "kind"       = "Deployment"
        "name"       = "populare-db-proxy"
      }
    }
  }
}

resource "kubernetes_manifest" "populare-db-proxy-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "populare-db-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 80
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
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "reverse-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "minReadySeconds" = 10
      "replicas"        = 1
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
                  "protocol"      = "TCP"
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/health"
                  "port" = 80
                }
                "periodSeconds" = 1
              }
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                }
              }
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "reverse-proxy-horizontalpodautoscaler" {
  manifest = {
    "apiVersion" = "autoscaling/v2beta2"
    "kind"       = "HorizontalPodAutoscaler"
    "metadata" = {
      "name"      = "reverse-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "maxReplicas" = 3
      "metrics" = [
        {
          "resource" = {
            "name" = "cpu"
            "target" = {
              "averageUtilization" = 70
              "type"               = "Utilization"
            }
          }
          "type" = "Resource"
        },
      ]
      "minReplicas" = 1
      "scaleTargetRef" = {
        "apiVersion" = "apps/v1"
        "kind"       = "Deployment"
        "name"       = "reverse-proxy"
      }
    }
  }
}

resource "kubernetes_manifest" "reverse-proxy-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "reverse-proxy"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 80
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

resource "kubernetes_manifest" "prometheus-clusterrole" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRole"
    "metadata" = {
      "name" = "prometheus"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
          "services",
          "endpoints",
          "pods",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "configmaps",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "nonResourceURLs" = [
          "/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "prometheus-service-account" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "prometheus"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "prometheus-clusterrole-binding" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind"       = "ClusterRoleBinding"
    "metadata" = {
      "name" = "prometheus"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind"     = "ClusterRole"
      "name"     = "prometheus"
    }
    "subjects" = [
      {
        "kind"      = "ServiceAccount"
        "name"      = "prometheus"
        "namespace" = "default"
      },
    ]
  }
}

resource "kubernetes_manifest" "prometheus-configmap" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "prometheus.yml" = <<-EOT
    global:
      scrape_interval: 15s
      external_labels:
        monitor: 'codelab-monitor'
    scrape_configs:
    - job_name: 'prometheus'
      scrape_interval: 5s
      static_configs:
      - targets: ['localhost:9090']
    - job_name: 'kubernetes-service-endpoints'
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_service_name]
        action: replace
        target_label: kubernetes_name
    EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "name"      = "prometheus"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "prometheus-deployment" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind"       = "Deployment"
    "metadata" = {
      "name"      = "prometheus"
      "namespace" = "default"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app" = "prometheus"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "prometheus"
          }
          "name" = "prometheus"
        }
        "spec" = {
          "containers" = [
            {
              "image" = "prom/prometheus"
              "livenessProbe" = {
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = 9090
                }
                "initialDelaySeconds" = 15
              }
              "name" = "prometheus"
              "ports" = [
                {
                  "containerPort" = 9090
                },
              ]
              "readinessProbe" = {
                "httpGet" = {
                  "path" = "/metrics"
                  "port" = 9090
                }
                "periodSeconds" = 1
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/prometheus"
                  "name"      = "config"
                },
              ]
            },
          ]
          "serviceAccountName" = "prometheus"
          "volumes" = [
            {
              "configMap" = {
                "name" = "prometheus"
              }
              "name" = "config"
            },
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "prometheus-service" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "labels" = {
        "app" = "prometheus"
      }
      "name"      = "prometheus"
      "namespace" = "default"
    }
    "spec" = {
      "ports" = [
        {
          "port"       = 80
          "targetPort" = 9090
        },
      ]
      "selector" = {
        "app" = "prometheus"
      }
    }
  }
}

resource "kubernetes_manifest" "populare-sns-notifier-cronjob" {
  manifest = {
    "apiVersion" = "batch/v1"
    "kind"       = "CronJob"
    "metadata" = {
      "name"      = "populare-sns-notifier"
      "namespace" = "default"
    }
    "spec" = {
      "jobTemplate" = {
        "spec" = {
          "backoffLimit" = 1
          "template" = {
            "spec" = {
              "containers" = [
                {
                  "image" = "kostaleonard/populare_sns_notifier:0.0.2"
                  "name"  = "populare-sns-notifier"
                  "volumeMounts" = [
                    {
                      "mountPath" = "/etc/populare-sns-notifier"
                      "name"      = "populare-sns-notifier"
                    },
                  ]
                },
              ]
              "volumes" = [
                {
                  "configMap" = {
                    "name" = "populare-sns-notifier"
                  }
                  "name" = "populare-sns-notifier"
                },
              ]
              "restartPolicy"      = "Never"
              "serviceAccountName" = "sns-publish"
            }
          }
        }
      }
      "schedule" = "*/5 * * * *"
    }
  }
}

resource "kubernetes_manifest" "sns-publish-serviceaccount" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "annotations" = {
        "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/populare-sns-publish-role"
      }
      "name"      = "sns-publish"
      "namespace" = "default"
    }
  }
}

resource "aws_iam_role" "sns_publish" {
  name = "populare-sns-publish-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}:aud": "sts.amazonaws.com",
          "${data.terraform_remote_state.populare_workspace_state.outputs.cluster_oidc_provider}:sub": "system:serviceaccount:default:sns-publish"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "sns_publish" {
  name        = "populare-sns-publish-policy"
  description = "Allow SNS:Publish on all resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "SNS:Publish",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_publish" {
  role       = aws_iam_role.sns_publish.name
  policy_arn = aws_iam_policy.sns_publish.arn
}
