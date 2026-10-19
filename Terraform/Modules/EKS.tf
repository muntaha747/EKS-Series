resource "aws_eks_cluster" "EKS-Control-Plane" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.EKS-Performance-Cluster-Role.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = true

  vpc_config {
    subnet_ids              = slice(aws_subnet.Private_Subnets[*].id, 0, 6)
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.EKS-API-SG.id]
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

# Get the current AWS account ID dynamically
data "aws_caller_identity" "current_aws_user" {}

# 1. Create the Access Entry for your Root User
resource "aws_eks_access_entry" "root_admin_entry" {
  cluster_name  = aws_eks_cluster.EKS-Control-Plane.name
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current_aws_user.account_id}:root"
  type          = "STANDARD"
}

# 2. Attach the Cluster Admin Policy to the Access Entry
resource "aws_eks_access_policy_association" "root_admin_policy" {
  cluster_name  = aws_eks_cluster.EKS-Control-Plane.name
  principal_arn = aws_eks_access_entry.root_admin_entry.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "Hassan-devops-engineer-entry" {
  cluster_name = aws_eks_cluster.EKS-Control-Plane.name
  principal_arn = aws_iam_role.Hassan-eks-iam-role.arn
  type              = "STANDARD"
  kubernetes_groups = ["hassan-devops"]
  region = "us-east-1"
}


###############################################EKS-Security-Group###############################################
resource "aws_security_group" "EKS-API-SG" {
  name        = "Security group to access Kube-Api-Server"
  description = "Inbound traffic for the worker node only https"
  vpc_id      = aws_vpc.EKS_VPC.id
  tags = {
    Name = "EKS-API-Access-SG"
    Env  = var.env
  }
}

resource "aws_vpc_security_group_ingress_rule" "EKS-API-SG-Ingress" {
  security_group_id = aws_security_group.EKS-API-SG.id
  referenced_security_group_id = aws_security_group.vpn_security_group.id
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description                  = "Allow VPN clients to access EKS API Server"
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