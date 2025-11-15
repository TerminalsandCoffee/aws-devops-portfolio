# ECS Fargate CI/CD Pipeline for Containerized Web App

## Overview
This project deploys a scalable Flask web app to AWS ECS Fargate using Terraform for IaC, Docker for containerization, and GitHub Actions for CI/CD. It follows AWS Well-Architected best practices, including auto-scaling, CloudWatch monitoring, and secure ALB integration.

## Architecture
The following diagram illustrates the end-to-end architecture, from GitHub source to Fargate-hosted service:

![Architecture Diagram](./docs/architecture.png)

Key components:
- **Source Control & CI/CD**: GitHub repo triggers Actions workflow for build/test/deploy.
- **Container Registry**: ECR pushes Docker images.
- **Compute**: ECS cluster with Fargate tasks, orchestrated via Terraform.
- **Networking & Security**: ALB for ingress, VPC with private subnets, IAM roles for least-privilege access.
- **Observability**: CloudWatch Logs/Metrics for monitoring.

## Prerequisites
- AWS CLI configured with appropriate IAM permissions.
- Terraform v1.5+ and Helm for any Kubernetes extensions (if applicable).
- Docker installed for local builds.

## Deployment
1. Run `terraform init && terraform plan` in the root.
2. Trigger GitHub Actions via push to main.
...

## Monitoring & Security
- Use CloudWatch dashboards for metrics.
- Enable GuardDuty and Config for compliance.
