# Architecture – Aurora Zero-Downtime Migration

- Source: Amazon RDS MySQL
- Target: Amazon Aurora MySQL-compatible cluster
- Replication: snapshot/binlog-based sync
- Cutover: application points to a Route 53 CNAME that you flip from RDS to Aurora

+----------------+      +----------------+      +-------------------+
|   Source RDS   | <--> |   DMS Replica  | <--> |   Target Aurora   |
|   MySQL 5.7    |      |   (CDC)        |      |   MySQL 8.0       |
+----------------+      +----------------+      +-------------------+
        |                        |                        |
        |                        |                        |
        v                        v                        v
   Route53 Alias          CloudWatch Alarms           Grafana
   (weighted 100→0)       (latency, replica lag)      Dashboard