provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", "us-east-2", "--output", "json"]
      command     = "aws"
    }
  }
}
# resource "aws_ecr_repository" "rds-eks-app" {
#   name = "rds-eks-app"
#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }


resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "default"
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}
