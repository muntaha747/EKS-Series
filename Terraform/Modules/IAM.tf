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



##################################Creating an New IAM User#############################################
resource "aws_iam_user" "muntaha_iam_user" {
  name = "muntaha"
  tags = {
    Name = "muntaha"
  }
}

##################################Creating an New IAM Role for the User#############################################
resource "aws_iam_role" "muntaha-eks-iam-role" {
  name = "muntaha-eks-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = aws_iam_user.muntaha_iam_user.arn }}, ]})
  tags = { Name= "muntaha-eks-iam-role"} 
}
##################################Attaching IAM User with IAM Role#############################################
resource "aws_iam_user_policy" "IAM_User_and_Role_attachment" {
  name = "IAM_User_and_Role_attachment"
  user = aws_iam_user.muntaha_iam_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = aws_iam_role.muntaha-eks-iam-role.arn},]})
}
##################################Attaching IAM Role with EKS Policy attachment#############################################
resource "aws_iam_role_policy_attachment" "attaching-IAM-role-with-eks-policy" {
  role       = aws_iam_role.muntaha-eks-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_access_key" "muntaha_iam_user_access_keys" {
  user = aws_iam_user.muntaha_iam_user.name
}

output "muntaha_iam_user_access_keys" {
  value = aws_iam_access_key.muntaha_iam_user_access_keys.id
}

output "muntaha_iam_user_secret_keys" {
  value = muntaha_iam_user_secret_keys.secret
  sensitive = true
}