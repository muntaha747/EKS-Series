####################aws_region############
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

####################cluster_name############
variable "cluster_name" {
  type    = string
  default = "Performance-Cluster"
}

####################vpc_cidr############
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

####################vpc_name############
variable "vpc_name" {
  type    = string
  default = "Performance-EKS-VPC"
}

####################env############
variable "env" {
  type    = string
  default = "Dev"
}

####################igw_name############
variable "igw_name" {
  type    = string
  default = "Performance-EKS-IGW"
}

####################public_subnet_count############
variable "public_subnet_count" {
  type    = number
  default = 6
}

####################public_subnet_cidrs############
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

####################public_subnet_name############
variable "public_subnet_name" {
  type    = list(string)
  default = ["EKS-Public-subnet-1", "EKS-Public-subnet-2", "EKS-Public-subnet-3", "EKS-Public-subnet-4", "EKS-Public-subnet-5", "EKS-Public-subnet-6"]
}

####################private_subnet_count############
variable "private_subnet_count" {
  type    = number
  default = 6
}

####################private_subnet_name############
variable "private_subnet_name" {
  type    = list(string)
  default = ["EKS-Private-Subnet-1", "EKS-Private-Subnet-2", "EKS-Private-Subnet-3", "EKS-Private-Subnet-4", "EKS-Private-Subnet-5", "EKS-Private-Subnet-6", ]
}

####################private_subnet_cidrs############
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24", "10.0.10.0/24", "10.0.11.0/24"]
}

####################availability_zones############
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

####################public_route_table_cidr############
variable "public_route_table_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

####################public_route_table_name############
variable "public_route_table_name" {
  type    = string
  default = "EKS-Public-Subnet-Route-Table"
}

####################private_route_table_name############
variable "private_route_table_name" {
  type    = string
  default = "EKS-Private-Subnet-Route-Table"
}

####################private_route_table_cidr############
variable "private_route_table_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

####################eip_name############
variable "eip_name" {
  type    = string
  default = "EKS-Elastic-IP-Address"
}

####################nat_gateway_name############
variable "nat_gateway_name" {
  type    = string
  default = "EKS-NAT-Gateway"
}

####################cluster_version############
variable "cluster_version" {
  type    = string
  default = "1.37"
}

####################endpoint_private_access############
variable "endpoint_private_access" {
  type    = bool
  default = true
}

####################endpoint_public_access############
variable "endpoint_public_access" {
  type    = bool
  default = false
}

####################node_group_instance_types############
variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

####################node_group_capacity_type############
variable "node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

####################node_group_desired_size############
variable "node_group_desired_size" {
  type    = number
  default = 1
}

####################node_group_max_size############
variable "node_group_max_size" {
  type    = number
  default = 10
}

####################node_group_min_size############
variable "node_group_min_size" {
  type    = number
  default = 1
}

####################vpn_domain############
variable "vpn_domain" {
  type    = string
  default = "eks-series.internal"
}

####################client_cidr_block############
variable "client_cidr_block" {
  type    = string
  default = "10.100.0.0/22"
}