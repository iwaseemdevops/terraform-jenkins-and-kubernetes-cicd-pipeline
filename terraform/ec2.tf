# ec2.tf
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_key_pair" "cicd_key" {
  key_name   = "cicd-key"
  public_key = file("/home/obito/.ssh/id_ed25519.pub")
}

# Single server for both Jenkins and Kubernetes (Free Tier)
resource "aws_instance" "cicd_server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro" # Free Tier eligible
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.cicd_sg.id]
  key_name               = aws_key_pair.cicd_key.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = file("setup.sh")
  

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = "CI-CD-Server"
  }
}
