# Project 02: Database Integration Structure

## Proposed Directory Structure

```
02-eks-observability-stack/
│
├── infra/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── aurora.tf                 # NEW - Aurora PostgreSQL
│   │   ├── rds_secrets.tf            # NEW - Secrets Manager for Aurora
│   │   ├── irsa_aurora.tf            # NEW - IRSA for Aurora access
│   │   ├── outputs.tf                # Updated with Aurora endpoints
│   │   └── ...
│   │
│   └── k8s-manifests/
│       ├── namespaces.yaml
│       ├── nginx-deployment.yaml
│       ├── nginx-servicemonitor.yaml
│       ├── external-secrets/         # NEW
│       │   ├── external-secrets-operator.yaml
│       │   └── aurora-secret-store.yaml
│       ├── postgres-exporter/        # NEW
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── servicemonitor.yaml
│       └── sample-app/               # NEW - Demo app with DB
│           ├── deployment.yaml
│           ├── service.yaml
│           └── configmap.yaml
│
├── charts/
│   ├── grafana/
│   │   ├── values.yaml
│   │   └── dashboards/               # NEW
│   │       └── postgres-dashboard.json
│   └── prometheus/
│       ├── values.yaml
│       └── rules/                    # NEW
│           └── postgres-alerts.yaml
│
├── docs/
│   ├── architecture.md               # Updated with Aurora
│   ├── database-observability.md     # NEW
│   └── aurora-integration.md         # NEW
│
└── README.md                         # Updated
```

## Key Files to Create

### 1. Terraform: `infra/terraform/aurora.tf`
```hcl
# Aurora PostgreSQL Serverless v2 Cluster
resource "aws_rds_cluster" "aurora_postgres" {
  cluster_identifier      = "${var.project_name}-aurora-postgres"
  engine                  = "aurora-postgresql"
  engine_version          = "15.3"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = random_password.aurora_password.result
  
  db_subnet_group_name    = aws_db_subnet_group.aurora.name
  vpc_security_group_ids  = [aws_security_group.aurora.id]
  
  serverlessv2_scaling_configuration {
    max_capacity = 2
    min_capacity = 0.5
  }
  
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  
  skip_final_snapshot = var.environment != "production"
  deletion_protection  = var.environment == "production"
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = var.common_tags
}

resource "aws_rds_cluster_instance" "aurora_postgres" {
  identifier         = "${var.project_name}-aurora-postgres-instance-1"
  cluster_identifier = aws_rds_cluster.aurora_postgres.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora_postgres.engine
  engine_version     = aws_rds_cluster.aurora_postgres.engine_version
}
```

### 2. Terraform: `infra/terraform/irsa_aurora.tf`
```hcl
# IRSA for Aurora access from EKS pods
resource "aws_iam_role" "aurora_access" {
  name = "${var.project_name}-aurora-access-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.eks_oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:default:aurora-access"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "aurora_secrets" {
  role = aws_iam_role.aurora_access.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = aws_secretsmanager_secret.aurora_credentials.arn
    }]
  })
}
```

### 3. Kubernetes: `infra/k8s-manifests/external-secrets/aurora-secret-store.yaml`
```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aurora-secret-store
  namespace: default
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: aurora-access
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: aurora-credentials
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aurora-secret-store
    kind: SecretStore
  target:
    name: aurora-credentials
    creationPolicy: Owner
  data:
    - secretKey: username
      remoteRef:
        key: aurora-postgres-credentials
        property: username
    - secretKey: password
      remoteRef:
        key: aurora-postgres-credentials
        property: password
    - secretKey: host
      remoteRef:
        key: aurora-postgres-credentials
        property: host
    - secretKey: port
      remoteRef:
        key: aurora-postgres-credentials
        property: port
```

### 4. Kubernetes: `infra/k8s-manifests/postgres-exporter/deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-exporter
  namespace: observability
  labels:
    app: postgres-exporter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-exporter
  template:
    metadata:
      labels:
        app: postgres-exporter
    spec:
      serviceAccountName: aurora-access
      containers:
      - name: postgres-exporter
        image: quay.io/prometheuscommunity/postgres-exporter:latest
        env:
        - name: DATA_SOURCE_NAME
          valueFrom:
            secretKeyRef:
              name: aurora-credentials
              key: connection-string
        ports:
        - containerPort: 9187
          name: metrics
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-exporter
  namespace: observability
  labels:
    app: postgres-exporter
spec:
  ports:
  - port: 9187
    targetPort: 9187
    name: metrics
  selector:
    app: postgres-exporter
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: postgres-exporter
  namespace: observability
spec:
  selector:
    matchLabels:
      app: postgres-exporter
  endpoints:
  - port: metrics
    interval: 30s
    path: /metrics
```

### 5. Grafana Dashboard: `charts/grafana/dashboards/postgres-dashboard.json`
```json
{
  "dashboard": {
    "title": "Aurora PostgreSQL Metrics",
    "panels": [
      {
        "title": "Database Connections",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "Active Connections"
          }
        ]
      },
      {
        "title": "Query Performance",
        "targets": [
          {
            "expr": "rate(pg_stat_database_xact_commit[5m])",
            "legendFormat": "Commits/sec"
          }
        ]
      }
    ]
  }
}
```

---

## Observability Integration

### Prometheus Metrics
- `pg_stat_database_*` - Database statistics
- `pg_stat_activity_*` - Active connections
- `pg_stat_bgwriter_*` - Background writer stats
- Custom application metrics for query performance

### Grafana Dashboards
1. **Database Overview**: Connections, transactions, queries
2. **Performance**: Query latency, throughput
3. **Resource Usage**: CPU, memory, storage
4. **Connection Pool**: Pool size, active connections

### Alerting Rules
```yaml
# charts/prometheus/rules/postgres-alerts.yaml
groups:
- name: postgres_alerts
  rules:
  - alert: HighDatabaseConnections
    expr: pg_stat_database_numbackends > 80
    for: 5m
    annotations:
      summary: "High number of database connections"
      
  - alert: SlowQueries
    expr: rate(pg_stat_database_blk_read_time[5m]) > 0.1
    for: 5m
    annotations:
      summary: "Slow database queries detected"
```

---

## Integration Points

1. **IRSA**: Pods use IAM roles to access Secrets Manager
2. **External Secrets**: Automatically sync credentials to Kubernetes secrets
3. **Prometheus**: Scrapes PostgreSQL exporter metrics
4. **Grafana**: Visualizes database performance
5. **ServiceMonitor**: Kubernetes-native metric collection


