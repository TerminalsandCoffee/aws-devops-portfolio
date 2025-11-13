# Project 02: EKS Observability Stack

## Prerequisites
- AWS CLI, Terraform, Helm, kubectl, eksctl.
- IAM role with EKS perms.

## Overview
This project provisions an Amazon EKS cluster, deploys a sample NGINX workload, and layers in a full observability toolchain.

## Features
- Metrics via Prometheus scraping pods and nodes, with exports into Amazon CloudWatch
- Logs shipped through Fluent Bit to CloudWatch Container Insights
- Optional Loki integration for richer log aggregation and trace correlation
- Grafana dashboards preloaded for EKS and Prometheus visibility

## Why It Matters
Demonstrates an end-to-end DevOps flow: Infrastructure as Code ➜ Kubernetes orchestration ➜ Observability ➜ CI/CD automation.


## Quickstart
1. `cd terraform && terraform apply`
2. `./scripts/init-eks.sh`
3. Access Grafana: `kubectl port-forward svc/observability-grafana -n monitoring 3000:80`
4. Test: `curl $(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')`

## Monitoring
- **Prometheus**: Scrapes metrics, exports to CloudWatch.
- **Grafana**: Dashboards for EKS, pods, nodes.
- **Logs**: Enable in EKS control plane.

## CI/CD
See `.github/workflows/deploy.yml`.

## Cleanup
`./scripts/cleanup.sh`

## Extensions
- Add Loki for centralized logs.
- Integrate AWS X-Ray for tracing.
- Use Karpenter for auto-scaling nodes.