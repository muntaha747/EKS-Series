terraform {
  backend "s3" {
    bucket       = "terraform-statefile-devops-muntaha"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}