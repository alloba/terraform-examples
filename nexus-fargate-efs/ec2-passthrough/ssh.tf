resource "tls_private_key" "testing_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "testing_ssh_key" {
  public_key = tls_private_key.testing_tls_key.public_key_openssh
  key_name   = "ssh-key-val"
  provisioner "local-exec" {
    command = "echo '${tls_private_key.testing_tls_key.private_key_pem}' > ./myKey.pem"
  }
}