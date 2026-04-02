pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '924609080533' 
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/iwaseemdevops/terraform-jenkins-and-kubernetes-cicd-pipeline.git'
            }
        }

        stage('Build Backend') {
            steps {
                dir('microservices/backend') {
                    script {
                        docker.build("${ECR_REGISTRY}/backend:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Test Backend') {
            steps {
                dir('microservices/backend') {
                    sh 'echo "Skipping backend tests (npm not installed on host)"'
                }
            }
        }

        stage('Push Backend to ECR') {
            steps {
                script {
                    // Login using EC2 instance IAM role (no credentials needed)
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                    docker.image("${ECR_REGISTRY}/backend:${env.BUILD_ID}").push('latest')
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('microservices/frontend') {
                    script {
                        docker.build("${ECR_REGISTRY}/frontend:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Test Frontend') {
            steps {
                dir('microservices/frontend') {
                    sh 'echo "Skipping frontend tests (npm not installed on host)"'
                }
            }
        }

        stage('Push Frontend to ECR') {
            steps {
                script {
                   
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                    """
                    docker.image("${ECR_REGISTRY}/frontend:${env.BUILD_ID}").push('latest')
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([string(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG_CONTENT')]) {
                    writeFile file: 'kubeconfig.yaml', text: "${KUBECONFIG_CONTENT}"
                    sh """
                        export KUBECONFIG=kubeconfig.yaml
                        kubectl set image deployment/backend-deployment backend=${ECR_REGISTRY}/backend:latest
                        kubectl set image deployment/frontend-deployment frontend=${ECR_REGISTRY}/frontend:latest

                        kubectl rollout status deployment/backend-deployment --timeout=120s
                        kubectl rollout status deployment/frontend-deployment --timeout=120s
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                withCredentials([string(credentialsId: 'k3s-kubeconfig', variable: 'KUBECONFIG_CONTENT')]) {
                    writeFile file: 'kubeconfig.yaml', text: "${KUBECONFIG_CONTENT}"
                    script {
                        def nodePort = sh(
                            script: "kubectl --kubeconfig=kubeconfig.yaml get svc frontend-service -o jsonpath='{.spec.ports[0].nodePort}'",
                            returnStdout: true
                        ).trim()
                        def nodeIp = sh(
                            script: "kubectl --kubeconfig=kubeconfig.yaml get nodes -o jsonpath='{.items[0].status.addresses[?(@.type==\"ExternalIP\")].address}'",
                            returnStdout: true
                        ).trim()
                        if (!nodeIp) {
                            nodeIp = sh(
                                script: "kubectl --kubeconfig=kubeconfig.yaml get nodes -o jsonpath='{.items[0].status.addresses[?(@.type==\"InternalIP\")].address}'",
                                returnStdout: true
                            ).trim()
                        }
                        sh """
                            echo "Smoke testing http://${nodeIp}:${nodePort}/"
                            curl --fail --retry 5 --retry-delay 10 http://${nodeIp}:${nodePort}/
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        always {
            sh 'docker system prune -f || true'
            sh 'rm -f kubeconfig.yaml'
        }
    }
}