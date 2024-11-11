#!/usr/bin/env groovy

def deploy(servers, branch) {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            if (branch == 'react-frontend') {
                // Run the alias command for react-frontend
                sh(script: """
          
                server
                """)
            } else if (branch == 'prod-frontend') {
                // Run the deployment script directly on prod-frontend
                sh(script: """
                whoami
		sshpass -p 'P@ssw0rd' ssh -o StrictHostKeyChecking=no root@'${item}' bash -c "'
               	cd /home/ubuntu/scripts && source /home/ubuntu/scripts/deploy.sh && zero_downtime_deploy_be_'${branch}'
	       whoami
                    ./deploy-be-staging.sh
                '"
                """)
            }
        }
    }
}


def deploy_docker(servers, branch = '') {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            sh(script: """
	    whoami
            sshpass -p 'HrQ43B6mtjj2mVOTYq9hoyMq' ssh -p 2208 -o StrictHostKeyChecking=no root@'${item}' bash -c "'
               cd /home/ubuntu/scripts && source /home/ubuntu/scripts/deploy.sh && zero_downtime_deploy_be_'${branch}'
	       whoami
            '"
            """)
        }
    }
}
pipeline {
    agent {
        node {
            label 'prod-server'
        }
    }
    environment {
        DOCKER_HUB_REPO = 'dksavai/dksavai-test'  // Your Docker Hub repository
        DOCKER_IMAGE_TAG = 'frontend-dev' 
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
        stage('Main Build Docker Image') {
            when {
                   anyOf {
		      branch 'react-frontend'
                   }
            }
            steps {
                script {
                // Build your Docker image here
                if (env.GIT_BRANCH == 'prod-frontend') {
                sh 'cp /var/jenkins_home/env/.env.prod .env'
	        sh 'docker build --platform linux/amd64 -t $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG .'
                } else if (env.GIT_BRANCH == 'react-frontend') {
                sh 'cp /var/jenkins_home/env/.env.dev .env'
	        sh 'docker build --platform linux/amd64 -t $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG .'
                }
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

        stage('Tag and Push to ECR') {
            when {
                   anyOf {
		    branch 'react-frontend'
                   }
            }
            steps {
                script {
                 if (env.GIT_BRANCH == 'production-test') {
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG"
                // Cleanup the Docker image
                 } else if (env.GIT_BRANCH == 'react-frontend') {
                // Push the Docker image to ECR
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG"
                // Cleanup the Docker image
                 }
                }
            }
            } 	        
        stage ('deploy to dev') {
            when {
                branch 'react-frontend'
            }
            steps {
                script {
                        def servers = ['38.242.198.81']
                        def branch = 'react-frontend'
                        deploy_docker (servers,branch)
                    }
                }
            post {
                always {
            echo 'I will always run!'
                }
            }                
			}
        stage ('deploy to staging ') {
            when {
                branch 'prod-frontend'
            }
            steps {
                script {
                        def servers = ['192.168.1.13']
                        def branch = 'prod-frontend'
                        deploy (servers,branch)
                    }
                }
            post {
                always {
            echo 'I will always run!'
                }
            }             
			}
       	}
    post { 
        always { 
            echo 'I will always run!'
           
        }
    }
}
