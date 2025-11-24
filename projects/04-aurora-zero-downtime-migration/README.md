## Project 04 – Aurora Zero-Downtime Migration

This project demonstrates a real-world migration from Amazon RDS MySQL to Amazon Aurora MySQL with near-zero downtime. The goal is to show how to modernize a production database safely, replicate data with minimal lag, and cut over with a reversible, low-risk approach.

The project simulates an environment where an application originally points to a traditional RDS MySQL instance. Using Terraform, Route 53, and replication features, the migration shifts the backend to Aurora without interrupting active workloads. This is the same type of operation SaaS companies perform when moving toward faster failover, better scalability, and reduced operational overhead.

## Key Features

- **Infrastructure as Code**: Both the source RDS MySQL 5.7 instance and the target Aurora MySQL 8.0 cluster are fully defined and deployed using Terraform, ensuring repeatable, version-controlled provisioning.
- **Independent Aurora instance configuration**: Writer and reader instances use explicit instance classes and parameter groups for realistic production-like setups.
- **Zero-downtime replication**: Initial full snapshot followed by continuous binlog replication via AWS Database Migration Service (DMS) with Change Data Capture (CDC).
- **DNS-based cutover**: A Route 53 CNAME record (`db.eduphoria.ex`) acts as the single point of truth; switching traffic from RDS to Aurora requires only an alias update (typically < 30 seconds globally).
- **Automated validation & orchestration**: Custom scripts validate replication lag, row counts, and checksums before allowing cutover, then execute the DNS flip and post-cutover checks.
- **Safe rollback capability**: Rollback script instantly repoints the CNAME back to the original RDS endpoint; the source instance remains read-write and fully intact throughout the process.
- **Realistic workload simulation**: Includes baseline schema, sample data, and representative migration SQL files (schema changes, indexes, data fixes).
- **Comprehensive runbooks**: Detailed cutover and rollback procedures provided in `/docs`, ready for operational handoff.

## What This Project Demonstrates

- How to perform a controlled, low-risk database migration from RDS MySQL to Aurora MySQL  
- Effective use of DNS (Route 53) for near-zero-downtime traffic switching  
- Rigorous pre-cutover validation of replication health and data consistency  
- Design and execution of a reversible migration with a guaranteed rollback path  
- Application of Terraform for consistent, auditable database infrastructure  
- Integration of migration processes into standard DevOps practices and documentation  

This repository serves as a complete, production-grade reference implementation for Aurora migrations.

How to Use This Project

1. Deploy the infrastructure using Terraform from the infra/terraform directory.
2. Apply the baseline schema from `sql/baseline/001_create_schema.sql` to the RDS instance.
3. Insert seed data using `sql/baseline/002_seed_data.sql` to populate initial records.
4. Start DMS replication task to begin syncing data to Aurora.
5. (Optional) Insert additional data using `sql/baseline/003_insert_during_migration.sql` to demonstrate CDC replication in real-time.
6. Run the replication check script to confirm synchronization and verify data consistency.
7. Use the cutover script to switch the Route 53 CNAME from RDS to Aurora.
8. Validate application connectivity and read/write operations on Aurora.
9. If issues occur, revert using the rollback script.

Repo Structure

– architecture.md: detailed migration flow and diagram context
– infra/terraform: full IaC for RDS, Aurora, networking, and Route 53
– sql: baseline and migration scripts to simulate real-world DB activity
– scripts: operational scripts for replication validation, cutover, and rollback
– docs: structured runbooks for predictable execution of changes

Why This Project Matters

Database migrations show up constantly in interviews for DevOps, Cloud, and Platform Engineering roles. This project demonstrates the ability to manage stateful workloads, plan safe migrations, automate infrastructure, and think about risk the same way production SaaS teams do.


![Architecture](diagrams/aurora-zero-downtime-migration.png)

<a href="https://github.com/TerminalsandCoffee/aws-devops-portfolio/blob/main/projects/04-aurora-zero-downtime-migration/docs/cutover-demo.gif">
  <img src="https://github.com/TerminalsandCoffee/aws-devops-portfolio/raw/main/projects/04-aurora-zero-downtime-migration/docs/cutover-demo.gif" width="300" alt="Live Cutover Demo">
</a>
