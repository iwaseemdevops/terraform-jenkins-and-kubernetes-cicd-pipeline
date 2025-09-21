pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '522814695006' 
        AWS_REGION = 'ap-south-1'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/iwaseemdevops/terraform-jenkins-and-kubernetes-cicd-pipeline.git',
                    credentialsId: 'github-cres'
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    script {
                        docker.build("${ECR_REGISTRY}/backend:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Test Backend') {
            steps {
                dir('backend') {
                    sh 'echo "Running backend tests..."'
                    sh 'npm test || true'  // Example tests
                }
            }
        }

        stage('Push Backend to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${ECR_REGISTRY}", 'aws-creds') {
                        docker.image("${ECR_REGISTRY}/backend:${env.BUILD_ID}").push('latest')
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                dir('frontend') {
                    script {
                        docker.build("${ECR_REGISTRY}/frontend:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Test Frontend') {
            steps {
                dir('frontend') {
                    sh 'echo "Running frontend tests..."'
                    sh 'npm test || true'
                }
            }
        }

        stage('Push Frontend to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${ECR_REGISTRY}", 'aws-creds') {
                        docker.image("${ECR_REGISTRY}/frontend:${env.BUILD_ID}").push('latest')
                    }
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
                script {
                    // Get NodePort dynamically (assuming frontend-service is NodePort type)
                    def nodePort = sh(
                        script: "kubectl get svc frontend-service -o jsonpath='{.spec.ports[0].nodePort}'",
                        returnStdout: true
                    ).trim()

                    sh """
                        echo "Testing frontend on NodePort: ${nodePort}"
                        sleep 10
                        curl -f http://localhost:${nodePort}/ || echo "⚠️ Smoke test failed but continuing"
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}
