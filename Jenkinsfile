#!/usr/bin/env groovy

def deploy(servers, branch) {
    script {
        for (item in servers) {
            println "Deploying to ${item}."
            sh(script: """
                whoami
                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${item} bash -c \"
                    if [ '${branch}' == 'develop' ]; then
                        ifconfig
                        ./deploy.sh
                    elif [ '${branch}' == 'prod' ]; then
                        ifconfig
                        ./deploy.sh
                    fi
                \"
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
	    echo "Deployment server cmd execution in  IP address is: $(hostname -I | awk '{print $1}')"
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
                     branch 'prod';
		      branch 'develop'
                   }
            }
            steps {
                script {
                // Build your Docker image here
                if (env.GIT_BRANCH == 'production') {
           //     sh 'cp /var/jenkins_home/env/.env.care-fe-prod .env.care-fe-prod'
           //     sh "sed -i 's/ENVI/.env.care-fe-prod/g' Dockerfile"
	        sh 'docker build -t $DOCKER_IMAGE_NAME:prod -f Dockerfile .'
                } else if (env.GIT_BRANCH == 'develop') {
            //    sh 'cp /var/jenkins_home/env/.env.care-fe-dev .env.care-fe-dev'
            //    sh "sed -i 's/ENVI/.env.care-fe-dev/g' Dockerfile"
	        sh 'docker build -t $DOCKER_IMAGE_NAME:dev -f Dockerfile .' 
                } else {
                    echo "I will always run main build docker image condition applied."
              //  sh 'cp /var/jenkins_home/env/.env.care-fe-stg .env.care-fe-stg'
              //  sh "sed -i 's/ENVI/.env.care-fe-stg/g' Dockerfile"
              //  sh 'docker build -t $DOCKER_IMAGE_NAME:stg -f Dockerfile .'
                }
                }
            }
        }
        stage('Login to Docker Hub') {
	   when {
        	    anyOf {
                     branch 'prod';
		    branch 'develop'
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
                     branch 'prod';
		    branch 'develop'
                   }
            }
            steps {
                script {
                 if (env.GIT_BRANCH == 'prod') {
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG:prod"
                // Push the Docker image to ECR
         //       sh "docker push $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:prod"
                // Cleanup the Docker image
              //  sh "docker images  | grep $DOCKER_IMAGE_NAME | grep prod | awk '{print \$3}' | xargs -L 1 docker rmi -f"
                 } else if (env.GIT_BRANCH == 'develop') {
             //   sh "docker tag $DOCKER_IMAGE_NAME:dev $ECR_REPOSITORY/$DOCKER_IMAGE_NAME:dev"
                // Push the Docker image to ECR
                sh "docker push $DOCKER_HUB_REPO:$DOCKER_IMAGE_TAG:dev"
                // Cleanup the Docker image
         //       sh "docker images  | grep $DOCKER_IMAGE_NAME | grep dev | awk '{print \$3}' | xargs -L 1 docker rmi -f"
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
        stage ('Deploy to develop ') {
            when {
                branch 'develop'
            }
            steps {
                script {
                        def servers = ['98.81.247.18']
                        def branch = 'develop'
                        deploy_docker (servers,branch)
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
                        deploy (servers,branch)
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
