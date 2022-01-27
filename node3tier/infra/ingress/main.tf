/* Ingress controller, guided by https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html */

### Terraform data sources and Helm provider to install kubernetes objects

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

data "aws_caller_identity" "current" {}

### ALB Controller IAM Role & Policies:

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name        = "eks-alb-ingress-controller"
  description = "Permissions required by the Kubernetes AWS ALB Ingress controller to do it's job."

  force_detach_policies = true

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
ROLE
}

resource "aws_iam_policy" "ALBIngressControllerIAMPolicy" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = file("${path.module}/ALBIngressControllerIAMPolicy.json")
}

resource "aws_iam_role_policy_attachment" "ALBIngressControllerIAMPolicy" {
  policy_arn = aws_iam_policy.ALBIngressControllerIAMPolicy.arn
  role       = aws_iam_role.eks_alb_ingress_controller.name
}

### ALB Controller Helm Chart

resource "helm_release" "aws_load_balancer_controller" {
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  version         = "1.3.3"
  repository      = "https://aws.github.io/eks-charts"
  namespace       = "kube-system"
  cleanup_on_fail = true

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_id
      "serviceAccount.name"                                       = "alb-ingress-controller"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.eks_alb_ingress_controller.arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

### External-DNS Helm Chart

resource "helm_release" "external_dns" {
  name            = "external-dns"
  chart           = "external-dns"
  version         = "1.7.1"
  repository      = "https://kubernetes-sigs.github.io/external-dns"
  namespace       = "kube-system"
  cleanup_on_fail = true
}
