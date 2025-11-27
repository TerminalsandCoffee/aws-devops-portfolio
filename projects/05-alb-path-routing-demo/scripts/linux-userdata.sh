#!/bin/bash
set -xe

dnf update -y
dnf install -y nginx

mkdir -p /usr/share/nginx/html/app1
cat > /usr/share/nginx/html/app1/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>App1 - Nginx</title>
  <style>
    body { font-family: Arial, sans-serif; background: #0d1117; color: #e6edf3; text-align: center; padding: 60px; }
    h1 { color: #58a6ff; }
    p { font-size: 1.1rem; }
  </style>
</head>
<body>
  <h1>Welcome to App1</h1>
  <p>Linux + Nginx behind ALB path routing – Brought to you by DevOps Raf</p>
</body>
</html>
HTML

rm -f /etc/nginx/conf.d/default.conf
cat > /etc/nginx/conf.d/app1.conf <<'NGINX'
server {
    listen       80 default_server;
    server_name  _;
    root         /usr/share/nginx/html;

    location = / {
        return 404;
    }

    location = /app1 {
        return 301 /app1/;
    }

    location /app1/ {
        alias /usr/share/nginx/html/app1/;
        index index.html;
    }
}
NGINX

systemctl enable nginx
systemctl restart nginx
