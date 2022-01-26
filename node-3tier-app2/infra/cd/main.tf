### Flux Helm Chart

resource "helm_release" "flux" {
  name            = "flux"
  chart           = "flux"
  version         = "1.11.4"
  repository      = "https://charts.fluxcd.io"
  namespace       = "kube-system"
  cleanup_on_fail = true

  values = [
    file("${path.module}/values.yml")
  ]
}
