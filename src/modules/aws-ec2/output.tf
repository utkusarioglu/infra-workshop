output "ssh-dns" {
  description = "Connect through SSH DNS"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${aws_route53_record.subdomain.name}"
}

output "ssh-ip" {
  description = "Connect through SSH DNS"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${aws_instance.bird.public_ip}"
}

output "ip" {
  description = "Visit the website here"
  value       = "http://${aws_instance.bird.public_ip}"
}

output "dns" {
  description = "Visit the website here"
  value       = "https://${aws_route53_record.subdomain.name}"
}
