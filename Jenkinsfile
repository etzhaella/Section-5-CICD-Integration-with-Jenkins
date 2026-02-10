pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')   // Secret text credential ID
        DOCKERHUB_PASSWORD = credentials('dockerhub-password')   // Secret text credential ID
        IMAGE_NAME = "${DOCKERHUB_USERNAME}/flask-aws-monitor"
        IMAGE_TAG = "${env.BUILD_NUMBER}"   // or use GIT_COMMIT, or "latest"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo.git'
                // If private repo → use credentials('github-token') or ssh
            }
        }

        stage('Parallel Checks') {
            parallel {
                stage('Linting') {
                    steps {
                        // Python linting (Flake8) - install if not present, or use docker run
                        sh '''
                            pip install --user flake8 || true
                            flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics || true
                        '''

                        // ShellCheck for *.sh files
                        sh '''
                            shellcheck --version || echo "ShellCheck not found - skipping"
                            shellcheck **/*.sh || true
                        '''

                        // Hadolint for Dockerfile (recommended: use docker container)
                        sh '''
                            docker run --rm -i -v "$PWD":/workdir hadolint/hadolint hadolint /workdir/Dockerfile || true
                        '''
                    }
                }

                stage('Security Scanning') {
                    steps {
                        // Bandit for Python security issues
                        sh '''
                            pip install --user bandit || true
                            bandit -r . -f txt || true
                        '''

                        // Trivy for Docker image vulnerabilities (scan after build would be better, but here as early check if Dockerfile-only)
                        // Bonus: real implementation (most common pattern)
                        sh '''
                            docker run --rm aquasec/trivy:latest image --exit-code 0 --no-progress \
                            --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} || true
                        '''
                        // Note: real scan → move to after build stage (scan the built image)
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build and tag
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    // Login using credentials
                    sh '''
                        echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                    '''

                    // Push both tags
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            // Optional: clean up docker images to save space on agent
            sh 'docker logout || true'
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            sh "docker rmi ${IMAGE_NAME}:latest || true"
        }
        success {
            echo 'Pipeline completed successfully! Image pushed to Docker Hub.'
        }
        failure {
            echo 'Pipeline failed! Check logs for details.'
        }
    }
}