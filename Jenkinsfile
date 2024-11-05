pipeline {
    agent { label 'docker-node' } // Specify your Jenkins agent

    environment {
        DOCKER_HUB_REPO = 'dksavai/dksavai-test'  // Your Docker Hub repository
        DOCKER_IMAGE_TAG = 'frontend-dev'          // Custom tag for the Docker image
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    // Checkout the specific branch 'nodejs-backend'
                    checkout([$class: 'GitSCM', 
                              branches: [[name: 'react-frontend']], 
                              userRemoteConfigs: [[
                                  url: 'https://github.com/dhavalsavai/jenkins.git',
                                  credentialsId: 'github-id' // Add credentials for private repo
                              ]]
                    ])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG .'
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', 
                                                  usernameVariable: 'DOCKER_HUB_USER', 
                                                  passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                    // Log in to Docker Hub
                    sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                // Push the image to Docker Hub
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG"
            }
        }

        stage('Deploy on Jenkins Server') {
            steps {
                script {
                    // Deploy the application
                    sh """
                    docker pull $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG
                    docker stop my-react-app || true
                    docker rm my-react-app || true
                    docker run -d --name my-react-app -p 3002:80 $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG
                    """
                }
            }
        }
    }

    post { 
        always { 
            echo 'Pipeline execution complete.'
        }
    }
}

