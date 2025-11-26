# Quick Start: Database & Ansible Enhancements

## 📋 Overview

This guide provides a quick reference for implementing database integration and Ansible configuration management across Projects 01 and 02.

## 🗂️ Documentation Structure

```
projects/
├── PLANNING-database-ansible-enhancements.md    # Master plan
├── QUICK-START-database-ansible.md             # This file
│
├── 01-ecs-fargate-ci-cd-pipeline-webapp/
│   ├── STRUCTURE-database-integration.md        # DB structure for Project 01
│   └── STRUCTURE-ansible-integration.md         # Ansible structure
│
└── 02-eks-observability-stack/
    └── STRUCTURE-database-integration.md        # DB structure for Project 02
```

## 🚀 Implementation Order

### Phase 1: Project 01 Database (Week 1-2)
1. ✅ Review `STRUCTURE-database-integration.md`
2. Add RDS PostgreSQL via Terraform (`infra/terraform/rds.tf`)
3. Update Flask app with SQLAlchemy models
4. Add database migrations (Alembic)
5. Update CI/CD pipeline
6. Test and document

### Phase 2: Project 02 Database (Week 3-4)
1. ✅ Review `STRUCTURE-database-integration.md`
2. Add Aurora PostgreSQL via Terraform (`infra/terraform/aurora.tf`)
3. Configure IRSA for database access
4. Set up External Secrets Operator
5. Create Prometheus exporters
6. Build Grafana dashboards
7. Test and document

### Phase 3: Ansible Integration (Week 5-6)
1. ✅ Review `STRUCTURE-ansible-integration.md`
2. Create Ansible directory structure
3. Write playbooks for app deployment
4. Write playbooks for database setup
5. Integrate with GitHub Actions
6. Test and document

## 📝 Key Files to Create

### Project 01 - Database
- `infra/terraform/rds.tf` - RDS PostgreSQL instance
- `infra/terraform/secrets.tf` - Secrets Manager configuration
- `app/models.py` - SQLAlchemy models
- `app/database.py` - Database connection handling
- `app/migrations/` - Alembic migration files

### Project 02 - Database
- `infra/terraform/aurora.tf` - Aurora PostgreSQL cluster
- `infra/terraform/irsa_aurora.tf` - IRSA configuration
- `infra/k8s-manifests/external-secrets/` - External Secrets setup
- `infra/k8s-manifests/postgres-exporter/` - Prometheus exporter
- `charts/grafana/dashboards/postgres-dashboard.json` - Grafana dashboard

### Project 01 - Ansible
- `infra/ansible/ansible.cfg` - Ansible configuration
- `infra/ansible/inventory/` - Inventory files
- `infra/ansible/playbooks/` - Deployment playbooks
- `infra/ansible/roles/` - Reusable roles

## 🔧 Quick Commands

### Database Setup (Project 01)
```bash
# Terraform
cd projects/01-ecs-fargate-ci-cd-pipeline-webapp/infra/terraform
terraform init
terraform plan
terraform apply

# Run migrations
cd ../../app
alembic upgrade head
```

### Database Setup (Project 02)
```bash
# Terraform
cd projects/02-eks-observability-stack/infra/terraform
terraform init
terraform plan
terraform apply

# Deploy External Secrets
kubectl apply -f ../k8s-manifests/external-secrets/

# Deploy PostgreSQL Exporter
kubectl apply -f ../k8s-manifests/postgres-exporter/
```

### Ansible Deployment
```bash
# Install dependencies
cd projects/01-ecs-fargate-ci-cd-pipeline-webapp/infra/ansible
ansible-galaxy install -r requirements.yml

# Deploy
ansible-playbook -i inventory/production.yml playbooks/site.yml
```

## 🎯 Success Criteria

### Database Integration
- [ ] Database provisioned via Terraform
- [ ] Application connects successfully
- [ ] Migrations run automatically
- [ ] Monitoring in place
- [ ] Documentation complete

### Ansible Integration
- [ ] Playbooks are idempotent
- [ ] Multi-environment support
- [ ] CI/CD integration
- [ ] Documentation complete

## 📚 Additional Resources

- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Ansible AWS Collection**: https://docs.ansible.com/ansible/latest/collections/amazon/aws/
- **SQLAlchemy Documentation**: https://docs.sqlalchemy.org/
- **Alembic Documentation**: https://alembic.sqlalchemy.org/
- **External Secrets Operator**: https://external-secrets.io/

## 🐛 Troubleshooting

### Database Connection Issues
- Check security group rules
- Verify Secrets Manager configuration
- Test connection from application container
- Review CloudWatch logs

### Ansible Playbook Failures
- Verify AWS credentials
- Check inventory configuration
- Review Ansible logs with `-vvv`
- Ensure Terraform outputs are available

## 💡 Tips

1. **Start Small**: Begin with basic database setup, then add complexity
2. **Test Locally**: Use Docker Compose for local database testing
3. **Version Control**: Keep all infrastructure and config in Git
4. **Documentation**: Update README files as you go
5. **Iterate**: Don't try to do everything at once

## 🔄 Next Steps

1. Review the planning documents
2. Start with Project 01 database integration
3. Test thoroughly before moving to Project 02
4. Add Ansible after databases are stable
5. Update portfolio documentation

---

**Questions?** Review the detailed planning documents in each project directory.


