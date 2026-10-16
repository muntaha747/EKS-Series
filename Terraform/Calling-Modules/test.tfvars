#This has highest precidence over vars.
####################aws_region############
aws_region = "us-east-1"

####################cluster_name############
cluster_name = "Performance-Cluster"

####################vpc_cidr############
vpc_cidr = "10.0.0.0/16"

####################vpc_name############
vpc_name = "Performance-EKS-VPC"

####################env############
env = "Dev"

####################igw_name############
igw_name = "Performance-EKS-IGW"

####################public_subnet_count############
public_subnet_count = 6

####################public_subnet_cidrs############
public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

####################public_subnet_name############
public_subnet_name = ["EKS-Public-subnet-1", "EKS-Public-subnet-2", "EKS-Public-subnet-3", "EKS-Public-subnet-4", "EKS-Public-subnet-5", "EKS-Public-subnet-6"]

####################private_subnet_count############
private_subnet_count = 6

####################private_subnet_name############
private_subnet_name = ["EKS-Private-Subnet-1", "EKS-Private-Subnet-2", "EKS-Private-Subnet-3", "EKS-Private-Subnet-4", "EKS-Private-Subnet-5", "EKS-Private-Subnet-6"]

####################private_subnet_cidrs############
private_subnet_cidrs = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24", "10.0.10.0/24", "10.0.11.0/24"]

####################availability_zones############
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]

####################public_route_table_cidr############
public_route_table_cidr = "0.0.0.0/0"

####################public_route_table_name############
public_route_table_name = "EKS-Public-Subnet-Route-Table"

####################private_route_table_name############
private_route_table_name = "EKS-Private-Subnet-Route-Table"

####################private_route_table_cidr############
private_route_table_cidr = "0.0.0.0/0"

####################eip_name############
eip_name = "EKS-Elastic-IP-Address"

####################nat_gateway_name############
nat_gateway_name = "EKS-NAT-Gateway"

####################cluster_version############
# Check the real list first: aws eks describe-cluster-versions --query "clusterVersions[].clusterVersion"
cluster_version = "1.37"

####################endpoint_private_access############
endpoint_private_access = true

####################endpoint_public_access############
endpoint_public_access = false

####################node_group_instance_types############
node_group_instance_types = ["t3.medium"]

####################node_group_capacity_type############
node_group_capacity_type = "ON_DEMAND"

####################node_group_desired_size############
node_group_desired_size = 1

####################node_group_max_size############
node_group_max_size = 10

####################node_group_min_size############
node_group_min_size = 1

####################vpn_domain############
vpn_domain = "eks-series.internal"

####################client_cidr_block############
client_cidr_block = "10.100.0.0/22"