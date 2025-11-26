# Project 01: Database Integration Structure

## Proposed Directory Structure

```
01-ecs-fargate-ci-cd-pipeline-webapp/
│
├── app/
│   ├── app.py                    # Updated with database models
│   ├── models.py                  # SQLAlchemy models (NEW)
│   ├── database.py                # Database connection & session (NEW)
│   ├── migrations/                # Alembic migrations (NEW)
│   │   ├── versions/
│   │   └── env.py
│   ├── requirements.txt           # Updated with psycopg2, SQLAlchemy, Alembic
│   ├── Dockerfile
│   ├── templates/
│   └── tests/
│       ├── test_app.py
│       └── test_database.py       # NEW
│
├── infra/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── rds.tf                 # NEW - RDS PostgreSQL
│   │   ├── secrets.tf              # NEW - Secrets Manager
│   │   ├── outputs.tf              # Updated with DB endpoints
│   │   ├── variables.tf            # Updated with DB variables
│   │   └── ...
│   │
│   └── ansible/                   # NEW - Ansible configuration
│       ├── playbooks/
│       │   ├── deploy-app.yml
│       │   ├── database-setup.yml
│       │   └── configure-monitoring.yml
│       ├── roles/
│       │   ├── app-deploy/
│       │   │   ├── tasks/main.yml
│       │   │   ├── handlers/main.yml
│       │   │   └── templates/
│       │   ├── database-setup/
│       │   │   └── tasks/main.yml
│       │   └── monitoring/
│       │       └── tasks/main.yml
│       ├── inventory/
│       │   ├── production.yml
│       │   └── staging.yml
│       ├── group_vars/
│       │   └── all.yml
│       ├── ansible.cfg
│       └── requirements.yml       # Ansible role dependencies
│
├── docs/
│   ├── architecture.png            # Updated with database
│   ├── database-design.md          # NEW
│   └── ansible-usage.md            # NEW
│
└── README.md                       # Updated with database info
```

## Key Files to Create/Update

### 1. Terraform: `infra/terraform/rds.tf`
```hcl
# RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier             = "${var.project_name}-postgres"
  engine                 = "postgres"
  engine_version         = "15.4"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp3"
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  skip_final_snapshot = var.environment != "production"
  deletion_protection  = var.environment == "production"
  
  tags = var.common_tags
}
```

### 2. Application: `app/models.py`
```python
from sqlalchemy import Column, Integer, String, DateTime, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    username = Column(String(80), unique=True, nullable=False)
    email = Column(String(120), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'created_at': self.created_at.isoformat()
        }
```

### 3. Application: `app/database.py`
```python
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from contextlib import contextmanager
import boto3
import json

def get_db_connection_string():
    """Get database connection string from Secrets Manager or env vars"""
    if os.getenv('DB_SECRET_ARN'):
        secrets_client = boto3.client('secretsmanager')
        secret = secrets_client.get_secret_value(SecretId=os.getenv('DB_SECRET_ARN'))
        secret_dict = json.loads(secret['SecretString'])
        return f"postgresql://{secret_dict['username']}:{secret_dict['password']}@{secret_dict['host']}:{secret_dict['port']}/{secret_dict['dbname']}"
    else:
        # Fallback to environment variables
        return os.getenv('DATABASE_URL')

engine = create_engine(
    get_db_connection_string(),
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True  # Verify connections before using
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@contextmanager
def get_db():
    """Database session context manager"""
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
```

### 4. Ansible: `infra/ansible/playbooks/deploy-app.yml`
```yaml
---
- name: Deploy Flask Application to ECS
  hosts: localhost
  gather_facts: false
  vars:
    app_name: "ecs-fargate-webapp"
    image_tag: "{{ lookup('env', 'IMAGE_TAG') | default('latest') }}"
  
  tasks:
    - name: Run database migrations
      command: >
        docker run --rm
        -e DATABASE_URL="{{ db_connection_string }}"
        {{ ecr_repo }}/{{ app_name }}:{{ image_tag }}
        alembic upgrade head
      register: migration_result
      
    - name: Update ECS service
      ecs_service:
        name: "{{ app_name }}"
        cluster: "{{ ecs_cluster_name }}"
        task_definition: "{{ task_definition_arn }}"
        desired_count: "{{ desired_count | default(2) }}"
        state: present
      register: ecs_service_result
      
    - name: Wait for service to stabilize
      ecs_service:
        name: "{{ app_name }}"
        cluster: "{{ ecs_cluster_name }}"
      register: service_status
      until: service_status.service.runningCount == service_status.service.desiredCount
      retries: 30
      delay: 10
```

---

## Database Schema

### Initial Migration
```python
# migrations/versions/001_initial_schema.py
"""Initial schema

Revision ID: 001_initial
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('username', sa.String(80), nullable=False),
        sa.Column('email', sa.String(120), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('username'),
        sa.UniqueConstraint('email')
    )

def downgrade():
    op.drop_table('users')
```

---

## Integration Points

1. **Terraform → Ansible**: Terraform outputs database endpoint to Ansible inventory
2. **Secrets Manager**: Database credentials stored securely
3. **ECS Task Definition**: Environment variables for database connection
4. **CI/CD**: Migration step before deployment
5. **Monitoring**: CloudWatch metrics for RDS and application database connections



