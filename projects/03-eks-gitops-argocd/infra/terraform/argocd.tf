resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.52.1"
  namespace        = "argocd"
  create_namespace = true

  values = [file("${path.module}/../../argocd/helm-chart/values.yaml")]

  depends_on = [module.eks]
}
