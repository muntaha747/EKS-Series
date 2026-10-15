variable "cluster_name" {
  type    = string
  default = "EKS-Performance-Cluster"
}



variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}



variable "vpc_name" {
  type    = string
  default = "Performance-EKS-VPC"
}



variable "env" {}



variable "igw_name" {
  type    = string
  default = "Performance-EKS-IGW"
}


variable "public_subnet_count" {
  type    = number
  default = 6
}


variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.0.1/24", "10.0.0.2/24", "10.0.0.3/24", "10.0.0.4/24", "10.0.0.5/24"]
}


variable "public_subnet_name" {
  type    = list(string)
  default = ["EKS-Public-subnet-1", "EKS-Public-subnet-2", "EKS-Public-subnet-3", "EKS-Public-subnet-4", "EKS-Public-subnet-5", "EKS-Public-subnet-6"]
}

variable "private_subnet_count" {
  type    = number
  default = 6
}

variable "private_subnet_name" {
  type    = list(string)
  default = ["EKS-Private-Subnet-1", "EKS-Private-Subnet-2", "EKS-Private-Subnet-3", "EKS-Private-Subnet-4", "EKS-Private-Subnet-5", "EKS-Private-Subnet-6", ]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.0.6/24", "10.0.0.7/24", "10.0.0.8/24", "10.0.0.9/24", "10.0.0.11/24", "10.0.0.12/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

variable "public_route_table_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "public_route_table_name" {
  type    = string
  default = "EKS-Public-Subnet-Route-Table"
}

variable "private_route_table_name" {
  type    = string
  default = "EKS-Private-Subnet-Route-Table"
}

variable "private_route_table_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "eip_name" {
  type    = string
  default = "EKS-Elastic-IP-Address"
}

variable "nat_gateway_name" {
  type    = string
  default = "EKS-NAT-Gateway"
}

variable "cluster_version" {
  type    = string
  default = "1.37"
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "node_group_instance_types" {
  type = list(string)

}
variable "node_group_capacity_type" {
  type = string

}

variable "node_group_desired_size" {
  type = number
}
variable "node_group_max_size" {
  type = number
}

variable "node_group_min_size" {
  type = number
}

variable "vpn_domain" {

}
variable "client_cidr_block" {

}