resource "aws_eks_cluster" "EKS-Control-Plane" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.EKS-Performance-Cluster-Role.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids              = slice(aws_subnet.Private_Subnets[*].id, 0, 6)
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


###############################################EKS-Managed-Node-Group###############################################
resource "aws_eks_node_group" "EKS-Worker-Nodes" {
  cluster_name    = aws_eks_cluster.EKS-Control-Plane.name
  node_group_name = "${var.cluster_name}-node-group"
  
  node_role_arn   = aws_iam_role.EKS-Performance-Worker-Node-Role.arn

  subnet_ids      = slice(aws_subnet.Public_Subnets[*].id, 0, 6) 

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  instance_types = var.node_group_instance_types
  capacity_type  = var.node_group_capacity_type

  tags = {
    Name = "${var.cluster_name}-node-group"
    Env  = var.env
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}