#!/usr/bin/env groovy

def deploy_helm(servers, branch = '') {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            sh(script: """
                whoami
                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'${item}' bash -c "
                    echo Deploying Helm chart to ${item} for branch ${branch}
                    cd helm-chart
                    helm upgrade --install react-app ./react-app \\
                        --namespace ${branch} \\
                        --set image.repository=$DOCKER_HUB_REPO \\
                        --set image.tag=${branch} \\
                        --set app.environment=${branch}
                "
            """)
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
        stage ('Checkout') {
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
        stage('Main Build Docker Image') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                script {
                    if (env.GIT_BRANCH == 'prod') {
                        sh 'docker build -t $DOCKER_HUB_REPO:prod -f Dockerfile .'
                    } else if (env.GIT_BRANCH == 'helm-develop') {
                        sh 'docker build -t $DOCKER_HUB_REPO:dev -f Dockerfile .'
                    } else {
                        echo "I will always run main build docker image condition applied."
                    }
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
                    // Log in to Docker Hub
                    sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USER --password-stdin"
                }
            }
        }
        stage('Tag and Push to Dockerhub') {
            when {
                anyOf {
                    branch 'prod'
                    branch 'helm-develop'
                }
            }
            steps {
                script {
                    if (env.GIT_BRANCH == 'prod') {
                        sh "docker push $DOCKER_HUB_REPO:prod"
                    } else if (env.GIT_BRANCH == 'helm-develop') {
                        sh "docker push $DOCKER_HUB_REPO:dev"
                    }
                }
            }
        }
        stage ('Deploy to helm-develop') {
            when {
                branch 'helm-develop'
            }
            steps {
                script {
                    def servers = ['98.81.247.18']
                    def branch = 'helm-develop'
                    deploy_helm(servers, branch)
                }
            }
            post {
                always {
                    echo "I will always run"
                }
            }
        }
        stage ('Deploy to prod') {
            when {
                branch 'prod'
            }
            steps {
                script {
                    def servers = ['54.91.121.21']
                    def branch = 'prod'
                    deploy_helm(servers, branch)
                }
            }
            post {
                always {
                    echo "I will always run"
                }
            }
        }
    }
}
