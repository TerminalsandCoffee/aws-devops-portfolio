Install-WindowsFeature -Name Web-Server -IncludeManagementTools

$newSitePath = "C:\inetpub\wwwroot\app2"
New-Item -Path $newSitePath -ItemType Directory -Force | Out-Null

$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>App2 - IIS</title>
  <style>
    body { font-family: Arial, sans-serif; background: #111827; color: #e5e7eb; text-align: center; padding: 60px; }
    h1 { color: #38bdf8; }
    p { font-size: 18px; }
  </style>
</head>
<body>
  <h1>Welcome to App2</h1>
  <p>Windows + IIS behind ALB path routing – Brought to you by DevOps Raf</p>
</body>
</html>
"@

Set-Content -Path "$newSitePath\index.html" -Value $html -Encoding UTF8

Start-Service W3SVC
Set-Service W3SVC -StartupType Automatic

New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -Profile Any
