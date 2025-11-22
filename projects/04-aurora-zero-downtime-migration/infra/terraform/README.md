# Terraform Infrastructure for Aurora Zero-Downtime Migration

This Terraform configuration provisions the complete infrastructure for migrating from RDS MySQL to Aurora MySQL with zero downtime using AWS DMS (Database Migration Service).

## Architecture

- **Source**: RDS MySQL 5.7 instance
- **Target**: Aurora MySQL 8.0 cluster
- **Replication**: AWS DMS with Change Data Capture (CDC)
- **Cutover**: Route 53 CNAME for blue/green switching

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with appropriate permissions
- AWS account with permissions to create:
  - VPC, Subnets, Security Groups
  - RDS instances and clusters
  - DMS replication instances
  - Route 53 hosted zones (optional)
  - Secrets Manager
  - IAM roles and policies

## Quick Start

### 1. Set Password Variable

Set the database password via environment variable or Terraform variable:

```bash
# Option 1: Environment variable
export TF_VAR_rds_password="YourSecurePassword123!"

# Option 2: Pass via command line
terraform apply -var="rds_password=YourSecurePassword123!"

# Option 3: Leave empty to auto-generate (stored in Secrets Manager)
```

### 2. Initialize Terraform

```bash
cd projects/04-aurora-zero-downtime-migration/infra/terraform
terraform init
```

### 3. Plan Deployment

```bash
# For development
terraform plan -var-file="envs/dev.tfvars"

# For production
terraform plan -var-file="envs/prod.tfvars" -var="rds_password=YourSecurePassword"
```

### 4. Apply Configuration

```bash
# For development
terraform apply -var-file="envs/dev.tfvars"

# For production
terraform apply -var-file="envs/prod.tfvars" -var="rds_password=YourSecurePassword"
```

## Configuration Files

### Variables

- `variables.tf` - All input variables
- `envs/dev.tfvars` - Development environment settings
- `envs/prod.tfvars` - Production environment settings

### Infrastructure Files

- `main.tf` - VPC, networking, security groups
- `rds-source.tf` - RDS MySQL source instance
- `aurora-target.tf` - Aurora MySQL target cluster
- `replication.tf` - DMS replication instance and task
- `route53.tf` - Route 53 CNAME for cutover
- `outputs.tf` - Output values

## Key Resources Created

### Networking
- VPC with public and private subnets
- Internet Gateway and NAT Gateways
- Route tables and associations
- Security groups for RDS, Aurora, and DMS

### Databases
- RDS MySQL 5.7 instance (source)
- Aurora MySQL 8.0 cluster (target)
- DB subnet groups
- KMS keys for encryption
- Secrets Manager secrets for credentials

### Replication
- DMS replication instance
- DMS source endpoint (RDS)
- DMS target endpoint (Aurora)
- DMS replication task (CDC)

### DNS (Optional)
- Route 53 CNAME record for blue/green cutover

## Outputs

After deployment, important outputs include:

- `rds_endpoint` - RDS MySQL endpoint
- `aurora_endpoint` - Aurora MySQL writer endpoint
- `aurora_reader_endpoint` - Aurora MySQL reader endpoint
- `dms_replication_task_arn` - DMS task ARN
- `route53_record_name` - Route 53 record (if configured)

View all outputs:
```bash
terraform output
```

## Migration Workflow

1. **Initial Setup**: Terraform creates RDS and Aurora instances
2. **Data Migration**: DMS performs initial full load
3. **CDC Replication**: DMS continuously replicates changes
4. **Validation**: Verify data consistency between RDS and Aurora
5. **Cutover**: Update Route 53 CNAME to point to Aurora
6. **Validation**: Test application connectivity
7. **Rollback** (if needed): Point Route 53 back to RDS

## Using the Cutover Scripts

After infrastructure is deployed, use the scripts in `../../scripts/`:

```bash
# Check replication status
python scripts/python/check_replication_status.py \
  --rds-instance-id <rds-id> \
  --aurora-cluster-id <aurora-id>

# Perform cutover
python scripts/python/cutover_to_aurora.py \
  --rds-instance-id <rds-id> \
  --aurora-cluster-id <aurora-id> \
  --aurora-endpoint <aurora-endpoint> \
  --hosted-zone-id <zone-id> \
  --record-name db.eduphoria.ex

# Rollback if needed
python scripts/python/rollback_to_rds.py \
  --rds-instance-id <rds-id> \
  --rds-endpoint <rds-endpoint> \
  --hosted-zone-id <zone-id> \
  --record-name db.eduphoria.ex
```

## Cost Considerations

### Development Environment
- RDS: db.t3.micro (~$15/month)
- Aurora: db.t3.small single instance (~$30/month)
- DMS: dms.t3.micro (~$50/month)
- **Total**: ~$95/month

### Production Environment
- RDS: db.r5.large (~$200/month)
- Aurora: db.r5.xlarge multi-AZ (~$800/month)
- DMS: dms.r5.large (~$300/month)
- **Total**: ~$1,300/month

*Note: Costs vary by region and usage. Use AWS Pricing Calculator for accurate estimates.*

## Security Best Practices

1. **Encryption**: All databases use KMS encryption at rest
2. **Secrets**: Credentials stored in Secrets Manager
3. **Network**: Databases in private subnets
4. **Access**: Security groups restrict access to necessary services only
5. **Backups**: Automated backups enabled with 7-day retention

## Troubleshooting

### DMS Replication Issues
- Check DMS task status in AWS Console
- Review CloudWatch logs: `/aws/dms/{project-name}-replication-task`
- Verify security group rules allow DMS to access RDS and Aurora

### Connection Issues
- Verify security groups allow traffic on port 3306
- Check that endpoints are in the same VPC
- Verify credentials in Secrets Manager

### Route 53 Issues
- Ensure hosted zone exists if using Route 53
- Verify record name matches your domain
- Check DNS propagation (can take a few minutes)

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="envs/dev.tfvars"
```

**Warning**: This will delete all databases and data. Ensure you have backups before running destroy.

## Next Steps

1. Deploy infrastructure with Terraform
2. Initialize database schema on RDS
3. Start DMS replication task
4. Monitor replication lag
5. Perform cutover using scripts
6. Validate application functionality
7. Decommission RDS instance (after validation period)

## Additional Resources

- [AWS DMS Documentation](https://docs.aws.amazon.com/dms/)
- [Aurora Migration Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Migrating.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

