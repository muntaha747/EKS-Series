# 1. Fetch the OIDC Issuer URL dynamically from your EKS Cluster
############# We are fetching the exsisting running Cluster Name.
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.EKS-Control-Plane.name
}

# 2. Create the OIDC Identity Provider (if not already created)
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# 3. The S3 Permission Policy
resource "aws_iam_policy" "IRSA-S3-Permission-Policy" {
  name        = "IRSA-S3-Permission-Policy"
  description = "Policy for IRSA Pod to access S3"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
  })
}

# 4. The IAM Role and Trust Policy
# We dynamically strip the "https://" from the OIDC URL to use in the ARN
locals {
  oidc_provider_url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_role" "irsa_s3_role" {
  name = "IRSA-S3-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:default:s3-access-sa",
            "${local.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 5. Attach the S3 Policy to the Role
resource "aws_iam_role_policy_attachment" "irsa_s3_attach" {
  role       = aws_iam_role.irsa_s3_role.name
  policy_arn = aws_iam_policy.IRSA-S3-Permission-Policy.arn
}

# 6. Output the Role ARN
output "irsa_role_arn" {
  value = aws_iam_role.irsa_s3_role.arn
}