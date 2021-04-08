##################################################
# Outputs
##################################################

output "vm_fqdn" {
  value = "${azurerm_public_ip.pip.fqdn}"
}

output "tls_private_key" { 
  value = "${tls_private_key.sshkey.private_key_pem}"
}