# PowerShell User Data Script for Windows EC2 Instance
# Installs IIS, creates App2, and configures for ALB path routing

# Set error handling
$ErrorActionPreference = "Stop"

# Log function
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

Write-Log "Starting IIS and App2 configuration..."

# 1. Install IIS with Management Tools
Write-Log "Installing IIS with management tools..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools -IncludeAllSubFeature

# 2. Create app2 subfolder under inetpub\wwwroot
Write-Log "Creating app2 directory..."
$app2Path = "C:\inetpub\wwwroot\app2"
New-Item -ItemType Directory -Path $app2Path -Force | Out-Null

# 3. Create index.html with nice styling
Write-Log "Creating index.html..."
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to App2</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 20px;
            font-weight: 700;
        }
        .subtitle {
            color: #764ba2;
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
        <div class="icon">🚀</div>
        <h1>Welcome to App2</h1>
        <p class="subtitle">Windows + IIS behind ALB path routing</p>
        <p class="tagline">Brought to you by DevOps Raf</p>
    </div>
</body>
</html>
"@

Set-Content -Path "$app2Path\index.html" -Value $htmlContent -Encoding UTF8

# 4. Set proper ACLs so IIS can read the files
Write-Log "Setting ACLs for IIS..."
$acl = Get-Acl $app2Path
$iisUser = New-Object System.Security.Principal.NTAccount("IIS_IUSRS")
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $iisUser,
    "ReadAndExecute",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)
$acl.SetAccessRule($accessRule)
Set-Acl -Path $app2Path -AclObject $acl

# Also set ACLs on the file itself
$fileAcl = Get-Acl "$app2Path\index.html"
$fileAcl.SetAccessRule($accessRule)
Set-Acl -Path "$app2Path\index.html" -AclObject $fileAcl

# 5. Create IIS Application for app2
Write-Log "Creating IIS application for app2..."
Import-Module WebAdministration
New-WebApplication -Name "app2" -Site "Default Web Site" -PhysicalPath $app2Path -Force

# 6. Install URL Rewrite Module (optional bonus)
Write-Log "Installing URL Rewrite Module..."
$urlRewriteUrl = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
$urlRewriteInstaller = "$env:TEMP\urlrewrite.msi"

try {
    Invoke-WebRequest -Uri $urlRewriteUrl -OutFile $urlRewriteInstaller -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$urlRewriteInstaller`" /quiet /norestart" -Wait
    Write-Log "URL Rewrite Module installed successfully"
} catch {
    Write-Log "Warning: Could not install URL Rewrite Module - $($_.Exception.Message)"
}

# 7. Add a simple redirect rule (bonus)
Write-Log "Configuring URL Rewrite rule..."
$webConfigPath = "$app2Path\web.config"
$webConfigContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <rewrite>
            <rules>
                <rule name="Redirect to app2" stopProcessing="true">
                    <match url="^$" />
                    <action type="Rewrite" url="/app2/" />
                </rule>
            </rules>
        </rewrite>
        <defaultDocument>
            <files>
                <clear />
                <add value="index.html" />
            </files>
        </defaultDocument>
    </system.webServer>
</configuration>
"@

Set-Content -Path $webConfigPath -Value $webConfigContent -Encoding UTF8

# 8. Ensure IIS is running
Write-Log "Starting IIS..."
Start-Service W3SVC
Set-Service -Name W3SVC -StartupType Automatic

# 9. Configure firewall to allow HTTP/HTTPS
Write-Log "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow -ErrorAction SilentlyContinue

Write-Log "Configuration complete! App2 is ready at /app2/"
Write-Log "IIS Status: $((Get-Service W3SVC).Status)"

