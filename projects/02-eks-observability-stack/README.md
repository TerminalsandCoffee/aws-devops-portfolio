# Project 02 – EKS Observability Stack

An Amazon EKS observability + service mesh demo that deploys a small microservices app (frontend + API) with metrics, logs, tracing, and optional mesh sidecars. Terraform builds the cluster and IAM integration points, Helm ships the observability stack and workloads, and GitHub Actions keeps the IaC and charts linted.

## What you get
- **EKS + Node Groups:** Minimal, production-like cluster with control plane logs enabled and IRSA ready for telemetry components.
- **Microservices sample app:** Helm chart that deploys a frontend + API pair with resource requests/limits and mesh-aware annotations.
- **Observability path:** Prometheus + Grafana values, optional OpenTelemetry collector with IAM role for service accounts.
- **Service mesh ready:** Flip a value to inject sidecars (Istio or AWS App Mesh) and route traffic through Envoy while reusing the same dashboards.

## Tech stack
- **Cloud/IaC:** Terraform, AWS VPC, Amazon EKS, IAM/IRSA
- **Platform add-ons:** Prometheus, Grafana, OpenTelemetry Collector (optional)
- **App delivery:** Helm charts, kubectl
- **Automation:** GitHub Actions workflow for YAML/Helm/Terraform linting

## Why it matters for DevOps/Platform roles
This repo mirrors the paved path a Platform Engineer would hand to application teams: consistent cluster bootstrapping, pre-wired observability, and an easy toggle for mesh-powered traffic management. Everything is documented and scripted so you can demo operational excellence without days of setup.

## Quickstart
1. **Provision** – `cd infra/terraform && terraform init && terraform apply -auto-approve`
2. **Configure kubectl** – `aws eks --region <region> update-kubeconfig --name eks-observability-demo`
3. **Deploy** – `./scripts/deploy.sh` (installs Prometheus/Grafana + the sample frontend/API)
4. **Explore** – Visit Grafana/Prometheus or wire in a mesh per [`docs/SETUP-STEPS.md`](docs/SETUP-STEPS.md).

See [`docs/OVERVIEW.md`](docs/OVERVIEW.md) for architecture context and [`docs/SETUP-STEPS.md`](docs/SETUP-STEPS.md) for full commands.
