# Kubernetes Deployment for misp-dashboard
# Include the container configuration
resource "kubernetes_deployment" "MISP" {
  metadata {
    name = "${local.config.network.cname.api}"
    labels = {
      app = "${local.config.network.cname.api}"
    }
  }
  spec {
    selector {
        match_labels = {
            app = "${local.config.network.cname.api}"
        }
    }
    template {
      metadata {
        name = "${local.config.network.cname.api}"
        labels = {
          app = "${local.config.network.cname.api}"
        }
      }
      spec {
        container {
          image = "xyrodileas/misp:latest"
          name  = "${local.config.network.cname.api}"
          port {
            container_port = "${local.config.app.ports.internal}"
          }
          env {
              name = "MYSQL_HOST"
              value = "${aws_db_instance.MISP_Database.address}"
          }
          env {
              name  = "MYSQL_DATABASE"
              value = "${aws_db_instance.MISP_Database.name}"
          }
          env {
              name  = "MYSQL_USER"
              value = "${aws_db_instance.MISP_Database.username}"
          }
          env {
              name  = "MYSQL_PASSWORD"
              value = "${random_password.MISP_database_psswd.result}"
          }
          env {
              name  = "MISP_ADMIN_EMAIL"
              value = "${var.MISP_ADMIN_EMAIL}"
          }
          env {
              name  = "MISP_ADMIN_PASSPHRASE"
              value = "${var.MISP_ADMIN_PASSPHRASE}"
          }
          env {
              name  = "MISP_BASEURL"
              value = "https://misp.${var.route53_zone}"
          }
          env {
              name  = "POSTFIX_RELAY_HOST"
              value = "${var.POSTFIX_RELAY_HOST}"
          }
          env {
              name  = "TIMEZONE"
              value = "${var.TIMEZONE}"
          }


        }

      }
    }
  }
}

# Kubernetes Service configuration
# Configure the port mapping between container and ingress point for MISP
resource "kubernetes_service" "MISP" {
  metadata {
    name = "${local.config.network.cname.api}-service"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.MISP.metadata.0.labels.app}"
    }
    port {
      port = "${local.config.app.ports.external}"
      target_port = "${local.config.app.ports.internal}"
    }
    type= "NodePort"
  }
}

# Kubernetes Service configuration
# Configure the port mapping between container and ingress point for the ZMQ service
resource "kubernetes_service" "MISP_ZMQ" {
  metadata {
    name = "${local.config.network.cname.api}-zmq"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.MISP.metadata.0.labels.app}"
    }
    port {
      port = "${local.config.app.zmq.port}"
      target_port = "${local.config.app.zmq.port}"
    }
    type= "NodePort"
  }
}

# Kubernetes Ingress configuration
# Configure the external load balancer for access (AWS ALB)
# var.authorized_ips is used to whitelist IP.
resource "kubernetes_ingress" "misp_ingress" {
  metadata {
    name = "${local.config.network.cname.api}-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = "${module.misp_dns_record.certificate_arn}"
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/inbound-cidrs" = "${join(", ",var.authorized_ips)}"
      "alb.ingress.kubernetes.io/tags" = "Name=misp_tf, Environment=Prod, Product=misp"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    }
  }

  spec {
    rule {
      host = "${module.misp_dns_record.fqdn}"
      http {
        path {
          backend {
            service_name = "ssl-redirect"
            service_port = "use-annotation"
          }
        }
        path {
          backend {
            service_name = "${kubernetes_service.MISP.metadata.0.name}"
            service_port = "${local.config.app.ports.external}"
          }
        }
      }
    }
  }
}
