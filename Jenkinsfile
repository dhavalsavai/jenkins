#!/usr/bin/env groovy

pipeline {
    agent any
    environment {
        DOCKER_HUB_REPO = 'dksavai/dksavai-test'  // Your Docker Hub repository
        DOCKER_IMAGE_TAG = 'backend-test:dev'  // Custom tag format
    }
    stages {
        stage ('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG .'
                }
            }
        }
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', 
                                                  usernameVariable: 'DOCKER_HUB_USER', 
                                                  passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                    sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin"
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG"
            }
        }
        stage('Deploy on Jenkins Server') {
            steps {
                script {
                    sh """
                    docker pull $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG
                    docker stop test_backend || true
                    docker rm test_backend || true
                    docker run -d --name test_backend -p 3000:3000 $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG
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

