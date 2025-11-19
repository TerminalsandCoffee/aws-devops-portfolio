param(
    [string]$File
)

if (-not $File) {
    Write-Host "Usage: .\render-diagram.ps1 <path-to-diagram.mmd>" -ForegroundColor Yellow
    exit 1
}

mmdc -i $File -o ($File -replace '.mmd','.png') -t dark -b transparent --width 2000
Write-Host "Rendered: $($File -replace '.mmd','.png')" -ForegroundColor Green
