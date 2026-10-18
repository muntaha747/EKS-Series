resource "aws_security_group" "vpn_security_group" {
  name        = "vpn-endpoint-sg"
  description = "Allow VPN traffic to VPC"
  vpc_id      = aws_vpc.EKS_VPC.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Env = var.env }
}


########################################################AWS Client VPN Association with the subnet##################################

resource "aws_ec2_client_vpn_endpoint" "VPN_Client" {
  description            = "terraform-clientvpn-example"
  server_certificate_arn = aws_acm_certificate.server_cert.arn
  client_cidr_block      = var.client_cidr_block
  vpc_id = aws_vpc.EKS_VPC.id
  split_tunnel = true

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.ca_crt.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.vpn_logs.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.vpn_logs.name
  }
  session_timeout_hours = 8

  client_login_banner_options {
    enabled = true
    banner_text = "This AWS VPN is for authorized users only"
  }
}

########################################################AWS Client VPN Association with the subnet##################################

resource "aws_ec2_client_vpn_network_association" "vpn-subnet-association" {
  count = 2
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.VPN_Client.id
  subnet_id              = aws_subnet.Private_Subnets[count.index].id
}

########################################################AWS Client VPN Authorization rule##################################

resource "aws_ec2_client_vpn_authorization_rule" "vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.VPN_Client.id
  target_network_cidr    = var.vpc_cidr  # <--- CHANGED: Allows the whole VPC (10.0.0.0/16)
  authorize_all_groups   = true
}

# ============= CloudWatch Logs for VPN ===============

resource "aws_cloudwatch_log_group" "vpn_logs" {
    # encrypted by default
    name              = "/aws/vpn/${var.vpn_domain}"
    retention_in_days = 2192 # 6 years
}

resource "aws_cloudwatch_log_stream" "vpn_logs" {
  name           = "vpn-connection-logs"
  log_group_name = aws_cloudwatch_log_group.vpn_logs.name
}

output "client_key" {
  value     = tls_private_key.client_key.private_key_pem
  sensitive = true
}

output "client_cert" {
  value = tls_locally_signed_cert.client_crt.cert_pem
}