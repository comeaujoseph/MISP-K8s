# Kubernetes Deployment for misp-dashboard
# Include the container configuration
resource "kubernetes_deployment" "MISP_Dashboard" {
  metadata {
    name = "${local.config.network.cname.dashboard}"
    labels = {
      app = "${local.config.network.cname.dashboard}"
    }
  }
  spec {
    selector {
        match_labels = {
            app = "${local.config.network.cname.dashboard}"
        }
    }
    template {
      metadata {
        name = "${local.config.network.cname.dashboard}"
        labels = {
          app = "${local.config.network.cname.dashboard}"
        }
      }
      spec {
        container {
          image = "xyrodileas/misp-dashboard:latest"
          name  = "${local.config.network.cname.dashboard}"
          port {
            container_port = "${local.config.dashboard.ports.internal}"
          }
          env {
              name = "REDISHOST"
              value = "${aws_elasticache_replication_group.MISP_Redis.primary_endpoint_address}"
          }
          env {
              name  = "REDISPORT"
              value = "${aws_elasticache_replication_group.MISP_Redis.port}"
          }
          env {
              name  = "MISP_URL"
              value = "${kubernetes_service.MISP.metadata[0].name}"
          }
          env {
              name  = "ZMQ_URL"
              value = "${kubernetes_service.MISP_ZMQ.metadata[0].name}"
          }
          env {
              name  = "ZMQ_PORT"
              value = "${local.config.app.zmq.port}"
          }

        }

      }
    }
  }
}

# Kubernetes Service configuration
# Configure the port mapping between container and ingress point for the dashboard
resource "kubernetes_service" "MISP_Dashboard" {
  metadata {
    name = "${local.config.network.cname.dashboard}-service"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.MISP_Dashboard.metadata.0.labels.app}"
    }
    port {
      port = "${local.config.dashboard.ports.external}"
      target_port = "${local.config.dashboard.ports.internal}"
    }
    type= "NodePort"
  }
}

# Kubernetes Ingress configuration
# Configure the external load balancer for access (AWS ALB)
# var.authorized_ips is used to whitelist IP.
resource "kubernetes_ingress" "misp_dashboard_ingress" {
  metadata {
    name = "${local.config.network.cname.dashboard}-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = "${module.misp_dashboard_dns_record.certificate_arn}"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/inbound-cidrs" = "${join(", ",var.authorized_ips)}"
      "alb.ingress.kubernetes.io/tags" = "Name=misp_dashboard_tf, Environment=Prod, Product=misp_dashboard"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    }
  }

  spec {
    rule {
      host = "${module.misp_dashboard_dns_record.fqdn}"
      http {
        path {
          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
        path {
          backend {
            service_name = "${kubernetes_service.MISP_Dashboard.metadata.0.name}"
            service_port = "${local.config.dashboard.ports.external}"
          }
        }
      }
    }
  }
}
