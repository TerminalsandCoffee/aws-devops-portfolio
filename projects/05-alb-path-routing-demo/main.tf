##############################################
# ALB Path Routing Demo
# - Routes /app1/ to Amazon Linux 2023 + Nginx
# - Routes /app2/ to Windows Server 2022 + IIS
# Test URLs after apply: http://<alb_dns>/app1/ and http://<alb_dns>/app2/
##############################################

# ALB Path Routing Demo - Main Terraform Configuration

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

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Preferred availability zones (fall back to the first two available)
locals {
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
}

# Data source for Windows Server 2022 AMI
data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

# Public Subnets (for ALB and EC2 instances)
resource "aws_subnet" "public" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-subnet-${count.index + 1}"
      Type = "Public"
    }
  )
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-public-rt"
    }
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(local.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-alb-sg"
    }
  )
}

# Security Group for EC2 Instances (Linux and Windows)
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instances (allows traffic only from ALB)"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-ec2-sg"
    }
  )
}

# Read Windows user data script
locals {
  windows_user_data = file("${path.module}/windows-userdata.ps1")
}

# Linux user data script (cloud-init)
locals {
  linux_user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    
    # Create app1 directory
    mkdir -p /usr/share/nginx/html/app1
    
    # Create index.html for app1
    cat > /usr/share/nginx/html/app1/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to App1</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                color: #333;
            }
            .container {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                padding: 60px 40px;
                text-align: center;
                max-width: 600px;
                animation: fadeIn 0.8s ease-in;
            }
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            h1 {
                color: #f5576c;
                font-size: 2.5em;
                margin-bottom: 20px;
                font-weight: 700;
            }
            .subtitle {
                color: #f093fb;
                font-size: 1.3em;
                margin-bottom: 30px;
                font-weight: 300;
            }
            .tagline {
                color: #666;
                font-size: 1.1em;
                margin-top: 30px;
                padding-top: 30px;
                border-top: 2px solid #eee;
                font-style: italic;
            }
            .icon {
                font-size: 4em;
                margin-bottom: 20px;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="icon">🐧</div>
            <h1>Welcome to App1</h1>
            <p class="subtitle">Linux + Nginx behind ALB path routing</p>
            <p class="tagline">Brought to you by DevOps Raf</p>
        </div>
    </body>
    </html>
    HTML
    
    # Configure Nginx to serve app1
    cat > /etc/nginx/conf.d/app1.conf <<'NGINX'
    server {
        listen 80;
        server_name _;

        location = /app1 {
            return 301 /app1/;
        }

        location /app1/ {
            alias /usr/share/nginx/html/app1/;
            index index.html;
            try_files $uri $uri/ /app1/index.html;
        }
        
        location / {
            return 404;
        }
    }
    NGINX
    
    # Start and enable Nginx
    systemctl start nginx
    systemctl enable nginx
    
    # Set proper permissions
    chmod -R 755 /usr/share/nginx/html/app1
    chown -R nginx:nginx /usr/share/nginx/html/app1
  EOF
}

# Linux EC2 Instance (App1)
resource "aws_instance" "linux_app1" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.linux_instance_type
  subnet_id     = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null

  user_data = local.linux_user_data

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-linux-app1"
      App  = "app1"
    }
  )
}

# Windows EC2 Instances (App2) - using count for scalability
resource "aws_instance" "windows_app2" {
  count         = var.windows_instance_count
  ami           = data.aws_ami.windows_2022.id
  instance_type = var.windows_instance_type
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)]

  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name != "" ? var.key_name : null

  user_data_base64 = base64encode(local.windows_user_data)

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-windows-app2-${count.index + 1}"
      App  = "app2"
    }
  )
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-alb"
    }
  )
}

# Target Group for App1 (Linux/Nginx)
resource "aws_lb_target_group" "app1" {
  name     = "${var.project_name}-app1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/app1/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-app1-tg"
    }
  )
}

# Target Group for App2 (Windows/IIS)
resource "aws_lb_target_group" "app2" {
  name     = "${var.project_name}-app2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/app2/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-app2-tg"
    }
  )
}

# Target Group Attachments - App1
resource "aws_lb_target_group_attachment" "app1" {
  target_group_arn = aws_lb_target_group.app1.arn
  target_id        = aws_instance.linux_app1.id
  port             = 80
}

# Target Group Attachments - App2 Instances
resource "aws_lb_target_group_attachment" "app2" {
  count            = var.windows_instance_count
  target_group_arn = aws_lb_target_group.app2.arn
  target_id        = aws_instance.windows_app2[count.index].id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Default action - friendly 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = <<-HTML
        <!DOCTYPE html>
        <html>
        <head>
            <title>404 - Not Found</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    text-align: center;
                    padding: 50px;
                    background: #f5f5f5;
                }
                h1 { color: #333; }
                p { color: #666; }
            </style>
        </head>
        <body>
            <h1>404 - Page Not Found</h1>
            <p>Available paths:</p>
            <ul style="list-style: none; padding: 0;">
                <li><a href="/app1/">/app1/ - Linux + Nginx</a></li>
                <li><a href="/app2/">/app2/ - Windows + IIS</a></li>
            </ul>
        </body>
        </html>
      HTML
      status_code  = "404"
    }
  }
}

# ALB Listener Rule - App1 (Priority 100)
resource "aws_lb_listener_rule" "app1" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app1.arn
  }

  condition {
    path_pattern {
      values = ["/app1*"]
    }
  }
}

# ALB Listener Rule - App2 (Priority 200)
resource "aws_lb_listener_rule" "app2" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app2.arn
  }

  condition {
    path_pattern {
      values = ["/app2*"]
    }
  }
}
