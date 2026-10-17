####################################################CA.Key & CA.CRT###########################################################
resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_crt" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "VPN Root CA"
    organization = "EKS-Series"
  }

  validity_period_hours = 8600
  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
    "key_encipherment"
  ]
}

####################################################Server Key & Server Certificate###########################################################

resource "tls_private_key" "server_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "csr_server" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name  = "server.${var.vpn_domain}"
    organization = "EKS-Series"
  }

  dns_names = [
    "server.${var.vpn_domain}",
    "vpn.${var.vpn_domain}"
  ]
}

resource "tls_locally_signed_cert" "server_crt" {
  cert_request_pem   = tls_cert_request.csr_server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_crt.cert_pem

  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]

  set_subject_key_id = true
}

####################################################Client Key & Client Certificate###########################################################

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "csr_client" {
  private_key_pem = tls_private_key.client_key.private_key_pem

  subject {
    common_name  = "client.${var.vpn_domain}"
    organization = "EKS-Series"
  }
}

resource "tls_locally_signed_cert" "client_crt" {
  cert_request_pem   = tls_cert_request.csr_client.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_crt.cert_pem

  validity_period_hours = 8600

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
  ]

  set_subject_key_id = true
}

####################################################Save Files###########################################################
resource "local_file" "ca_crt" {
  filename = "certs/ca.crt"
  content  = tls_self_signed_cert.ca_crt.cert_pem
}

resource "local_sensitive_file" "ca_key" {
  filename        = "certs/ca.key"
  content         = tls_private_key.ca_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "server_crt" {
  filename = "certs/server.crt"
  content  = tls_locally_signed_cert.server_crt.cert_pem
}

resource "local_sensitive_file" "server_key" {
  filename        = "certs/server.key"
  content         = tls_private_key.server_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "client_crt" {
  filename = "certs/client.crt"
  content  = tls_locally_signed_cert.client_crt.cert_pem
}

resource "local_sensitive_file" "client_key" {
  filename        = "certs/client.key"
  content         = tls_private_key.client_key.private_key_pem
  file_permission = "0600"
}