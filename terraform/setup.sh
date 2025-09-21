# #!/bin/bash
# set -e
# # Update system
# sudo yum update -y

# # Install Docker
# sudo amazon-linux-extras install docker -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user

# # Install Jenkins repo
# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# # Enable and install Amazon Corretto 17
# sudo amazon-linux-extras enable corretto17
# sudo yum clean metadata
# sudo yum install -y java-17-amazon-corretto-devel

# # Install Jenkins
# sudo yum install -y jenkins
# sudo usermod -a -G docker jenkins
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# # Install unzip (needed for AWS CLI)
# sudo yum install -y unzip

# # Install AWS CLI v2
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install

# # Install kubectl
# curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl
# sudo mv kubectl /usr/local/bin/

# # Install growpart and resize root volume
# sudo yum install -y cloud-utils-growpart xfsprogs
# sudo growpart /dev/xvda 1
# sudo xfs_growfs /

# # Create 1GB swap file
# sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab


# # Install K3s (lightweight Kubernetes)

# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -

# # Setup kubeconfig for ec2-user
# mkdir -p /home/ec2-user/.kube
# cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
# chown ec2-user:ec2-user /home/ec2-user/.kube/config
# sed -i "s/127.0.0.1/$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)/" /home/ec2-user/.kube/config
# chmod 600 /home/ec2-user/.kube/config

# # Setup kubeconfig for Jenkins
# chmod 644 /etc/rancher/k3s/k3s.yaml
# cp /etc/rancher/k3s/k3s.yaml /tmp/kubeconfig
# chown jenkins:jenkins /tmp/kubeconfig


# #!/bin/bash
# set -e

# # ===============================
# # Update system
# # ===============================
# sudo yum update -y

# # ===============================
# # Install Docker
# # ===============================
# sudo amazon-linux-extras install docker -y
# sudo service docker start
# sudo usermod -a -G docker ec2-user

# # ===============================
# # Install Jenkins + Java 17
# # ===============================
# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# sudo amazon-linux-extras enable corretto17
# sudo yum clean metadata
# sudo yum install -y java-17-amazon-corretto-devel jenkins

# # Add Jenkins to docker group
# sudo usermod -a -G docker jenkins
# sudo systemctl enable jenkins
# sudo systemctl start jenkins

# # ===============================
# # Install unzip (needed for AWS CLI)
# # ===============================
# sudo yum install -y unzip

# # ===============================
# # Install AWS CLI v2
# # ===============================
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install
# rm -rf awscliv2.zip aws

# # ===============================
# # Install kubectl
# # ===============================
# curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
# chmod +x kubectl
# sudo mv kubectl /usr/local/bin/

# # ===============================
# # Resize root volume
# # ===============================
# sudo yum install -y cloud-utils-growpart xfsprogs
# sudo growpart /dev/xvda 1
# sudo xfs_growfs /

# # ===============================
# # Create 1GB swap file
# # ===============================
# sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
# sudo chmod 600 /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile
# echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

# # ===============================
# # Install K3s (lightweight Kubernetes)
# # ===============================
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb" sh -
# sudo systemctl enable k3s
# sudo systemctl start k3s

# # ===============================
# # Setup kubeconfig for ec2-user
# # ===============================
# mkdir -p /home/ec2-user/.kube
# sudo cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
# sudo chown ec2-user:ec2-user /home/ec2-user/.kube/config

# LOCAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
# sudo sed -i "s/127.0.0.1/$LOCAL_IP/" /home/ec2-user/.kube/config
# sudo chmod 600 /home/ec2-user/.kube/config

# # ===============================
# # Setup kubeconfig for Jenkins
# # ===============================
# sudo cp /etc/rancher/k3s/k3s.yaml /tmp/kubeconfig
# sudo chown jenkins:jenkins /tmp/kubeconfig
# sudo chmod 644 /tmp/kubeconfig

# # ===============================
# # Update PATH for current session
# # ===============================
# export PATH=$PATH:/usr/local/bin

# # ===============================
# # Verify installations
# # ===============================
# echo "Verifying installations..."
# java -version
# docker --version
# aws --version
# kubectl version --client
# sudo systemctl status jenkins --no-pager
# sudo systemctl status k3s --no-pager

# echo "Setup completed successfully!"
# echo "Jenkins admin password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"


#!/bin/bash
set -e

echo "===== Updating system ====="
sudo yum update -y

echo "===== Installing Docker ====="
sudo amazon-linux-extras install docker -y || sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

echo "===== Installing Java 17 (Amazon Corretto) ====="
wget https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.rpm
sudo rpm -ivh amazon-corretto-17-x64-linux-jdk.rpm
rm -f amazon-corretto-17-x64-linux-jdk.rpm
java -version

echo "===== Installing Jenkins ====="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo usermod -a -G docker jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Installing AWS CLI v2 ====="
sudo yum install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
aws --version

echo "===== Installing kubectl ====="
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt | tr -d '\r\n')
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
kubectl version --client

echo "===== Creating 1GB swap file ====="
sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab

echo "===== Setup completed ====="
echo "Jenkins admin password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
