#!/bin/bash
set -e

echo "Configuring kubectl..."
aws eks update-kubeconfig --region us-west-2 --name eks-observability-demo

echo "Applying k8s manifests..."
kubectl apply -f k8s-manifests/

echo "Deploying observability stack..."
helm upgrade --install observability prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f helm/prometheus/values.yaml \
  -f helm/grafana/values.yaml

echo "NGINX LoadBalancer URL:"
kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

echo "EKS ready! Grafana: $(kubectl get svc -n monitoring observability-grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"