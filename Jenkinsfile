pipeline {
    agent {
        any {
            image 'python:3.12-slim'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
        IMAGE_NAME = "etzhaella/flask-aws-monitor"
        IMAGE_TAG = "latest"
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/etzhaella/Section-5-CICD-Integration-with-Jenkins.git'
            }
        }

        stage('Parallel Checks') {
            parallel {

                stage('Linting') {
                    steps {
                        echo "Running linting checks..."
                        sh '''
                            python --version
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
