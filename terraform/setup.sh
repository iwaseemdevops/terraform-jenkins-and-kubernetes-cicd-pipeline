#!/bin/bash
set -e

echo "===== Updating system ====="
sudo yum update -y

echo "===== Installing Docker ====="
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

echo "===== Installing Java 17 (Amazon Corretto) ====="
wget -q https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.rpm
sudo rpm -ivh amazon-corretto-17-x64-linux-jdk.rpm
rm -f amazon-corretto-17-x64-linux-jdk.rpm

echo "===== Installing Jenkins ====="
sudo wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo usermod -a -G docker jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Installing AWS CLI v2 ====="
sudo yum install -y unzip curl
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

echo "===== Installing kubectl ====="
KUBECTL_VERSION=$(curl -s -L https://dl.k8s.io/release/stable.txt)
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "===== Creating 1GB swap file (for t2.micro) ====="
sudo dd if=/dev/zero of=/swapfile bs=1M count=1024 status=none
sudo chmod 600 /swapfile
sudo mkswap /swapfile > /dev/null
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

echo "===== Installing K3s (lightweight Kubernetes) ====="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -
sudo systemctl enable k3s
sudo systemctl start k3s

echo "===== Configuring kubeconfig for ec2-user ====="
mkdir -p /home/ec2-user/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo sed -i "s/127.0.0.1/${LOCAL_IP}/" /home/ec2-user/.kube/config
sudo chmod 600 /home/ec2-user/.kube/config

echo "===== Copying kubeconfig for Jenkins user ====="
sudo cp /etc/rancher/k3s/k3s.yaml /tmp/kubeconfig
sudo chown jenkins:jenkins /tmp/kubeconfig
sudo chmod 644 /tmp/kubeconfig

echo "===== Verifying installations ====="
java -version
docker --version
aws --version
kubectl version --client --output=yaml
sudo systemctl status jenkins --no-pager | head -5
sudo systemctl status k3s --no-pager | head -5

echo "=========================================="
echo "Setup completed successfully!"
echo "Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "=========================================="