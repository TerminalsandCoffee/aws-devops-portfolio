# Architecture – Aurora Zero-Downtime Migration

- Source: Amazon RDS MySQL
- Target: Amazon Aurora MySQL-compatible cluster
- Replication: snapshot/binlog-based sync
- Cutover: application points to a Route 53 CNAME that you flip from RDS to Aurora

┌────────────────────┐
│ App / Web Service  │
└─────────▲──────────┘
          │
          ▼
┌────────────────────┐   ┌────────────────────┐
│ Route 53 CNAME     │   │ RDS MySQL 5.7      │
│ db.eduphoria.ex    │   │ Writer Endpoint    │
└───────▲───────▲────┘   └─────────▲──────────┘
        │       │                 │
        │       └───── DMS CDC ───┼──► DMS Task
        │                         │
        │                         ▼
        │                 ┌────────────────────┐
        │                 │ Aurora MySQL 8.0   │
        │                 │ Cluster Endpoint   │
        │                 └──────▲──────▲──────┘
        │                        │      │
        │                        │      │
        │                        │      │
        │                        │      │
        │                        │      │
        ▼                        │      │
┌────────────────────┐           │      │
│ CloudWatch Metrics │◄── Alarms ─┼──────┘
└───────▲────────────┘           │
        │                        │
        ▼                        │
┌────────────────────┐           │
│ Replica Lag, CPU   │           │
│ Connections        │           │
└───────▲────────────┘           │
        │                        │
        ▼                        │
┌────────────────────┐           │
│ Grafana Dashboard  │◄──────────┘
│ Live Cutover View  │
└────────────────────┘
