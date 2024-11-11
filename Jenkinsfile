#!/usr/bin/env groovy

def deploy (servers, branch) {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            sh(script: """
	    whoami
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'${item}' bash -c "'
                if [ ${branch} == 'prod' ]; then
                    ./deploy-fe-prod.sh
                elif [ ${branch} == 'develop' ]; then
                    ./deploy-fe.sh
                fi
            '"
            """)
        }
    }
}

def deploy_docker(servers, branch = '') {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            sh(script: """
	    whoami
            ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'${item}' bash -c "'
               cd /home/ubuntu/scripts && source ~/scripts/deploy.sh && zero_downtime_deploy_fe_'${branch}'
            '"
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
        AWS_REGION = 'eu-west-2'  // e.g., 'us-east-1'
        AWS_CREDENTIALS = 'ecr'  // The ID of the AWS credentials added in Jenkins
        ECR_REPOSITORY = '466220267847.dkr.ecr.eu-west-2.amazonaws.com'  // The name of your ECR repository
        DOCKER_IMAGE_NAME = 'careapps_frontend'  // The name to tag your Docker image with
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
                     branch 'production';
                     branch 'staging';
		      branch 'develop'
                   }
            }
            steps {
                script {
                // Build your Docker image here
                if (env.GIT_BRANCH == 'production') {
                sh 'cp /var/jenkins_home/env/.env.care-fe-prod .env.care-fe-prod'
                sh "sed -i 's/ENVI/.env.care-fe-prod/g' Dockerfile"
	        sh 'docker build -t $DOCKER_IMAGE_NAME:prod -f Dockerfile .'
                } else if (env.GIT_BRANCH == 'develop') {
                sh 'cp /var/jenkins_home/env/.env.care-fe-dev .env.care-fe-dev'
                sh "sed -i 's/ENVI/.env.care-fe-dev/g' Dockerfile"
	        sh 'docker build -t $DOCKER_IMAGE_NAME:dev -f Dockerfile .'
                } else {
                sh 'cp /var/jenkins_home/env/.env.care-fe-stg .env.care-fe-stg'
                sh "sed -i 's/ENVI/.env.care-fe-stg/g' Dockerfile"
                sh 'docker build -t $DOCKER_IMAGE_NAME:stg -f Dockerfile .'
                }
                }
            }
        }
        stage('Login to AWS ECR') {
            when {
                   anyOf {
                     branch 'production';
                     branch 'staging';
		     branch 'develop'
                   }
            }
            steps {
                // Log in to AWS ECR using AWS CLI
                sh "aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY"
            }
        }

        stage('Tag and Push to ECR') {
            when {
                   anyOf {
                     branch 'production';
                     branch 'staging';
		    branch 'develop'
                   }
            }
            steps {
                script {
                 if (env.GIT_BRANCH == 'production') {
                sh "docker tag $DOCKER_IMAGE_NAME:prod $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:prod"
                // Push the Docker image to ECR
                sh "docker push $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:prod"
                // Cleanup the Docker image
                sh "docker images  | grep $DOCKER_IMAGE_NAME | grep prod | awk '{print \$3}' | xargs -L 1 docker rmi -f"
                 } else if (env.GIT_BRANCH == 'develop') {
                sh "docker tag $DOCKER_IMAGE_NAME:dev $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:dev"
                // Push the Docker image to ECR
                sh "docker push $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:dev"
                // Cleanup the Docker image
                sh "docker images  | grep $DOCKER_IMAGE_NAME | grep dev | awk '{print \$3}' | xargs -L 1 docker rmi -f"
                 } else {
                // Tag your Docker image with the ECR repository URI
                sh "docker tag $DOCKER_IMAGE_NAME:stg $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:stg"

                // Push the Docker image to ECR
                sh "docker push $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:stg"

                // Cleanup the Docker image
                sh "docker images  | grep $DOCKER_IMAGE_NAME | grep stg | awk '{print \$3}' | xargs -L 1 docker rmi -f"
                }
                }
            }
            } 	
        stage ('Deploy to staging ') {
            when {
                branch 'staging'
            }
            steps {
                script {
                        def servers = ['10.217.126.29']
                        def branch = 'staging'
                        deploy_docker (servers,branch)
                    }
                }
            post {
                always {
                    jiraSendDeploymentInfo environmentId: 'staging', environmentName: 'staging', environmentType: 'staging'
                }
            } 	
			}
        stage ('Deploy to develop ') {
            when {
                branch 'develop'
            }
            steps {
                script {
                        def servers = ['10.217.126.24']
                        def branch = 'develop'
                        deploy_docker (servers,branch)
                    }
                }
            post {
                always {
                    jiraSendDeploymentInfo environmentId: 'development', environmentName: 'development', environmentType: 'development'
                }
            }  		
			}	    
        stage ('Deploy to docker prod') {
            when {
                branch 'production'
            }
            steps {
                script {
                        def servers = ['10.217.126.27']
			def branch = 'production'
                        deploy_docker (servers,branch)
                }
            }
            post {
                always {
                    jiraSendDeploymentInfo environmentId: 'production', environmentName: 'production', environmentType: 'production'
                }
            } 	
		}
        stage ('Deploy to prod') {
            when {
                branch 'production'
            }
            steps {
                script {
                        def servers = ['10.217.126.27']
			def branch = 'production'
                        deploy (servers,branch)
                }
            }
            post {
                always {
                    jiraSendDeploymentInfo environmentId: 'production', environmentName: 'production', environmentType: 'production'
                }
            }   		
		}
	}
}
