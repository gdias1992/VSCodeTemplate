# Clear Laravel Log
Write-Host "Clearing Laravel log file..." -ForegroundColor Cyan

$logPath = "$PSScriptRoot\..\backend\storage\logs\laravel.log"

if (Test-Path $logPath) {
    # Using Set-Content with empty string to ensure file is cleared but exists
    Set-Content -Path $logPath -Value ""
    Write-Host "Laravel log cleared: $logPath" -ForegroundColor Green
} else {
    Write-Host "Log file not found: $logPath" -ForegroundColor Yellow
}
