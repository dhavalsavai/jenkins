# Helm Charts for Kubernetes Deployment Using Jenkins

This repository contains Helm charts designed for automating Kubernetes deployments via Jenkins. The setup enables seamless Continuous Integration (CI) and Continuous Deployment (CD) pipelines for AWS-based infrastructures.

## Prerequisites

Before proceeding, ensure the following requirements are met:

1. **AWS Setup**
   - AWS account with privileged access.
   - EKS cluster with at least two worker nodes.
   - Nginx Ingress Controller and Cert Manager installed for external site access and SSL termination.

2. **Infrastructure Setup**
   - Three EC2 instances on AWS for:
     - **Jenkins Server**
     - **Docker Node (Build Agent)**
     - **Dev Node (Deployment Agent)**

3. **Jenkins Setup**
   - Jenkins server installed and configured.
   - Webhooks integrated for CI/CD triggers.
   - Nodes (Docker Node and Dev Node) added as Jenkins agents.

4. **Authentication**
   - Passwordless SSH authentication set up between Docker Node and Dev Node.

5. **Docker and Docker Hub**
   - Dockerfile created for your project.
   - Docker Hub account to store and pull images.

6. **Domain and SSL**
   - Access to domain hosting for creating subdomains.
   - SSL certificate for secure connections.

7. **Tools Installed** (on Dev Node):
   - AWS CLI
   - `kubectl`
   - Helm

8. **GitHub Access**
   - GitHub repository access for managing and deploying the project.

## Deployment Steps

### 1. AWS EKS Cluster Setup
- Create an EKS cluster with a minimum of two worker nodes.

### 2. EC2 Instances Setup
- Provision three EC2 instances:
  - **Jenkins Server**: For managing CI/CD pipelines.
  - **Docker Node**: For building and pushing Docker images.
  - **Dev Node**: For deploying the application to the EKS cluster.

### 3. Subdomain and SSL Configuration
- Create a subdomain in your domain hosting provider for DNS and SSL termination.
- Configure Nginx Ingress and Cert Manager for the setup.

### 4. Jenkins Configuration
- Integrate a GitHub webhook for Continuous Integration.
- Add Docker Node and Dev Node as Jenkins agents for build and deployment.

### 5. Tool Installation on Dev Node
- Install AWS CLI, `kubectl`, and Helm.
- Configure AWS CLI with necessary access credentials to manage AWS resources.

### 6. Docker Hub Integration
- Build and push Docker images to your Docker Hub repository using the Docker Node.

### 7. GitHub Integration
- Clone your project repository with Helm charts for Kubernetes deployment.
- Create a `Jenkinsfile` to automate the deployment process.

## Continuous Deployment Workflow

1. **Build Stage**:
   - Docker Node builds the Docker image using the provided Dockerfile.
   - The image is tagged and pushed to Docker Hub.

2. **Deploy Stage**:
   - The Dev Node pulls the latest Docker image from Docker Hub.
   - Helm charts are used to deploy the application on the EKS cluster.

3. **Ingress and SSL Setup**:
   - Nginx Ingress Controller manages external access.
   - Cert Manager handles SSL termination for secure connections.

## File Structure

- **`helm-chart/`**: Contains Helm charts for Kubernetes deployment.
- **`Jenkinsfile`**: Jenkins pipeline script for CI/CD.
- **`Dockerfile`**: Docker configuration for building application images.

## Additional Notes

- Ensure the `imagePullPolicy` is set to `Always` in the Helm values file to fetch the latest image during deployment.
- Use `kubectl rollout restart deployment <deployment-name>` to ensure pods reflect the latest changes after deployment.

This structured setup ensures a streamlined CI/CD process for Kubernetes-based application deployments using Jenkins.
