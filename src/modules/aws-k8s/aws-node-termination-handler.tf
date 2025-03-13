resource "helm_release" "spot_termination_handler" {
  name       = "aws-node-termination-handler"
  chart      = "aws-node-termination-handler"
  repository = "oci://public.ecr.aws/aws-ec2/helm"
  version    = "0.27.0"
  namespace  = "kube-system"

  atomic          = true
  wait            = true
  cleanup_on_fail = true
  wait_for_jobs   = true

  values = [
    yamlencode({
      enableSpotInterruptionDraining = true
      enableRebalanceMonitoring      = true
      enableRebalanceDraining        = true
      enableScheduledEventDraining   = true
      enableSQSTerminationDraining   = false # Set to true if using SQS mode
      awsRegion                      = var.region
      podAnnotations = {
        "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
      }
    })
  ]
}
