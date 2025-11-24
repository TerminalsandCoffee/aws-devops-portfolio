# Architecture – Aurora Zero-Downtime Migration

- **Source**: Amazon RDS MySQL 5.7  
- **Target**: Amazon Aurora MySQL-compatible cluster (MySQL 8.0)  
- **Replication**: Initial snapshot + ongoing binlog via DMS CDC  
- **Cutover**: Flip a Route 53 CNAME from RDS → Aurora (zero downtime magic)

```mermaid
flowchart TD
    A[App / Web Service] -->|db.eduphoria.ex| B[Route 53 CNAME]
    B -->|before cutover| C[RDS MySQL 5.7\nWriter Endpoint]
    B -->|after cutover| D[Aurora MySQL 8.0\nCluster Endpoint]

    C -->|"DMS CDC\n(binlog replication)"| E[DMS Task]
    E --> D

    D -->|Metrics & Alarms| F[CloudWatch]
    F -->|Replica Lag\CPU Usage\Connections| G[Grafana Dashboard\Live Cutover View]

    classDef rds fill:#FF9900,color:white
    classDef aurora fill:#2196F3,color:white
    classDef route53 fill:#4CAF50,color:white
    class C rds
    class D aurora
    class B route53
