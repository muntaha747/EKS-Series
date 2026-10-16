###########################################################Importing Certificate Authority#################################################

resource "aws_acm_certificate" "ca_crt" {
  private_key      = tls_private_key.ca_key.private_key_pem
  certificate_body = tls_self_signed_cert.ca_crt.cert_pem

  tags = {
    Key = "ca-cred"
  }
}

###########################################################Importing Server certificate#################################################
resource "aws_acm_certificate" "server_cert" {
  private_key       = tls_private_key.server_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.server_crt.cert_pem
  certificate_chain = tls_self_signed_cert.ca_crt.cert_pem

  tags = {
    Key = "server-cred"
  }
}

###########################################################Importing Client certificate#################################################
resource "aws_acm_certificate" "client_cert" {
  private_key       = tls_private_key.client_key.private_key_pem
  certificate_body  = tls_locally_signed_cert.client_crt.cert_pem
  certificate_chain = tls_self_signed_cert.ca_crt.cert_pem

  tags = {
    Key = "client-cred"
  }
}

# This is the certificate which will be stored in AWS ACM.