#!/bin/bash
set -e

echo "===== Installing minimal dependencies ====="
sudo yum install -y curl wget tar

echo "===== Installing K3s (no SELinux) ====="
export INSTALL_K3S_SKIP_SELINUX_RPM=true
curl -sfL https://get.k3s.io | INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_EXEC="--disable selinux --disable traefik --disable servicelb" sh -

echo "===== Enabling and starting K3s ====="
sudo systemctl enable k3s
sudo systemctl start k3s
sleep 10

echo "===== Configuring kubeconfig for ec2-user ====="
mkdir -p /home/ec2-user/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config
LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sudo sed -i "s/127.0.0.1/$LOCAL_IP/" /home/ec2-user/.kube/config
sudo chmod 600 /home/ec2-user/.kube/config

echo "===== Installing kubectl ====="
# Use a fixed version instead of querying the latest to avoid formatting issues
KUBECTL_VERSION="v1.29.0"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "===== K3s and kubectl installed successfully ====="
kubectl get nodes