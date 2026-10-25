
# Project 4: GitOps delivery of Multi-service Java Application on AWS EKS with Argo CD  

[![Platform](https://img.shields.io/badge/Platform-AWS_EKS-blue)](#)
[![GitOps](https://img.shields.io/badge/GitOps-Argo_CD-informational)](#)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-informational)](#)
[![Status](https://img.shields.io/badge/Deployment-Complete-brightgreen)](#)

---

## About the 4-Project DevOps System

This self-designed, 4-part DevOps portfolio series is intended to demonstrate the staged cloud migration and infrastructure maturity path of a multi-service web application: from containerization, to Kubernetes orchestration, to infrastructure automation, CI/CD, and observability, and finally to GitOps-based application delivery.

- **Project 1**: Multi-service containerization and deployment using Docker Compose on AWS EC2 - [Project 1](https://github.com/ravi-rajyaguru15/Project-01-dockerized-multi-service-application)
- **Project 2**: Kubernetes orchestration of the same application stack on AWS EKS - [Project 2](https://github.com/ravi-rajyaguru15/Project-02-eks-k8s-infrastructure-orchestration)
- **Project 3**: Infrastructure as Code with Terraform, CI/CD via GitHub Actions, and monitoring using Prometheus and Grafana - [Project 3](https://github.com/ravi-rajyaguru15/Project-03-terraform-cicd-observability-pipeline)
- **Project 4 (this)**: GitOps-based application delivery on AWS EKS using GitHub Actions and Argo CD

The Java web application used across this portfolio is externally sourced. Minor UI/content adjustments are made to remove source-specific branding and present it as a neutral demo web application. The infrastructure design, containerization, cloud deployment, Kubernetes manifests, Terraform configuration, CI/CD workflow setup, monitoring integration, GitOps implementation, documentation, troubleshooting, and migration-stage decisions were independently implemented.

The same application stack is intentionally reused across all four projects so the focus remains on infrastructure maturity and core DevOps practices.

---

## Project Overview

This project demonstrates the fourth stage of the portfolio: introducing GitOps-based continuous delivery to the Terraform-provisioned EKS application stack from Project 3.

In Project 3, GitHub Actions handled both automation and application deployment by applying Kubernetes manifests directly to the EKS cluster. Project 4 changes that delivery model by separating CI from CD. GitHub Actions validates the Java application, builds and publishes a Docker image tagged with the source commit SHA, and updates the image reference in Git. Argo CD watches the GitOps manifests in the repository and reconciles the Kubernetes application state on EKS.

Terraform continues to manage the underlying AWS infrastructure separately. This keeps infrastructure provisioning, CI, and application delivery as distinct parts of the workflow while preserving the same EKS, Kubernetes, storage, and ingress foundation used in the previous project.

---

## Project Scope

This stage focuses on pull-request validation, SHA-tagged container image publishing, automated GitOps manifest updates, Argo CD synchronization, Git-based application delivery, EBS-backed persistence, and hands-on troubleshooting across the CI-to-Kubernetes delivery path.

It is not intended to represent a fully production-operated GitOps platform. Advanced secret management, multi-environment promotion, policy enforcement, self-managing GitOps infrastructure, and team-based release workflows are outside the scope of this stage and are areas I aim to deepen through professional cloud/platform engineering experience.

---

## Architecture Overview

![Project 4 architecture](images/architecture/project-4-architecture.png)

The application Kubernetes resources are managed from `gitops/manifests/`. GitHub Actions updates the desired application image version in Git, while Argo CD is responsible for applying and reconciling that desired state in the cluster.

---

## Tech Stack

- **Infrastructure**: AWS EKS, EKS managed node groups, VPC networking, public/private subnets, NAT gateway
- **Infrastructure as Code**: Terraform, S3-backed Terraform state
- **Orchestration**: Kubernetes
- **GitOps / Continuous Delivery**: Argo CD
- **CI & Automation**: GitHub Actions, Maven
- **Containers**: Docker, Docker Hub
- **Workloads**: Tomcat web app, MySQL, RabbitMQ, Memcached
- **Routing**: NGINX Ingress Controller, Kubernetes Ingress, AWS load balancing
- **Storage**: PersistentVolumeClaim, Amazon EBS, EBS CSI Driver
- **Runtime Configuration & Startup Control**: Kubernetes Secrets, initContainers
- **Tooling**: `kubectl`, AWS CLI, Terraform, Git

---

## Repository Structure

```text
Project_04/
│
├── .github/                                       # GitHub Actions CI pipeline
│   └── workflows/                                
│       └── ci.yml                                 # Pull-Request validation, image publishing and GitOps manifest update
├── gitops/
│   ├── argocd/
│   │   └── application.yaml                       # Argo CD Application definition
│   └── manifests/                                 # Active GitOps desired state, monitored by Argo CD
│       ├── deployments/                           # Application, MySQL, RabbitMQ, Memcached
│       │   └── app-deploy.yaml                    # SHA-tagged Java image reference updated by CI
│       ├── services/                              # Internal Kubernetes Services
│       ├── ingress/                               # Application Ingress
│       ├── secrets/                               # Demo runtime configuration
│       └── persistentVolumeClaim/                 # MySQL EBS-backed PVC
│
├── terraform/                                     # Carried over Terraform configuration from Project 3 for AWS VPC, EKS, IAM and EBS CSI
│   ├── aws-ebs-csi.tf
│   ├── eks-cluster.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tf
│   ├── variables.tf
│   └── vpc.tf       
│     
├── kubernetes/                                    # Retained Project 3 manifest baseline (not active GitOps source) for continuity.
│      
├── images/
|   ├── screenshots/...                            # Screenshots of Argo CD application running and status, k8s resources, web app docker image tag updates, etc.
│   └── architecture/
|         └── project-4-architecture.png           # Architecture overview diagram of Project 4
│      
├── legacy/                                        # Files carried over from Project 2 for continuity.
│   ├── app/                                       # Java source, Maven configuration and application Dockerfile
│   └── mysql/                                     # MySQL Dockerfile and database initialization files
│   
│ 
├── .gitignore                                     # gitignore file to prevent large runtime generated files from pushing into repository.                     
│                     
└── README.md                                      # Project README
```

`gitops/manifests/` is the active desired-state path used by Argo CD. The earlier `kubernetes/` manifests are retained as the Project 3 baseline, while `legacy/app/` remains the application source used by the GitHub Actions workflow for Maven validation and Docker image builds.

---

## CI and GitOps Delivery Flow

### Pull Request

For pull requests targeting `main`, GitHub Actions runs Maven validation against the Java application:

```text
Pull Request
    |
    v
GitHub Actions
    |
    v
Maven clean verify
```

This provides a CI check before changes are merged.

### Merge / Push to Main

After a change reaches `main`, the workflow:

1. Runs Maven verification.
2. Builds the Java application Docker image.
3. Pushes the image to Docker Hub using the source Git commit SHA as the image tag.
4. Updates the image reference in `gitops/manifests/deployments/app-deploy.yaml`.
5. Commits the updated manifest back to `main`.
6. Argo CD detects the Git change and reconciles the application on EKS.
7. Kubernetes rolls out the new application image.

This replaces the Project 3 model where GitHub Actions directly ran `kubectl apply` against the application manifests.

---

## How to Deploy (Reproduction Steps)

1. **Prerequisites/Dependencies**:
      - Local machine with `aws-cli`, `kubectl`, `terraform`, and `git` installed.
      - AWS account configured via AWS CLI, and with appropriate IAM permissions.
      - GitHub repository configured with the required GitHub Actions secrets: `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`.  
      - A remote S3 bucket created manually beforehand for Terraform backend state, with the bucket name matching the backend configuration in `terraform/terraform.tf`.
      - Docker Hub repositories for the Project 4 application and database images.

2. Open a Bash terminal, clone the repository, and navigate into the project folder.

3. Provision the EKS infrastructure via Terraform: 

    ```bash
    cd terraform

    terraform init -upgrade
    terraform fmt
    terraform validate
    terraform plan
    terraform apply
    ```
4. Connect to the EKS cluster and verify node access: 

    ```bash
    cd ..
    aws eks update-kubeconfig --region us-east-1 --name project4-eks-cluster
    ```
    ```bash
    kubectl get nodes
    kubectl get pods -n kube-system
    kubectl get storageclass
    ```
5. Install the NGINX Ingress Controller and verify its pods and services:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/aws/deploy.yaml
    ```
    ```bash
    kubectl get pods -n ingress-nginx
    kubectl get svc -n ingress-nginx
    kubectl get ingressclass
    ```
6. Instrall Argo CD:

    ```bash
    kubectl create namespace argocd

    kubectl apply -n argocd --server-side --force-conflicts \
      -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    kubectl get pods -n argocd
    ```
7. Create the Argo CD Application:

    ```bash
    kubectl apply -f gitops/argocd/application.yaml

    kubectl get applications -n argocd
    ```

The Application points Argo CD to `gitops/manifests/` on the `main` branch. The application manifests themselves are not manually applied with `kubectl`; Argo CD deploys them from Git.

8. Verify the application deployment:

    ```bash
    kubectl get applications -n argocd
    kubectl get pods
    kubectl get pvc
    kubectl get svc
    kubectl get ingress
    ```

The expected application state includes the Java web app, MySQL, RabbitMQ and Memcached workloads, with the MySQL PVC bound through Amazon EBS.

9. Access the web application using the external address assigned to the NGINX Ingress:

    ```bash
    kubectl get ingress
    ```

10. Test the complete CI-to-GitOps flow by creating a feature branch and pull request. After CI validation, merge the change into `main`. The GitHub Actions workflow publishes the SHA-tagged application image and updates the GitOps manifest, after which Argo CD reconciles the new image version into EKS.

    The rollout can be checked using:

    ```bash
    kubectl get applications -n argocd

    kubectl get deployment web-app \
      -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'

    kubectl rollout status deployment/web-app --timeout=300s
    ```

11. After verification, remove the application and supporting ingress resources before destroying the AWS infrastructure:

    ```bash
    kubectl delete application gitops -n argocd --wait=true --timeout=180s

    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/aws/deploy.yaml
    ```

12. Destroy the Terraform-managed infrastructure:

    ```bash
    cd terraform

    terraform plan -destroy
    terraform destroy
    ```
---

## Engineering Insights

- Extended the Terraform-provisioned EKS platform from Project 3 with Argo CD-based GitOps delivery while keeping the existing infrastructure and Kubernetes application design largely unchanged.
- Separated CI and CD responsibilities: GitHub Actions validates and publishes the application image and updates Git, while Argo CD manages application deployment and reconciliation on EKS.
- Used full Git commit SHA tags for application images so the deployed image version can be traced back to the source change that produced it.
- Used Git as the source of truth for application deployment rather than allowing the CI workflow to directly apply Kubernetes resources to the cluster.
- Reused plain Kubernetes manifests instead of converting the application to Helm, keeping the project focused on the GitOps delivery model rather than introducing an unrelated packaging change.
- Debugged Maven CI failures caused by inherited test expectations that did not match the existing application controller behavior, then verified the corrected tests through the pull-request workflow.
- Diagnosed an Argo CD repository access failure caused by the GitHub repository being private while Argo CD was configured for anonymous HTTPS access.
- Verified the complete delivery path from GitHub Actions image publishing and Git manifest update through Argo CD synchronization to a successful Kubernetes application image rollout.
- Verified the running application through Kubernetes resources, EBS-backed MySQL storage, NGINX Ingress access, and the browser-accessible web application.

---

## Natural Extension Points

This project intentionally focuses on Terraform-based EKS infrastructure provisioning, CI/CD-driven deployment, and basic Kubernetes observability. Given more time and a production-oriented team context, natural next iterations could include:

- **GitOps bootstrap automation**: Managing Argo CD installation and configuration through Terraform or Helm instead of installing it manually.
- **Secret management**: Replacing demo Kubernetes Secrets with a dedicated secret-management approach integrated with the deployment workflow.
- **Multi-environment delivery**: Extending the GitOps structure toward separate development using Kustomise overlays, staging and production environments with clearer promotion and approval patterns.
- **GitOps scaling patterns**: Exploring Argo CD ApplicationSets, separate environment repositories, or image automation when the number of applications and environments justifies the additional complexity.
- **Observability integration**: Bringing monitoring configuration from Project 3 into a repeatable GitOps-managed workflow.

These are intentionally outside the current implementation so the project remains focused on the main architectural change: moving application deployment authority from GitHub Actions to Argo CD.