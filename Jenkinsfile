pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
        IMAGE_NAME = "your-dockerhub-username/flask-aws-monitor"   // ← להחליף לשם המשתמש שלך
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'  // ← להחליף ל־repo שלך
            }
        }

        stage('Parallel Checks') {
            parallel {

                stage('Linting') {
                    steps {
                        echo "Running linting checks..."
                        sh '''
                            echo "Mock: Running Flake8..."
                            echo "Mock: Running ShellCheck..."
                            echo "Mock: Running Hadolint..."
                        '''
                    }
                }

                stage('Security Scan') {
                    steps {
                        echo "Running security scans..."
                        sh '''
                            echo "Mock: Running Bandit..."
                            echo "Mock: Running Trivy..."
                        '''
                    }
                }

            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "Logging in to Docker Hub..."
                    echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

                    echo "Pushing Docker image..."
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed! Check logs for details."
        }
    }
}