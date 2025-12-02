# ECS Stale-Route Auto-Healer 

Reduced MTTR from **10+ minutes → <60 seconds** for a recurring 5xx issue caused by stale service-discovery state.

## The Problem (Real Customer Impact)
- Legacy Registrator process on ECS EC2 hosts would lose sync with Docker
- ALB kept sending traffic to deregistered tasks → HTTP 500s
- Manual fix: CloudWatch → find task → find host → SSH → Troubleshoot (10+ mins)

## The Solution I Built

- CloudWatch alarm on `HTTPCode_Target_5XX_Count`
- EventBridge rule → Python Lambda
- Lambda verifies unhealthy targets exist (prevents flapping)
- Resolves task → EC2 instance ID
- SSM RunCommand surgically restarts only `registrator` on affected host(s)


## Why I rejected Step Functions
| Criteria          | Lambda + SSM | Step Functions |
|-------------------|--------------|----------------|
| Latency           | 15–45s       | 60–120s+       |
| Cost per 1k fixes | ~$0.02       | ~$0.25–$0.50   |
| Complexity        | 1 function   | 6–8 states     |

## Tech Stack
Terraform → ECS EC2 → ALB → CloudWatch → EventBridge → Lambda → SSM

## Impact
- Zero customer-visible outages from this issue after deployment
- Pattern now reused for three other auto-remediation workflows

## Fully reproducible in <4 minutes
```bash
git clone https://github.com/yourname/ecs-stale-route-auto-healer.git
cd 06-ecs-stale-route-auto-healer/terraform
terraform init && terraform apply -auto-approve
# → 1× ECS EC2 cluster + ALB + auto-healer Lambda + alarm ready
./scripts/trigger-failure.sh
# → 5xx errors + CloudWatch alarm + EventBridge rule + Lambda triggered

