# EKS Observability + Service Mesh Demo

This project spins up a lightweight yet production-inspired Amazon EKS environment to showcase how platform teams can bootstrap observability for a microservices application. Terraform (or `eksctl`) provisions a right-sized cluster, Helm deploys a frontend + API demo workload, and an out-of-the-box Prometheus/Grafana + OpenTelemetry stack captures metrics, logs, and traces without custom code changes.

A service mesh such as Istio or AWS App Mesh can be layered on to demonstrate mTLS, traffic splitting, and richer telemetry. Mesh sidecars (Envoy) intercept traffic between the frontend and API services, exporting golden signals and spans to the same observability backend—no app changes needed beyond enabling sidecar injection or routing resources.

Observability is intentionally high-level and pluggable. Prometheus scrapes pod and node metrics; Grafana visualizes service health and latency; and the OpenTelemetry Collector (optionally using IRSA) can forward traces/metrics/logs to AWS managed services like X-Ray, CloudWatch, and Amazon Managed Service for Prometheus. The goal is to mirror what a Platform Engineer would hand teams as a paved path for debugging and performance tuning.
