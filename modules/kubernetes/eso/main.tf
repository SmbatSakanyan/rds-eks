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
locals {
  external_secrets = {
    namespace            = "external-secrets"
    service_account_name = "external-secrets-sa"
  }
  cluster_autoscaler = {
    service_account_name = "cluster-autoscaler-sa"
    namespace            = "default"
  }
}

module "iam_assumable_role_external_secrets" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "testcluster2-external-secrets-role"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.external_secrets.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.external_secrets.namespace}:${local.external_secrets.service_account_name}"]
}

module "iam_assumable_role_cluster_autoscaler" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.3.0"
  create_role                   = true
  role_name                     = "testcluster2-cluster-autoscaler-role"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${local.cluster_autoscaler.namespace}:${local.cluster_autoscaler.service_account_name}"]
}

resource "aws_iam_policy" "external_secrets" {
  name        = "testcluster2-external-secrets-policy"
  description = "EKS AWS External Secrets policy for cluster testcluster2"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": [
                "arn:aws:secretsmanager:us-east-2:548844171305:secret:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "testcluster2-cluster-autoscaler-policy"
  description = "EKS AWS Cluster Autoscaler policy for cluster testcluster2"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeImages",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   chart      = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   namespace  = "default"
#   values = [
#     "${file("./values/values.yaml")}"
#   ]
# }


resource "helm_release" "external-secrets" {
  name             = "external-secrets"
  chart            = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  version          = "v0.9.6"
  namespace        = "external-secrets"
  create_namespace = true
}

resource "helm_release" "reloader" {
  name       = "reloader"
  chart      = "reloader"
  repository = "https://stakater.github.io/stakater-charts"

}


