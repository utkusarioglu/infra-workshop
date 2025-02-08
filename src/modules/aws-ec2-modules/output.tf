output "http" {
  description = "Access the instance from here"
  value       = "http://${module.ec2_instance.public_ip}"
}

output "curl" {
  description = "Curl call"
  value       = "curl http://${module.ec2_instance.public_ip}"
}

output "ssh" {
  description = "Connect through SSH"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${module.ec2_instance.public_ip}"
}
