resource "random_integer" "suffix" {
  min = 777
  max = 7777
}

###############################################EKS-Cluster-Role###############################################
resource "aws_iam_role" "EKS-Performance-Cluster-Role" {
  name = "${var.cluster_name}-Role-${random_integer.suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.cluster_name}-Role-${random_integer.suffix.result}"
  }
}

###############################################EKS-CLUSTER-ROLE-POLICY-ATTACHMENT###############################################
resource "aws_iam_role_policy_attachment" "EKS_CLUSTER_POLICY_ATTACHMENT" {
  role       = aws_iam_role.EKS-Performance-Cluster-Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

###############################################EKS-Worker-Node-Role############################################################
resource "aws_iam_role" "EKS-Performance-Worker-Node-Role" {
  name = "${var.cluster_name}-Worker-Role-${random_integer.suffix.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "${var.cluster_name}-Worker-Role-${random_integer.suffix.result}"
  }
}

###############################################EKS-Worker-Node-Role-Attachment###############################################
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.EKS-Performance-Worker-Node-Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.EKS-Performance-Worker-Node-Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.EKS-Performance-Worker-Node-Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_security_group" "EKS-API-Access-SG" {
  name        = "Security group to access Kube-Api-Server"
  description = "Inbound traffic for the worker node only https"
  vpc_id      = aws_vpc.EKS_VPC.id
  tags = {
    Name = "EKS-Worker-Node-Security-Group"
    Env  = var.env
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.client_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}