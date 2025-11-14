# create-project04-aurora-zero-downtime-migration.ps1
# Run this from the ROOT of your aws-devops-portfolio repo

$projectRoot = "projects/04-aurora-zero-downtime-migration"

# Helper: create directory if it doesn't exist
function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

# Helper: create file if it doesn't exist
function Ensure-File {
    param(
        [string]$Path,
        [string]$Content = ""
    )
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType File -Path $Path -Value $Content | Out-Null
    }
}

# 1) Base project folder
Ensure-Dir $projectRoot

# 2) Top-level docs
Ensure-File "$projectRoot/README.md" @"
# Project 04 – Aurora Zero-Downtime Migration

This project simulates a zero-downtime migration from Amazon RDS MySQL to Aurora MySQL
using replication, controlled cutover, and DNS-based blue/green switching.
"@

Ensure-File "$projectRoot/architecture.md" @"
# Architecture – Aurora Zero-Downtime Migration

- Source: Amazon RDS MySQL
- Target: Amazon Aurora MySQL-compatible cluster
- Replication: snapshot/binlog-based sync
- Cutover: application points to a Route 53 CNAME that you flip from RDS to Aurora
"@

# 3) diagrams/
$diagramsDir = "$projectRoot/diagrams"
Ensure-Dir $diagramsDir
Ensure-File "$diagramsDir/aurora-zero-downtime-migration.drawio"

# 4) infra/terraform + envs
$tfDir = "$projectRoot/infra/terraform"
Ensure-Dir "$projectRoot/infra"
Ensure-Dir $tfDir
Ensure-Dir "$tfDir/envs"

Ensure-File "$tfDir/main.tf" @"
# Root Terraform file – wires modules and resources for RDS → Aurora migration
"@

Ensure-File "$tfDir/versions.tf" @"
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
"@

Ensure-File "$tfDir/variables.tf" @"
variable "aws_region" {
  type        = string
  description = "AWS region to deploy the RDS and Aurora resources"
  default     = "us-east-1"
}

# Add DB name, instance class, usernames, etc. here
"@

Ensure-File "$tfDir/outputs.tf" @"
output "rds_endpoint" {
  description = "Endpoint of the source RDS MySQL instance"
  value       = aws_db_instance.source.address
}

output "aurora_endpoint" {
  description = "Writer endpoint of the Aurora MySQL cluster"
  value       = aws_rds_cluster.aurora.endpoint
}
"@

Ensure-File "$tfDir/rds-source.tf" @"
# RDS MySQL source instance definition will go here.
"@

Ensure-File "$tfDir/aurora-target.tf" @"
# Aurora MySQL-compatible cluster + instances will go here.
"@

Ensure-File "$tfDir/replication.tf" @"
# Resources / notes for snapshot & replication config between RDS and Aurora.
"@

Ensure-File "$tfDir/route53.tf" @"
# Route 53 record to act as a blue/green CNAME between RDS and Aurora.
"@

Ensure-File "$tfDir/envs/dev.tfvars" @"
aws_region = "us-east-1"
# dev-sized instance classes and settings
"@

Ensure-File "$tfDir/envs/prod.tfvars" @"
aws_region = "us-east-1"
# prod-like instance classes and settings
"@

# 5) sql/ (baseline + migrations)
$sqlDir = "$projectRoot/sql"
Ensure-Dir $sqlDir
Ensure-Dir "$sqlDir/baseline"
Ensure-Dir "$sqlDir/migrations"

Ensure-File "$sqlDir/baseline/001_create_schema.sql" @"
-- Base schema for the RDS MySQL source instance
CREATE DATABASE IF NOT EXISTS eduphoria_demo;
USE eduphoria_demo;

CREATE TABLE students (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    grade_level INT NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

Ensure-File "$sqlDir/migrations/002_sample_migration.sql" @"
-- Example migration that can be replayed during/after the Aurora cutover
ALTER TABLE students
ADD COLUMN last_login_at TIMESTAMP NULL;
"@

# 6) scripts/
$scriptsDir = "$projectRoot/scripts"
Ensure-Dir $scriptsDir

Ensure-File "$scriptsDir/check-replication-status.sh" @"
#!/usr/bin/env bash
# Placeholder for checking replication state between RDS and Aurora
echo 'Check replication status between RDS and Aurora here.'
"@

Ensure-File "$scriptsDir/cutover-to-aurora.sh" @"
#!/usr/bin/env bash
# Placeholder script for performing cutover:
# 1) set RDS to read-only
# 2) ensure replication is caught up
# 3) flip Route 53 CNAME to Aurora
echo 'Cutover to Aurora script placeholder.'
"@

Ensure-File "$scriptsDir/rollback-to-rds.sh" @"
#!/usr/bin/env bash
# Placeholder script for rollback:
# 1) flip Route 53 CNAME back to RDS
# 2) restore write access
echo 'Rollback to RDS script placeholder.'
"@

# 7) docs/ (runbooks)
$docsDir = "$projectRoot/docs"
Ensure-Dir $docsDir

Ensure-File "$docsDir/runbook-cutover.md" @"
# Cutover Runbook – RDS MySQL → Aurora

1. Confirm replication is healthy.
2. Place RDS into read-only mode.
3. Wait for replication to reach zero lag.
4. Update Route 53 CNAME to point to Aurora.
5. Validate app connectivity and basic queries.
"@

Ensure-File "$docsDir/runbook-rollback.md" @"
# Rollback Runbook – Aurora → RDS

1. Identify reason for rollback (performance, errors, app failures).
2. Flip Route 53 CNAME back to the RDS endpoint.
3. Validate app connectivity.
4. Plan follow-up actions to re-attempt migration.
"@

Write-Host "Project 04 folder structure created/updated at $projectRoot"
