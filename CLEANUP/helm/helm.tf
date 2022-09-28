module "metrics_server" {
  count              = var.metrics_server_enable == true ? 1 : 0
  source             = "./metrics_server"
  image_repo_url     = var.image_repo_url
  public_docker_repo = var.public_docker_repo
}

module "cluster_autoscaler" {
  count              = var.cluster_autoscaler_enable == true ? 1 : 0
  source             = "./cluster_autoscaler"
  image_repo_url     = var.image_repo_url
  eks_cluster_id     = var.eks_cluster_id
  public_docker_repo = var.public_docker_repo
}

module "lb_ingress_controller" {
  count                 = var.lb_ingress_controller_enable == true ? 1 : 0
  source                = "./lb_ingress_controller"
  image_repo_url        = var.image_repo_url
  clusterName           = var.eks_cluster_id
  eks_oidc_issuer_url   = var.eks_oidc_issuer_url
  eks_oidc_provider_arn = var.eks_oidc_provider_arn
  public_docker_repo    = var.public_docker_repo
}

module "traefik_ingress" {
  count              = var.traefik_ingress_controller_enable == true ? 1 : 0
  source             = "./traefik_ingress"
  image_repo_url     = var.image_repo_url
  account_id         = data.aws_caller_identity.current.account_id
  s3_nlb_logs        = var.s3_nlb_logs
  public_docker_repo = var.public_docker_repo
  //  tls_cert_arn = ""
}

module "aws-for-fluent-bit" {
  count                    = var.aws_for_fluent_bit_enable == true ? 1 : 0
  source                   = "./aws-for-fluent-bit"
  image_repo_url           = var.image_repo_url
  cluster_id               = var.eks_cluster_id
  ekslog_retention_in_days = var.ekslog_retention_in_days
  public_docker_repo       = var.public_docker_repo
}

module "fargate_fluentbit" {
  source           = "./fargate_fluentbit"
  eks_cluster_id   = var.eks_cluster_id
  fargate_iam_role = var.fargate_iam_role
}