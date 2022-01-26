data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

### Kubernetes deployment, service and ingress to make app accessible via ELB on port 80

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "deployment-webdemo"
    namespace = "default"
    labels    = {
      app = "webdemo"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "webdemo"
      }
    }

    template {
      metadata {
        labels = {
          app = "webdemo"
        }
      }

      spec {
        container {
          image = "nikovirtala/whalesay"
          name  = "webdemo"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-webdemo"
    namespace = "default"
  }
  spec {
    selector = {
      app = "webdemo"
    }

    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }

    type = "NodePort"
  }

  depends_on = [kubernetes_deployment.app]
}

# Look up the ACM certificate, which should already have been issued by the SSL module
data "aws_acm_certificate" "app" {
  domain   = var.app_domain
  statuses = ["ISSUED"]
}

resource "kubernetes_ingress" "app" {
  metadata {
    name        = "webdemo-ingress"
    namespace   = "default"
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.app.arn
    }
    labels      = {
      "app" = "webdemo-ingress"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service_name = "service-webdemo"
            service_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.app]
}

# Look up the ALB which should have been created by the ALB ingress controller,
# so we can reference it below in the Route53 alias record
data "aws_lb" "app_alb" {
  tags = {
    "ingress.k8s.aws/stack" = "default/webdemo-ingress"
  }

  depends_on = [kubernetes_ingress.app]
}

# Look up the public DNS zone, which is assumed to have been already created manually in Route53
data "aws_route53_zone" "app_domain" {
  name         = var.app_domain
  private_zone = false
}

# Create Route53 alias record pointing to the ALB
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.app_domain.zone_id
  name    = data.aws_route53_zone.app_domain.name
  type    = "A"
  alias {
    name                   = data.aws_lb.app_alb.dns_name
    zone_id                = data.aws_lb.app_alb.zone_id
    evaluate_target_health = false
  }
}

output "app_load_balancer_url" {
  value = "http://${data.aws_lb.app_alb.dns_name}"
}

output "app_url_ssl" {
  value = "https://${aws_route53_record.app.fqdn}"
}
