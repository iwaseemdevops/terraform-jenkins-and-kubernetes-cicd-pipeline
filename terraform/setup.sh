#!/bin/bash
set -e

echo "===== Updating system ====="
sudo yum update -y

echo "===== Installing Docker ====="
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user

# Limit Docker memory usage
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"3"}}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker

echo "===== Installing Java 17 ====="
sudo yum install -y java-17-amazon-corretto

echo "===== Installing Jenkins (LIGHT MODE) ====="
sudo wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins

# Reduce Jenkins memory HARD
sudo sed -i 's/JENKINS_JAVA_OPTIONS=.*/JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Xmx256m"/' /etc/sysconfig/jenkins

sudo usermod -aG docker jenkins

# DO NOT auto start Jenkins
sudo systemctl disable jenkins

echo "===== Installing AWS CLI ====="
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

echo "===== Installing K3s (Manual Mode) ====="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb --disable metrics-server" sh -

# Disable auto start (VERY IMPORTANT)
sudo systemctl disable k3s

echo "===== Creating Swap (2GB enough) ====="
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# Reduce swap usage
echo 'vm.swappiness=5' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "===== Setup Complete ====="