### Jenkins Helm Chart

resource "helm_release" "jenkins" {
  name            = "jenkins"
  chart           = "jenkins"
  version         = "3.11.3"
  repository      = "https://charts.jenkins.io"
  namespace       = "default"
  cleanup_on_fail = true

  values = [
    file("${path.module}/values.yml")
  ]
}
