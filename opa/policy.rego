package kubernetes

deny[msg] {
  input.kind == "Deployment"
  c = input.spec.template.spec.containers[_]
  not c.securityContext.runAsNonRoot
  msg = "Container must run as non-root"
}
