# outputs.tf
output "server_public_ip" {
  description = "The public IP address of the CI/CD server"
  value       = aws_instance.cicd_server.public_ip
}

output "backend_ecr_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend.repository_url
}