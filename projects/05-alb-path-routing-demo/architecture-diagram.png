ALB Path-Based Routing Demo – Windows Server 2025
==================================================

                              ┌──────────────┐
                              │   Internet   │
                              └──────┬───────┘
                                     │ HTTPS/HTTP
                                     ▼
                     ┌─────────────────────────────────┐
                     │   Application Load Balancer     │
                     │   Public subnets (2 AZs)        │
                     │   Access Logs → S3              │
                     └───────┬────────────────┬────────┘
        ┌────────────────────┘                └─────────────────────┐
        │                                                            │
        │ /api*                                                    │ /app* | /*
        ▼                                                            ▼
┌─────────────────┐                                          ┌─────────────────┐
│ Target Group    │                                          │ Target Group    │
│ API (port 8080) │                                          │ APP (port 8081) │
│ Health: /index.html ───► 200                           │ Health: /index.html ───► 200   │
└───────┬─────────┘                                          └───────┬─────────┘
        │                                                            │
        ▼                                                            ▼
┌─────────────────┐                                          ┌─────────────────┐
│ EC2 Windows     │                                          │ EC2 Windows     │
│ Server 2025     │                                          │ Server 2025     │
│                 │                                          │                 │
│ • IIS Site "API"│                                          │ • IIS Site "APP"│
│ • Listening 8080│                                          │ • Listening 8081│
│ • index.html    │                                          │ • index.html    │
└─────────────────┘                                          └─────────────────┘

All provisioned with Terraform + pure PowerShell user data
Test it:
  http://<alb-dns-name>/api   →  "API Service - Healthy (port 8080)"
  http://<alb-dns-name>/app   →  "App Service - Healthy (port 8081)"
