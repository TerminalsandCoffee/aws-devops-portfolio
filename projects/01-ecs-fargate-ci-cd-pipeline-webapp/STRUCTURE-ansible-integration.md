# Project 01: Ansible Integration Structure

## Overview
This document outlines the Ansible structure for Project 01, demonstrating the Infrastructure as Code (Terraform) + Configuration Management (Ansible) pattern.

## Directory Structure

```
infra/ansible/
│
├── ansible.cfg                    # Ansible configuration
├── requirements.yml               # Ansible role dependencies
│
├── inventory/
│   ├── production.yml            # Production inventory
│   ├── staging.yml               # Staging inventory
│   └── dynamic_inventory.py      # AWS dynamic inventory (optional)
│
├── group_vars/
│   ├── all.yml                   # Common variables
│   ├── production.yml            # Production-specific vars
│   └── staging.yml               # Staging-specific vars
│
├── host_vars/                    # Host-specific variables (if needed)
│
├── playbooks/
│   ├── deploy-app.yml            # Main application deployment
│   ├── database-setup.yml        # Database initialization
│   ├── configure-monitoring.yml  # CloudWatch setup
│   ├── security-hardening.yml    # Security configurations
│   └── site.yml                  # Master playbook
│
└── roles/
    ├── app-deploy/
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── handlers/
    │   │   └── main.yml
    │   ├── templates/
    │   │   └── app-config.j2
    │   ├── vars/
    │   │   └── main.yml
    │   └── defaults/
    │       └── main.yml
    │
    ├── database-setup/
    │   ├── tasks/
    │   │   └── main.yml
    │   ├── templates/
    │   │   └── init-schema.sql.j2
    │   └── defaults/
    │       └── main.yml
    │
    └── monitoring/
        ├── tasks/
        │   └── main.yml
        ├── templates/
        │   └── cloudwatch-config.json.j2
        └── defaults/
            └── main.yml
```

## Key Files

### 1. `ansible.cfg`
```ini
[defaults]
inventory = inventory/production.yml
host_key_checking = False
retry_files_enabled = False
roles_path = roles
collections_path = collections

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
enable_plugins = aws_ec2, yaml, ini

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

### 2. `inventory/production.yml`
```yaml
---
all:
  children:
    ecs:
      hosts:
        localhost:
          ansible_connection: local
          ansible_python_interpreter: /usr/bin/python3
    aws:
      children:
        ecs:
          vars:
            aws_region: us-east-1
            ecs_cluster_name: "{{ lookup('env', 'ECS_CLUSTER_NAME') }}"
            ecr_repo: "{{ lookup('env', 'ECR_REPO') }}"
            db_endpoint: "{{ lookup('env', 'DB_ENDPOINT') }}"
            db_secret_arn: "{{ lookup('env', 'DB_SECRET_ARN') }}"
```

### 3. `group_vars/all.yml`
```yaml
---
# Common variables for all environments
project_name: "ecs-fargate-webapp"
app_name: "flask-app"
app_port: 5000

# AWS Configuration
aws_region: "us-east-1"

# Database Configuration
db_name: "webapp_db"
db_username: "webapp_user"

# Application Configuration
app_version: "latest"
desired_count: 2
min_capacity: 1
max_capacity: 10

# Monitoring
enable_cloudwatch: true
log_retention_days: 7
```

### 4. `playbooks/site.yml` (Master Playbook)
```yaml
---
- name: Complete Application Deployment
  hosts: localhost
  gather_facts: false
  vars:
    deployment_environment: "{{ deployment_env | default('staging') }}"
  
  tasks:
    - name: Include database setup
      include: database-setup.yml
      tags:
        - database
        - setup
    
    - name: Include app deployment
      include: deploy-app.yml
      tags:
        - app
        - deploy
    
    - name: Include monitoring setup
      include: configure-monitoring.yml
      tags:
        - monitoring
        - setup
```

### 5. `playbooks/deploy-app.yml`
```yaml
---
- name: Deploy Flask Application to ECS
  hosts: localhost
  gather_facts: false
  vars:
    image_tag: "{{ app_version | default('latest') }}"
  
  tasks:
    - name: Get ECS cluster info
      ecs_cluster_info:
        cluster_name: "{{ ecs_cluster_name }}"
      register: cluster_info
    
    - name: Run database migrations
      include_role:
        name: database-setup
        tasks_from: run_migrations
      vars:
        db_secret_arn: "{{ db_secret_arn }}"
        migration_image: "{{ ecr_repo }}/{{ app_name }}:{{ image_tag }}"
      tags:
        - migrations
    
    - name: Deploy application
      include_role:
        name: app-deploy
      vars:
        image_tag: "{{ image_tag }}"
        desired_count: "{{ desired_count }}"
      tags:
        - deploy
    
    - name: Wait for service to stabilize
      ecs_service_info:
        cluster: "{{ ecs_cluster_name }}"
        service: "{{ app_name }}"
      register: service_status
      until: >
        service_status.services[0].runningCount == service_status.services[0].desiredCount
      retries: 30
      delay: 10
      tags:
        - deploy
        - verify
```

### 6. `playbooks/database-setup.yml`
```yaml
---
- name: Initialize Database Schema
  hosts: localhost
  gather_facts: false
  
  tasks:
    - name: Get database credentials from Secrets Manager
      aws_secret:
        name: "{{ db_secret_arn }}"
        region: "{{ aws_region }}"
      register: db_secret
      no_log: true
    
    - name: Create database schema
      include_role:
        name: database-setup
      vars:
        db_host: "{{ db_endpoint }}"
        db_name: "{{ db_name }}"
        db_user: "{{ db_secret.secret.username }}"
        db_password: "{{ db_secret.secret.password }}"
      tags:
        - database
        - schema
```

### 7. `roles/app-deploy/tasks/main.yml`
```yaml
---
- name: Update ECS task definition
  ecs_taskdefinition:
    family: "{{ app_name }}"
    container_definitions:
      - name: "{{ app_name }}"
        image: "{{ ecr_repo }}/{{ app_name }}:{{ image_tag }}"
        memory: 512
        cpu: 256
        essential: true
        portMappings:
          - containerPort: "{{ app_port }}"
            protocol: tcp
        environment:
          - name: DATABASE_URL
            value: "{{ db_connection_string }}"
          - name: APP_ENV
            value: "{{ deployment_environment }}"
        logConfiguration:
          logDriver: awslogs
          options:
            awslogs-group: "/ecs/{{ app_name }}"
            awslogs-region: "{{ aws_region }}"
            awslogs-stream-prefix: "ecs"
    register: task_def
    
- name: Update ECS service
  ecs_service:
    name: "{{ app_name }}"
    cluster: "{{ ecs_cluster_name }}"
    task_definition: "{{ task_def.task_definition.Arn }}"
    desired_count: "{{ desired_count }}"
    force_new_deployment: true
    state: present
  register: service_result
  
- name: Display service URL
  debug:
    msg: "Service updated: {{ service_result.service.serviceName }}"
```

### 8. `roles/database-setup/tasks/main.yml`
```yaml
---
- name: Check if migrations need to run
  command: >
    docker run --rm
    -e DATABASE_URL="{{ db_connection_string }}"
    {{ migration_image }}
    alembic current
  register: current_revision
  changed_when: false
  failed_when: false
  
- name: Run database migrations
  command: >
    docker run --rm
    -e DATABASE_URL="{{ db_connection_string }}"
    {{ migration_image }}
    alembic upgrade head
  register: migration_result
  when: migration_result.rc != 0 or current_revision.stdout == ""
  changed_when: "'upgrade' in migration_result.stdout"
  
- name: Display migration status
  debug:
    msg: "Database migrations completed successfully"
  when: migration_result is succeeded
```

### 9. `roles/monitoring/tasks/main.yml`
```yaml
---
- name: Create CloudWatch log group
  cloudwatch_log_group:
    name: "/ecs/{{ app_name }}"
    state: present
    retention: "{{ log_retention_days }}"
    region: "{{ aws_region }}"
  
- name: Create CloudWatch dashboard
  cloudwatch_dashboard:
    name: "{{ app_name }}-dashboard"
    dashboard_body: "{{ lookup('template', 'cloudwatch-dashboard.json.j2') | from_json }}"
    region: "{{ aws_region }}"
```

### 10. `requirements.yml` (Ansible Collections)
```yaml
---
collections:
  - name: amazon.aws
    version: ">= 5.0.0"
  - name: community.aws
    version: ">= 5.0.0"
  - name: kubernetes.core
    version: ">= 2.4.0"

roles:
  # Add external roles if needed
  # - name: geerlingguy.docker
  #   version: ">= 5.0.0"
```

## Usage Examples

### Deploy Application
```bash
# Install Ansible collections
ansible-galaxy install -r requirements.yml

# Deploy to staging
ansible-playbook -i inventory/staging.yml playbooks/site.yml

# Deploy to production
ansible-playbook -i inventory/production.yml playbooks/site.yml

# Deploy only application (skip database/monitoring)
ansible-playbook -i inventory/production.yml playbooks/deploy-app.yml --tags deploy

# Run only database migrations
ansible-playbook -i inventory/production.yml playbooks/database-setup.yml
```

### With Terraform Outputs
```bash
# Get Terraform outputs and set as environment variables
export ECS_CLUSTER_NAME=$(terraform -chdir=infra/terraform output -raw ecs_cluster_name)
export ECR_REPO=$(terraform -chdir=infra/terraform output -raw ecr_repository_url)
export DB_ENDPOINT=$(terraform -chdir=infra/terraform output -raw db_endpoint)
export DB_SECRET_ARN=$(terraform -chdir=infra/terraform output -raw db_secret_arn)

# Run Ansible
ansible-playbook -i inventory/production.yml playbooks/site.yml
```

### CI/CD Integration
```yaml
# .github/workflows/deploy.yml
- name: Deploy with Ansible
  run: |
    ansible-galaxy install -r infra/ansible/requirements.yml
    ansible-playbook \
      -i infra/ansible/inventory/production.yml \
      infra/ansible/playbooks/deploy-app.yml \
      -e image_tag=${{ github.sha }}
```

## Best Practices

1. **Idempotency**: All playbooks are idempotent - safe to run multiple times
2. **Secrets Management**: Use Ansible Vault or AWS Secrets Manager
3. **Environment Separation**: Clear separation between staging/production
4. **Tagging**: Use tags to run specific parts of playbooks
5. **Error Handling**: Proper error handling and rollback strategies
6. **Documentation**: Clear documentation for each playbook and role

## Integration with Terraform

1. **Terraform provisions infrastructure** (VPC, ECS, RDS, etc.)
2. **Terraform outputs** are used as Ansible variables
3. **Ansible configures and deploys** applications
4. **Clear separation** of infrastructure vs. configuration

## Security Considerations

- Use Ansible Vault for sensitive data
- Leverage AWS Secrets Manager for credentials
- Implement least-privilege IAM roles
- Encrypt secrets at rest and in transit
- Use secure communication channels (SSH/TLS)


