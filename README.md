# End-to-End CI/CD Pipeline on AWS with Kubernetes

This project demonstrates a fully automated CI/CD pipeline for containerized microservices, built entirely on AWS Free Tier resources. It showcases modern DevOps practices by leveraging Infrastructure as Code, containerization, orchestration, and continuous delivery.

## 🚀 Architecture

![Architecture Diagram](https://mermaid.ink/svg/eyJjb2RlIjoiZmxvd2NoYXJ0IFREXG4gICAgc3ViZ3JhcGggXCJWZXJzaW9uIENvbnRyb2xcIlxuICAgICAgICBHaXRIdWJbR2l0SHViIFJlcG9zaXRvcnldXG4gICAgZW5kXG5cbiAgICBzdWJncmFwaCBcIkFXUyBDbG91ZCAoUHJvdmlzaW9uZWQgYnkgVGVycmFmb3JtXClcIlxuICAgICAgICBzdWJncmFwaCBWUFNbVlBTXVxuICAgICAgICAgICAgc3ViZ3JhcGggXCJQdWJsaWMgU3VibmV0XCJcbiAgICAgICAgICAgICAgICBFQzJbRUMyIEluc3RhbmNlIHRyYWluc2NvcmVdXG4gICAgICAgICAgICBlbmRcbiAgICAgICAgICAgIEVDUltFbGFzdGljIENvbnRhaW5lciBSZWdpc3RyeSBdXG4gICAgICAgIGVuZFxuICAgIGVuZFxuXG4gICAgc3ViZ3JhcGggXCJLdWJlcm5ldGVzIENsdXN0ZXIgKEszcyBvbiBFQzIpXCJcbiAgICAgICAgRnJvbnRlbmRQb2RbRnJvbnRlbmQgUG9kXVxuICAgICAgICBCYWNrZW5kUG9kW0JhY2tlbmQgUG9kXVxuICAgICAgICBGcm9udGVuZFN2Y1tGcm9udGVuZCBTZXJ2aWNlXVxuICAgICAgICBCYWNrZW5kU3ZjW0JhY2tlbmQgU2VydmljZV1cbiAgICAgICAgRnJvbnRlbmRQb2QgLS0-fENhbGxzfCBCYWNrZW5kU3ZjXG4gICAgZW5kXG5cbiAgICBVc2VyW0RldmVsb3Blcl0gLS0-fGdpdCBwdXNofCBHaXRIdWJcbiAgICBHaXRIdWIgLS0-fFRyaWdnZXJzIFdlYmhvb2t8IEplbmtpbnNcblxuICAgIHN1YmdyYXBoIEplbmtpbnNbXCJKZW5raW5zIFNlcnZlciAob24gRUMyKVwiXVxuICAgICAgICBQaXBlbGluZVtKZW5raW5zIFBpcGVsaW5lXVxuICAgIGVuZFxuXG4gICAgUGlwZWxpbmUgLS0-fDEuIENoZWNrb3V0IENvZGV8IEdpdEh1YlxuICAgIFBpcGVsaW5lIC0tPnwyLiBCdWlsZHMmIFRlc3RzfCBEb2NrZXJcbiAgICBQaXBlbGluZSAtLT58My4gUHVzaGVzIEltYWdlfCBFQ1JcbiAgICBQaXBlbGluZSAtLT58NC4gRGVwbG95c3wgSzNzXG5cbiAgICBFbmRVc2VyW0VuZCBVc2VyXSAtLT58QWNjZXNzZXMgQXBwbGljYXRpb258IEZyb250ZW5kU3ZjIiwibWVybWFpZCI6eyJ0aGVtZSI6ImRlZmF1bHQifSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)

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

3.  **Access Jenkins** at `http://<EC2_PUBLIC_IP>:8080` and configure the pipeline with your GitHub repository.

4.  **Push code to GitHub** to trigger the automated build and deployment.

5.  **Access the application** at `http://<EC2_PUBLIC_IP>:30000`.

## 🚧 Challenges & Solutions

- **Challenge: Resource Constraints on AWS Free Tier.**

  - **Solution:** Optimized the entire setup to run on a single `t2.micro` instance by installing Jenkins and K3s together, creating a swap file, and implementing strict Kubernetes resource limits.

- **Challenge: Configuring Kubernetes (K3s) for a Single Node.**

  - **Solution:** Modified the kubeconfig to use the node's private IP instead of localhost and configured Jenkins with the correct credentials to deploy to the cluster.

- **Challenge: Automating the End-to-End Process.**
  - **Solution:** Developed Bash scripts for initial server setup and authored a comprehensive Jenkinsfile that defines every stage of the pipeline, from code checkout to production deployment.

## 📂 Repository Structure
