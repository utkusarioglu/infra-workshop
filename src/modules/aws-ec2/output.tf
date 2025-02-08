output "ssh_connection_string" {
  description = "SSH connection string to access the instance"
  value       = "ssh -i artifacts/private-key.pem ec2-user@${aws_instance.bird.public_ip}"
}

output "web_address" {
  description = "Visit the website here"
  value       = "http://${aws_instance.bird.public_ip}"
}
