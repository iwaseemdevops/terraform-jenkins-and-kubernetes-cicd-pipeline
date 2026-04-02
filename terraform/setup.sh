#!/bin/bash
set -e

echo "===== Updating system ====="
sudo yum update -y

echo "===== Creating 1GB swap file FIRST (required for t2.micro) ====="
if [ ! -f /swapfile ]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
    echo "Swap created and activated."
else
    echo "Swap file already exists, activating..."
    sudo swapon /swapfile || true
fi
free -h

echo "===== Installing Docker ====="
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

echo "===== Installing Java 17 (Amazon Corretto) ====="
wget -q https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.rpm
sudo rpm -ivh amazon-corretto-17-x64-linux-jdk.rpm
rm -f amazon-corretto-17-x64-linux-jdk.rpm
java -version

echo "===== Installing Jenkins ====="
sudo wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo usermod -a -G docker jenkins

echo "===== Setting Jenkins Java memory limits (critical for t2.micro) ====="
sudo mkdir -p /etc/systemd/system/jenkins.service.d
cat <<EOF | sudo tee /etc/systemd/system/jenkins.service.d/override.conf
[Service]
Environment="JAVA_OPTS=-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseStringDeduplication"
EOF
sudo systemctl daemon-reload

echo "===== Starting Jenkins ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Waiting for Jenkins to fully start (up to 3 minutes) ====="
for i in $(seq 1 18); do
    if sudo systemctl is-active --quiet jenkins; then
        echo "Jenkins is running."
        break
    fi
    echo "Waiting... ($((i * 10))s)"
    sleep 10
done
sudo systemctl status jenkins --no-pager | head -8

echo "===== Installing AWS CLI v2 ====="
sudo yum install -y unzip curl
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
aws --version

echo "===== Installing kubectl ====="
KUBECTL_VERSION="v1.29.0"
curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client --output=yaml

echo "===== Installing K3s (lightweight Kubernetes) ====="
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -
sudo systemctl enable k3s
sudo systemctl start k3s

echo "===== Waiting for K3s to be ready ====="
for i in $(seq 1 12); do
    if sudo kubectl get nodes 2>/dev/null | grep -q "Ready"; then
        echo "K3s node is Ready."
        break
    fi
    echo "Waiting for K3s... ($((i * 10))s)"
    sleep 10
done
sudo kubectl get nodes

echo "===== Configuring kubeconfig for ec2-user ====="
mkdir -p /home/ec2-user/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo sed -i "s/127.0.0.1/${LOCAL_IP}/" /home/ec2-user/.kube/config
sudo chmod 600 /home/ec2-user/.kube/config
echo "kubeconfig configured for ec2-user with local IP: ${LOCAL_IP}"

echo "===== Copying kubeconfig for Jenkins user ====="
sudo cp /etc/rancher/k3s/k3s.yaml /tmp/kubeconfig
sudo sed -i "s/127.0.0.1/${LOCAL_IP}/" /tmp/kubeconfig
sudo chown jenkins:jenkins /tmp/kubeconfig
sudo chmod 644 /tmp/kubeconfig
echo "kubeconfig copied for Jenkins user"

echo "===== Final verification ====="
echo "--- Memory ---"
free -h
echo "--- Swap ---"
swapon --show
echo "--- Docker ---"
docker --version
echo "--- Java ---"
java -version
echo "--- AWS CLI ---"
aws --version
echo "--- kubectl ---"
kubectl version --client --short 2>/dev/null || kubectl version --client
echo "--- Jenkins ---"
sudo systemctl status jenkins --no-pager | head -5
echo "--- K3s ---"
sudo systemctl status k3s --no-pager | head -5
echo "--- Nodes ---"
kubectl get nodes

echo "=========================================="
echo "Setup completed successfully!"
echo ""
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo ""
echo "Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "=========================================="