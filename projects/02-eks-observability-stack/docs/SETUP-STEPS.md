# Setup Steps

Follow these steps to stand up the EKS observability demo. Commands assume you are in `projects/02-eks-observability-stack`.

## Prerequisites
- AWS CLI v2 authenticated against an AWS account with permissions to create EKS/VPC/IAM
- `kubectl` configured locally
- `terraform` **or** `eksctl` for cluster provisioning
- `helm` for deploying charts

## 1) Create the cluster (Terraform)
```bash
cd infra/terraform
terraform init
terraform apply -auto-approve
aws eks --region $(terraform output -raw aws_region 2>/dev/null || echo "us-west-2") update-kubeconfig --name $(terraform output -raw cluster_name)
```

> Prefer `eksctl`? Mirror the values in `variables.tf` with a minimal `eksctl create cluster --name eks-observability-demo --region us-west-2 --nodes 2`.

## 2) Install the observability stack
The repo ships opinionated values for Prometheus/Grafana. Swap these for your own charts if desired.
```bash
# Add repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Deploy Prometheus/Grafana into the observability namespace
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace observability --create-namespace \
  -f ../../charts/prometheus/values.yaml
```

Optional: bind the OpenTelemetry collector to the pre-created IRSA role from Terraform by adding the role ARN in your collector chart values (see `observability_irsa_role_arn` output).

## 3) Deploy the sample app
```bash
cd ../../
helm upgrade --install sample-app charts/sample-app -n demo --create-namespace
kubectl get svc -n demo
```

## 4) (Optional) Add a service mesh
You can layer Istio or AWS App Mesh on top to demonstrate mTLS and richer telemetry.
```bash
# Istio quickstart (demo profile)
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.22.0 sh -
./istio-1.22.0/bin/istioctl install --set profile=demo -y
kubectl label namespace demo istio-injection=enabled

# AWS App Mesh (controller + CRDs)
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install appmesh-controller eks/appmesh-controller \
  --namespace appmesh-system --create-namespace \
  --set region=$(aws configure get region)
```

Update the `mesh.enabled` flag in `charts/sample-app/values.yaml` to inject sidecars and route traffic through the mesh.
