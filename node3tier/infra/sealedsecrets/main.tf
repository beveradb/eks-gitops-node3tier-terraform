### Sealed Secret Controller Helm Chart

resource "helm_release" "sealed-secrets" {
  name            = "sealed-secrets"
  chart           = "sealed-secrets"
  version         = "2.1.1"
  repository      = "https://bitnami-labs.github.io/sealed-secrets"
  namespace       = "kube-system"
  cleanup_on_fail = true
}
