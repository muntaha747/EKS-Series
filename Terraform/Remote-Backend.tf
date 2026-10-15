terraform {
  backend "s3" {
    bucket       = "tf-eks-statefile-bucket"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}


