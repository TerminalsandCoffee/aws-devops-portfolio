# Planning: Database & Ansible Enhancements

## Overview
This document outlines the plan for adding database integration and Ansible configuration management to Projects 01 and 02.

---

## Phase 1: Database Integration

### Project 01: ECS Fargate Web App + RDS PostgreSQL

**Objective:** Add a managed PostgreSQL database to demonstrate full-stack application architecture.

**Implementation Plan:**

1. **Infrastructure (Terraform)**
   - Add RDS PostgreSQL instance in private subnet
   - Security group rules for ECS → RDS communication
   - Secrets Manager for database credentials
   - Parameter Store for connection strings
   - Database subnet group
   - Automated backups configuration

2. **Application Updates**
   - Update Flask app to connect to PostgreSQL
   - Add database models (SQLAlchemy)
   - Implement connection pooling
   - Add database health check endpoint
   - Database migration scripts (Alembic)

3. **CI/CD Updates**
   - Database migration step in GitHub Actions
   - Secrets injection via Secrets Manager
   - Connection string configuration

4. **Monitoring**
   - CloudWatch metrics for RDS
   - Database connection monitoring
   - Query performance tracking

**Database Schema Example:**
- Users table (for demo purposes)
- Simple CRUD operations
- Demonstrates real-world patterns

---

### Project 02: EKS Observability + Aurora PostgreSQL

**Objective:** Add Aurora PostgreSQL to EKS cluster and integrate with observability stack.

**Implementation Plan:**

1. **Infrastructure (Terraform)**
   - Aurora PostgreSQL cluster (serverless v2 for cost efficiency)
   - VPC endpoints for RDS Data API
   - Security groups for EKS → Aurora
   - Secrets Manager integration
   - IRSA for Aurora access from pods

2. **Kubernetes Integration**
   - External Secrets Operator for credential management
   - ConfigMap for connection strings
   - Database connection pooler (PgBouncer) as sidecar option
   - ServiceMonitor for database metrics

3. **Observability Integration**
   - Prometheus exporter for PostgreSQL
   - Grafana dashboard for database metrics
   - Custom metrics for connection pools, query performance
   - Alerting rules for database health

4. **Application Demo**
   - Update nginx demo or add new sample app
   - Show database connectivity from pods
   - Demonstrate connection pooling

**Key Features:**
- Database metrics in Prometheus
- Grafana dashboards for RDS/Aurora
- Connection monitoring
- Query performance insights

---

## Phase 2: Ansible Configuration Management

### Project 01: Ansible for Application Deployment

**Objective:** Demonstrate Infrastructure as Code (Terraform) + Configuration Management (Ansible) pattern.

**Implementation Plan:**

1. **Ansible Structure**
   ```
   infra/ansible/
   ├── playbooks/
   │   ├── deploy-app.yml          # Main deployment playbook
   │   ├── configure-ecs.yml       # ECS task configuration
   │   └── setup-monitoring.yml    # CloudWatch agent setup
   ├── roles/
   │   ├── app-deploy/
   │   ├── database-setup/
   │   └── monitoring/
   ├── inventory/
   │   ├── production.yml
   │   └── staging.yml
   ├── group_vars/
   │   └── all.yml
   └── ansible.cfg
   ```

2. **Use Cases**
   - Post-provisioning configuration (after Terraform)
   - Application deployment automation
   - Database initialization and migrations
   - Security hardening
   - Multi-environment management

3. **Integration Points**
   - Terraform outputs → Ansible inventory
   - Ansible Vault for secrets
   - GitHub Actions workflow integration
   - Dynamic inventory from AWS

4. **Key Playbooks**
   - `deploy-app.yml`: Deploy Flask app to ECS
   - `database-setup.yml`: Initialize database schema
   - `configure-monitoring.yml`: Set up CloudWatch agents
   - `security-hardening.yml`: Apply security configurations

---

## Implementation Timeline

### Week 1-2: Project 01 Database
- [ ] Add RDS PostgreSQL via Terraform
- [ ] Update Flask app with database models
- [ ] Implement connection pooling
- [ ] Add database migrations
- [ ] Update CI/CD pipeline
- [ ] Add monitoring and documentation

### Week 3-4: Project 02 Database
- [ ] Add Aurora PostgreSQL via Terraform
- [ ] Configure IRSA for database access
- [ ] Set up External Secrets Operator
- [ ] Create Prometheus exporters
- [ ] Build Grafana dashboards
- [ ] Update documentation

### Week 5-6: Ansible Integration
- [ ] Set up Ansible structure in Project 01
- [ ] Create playbooks for app deployment
- [ ] Create playbooks for database setup
- [ ] Integrate with GitHub Actions
- [ ] Create dynamic inventory
- [ ] Document Ansible usage

---

## Technical Decisions

### Database Choices
- **Project 01**: RDS PostgreSQL (managed, simple, cost-effective)
- **Project 02**: Aurora PostgreSQL Serverless v2 (scalable, Kubernetes-friendly)

### Ansible Approach
- **Post-Terraform**: Ansible runs after infrastructure is provisioned
- **Idempotent**: All playbooks are idempotent
- **Multi-Environment**: Support staging/production
- **Secrets Management**: Ansible Vault + AWS Secrets Manager

### Integration Strategy
- Terraform provisions infrastructure
- Ansible configures and deploys applications
- Clear separation of concerns
- Both tools work together seamlessly

---

## Success Criteria

✅ **Database Integration:**
- Applications successfully connect to databases
- Database migrations run automatically
- Monitoring and alerting in place
- Documentation complete

✅ **Ansible Integration:**
- Playbooks are idempotent and tested
- Multi-environment support
- Integration with CI/CD
- Clear documentation and examples

✅ **Portfolio Value:**
- Demonstrates full-stack understanding
- Shows multi-tool proficiency
- Real-world patterns and practices
- Production-ready examples

---

## Next Steps

1. Review and approve this plan
2. Start with Project 01 database integration
3. Iterate based on learnings
4. Apply patterns to Project 02
5. Add Ansible after databases are stable


