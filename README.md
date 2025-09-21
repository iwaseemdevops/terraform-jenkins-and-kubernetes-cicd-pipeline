# End-to-End CI/CD Pipeline on AWS with Kubernetes

This project demonstrates a fully automated CI/CD pipeline for containerized microservices, built entirely on AWS Free Tier resources. It showcases modern DevOps practices by leveraging Infrastructure as Code, containerization, orchestration, and continuous delivery.

## 🚀 Architecture

The infrastructure is provisioned using Terraform, creating a secure VPC, a single EC2 instance, and private ECR repositories. The EC2 instance hosts Jenkins and a lightweight K3s Kubernetes cluster.

1.  **Infrastructure as Code (Terraform):** A custom VPC, public subnet, security groups, EC2 instance, and ECR repositories are defined and provisioned in code.
2.  **Automation Server (Jenkins):** Configured with plugins and credentials to automate the entire pipeline.
3.  **Orchestration (Kubernetes K3s):** A production-grade, lightweight K8s distribution manages the deployment and lifecycle of the microservices.
4.  **CI/CD Pipeline:** Automatically builds, tests, and deploys new versions of the application on every Git push.

## 🛠️ Technologies Implemented

| Category               | Technologies Used                         |
| ---------------------- | ----------------------------------------- |
| **Cloud Provider**     | AWS (EC2, ECR, VPC, IAM, Security Groups) |
| **Infrastructure**     | Terraform                                 |
| **CI/CD & Automation** | Jenkins, Docker, Bash Scripting           |
| **Orchestration**      | Kubernetes (K3s), kubectl                 |
| **Containers**         | Docker                                    |
| **Version Control**    | GitHub, GitHub Actions                    |
| **Monitoring**         | Kubernetes CLI                            |
| **Operating System**   | Amazon Linux 2                            |

## ⚙️ Project Features

- **100% Infrastructure as Code:** Entire environment is reproducible with a single `terraform apply` command.
- **Containerized Microservices:** Backend (Node.js) and Frontend (React) are packaged into Docker containers.
- **Private Container Registry:** Docker images are securely stored and versioned in AWS ECR.
- **Automated Deployment Pipeline:** Jenkins pipeline automatically triggers on code changes to build, push, and deploy.
- **Free Tier Optimized:** Architecture designed to operate within AWS Free Tier limits.

## 🧪 How to Run

1.  **Provision Infrastructure:**

    ```bash
    terraform init
    terraform apply
    ```

2.  **SSH into the EC2 instance** and run the setup script to install Jenkins, Docker, K3s, and Kubernetes.

3.  **Access Jenkins** at `http://13.235.0.29:8080` and configure the pipeline with your GitHub repository.

4.  **Push code to GitHub** to trigger the automated build and deployment.

5.  **Access the application** at `http://13.235.0.29:30000`.

## 🚧 Challenges & Solutions

- **Challenge: Resource Constraints on AWS Free Tier.**

  - **Solution:** Optimized the entire setup to run on a single `t2.micro` instance by installing Jenkins and K3s together, creating a swap file, and implementing strict Kubernetes resource limits.

- **Challenge: Configuring Kubernetes (K3s) for a Single Node.**

  - **Solution:** Modified the kubeconfig to use the node's private IP instead of localhost and configured Jenkins with the correct credentials to deploy to the cluster.

- **Challenge: Automating the End-to-End Process.**
  - **Solution:** Developed Bash scripts for initial server setup and authored a comprehensive Jenkinsfile that defines every stage of the pipeline, from code checkout to production deployment.
