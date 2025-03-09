locals {
  name   = var.cluster_name
  region = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = var.tags

  autoscaling_average_cpu = 30
  # ebs_csi_service_account_namespace = "kube-system"
  # ebs_csi_service_account_name      = "ebs-csi-controller-sa"
}
