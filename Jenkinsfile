#!/usr/bin/env groovy

def deploy_with_helm(environment, dockerImageTag) {
    script {
        sh """
            echo "Deploying to $environment using Helm"
            hostname -I
            helm upgrade --install react-app ./react-app \\
                --namespace $environment \\
                --set image.repository=$DOCKER_HUB_REPO \\
                --set image.tag=$dockerImageTag \\
                --set app.environment=$environment
        """
    }
}

def deploy_docker(servers, branch) {
    script {
        for (item in servers) {
            sh """
                echo "Deploying to ${item} for branch ${branch}"
                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${item} bash -c "'
                    hostname -I
                    echo Deployment on server: ${item}
                '"
            """
        }
    }
}

pipeline {
    agent {
        node {
            label 'docker-node'
        }
    }
    environment {
        DOCKER_HUB_REPO = 'dksavai/dksavai-test'  // Your Docker Hub repository
        DOCKER_IMAGE_TAG = 'frontend-dev' 
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm: [
                    $class: 'GitSCM',
                    branches: scm.branches,
                    doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                    extensions: [[$class: 'CloneOption', noTags: false, shallow: false, depth: 0, reference: '']],
                    userRemoteConfigs: scm.userRemoteConfigs
                ]
            }
        }
        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                script {
                    def tag = env.BRANCH_NAME == 'prod' ? 'prod' : 'dev'
                    sh "docker build -t $DOCKER_HUB_REPO:$tag -f Dockerfile ."
                }
            }
        }
        stage('Login to Docker Hub') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', 
                                                  usernameVariable: 'DOCKER_HUB_USER', 
                                                  passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                    sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin"
                }
            }
        }
        stage('Tag and Push Docker Image') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                script {
                    def tag = env.BRANCH_NAME == 'prod' ? 'prod' : 'dev'
                    sh "docker tag $DOCKER_HUB_REPO:$tag $DOCKER_HUB_REPO:$tag"
                    sh "docker push $DOCKER_HUB_REPO:$tag"
                }
            }
        }
        stage('Deploy with Helm') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                script {
                    def environment = env.BRANCH_NAME == 'prod' ? 'production' : 'staging'
                    def tag = env.BRANCH_NAME == 'prod' ? 'prod' : 'dev'
                    deploy_with_helm(environment, tag)
                }
            }
        }
        stage('Deploy to helm-develop') {
            when {
                branch 'helm-develop'
            }
            steps {
                script {
                    def servers = ['34.234.54.61']
                    def branch = 'helm-develop'
                    deploy_docker(servers, branch)
                }
            }
            post {
                always {
                    echo "Deployment to helm-develop completed."
                }
            }
        }
        stage('Deploy to prod') {
            when {
                branch 'prod'
            }
            steps {
                script {
                    def servers = ['54.91.121.21']
                    def branch = 'prod'
                    deploy_docker(servers, branch)
                }
            }
            post {
                always {
                    echo "Deployment to prod completed."
                }
            }
        }
    }
}
