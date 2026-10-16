resource "aws_eks_cluster" "EKS-Control-Plane" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.EKS-Performance-Cluster-Role.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids              = slice(aws_subnet.Public_Subnets[*].id, 0, 2)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.EKS-API-Access-SG.id]
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags = {
    Name = "EKS-Control-Plane-${var.cluster_name}"
    Env  = var.env
  }

  depends_on = [aws_iam_role_policy_attachment.EKS_CLUSTER_POLICY_ATTACHMENT]
}