provider "kubernetes" {
  config_context_cluster = "default"
  username = "default"
  config_path = "/app/kube/kubeconfig"

}
provider "helm" {
  kubernetes {
    config_path = "/app/kube/kubeconfig"
  }
}