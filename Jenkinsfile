pipeline {
    agent any

    environment {
        // GitHub repo URL and branch
        GIT_REPO_URL = 'https://github.com/etzhaella/Section-5-CICD-Integration-with-Jenkins.git'
        GIT_BRANCH   = 'main'

        // Docker Hub image (must be lowercase)
        IMAGE_NAME   = 'etzhaella/section5-flask-aws-monitor'
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Parallel Checks') {
            parallel {

                stage('Linting') {
                    steps {
                        sh '''
                            echo "Running Python linting with flake8 (mock)"
                            echo "Running Shell linting with shellcheck (mock)"
                            echo "Running Dockerfile linting with hadolint (mock)"
                        '''
                    }
                }

                stage('Security Scan') {
                    steps {
                        sh '''
                            echo "Running Bandit security scan for Python (mock)"
                            echo "Running Trivy security scan for Docker image (mock)"
                        '''
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image from app/Dockerfile"
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ./app
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Stop Jenkins Container') {
            steps {
                sh '''
                    docker stop jenkins
                    docker rm jenkins
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKERHUB_USERNAME',
                    passwordVariable: 'DOCKERHUB_PASSWORD'
                )]) {
                    sh '''
                        echo "Login to Docker Hub"
                        echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

                        echo "Pushing Docker image to Docker Hub"
                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${IMAGE_NAME}:latest

                        echo "Logout from Docker Hub"
                        docker logout
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}
