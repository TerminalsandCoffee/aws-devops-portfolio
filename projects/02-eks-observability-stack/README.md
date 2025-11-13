## **PROJECT 02 – EKS OBSERVABILITY STACK**

## Overview

This project deploys a fully instrumented **Amazon EKS cluster** with a production-grade **observability stack** built around Prometheus, Grafana, and ServiceMonitor resources. Terraform provisions the AWS infrastructure, Helm handles the observability tools, and Kubernetes manifests demonstrate how applications integrate with the monitoring pipeline.

This stack mirrors what real platform teams build for visibility, debugging, and long-term reliability in Kubernetes environments.

## Architecture Summary

- Terraform → VPC, subnets, NAT gateway, route tables
- Terraform → EKS (managed node groups)
- Terraform → IRSA for Prometheus/Grafana external integrations
- Helm → Prometheus
- Helm → Grafana
- Kubernetes → demo nginx workload + ServiceMonitor
- GitHub Actions → CI for Terraform fmt/validate + workflow automation

## Why This Project Exists

I built this to demonstrate real DevOps engineering skills:

• Provisioning EKS using Terraform modules
• Setting up cloud-native observability pipelines
• Implementing ServiceMonitor resources for workload scraping
• Using IRSA instead of long-lived credentials
• Structuring repos the way platform engineering teams expect
• Integrating GitHub Actions for validation and automation

## Technologies Used

**Infrastructure:**
• AWS VPC
• Amazon EKS
• IAM + IRSA
• NAT Gateway
• Elastic Load Balancing

**Observability:**
• Prometheus
• Grafana
• kube-state-metrics
• ServiceMonitor (Prometheus Operator)

**DevOps Tooling:**
• Terraform (aws + eks + vpc modules)
• Helm
• GitHub Actions
• kubectl

## Repository Structure

```
02-eks-observability-stack/
│
├── README.md
├── .gitignore
│
├── .github/
│   └── workflows/
│       └── deploy-eks-observability.yml
│
├── docs/
│   ├── architecture.png
│   ├── flow.md
│   └── decisions.md
│
├── infra/
│   ├── vpc.tf
│   ├── eks.tf
│   ├── irsa.tf
│   ├── helm.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── .terraform.lock.hcl
│   │
│   └── k8s-manifests/
│       ├── namespaces.yaml
│       ├── nginx-deployment.yaml
│       └── nginx-servicemonitor.yaml
│
├── charts/
│   ├── grafana/values.yaml
│   └── prometheus/values.yaml
│
└── scripts/
    ├── init-eks.sh
    ├── setup-tf-backend.sh
    └── cleanup.sh
```

## Deployment Instructions

### 1. Configure Backend (Optional)

```
scripts/setup-tf-backend.sh
```

### 2. Build the Infrastructure

```
cd infra
terraform init
terraform plan
terraform apply
```

### 3. Update kubeconfig

```
scripts/init-eks.sh
```

### 4. Install Observability Stack

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

helm install prometheus prometheus-community/kube-prometheus-stack -f charts/prometheus/values.yaml -n observability
helm install grafana grafana/grafana -f charts/grafana/values.yaml -n observability
```

### 5. Deploy Demo Workload

```
kubectl apply -f infra/k8s-manifests/
```

## How Observability Works

- Prometheus scrapes workloads using ServiceMonitor
- Grafana dashboards use Prometheus as a data source
- kube-state-metrics adds cluster-level insights
- Nginx workload exposes /metrics endpoint for scraping

Once deployed, you can:
- track pod CPU/memory
- monitor node health
- visualize nginx request metrics
- debug deployments
- follow rollout failures


## Future Enhancements

- Add Loki for logs
- Add Tempo for tracing
- Add Karpenter for autoscaling
- Add GitOps with ArgoCD
- Add ALB Ingress Controller
- Add alerting 
