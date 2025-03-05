output "ssh_dns" {
  description = "Connect through SSH DNS"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${module.records.route53_record_name["${local.subdomain} A"]}"
}

output "ssh_ip" {
  description = "Connect through SSH DNS"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${module.ec2_instance.public_ip}"
}

output "ip" {
  description = "Visit the website here"
  value       = "http://${module.ec2_instance.public_ip}"
}

output "dns" {
  description = "Visit the website here"
  value       = "https://${module.records.route53_record_name["${local.subdomain} A"]}"
}
