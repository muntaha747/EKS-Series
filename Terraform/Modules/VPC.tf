#######################################VPC#######################################
resource "aws_vpc" "EKS_VPC" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
    Env  = var.env
  }
}
#######################################IGW#######################################
resource "aws_internet_gateway" "Internet_Gateway" {
  vpc_id = aws_vpc.EKS_VPC.id
  tags = {
    Name                                        = var.igw_name
    Env                                         = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
  depends_on = [aws_vpc.EKS_VPC]
}
########################################Public Subnet######################################
resource "aws_subnet" "Public_Subnets" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.EKS_VPC.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                        = element(var.public_subnet_name, count.index)
    Env                                         = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"                    = 1
  }
  depends_on = [aws_vpc.EKS_VPC]
}
########################################Private Subnets######################################
resource "aws_subnet" "Private_Subnets" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.EKS_VPC.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name                                        = element(var.private_subnet_name, count.index)
    Env                                         = var.env
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = 1
  }
  depends_on = [aws_vpc.EKS_VPC]
}
########################################Public Route Table######################################
resource "aws_route_table" "Public_Route_table" {
  count  = var.public_subnet_count
  vpc_id = aws_vpc.EKS_VPC.id
  route {
    cidr_block = var.public_route_table_cidr
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }
  tags = {
    Name = element(var.private_subnet_name, count.index)
    Env  = var.env
  }
  depends_on = [aws_subnet.Public_Subnets]
}
########################################Public Route Table subnet association######################################
resource "aws_route_table_association" "Public_route_table_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.Public_Subnets[count.index].id
  route_table_id = aws_route_table.Public_Route_table[count.index].id
  depends_on     = [aws_vpc.EKS_VPC, aws_subnet.Public_Subnets, aws_route_table.Public_Route_table]
}

########################################NAT Gateway######################################
resource "aws_eip" "nat_eip" {
  count  = 2
  domain = "vpc"
  tags = {
    Name = "EKS-NAT-EIP-${count.index + 1}"
    Env  = var.env
  }
  depends_on = [aws_internet_gateway.Internet_Gateway]
}

resource "aws_nat_gateway" "NAT_Gateway" {
  count         = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.Public_Subnets[count.index].id
  tags = {
    Name = "EKS-NAT-${count.index + 1}"
    Env  = var.env
  }
  depends_on = [aws_internet_gateway.Internet_Gateway]
}

resource "aws_route_table" "Private_Route_table" {
  count  = 2
  vpc_id = aws_vpc.EKS_VPC.id
  route {
    cidr_block     = var.private_route_table_cidr
    nat_gateway_id = aws_nat_gateway.NAT_Gateway[count.index].id
  }
  tags = {
    Name = "EKS-Private-RT-${count.index + 1}"
    Env  = var.env
  }
}