# security_groups.tf
resource "aws_security_group" "cicd_sg" {
  name        = "cicd_sg"
  description = "Allow traffic for CI/CD server"
  vpc_id      = aws_vpc.main.id

  # Allow SSH from your IP only
  ingress {
    description = "SSH from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["103.203.45.139/32"] # REPLACE WITH YOUR IP
  }

  # Allow HTTP for Jenkins UI
  ingress {
    description = "HTTP for Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NodePort range for Kubernetes services
  ingress {
    description = "NodePort Range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CI-CD-Server-SG"
  }
}


