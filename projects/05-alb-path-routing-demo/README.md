# Project 05 – ALB Path Routing Demo

This project demonstrates Application Load Balancer (ALB) path-based routing, serving two different applications behind a single load balancer:
- **App1**: Linux + Nginx (served at `/app1/*`)
- **App2**: Windows Server 2022 + IIS (served at `/app2/*`)

## Architecture

- **Application Load Balancer**: Routes traffic based on URL paths
- **Target Group 1**: Linux EC2 instance running Nginx
- **Target Group 2**: Windows EC2 instances (2x) running IIS
- **Path Routing**:
  - `/app1*` → Linux/Nginx target group
  - `/app2*` → Windows/IIS target group
  - Default → Friendly 404 page

## Key Features

- Path-based routing with ALB listener rules
- Multi-platform support (Linux and Windows)
- High availability (2 Windows instances for App2)
- Least-privilege security groups
- Automated instance configuration via user data

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured
- (Optional) EC2 Key Pair for SSH/RDP access

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   - Set `key_name` if you want SSH/RDP access
   - Adjust instance types if needed
   - Update region/availability zones

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Test the applications:**
   ```bash
   # Get ALB DNS name from outputs
   terraform output alb_dns_name

   # Test App1 (Linux/Nginx)
   curl http://$(terraform output -raw alb_dns_name)/app1/

   # Test App2 (Windows/IIS)
   curl http://$(terraform output -raw alb_dns_name)/app2/
   ```

## Outputs

After deployment, useful outputs include:
- `alb_dns_name` - ALB DNS name
- `app1_url` - Direct URL to App1
- `app2_url` - Direct URL to App2
- `test_commands` - Ready-to-use curl commands
- Instance IDs and private IPs

## Testing

Use the test commands from outputs:
```bash
terraform output test_commands
```

Or test manually:
```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
curl http://$ALB_DNS/app1/   # Should show Linux/Nginx page
curl http://$ALB_DNS/app2/   # Should show Windows/IIS page
curl http://$ALB_DNS/        # Should show 404 page
```

## Cleanup

```bash
terraform destroy
```

## Interview Talking Points

- **Path-based routing**: Demonstrates ALB's ability to route based on URL paths
- **Multi-platform**: Shows flexibility in serving different OS platforms
- **High availability**: Windows instances distributed across AZs
- **Security**: Least-privilege security groups (instances only accept traffic from ALB)
- **Automation**: User data scripts configure instances automatically
- **Cost-effective**: Uses appropriate instance sizes for demo purposes
